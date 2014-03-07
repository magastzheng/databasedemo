IF EXISTS (SELECT name FROM sysobjects WHERE name = 'UDF_SQLDateTimeToXmlDate' AND type = 'FN')
	DROP Function dbo.UDF_SQLDateTimeToXmlDate
GO

CREATE  FUNCTION dbo.UDF_SQLDateTimeToXmlDate (@DateTime DATETIME)
RETURNS VARCHAR(10)
AS
begin

declare @Return varchar(10)

/*
Replace datetime with a string containing only the date portion
Eg: replace "1975-01-31T00:00:00" with "1975-01-31"
This is done in 2 steps.
1) dbo.enumDate_ISO8601() function returns 126 which
    when used in the convert function returns a datetime string of the format yyyy-mm-dd Thh:mm:ss:mmm
2) Then the substring functions gets the 1st 10 characters i.e. the date part of the string
*/
select @Return = convert(varchar(25), @DateTime, 126)
select @Return = substring(@Return, 1, 10)

Return(@Return)

end


GO



