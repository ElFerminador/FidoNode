@echo off
for %%I in ("%~dp0\..") do set "base=%%~fI"

Set LogDir=%base%\log
cd /d %LogDir%

net stop binkd
del binkd.old
ren binkd.log binkd.old
net start binkd

pause