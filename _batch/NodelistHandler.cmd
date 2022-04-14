@echo off
for %%I in ("%~dp0\..") do set "base=%%~fI"

Set SourceDir=%base%\transfer\in
Set DestDir=%base%\nodelist
Set RestartService=No

:start
if exist %Sourcedir%\nodelist.* goto Nodelist
if exist %Sourcedir%\z2daily.*  goto Z2Daily
goto RestartService

:Nodelist
cd /d %DestDir%
del nodelist.bak
ren nodelist.* nodelist.bak
move /y %Sourcedir%\nodelist.* %DestDir%
Set RestartService=Yes
goto start

:Z2Daily
cd /d %DestDir%
del z2daily.bak
ren z2daily.* z2daily.bak
move /y %Sourcedir%\z2daily.* %DestDir%
Set RestartService=Yes
goto RestartService

:RestartService
If "%RestartService%"=="No" goto end
net stop binkd
net start binkd
goto end

:end