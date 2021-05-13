@echo off
for %%I in ("%~dp0\..") do set "base=%%~fI"

TITLE "FMail"
%base%\FMail\fmailw32.exe pack * /C
%base%\FMail\fmailw32.exe scan



