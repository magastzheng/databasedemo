@echo off
setlocal

set dbserver=(local)
if "%1"=="" goto skipdbserver
set dbserver=%1

:skipdbserver
osql -S (local) -d master -i "createDB.sql" -E -n

cscript setupdb.wsf /dbserver:%dbserver% /dbusername:MROwner /dbpassword:Y463vrz75F /dbappuserid:MRAppUser

rem load any domain data here


endlocal
pause
