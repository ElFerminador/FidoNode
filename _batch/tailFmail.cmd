@echo off
for %%I in ("%~dp0\..") do set "base=%%~fI"

TITLE "FMail Log"
powershell -command "& { gc %base%\log\fmail.log -wait -tail 50 }"

