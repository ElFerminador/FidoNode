@echo off
for %%I in ("%~dp0\..") do set "base=%%~fI"

set unk_mail="%base%\transfer\in.unknown\*.pkt"
IF EXIST "%unk_mail%" GOTO MoveUnknown
GOTO ProcessMail

:MoveUnknown
set in="%base%\transfer\in"
move %unk_mail% "%in%"
GOTO ProcessMail

:ProcessMail
%base%\FMail\fmailw32.exe toss /B
%base%\FMail\fmailw32.exe import
%base%\FMail\ftoolsw32.exe AddNew /A
%base%\FMail\fmailw32.exe toss /B
