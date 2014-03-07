-- create the database and add admin user and regular user

CREATE DATABASE [MR]  
	COLLATE SQL_Latin1_General_CP1_CI_AS
GO

--LOCAL ONLY - Creates MROwner if Login does not exist and adds MROwner as sysadmin
-- this user manages the database schema
use master
DECLARE @MROwner INT
SET @MROwner = (SELECT count(*) FROM master.sys.syslogins WHERE Name = 'MROwner')

IF(@MROwner <> 1)
BEGIN
	--Create MROwner SQL Server Login
	CREATE LOGIN MROwner WITH PASSWORD = 'Y463vrz75F', CHECK_POLICY = OFF;

	--Set MROwner as sysadmin
	exec sp_addsrvrolemember 'MROwner', 'sysadmin'
END
go

--LOCAL ONLY - Creates MRAppUser if Login does not exist
-- this user is the normal database user with no admin privilege
use master 
DECLARE @MRAppUser INT
SET @MRAppUser = (SELECT count(*) FROM master.sys.syslogins WHERE Name = 'MRAppUser')

IF(@MRAppUser <> 1)
BEGIN
	--Create MRAppUser SQL Server Login
	CREATE LOGIN MRAppUser WITH PASSWORD = 'jQude714zk', CHECK_POLICY = OFF;
END

go 

use [MR]
exec sp_grantdbaccess 'MROwner'
exec sp_addrolemember 'db_owner', 'MROwner'
exec sp_grantdbaccess 'MRAppUser'
go
