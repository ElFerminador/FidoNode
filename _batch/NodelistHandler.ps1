<#
.Synopsis
   Nodelisthandler
.DESCRIPTION
   Handle NODELIST.* and Z2DAILY.*
.EXAMPLE
   .\NodelistHandler.ps1

   Will do all the magic, no need to pass any parameters
.NOTES
   V    Date        Author              Description
   ---------------------------------------------------------------------------------
   1.0  18.04.2022  Fermin Sanchez      Initial Release
#>

$Version = '1.0'
$root = $PSScriptRoot

#Global Variables
$FidoRoot    = 'c:\fido'
$InboxDir    = Join-Path -Path $FidoRoot -ChildPath 'transfer\in'
$NodelistDir = Join-Path -Path $FidoRoot -ChildPath 'nodelist'
$LogDir      = Join-Path -Path $FidoRoot -ChildPath 'log'
$LogFile     = Join-Path -Path $LogDir -ChildPath 'NodelistHandler.log'
$Nodelists   = 'nodelist','z2daily'


#Probably no need to change anything below here...

#Functions
function WriteLog
{
    param (
            $LogText,
            $ToFile = $true,
            $ToScreen = $false)

    $TimeStamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $LogString = "$Timestamp  $LogText"
    if ($ToScreen) { Write-Host $LogString }
    if ($ToFile)   { $LogString | Out-File -FilePath $LogFile -Encoding utf8 -Append }

}


#The code

WriteLog -LogText "Nodelisthandler V$version invoked..." 

$RestartBinkd = $false 
foreach ($nl in $Nodelists)
{
    $Filter = $nl + '.*'
    $files = Get-ChildItem -Path $InboxDir -Filter $filter
    if ($files.count -gt 0)
    {
        WriteLog -LogText "Found new $nl file..."
        $RestartBinkd = $true
        $bak = $nl + '.bak'
        
        
        #Handling files in $NodelistDir first...
        $bakFile = Join-Path -Path $NodelistDir -ChildPath $bak
        if (Test-Path $bakFile) { del $bakFile }
        
        $prevFile = gci -Path $NodelistDir -Filter $Filter | ? Extension -ne '.bak' | sort CreationTime -Descending
        if ($prevFile.count -gt 0)
        {
            $f = $prevFile | select -first 1
            ren $prevFile.FullName $bakFile
            WriteLog -LogText "Renamed old $nl file to $bakFile"
        }
        if ($prevFile.count -gt 1)
        {
            WriteLog -LogText "Found obsolete $nl files in $NodelistDir!"
            foreach ($del in $prevFile)
            {
                $delFile = $del.FullName 
                WriteLog -LogText "`tDeleting: $($del.FullName)"
                if (Test-Path $delFile) { del $delFile }
            }
        }


        #Getting ready to move nodelist files from $InboxDir to $NodelistDir...
        $currentFile = Get-ChildItem -Path $InboxDir -Filter $filter | sort Creationtime -Descending
        if ($currentFile.Count -gt 0)
        {
            $f = $currentFile | select -first 1
            move -Path $f.FullName -Destination $NodelistDir
            WriteLog -LogText "Moved $($f.FullName) to $NodelistDir"
            if ($currentFile.Count -gt 1)
            {
                WriteLog -LogText "Found obsolete $nl files in $InboxDir!"
                foreach ($del in $currentFile)
                {
                    $delFile = $del.FullName 
                    WriteLog -LogText "`tDeleting: $($del.FullName)"
                    if (Test-Path $delFile) { del $delFile }
                }
            }
        }
    }

}


if ($RestartBinkd) 
{ 
    WriteLog -LogText 'Restarting BinkD to reload nodelist...'
    Restart-Service 'binkd' 
}
else
{
    WriteLog -LogText 'No restart of BinkD needed'
}

WriteLog -LogText 'Processing of NodelistHandler.ps1 finished'


