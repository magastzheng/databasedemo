@echo off

echo DATABASE IS ABOUT TO BE DELETED!!!!
pause

setlocal

set dbserver=(local)
if "%1"=="" goto skipdbserver
set dbserver=%1

:skipdbserver

echo Dropping MR Database...
osql -S %dbserver% -d master -i "dropDB.sql" -E -n

endlocal

call setupDB.cmd %1


