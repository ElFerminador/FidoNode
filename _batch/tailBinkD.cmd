@echo off
for %%I in ("%~dp0\..") do set "base=%%~fI"

TITLE "BinkD Log"
powershell -command "& { gc %base%\log\binkd.log -wait -tail 50 }"

