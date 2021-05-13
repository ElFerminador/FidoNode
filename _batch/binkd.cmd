@echo off
for %%I in ("%~dp0\..") do set "base=%%~fI"

TITLE "BinkD"
%base%\binkd\binkd.exe -C %base%\binkd\binkd.cfg
