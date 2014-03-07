@Echo off
setlocal

set dbserver=(local)
if "%1"=="" goto skipdbserver
set dbserver=%1

:skipdbserver

echo About to drop the MR Database...
Pause
rem iisreset
osql -S %dbserver% -d master -i "dropDB.sql" -E -n

endlocal
pause
