@echo off
for %%I in ("%~dp0\..") do set "base=%%~fI"

Set SourceDir="%base%\transfer\in"
Set DestDir1="%base%\nodelist"

move /y "%Sourcedir%\nodelist.*" %DestDir1%
move /y "%Sourcedir%\z2daily.*" %DestDir1%

