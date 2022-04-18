<#
.Synopsis
   Logrotator
.DESCRIPTION
   Rotate logs
.EXAMPLE
   .\Logrotator.ps1

   Will do all the magic, no need to pass any parameters
.NOTES
   V    Date        Author              Description
   ---------------------------------------------------------------------------------
   1.0  18.04.2022  Fermin Sanchez      Initial Release
#>

$Version = '1.0'
$root = $PSScriptRoot

#Global Variables
$Me = $MyInvocation.MyCommand.Path
$NodeRoot = (Get-Item -Path $Me).Directory.Parent.FullName
$LogDir   = Join-Path -Path $NodeRoot -ChildPath 'log'

#Script...
$Logfiles = Get-ChildItem -Path $LogDir -Filter '*.log'
foreach ($f in $Logfiles)
{
    $logFile = $f.FullName
    $bakFile = Join-Path -Path $LogDir -ChildPath ($f.BaseName + '.bak')
    if (Test-Path $bakFile) { del $bakFile }
    ren $logFile $bakFile
}

#Restart BinkD to create a new logfile
Restart-Service 'binkd'