@echo off
setlocal

set dbserver=(local)
if "%1"=="" goto skipdbserver
set dbserver=%1

:skipdbserver

cscript setupdb.wsf /dbserver:%dbserver% /dbusername:MROwner /dbpassword:Y463vrz75F /dbappuserid:MRAppUser

endlocal
