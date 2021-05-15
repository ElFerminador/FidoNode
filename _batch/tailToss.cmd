@echo off
for %%I in ("%~dp0\..") do set "base=%%~fI"

TITLE "Toss Log"
powershell -command "& { gc %base%\log\toss.log -wait -tail 50 }"

