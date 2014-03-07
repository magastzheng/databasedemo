function GetParameter(paramName, defaultValue)
    GetParameter = defaultValue
    dim tmp
    tmp = trim(WScript.arguments.named(paramName))
    if tmp <> "" then
        GetParameter = tmp
    end if
end function

Sub GetDOM(ByRef dom)
    set dom = createobject("MSXML2.DomDocument.4.0")
    dom.async = false
end Sub

Function GetXMLNodeText(objParentNode, XPathName)
	dim objNode
	set objNode = objParentNode.selectsinglenode(XPathName)
	if not objNode Is Nothing then
		GetXMLNodeText = objNode.text
	else
		GetXMLNodeText=""
	end if	
End Function

Sub RaiseXMLError(xmldom)
	dim lngErrorNumber
	dim strErrMsg	

	lngErrNumber=512+ xmldom.parseError.ErrorCode
	strErrMsg="XML Error Message: " & xmldom.parseerror.reason & " Line: " & xmldom.parseerror.line & " Linepos: " & xmldom.parseerror.linepos

	Err.Raise lngErrNumber, "WSH", strErrMsg 
End Sub	

Sub RaiseUserDefinedError(ErrorNumber, ErrMsg)
	dim lngErrorNumber
	dim strErrMsg	

	lngErrNumber=vbObjectError + lngErrorNumber
	strErrMsg="Error Message: " & ErrMsg
	
	Err.Raise lngErrNumber, "WSH", strErrMsg 
End Sub	

Function GetPath(strPath)
	GetPath=Left(strPath, InStrRev(strPath, "\"))
end Function				

sub GetConnection(ByVal ServerName, ByVal DatabaseName, ByVal UserName, ByVal Password, ByRef conn)
    on error resume next
    dim connStr
    if trim(ServerName) = "" then
        ServerName = "(local)"
    end if
    
	' sql native client
    'connStr = "Provider=SQLNCLI11;Server=" + ServerName + ";Database=" + DatabaseName + ";"
    'if trim(UserName) = "" then
    '    connStr = connStr + "Trusted_Connection=yes;"
    'else
    '   connStr = connStr + "Uid=" + UserName + ";Pwd=" + Password + ";"
    'end if    
	
	' OLE DB provider
	connStr = "Provider=SQLOLEDB;Data Source=" + ServerName + ";Connect Timeout=10;Initial Catalog=" + DatabaseName + ";"
    if trim(UserName) = "" then
        connStr = connStr + "Integrated Security=SSPI;"
    else
        connStr = connStr + "user id=" + UserName + ";password=" + Password + ";"
    end if 
	    
    set conn = CreateObject("ADODB.Connection")
    if err.number <> 0 then
        wscript.echo "Error creating ADO connection: " + err.description
    end if
    
    conn.Open(connStr)
    if ReportErrors(conn) then
        set conn = nothing
    end if
    on error goto 0
end sub

function ReportErrors(byref conn)
    ReportErrors = false
    if conn.Errors.Count > 0 then
        ReportErrors = true
        dim errLoop
        For Each errLoop In conn.Errors
             wscript.echo "Error #" & errLoop.Number & "   " & errLoop.Description & vbcrlf
        next
    end if
end function

sub ExecSqlScript(byref conn, byval filename)
    call ExecSqlScriptStatements(conn, filename, -1)
end sub

sub ExecSQLScriptStatements(byref conn, byval filename, byval statementCount)
    on error resume next
    Const ForReading = 1
    dim fso, infile, sql, line, msg, count
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set infile = fso.OpenTextFile(filename, ForReading)
    if err.number <> 0 then
        dim n
        n = err.number
        msg = "Unable to open file: " + filename + "  " + err.description
        on error goto 0
        err.raise n, "ExecSQLScript", msg
    end if
    
    on error goto 0
    while not infile.AtEndOfStream and (statementCount = -1 or count < statementCount)
        line = infile.ReadLine
        
        if trim(ucase(line)) = "GO" then
            call ExecSQL(conn, sql)
            sql = ""
            count = count + 1
        else
            sql = sql + line + vbcrlf
        end if
    wend
    call infile.Close()
    set fso = nothing
    
    if trim(sql) <> "" then
        call ExecSQL(conn, sql)     ' get trailers without GO
    end if
end sub

sub ExecSQL(byref conn, byval sql)
    on error resume next
    Const adCmdText = 1
    dim errors, errloop, firstErr, errMsg, cmd
    firstErr = 0
    'conn.Execute sql, , adCmdText
	
	set cmd = createobject("ADODB.Command")
	set cmd.ActiveConnection = conn
	cmd.CommandText = sql
	cmd.CommandTimeout = 0	' indefinite	
	cmd.Execute
	
    if conn.Errors.Count > 0 then
        For Each errLoop In conn.Errors
            if errLoop.Number <> 0 then
                wscript.echo "---" + vbcrlf + sql
                dim msg
                msg = "Error #" & errLoop.Number & "   " & errLoop.Description & vbcrlf
                wscript.echo msg
                if firstErr = 0 then
                    firstErr = errLoop.Number
                    errMsg = msg
                end if
            end if
        next
    end if
	set cmd = nothing

    if firstErr <> 0 then
        on error goto 0
        err.raise firstErr, "ExecSQL", errMsg
    end if
end sub

sub ExecScriptsFromFile(byref conn, byval filename)
    Const ForReading = 1
    dim fso, infile, line
    Set fso = CreateObject("Scripting.FileSystemObject")
    on error resume next
    Set infile = fso.OpenTextFile(filename, ForReading)
    if err.number <> 0 then
        dim n, msg
        n = err.number
        msg = "Unable to open file: " + filename + "  " + err.description
        on error goto 0
        err.raise n, "ExecScriptsFromFile", msg
    end if
    
    on error goto 0
    while not infile.AtEndOfStream
        line = trim(infile.ReadLine)
        if len(line) > 0 then
            if left(line, 1) <> "#" then    ' skip comments
                ExecSQLScript conn, line
            end if
        end if
    wend
    
    call infile.Close()        
    set infile = nothing
    set fso = nothing
end sub

sub ExecDBAccess(byref conn, byval appuserid)
	'Creates the specified appuserid in the database in the case it does not exist or map to the logged in user
	dim GrantDbAccess
	GrantDbAccess = "if not exists (select * from dbo.sysusers where [name] = '" & appuserid & "') begin create user " & appuserid & " end"
	
	ExecSQL conn, GrantDbAccess
end sub

sub ExecGrants(byref conn, byval filename, byval appuserid)
    Const ForReading = 1
    dim fso, infile, line, count, i, lines(5000)
    count = 0
    Set fso = CreateObject("Scripting.FileSystemObject")
    on error resume next
    Set infile = fso.OpenTextFile(filename, ForReading)
    if err.number <> 0 then
        dim n, msg
        n = err.number
        msg = "Unable to open file: " + filename + "  " + err.description
        on error goto 0
        err.raise n, "ExecGrants", msg
    end if
    
    on error goto 0
    while not infile.AtEndOfStream
        line = trim(infile.ReadLine)
        if len(line) > 0 then
            if left(line, 1) <> "#" then    ' skip comments
            	' replace the userid parameter with the userid specified
            	line = Replace(line, "%appuserid%", appuserid)
                ExecSQL conn, line
            end if
        end if
    wend
    call infile.Close()    
        
    set infile = nothing
    set fso = nothing
end sub

sub ExecProcGrants(byref conn, byval filename, byval appuserid)
	Const ForReading = 1
    dim fso, infile, line, i, re, matches, grant
    count = 0
    Set fso = CreateObject("Scripting.FileSystemObject")
    on error resume next
    Set infile = fso.OpenTextFile(filename, ForReading)
    if err.number <> 0 then
        dim n, msg
        n = err.number
        msg = "Unable to open file: " + filename + "  " + err.description
        on error goto 0
        err.raise n, "ExecProcGrants", msg
    end if
    
	set re = new regexp
	re.Pattern = "/(.*)\."	' get the value after the forward slash and before the "."
	re.Global = false
	re.IgnoreCase = true	
	
    on error goto 0
    while not infile.AtEndOfStream
        line = trim(infile.ReadLine)
        if len(line) > 0 then
            if left(line, 1) <> "#" then    ' skip comments
				set matches = re.Execute(line)
				grant = "grant execute on " & matches(0).SubMatches(0) & " to " & appuserid
				ExecSQL conn, grant
            end if
        end if
    wend
    call infile.Close()
        
    set infile = nothing
    set fso = nothing
end sub

sub ExecDrops(byref conn, byval filename)
    Const ForReading = 1
    dim fso, infile, line, count, i, lines(5000)
    count = 0
    Set fso = CreateObject("Scripting.FileSystemObject")
    on error resume next
    Set infile = fso.OpenTextFile(filename, ForReading)
    if err.number <> 0 then
        dim n, msg
        n = err.number
        msg = "Unable to open file: " + filename + "  " + err.description
        on error goto 0
        err.raise n, "ExecScriptsFromFile", msg
    end if
    
    on error goto 0
    while not infile.AtEndOfStream
        line = trim(infile.ReadLine)
        if len(line) > 0 then
            if left(line, 1) <> "#" then    ' skip comments
                lines(count) = line
                count = count + 1
            end if
        end if
    wend
    call infile.Close()     
    
    for i = count - 1 to 0 step -1
        ExecSQLScriptStatements conn, lines(i), 1
    next
    
    set infile = nothing
    set fso = nothing
end sub

' return true if database created
function CreateDatabase(dbname)
    dim conn
    CreateDatabase = false
    if not DatabaseExists2(pDBServer, dbname, pDBUserName, pDBPassword) then
        wscript.echo "Creating " & dbname & " Database..."
        call GetConnection(pDBServer, "master", pDBUserName, pDBPassword, conn)
        if conn is nothing then
            wscript.echo "Unable to connect to master database."
            wscript.quit
        else
            if isAdmin(conn) then
                ExecSQL conn, "create database [" & dbname & "]"
                CreateDatabase = true 
            else
                wscript.echo "User must be member of database sysadmin role to create a database."
                wscript.quit
            end if
            conn.Close()
        end if
    end if
    set conn = nothing
end function
    
' return database version, or create function and return version 1
Function GetDatabaseVersion(conn)
    on error resume next
    GetDatabaseVersion = 1
    dim rs, fields, item
    set rs = conn.Execute("select dbo.fnGetDatabaseVersion()")
    if err.number = -2147217865 then  ' not found
        err.clear
        call SetDatabaseVersion(conn, 1)
        set rs = conn.Execute("select dbo.fnGetDatabaseVersion()")
    end if
    
    set fields = rs.Fields
    set item = fields.Item(0)
    GetDatabaseVersion = item.Value
    
    set item = nothing
    set fields = nothing
    set rs = nothing
    on error goto 0
end function

Sub SetDatabaseVersion(conn, version)
    on error resume next
    conn.Execute("drop function dbo.fnGetDatabaseVersion")
    err.clear
    conn.Execute("create function dbo.fnGetDatabaseVersion() returns int as begin return " + cstr(version) + " end")
    call ReportErrors(conn)
    on error goto 0
end sub

function TableExists(byref conn, byval table)
    on error resume next
    const EOF = 3021
    TableExists = false
    dim rs, fields, item, value
    set rs = conn.Execute("select * from sysobjects where name='" & table & "' and xtype='U'")
    if conn.Errors.Count = 0 then
        set fields = rs.Fields
        set item = fields.Item(0)
        value = item.Value
        if err.number <> EOF then
            TableExists = true
        end if
    end if
    set rs = nothing
    set fields = nothing
    set item = nothing
end function

function ColumnExists(byref conn, byval table, byval column)
    on error resume next
    const EOF = 3021
    ColumnExists = false
    dim rs, fields, item, value
    set rs = conn.Execute("SELECT * FROM SYSCOLUMNS WHERE ID = OBJECT_ID('" & table & "') AND Name = '" & column & "'")
    if conn.Errors.Count = 0 then
        set fields = rs.Fields
        set item = fields.Item(0)
        value = item.Value
        if err.number <> EOF then
            ColumnExists = true
        end if
    end if
    set rs = nothing
    set fields = nothing
    set item = nothing
end function

function DatabaseExists2(DBServer, DatabaseName, UserName, Password)
    const EOF = 3021
    DatabaseExists2 = false
    dim conn
    call GetConnection(DBServer, "master", UserName, Password, conn)
    if not conn is nothing then
        on error resume next
        dim rs, fields, item, value
        set rs = conn.Execute("select name from sysdatabases where name = '" & DatabaseName & "'")
        if conn.Errors.Count = 0 then
            set fields = rs.Fields
            set item = fields.Item(0)
            value = item.Value
            if err.number <> EOF then
                DatabaseExists2 = true
            end if
            set fields = nothing
            set item = nothing
        end if
        set rs = nothing
        on error goto 0
        call conn.Close()
        set conn = nothing
    end if
end function

function validateDatabaseAccess(byval connStr)
    validateDatabaseAccess = validateSecurity(connStr)
    
    if not validateDatabaseAccess then
        wscript.echo "Unable to access database due to configuration error." + vbcrlf
        wscript.quit
    end if
end function 

function validateSecurity(byval connStr)
    on error resume next
    dim obj
    call CreateObjectVerify("IbbDB_Config.SecurityChecker", obj)
    if err.number <> 0 then
        wscript.echo err.description
        validateSecurity = false
        exit function
    end if

    validateSecurity = obj.HasAccess(connStr)
    if err.number <> 0 then
        wscript.echo err.description
    end if
    
    set obj = nothing
end function

function validateConnection(byval connStr)
    on error resume next
    dim conn, dbhelper
    
    validateConnection = true
    set conn = CreateObject("ADODB.Connection")
    if err.number <> 0 then
        wscript.echo "Unable to establish ADO database connection."
        validateConnection = false
    else
        if trim(connStr) = "" then
            set dbhelper = CreateObject("Ibb_DB.DBHelper")
            if dbhelper is nothing then
                wscript.echo "Unable to instantiate DBHelper.  Check component configuration."
                validateConnection = false
                exit function
            end if
            connStr = dbhelper.GetConnectionString()
        end if
        conn.Open(connStr)
        if ReportErrors(conn) then
            wscript.echo "Unable to connect to database using connection string: " + vbcrlf + connStr
            validateConnection = false
        else
            call conn.Close()
        end if
    end if
    
    set conn = nothing
    set dbhelper = nothing
end function

' returns true on success
' objectName is progid ex. "IbbDB_Config.Something"
' obj is instance to return
function CreateObjectVerify(byval objectName, byref obj)
    CreateObjectVerify = CreateObjectLocation(objectName, "", obj)
    
    if err.number <> 0 then
        wscript.echo err.description
        wscript.quit
    end if
end function

' returns true on success
function CreateObjectLocation(byval objectName, byval location, byref obj)
    on error resume next
    CreateObjectLocation = false
    
    if trim(location) = "" then
        set obj = CreateObject(objectName)
    else
        set obj = CreateObject(objectName, location)
    end if
    
    if err.number <> 0 then
        if err.number = 70 then    ' security error
            err.raise 50000, "CreateObjectLocation", "Error creating object: " & objectName & vbcrlf & _
                                    "Please check application security settings. " & vbcrlf & "Description: " & err.description
        else
            err.raise 50000, "CreateObjectLocation", "Error creating object: " & objectName & vbcrlf & "Description: " & err.description
        end if
        exit function
    end if
    
    CreateObjectLocation = true
end function

sub DropDefaultConstraint(byref conn, byval tableName, byval columnName)
    dim name
    name = GetDefaultConstraintName(conn, tableName, columnName)
    if name <> "" then
        'wscript.echo "Dropping default constraint for: " & tableName & "." & columnName
        ExecSQL conn, "alter table [" & tableName & "] drop constraint " & name
    end if
end sub

Function GetDefaultConstraintName(byref conn, byval tableName, byval columnName)
    GetDefaultConstraintName = ""
    dim rs, fields, item, sql
    sql = "select o2.name from sysobjects o1, syscolumns c1, sysconstraints c2, sysobjects o2 where o1.name='" & tableName & "' and c1.name='" & columnName & "' and o1.id=c1.id and o1.id=c2.id and c2.status & 0xf = 5 and c1.colid = c2.colid and c2.constid=o2.id"
    set rs = conn.Execute(sql)
    if not rs.EOF then
        set fields = rs.Fields
        set item = fields.Item(0)
        GetDefaultConstraintName = item.Value
    end if
    
    set item = nothing
    set fields = nothing
    set rs = nothing
end function

' replace with this when ddl creates with dbo prefix
' if is_member('db_owner') = 1 or is_member('ddl_admin') = 1 or IS_SRVROLEMEMBER('sysadmin') = 1 select 1 else select 0 

' return true if current database user is member of server sysadmin role
function isAdmin(byref conn)
    isAdmin = false
    dim rs, fields, item
    'set rs = conn.Execute("select IS_SRVROLEMEMBER('sysadmin')")
    set rs = conn.Execute("if is_member('db_owner') = 1 or is_member('ddl_admin') = 1 or IS_SRVROLEMEMBER('sysadmin') = 1 select 1 else select 0")
    if not rs.EOF then
        set fields = rs.Fields
        set item = fields.Item(0)
        if item.Value = 1 then
            isAdmin = true
        end if
    end if
    set item = nothing
    set fields = nothing
    set rs = nothing
end function

' return true if current database user is member of database owner role
function isOwner(byref conn)
    isOwner = false
    dim rs, fields, item
    set rs = conn.Execute("select IS_MEMBER('db_owner')")
    if not rs.EOF then
        set fields = rs.Fields
        set item = fields.Item(0)
        if item.Value = 1 then
            isOwner = true
        end if
    end if
    set item = nothing
    set fields = nothing
    set rs = nothing
end function

