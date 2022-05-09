<#
.Synopsis
   PowerFido - Fidonet Node Wrapping script
.DESCRIPTION
   Wraps around GoldEd, GoldNode, FMail and BinkD:
   - Launch GoldEd, GoldNode, FMail (config)
   - Tail logs of GoldEd/GoldNode, FMail, and BinkD
.EXAMPLE
   .\PowerFido.ps1
   No parameters needed, it's an interactive script with text based GUI
.OUTPUTS
   n/a
.NOTES
   V     Date        Author                 Notes
   ------------------------------------------------------------------------------------
   1.0   15.05.2021  Fermin Sanchez         First release
   1.1   16.05.2021  Fermin Sanchez         Added maintenance option, fixed typos
   1.2   17.05.2021  Fermin Sanchez         Close previously opened programs upon eXit
   1.3   17.05.2021  Rolf Wilhelm           Poll uplink 
   1.3a  17.05.2021  Fermin Sanchez         
#>
$Version = '1.3a'

#Path definitions
$Me = $MyInvocation.MyCommand.Path
$NodeRoot = (Get-Item -Path $Me).Directory.Parent.FullName
$GoldRoot  = Join-Path -Path $NodeRoot -ChildPath 'golded'
$FMailRoot = Join-Path -Path $NodeRoot -ChildPath 'fmail'
$LogRoot   = Join-Path -Path $NodeRoot -ChildPath 'log'
$SecureIn  = Join-Path -Path $NodeRoot -ChildPath 'transfer\in'
$UnknownIn = Join-Path -Path $NodeRoot -ChildPath 'transfer\in.unknown'
$Outbound  = Join-Path -path $NodeRoot -ChildPath 'transfer\out'

#get some definitions from config files (node and uplink)
$GoldCfg   = Get-Content -LiteralPath "$GoldRoot\golded.cfg"
$Node = ($GoldCfg | ? { $_.Replace("`t"," ").Replace("  "," ").Split(" ")[0] -eq "ADDRESS"}).Split(" ")[1]
$NodeUplink = ($GoldCfg | ? { $_.Replace("`t"," ").Replace("  "," ").Split(" ")[0] -eq "ADDRESSMACRO"}).Split(",")[2]
$host.ui.RawUI.WindowTitle = "Control Center for Node $Node  - v $Version"

#Functions
function ReviewLog
{
    param ($LogFile, $Keep=$false)

    Clear-Host
    Write-Host "`nLog created: $LogFile `n"

    if ((Read-Host "Do you want to review the log file? [yN]") -match "y|j")
    {
        Get-Content -Path $LogFile
        Read-Host '<Enter> to get back'
    }
    if ($Keep -eq $false)
    {
        Remove-Item -Path $LogFile -Force
    }
}



#The script
$OpenedProcesses = @()  #housekeeping
$loop = $true
do
{
    Clear-Host
    Write-Host ' '
    Write-Host ' 1 - Start GoldEd'
    Write-Host ' 2 - Start GoldNode (compile Nodelist)'
    Write-Host ' 3 - Perform FMail maintenance'
    Write-Host ' '
    Write-Host ' 5 - Tail BinkD log (separate window)'
    Write-Host ' 6 - Tail FMail log (separate window)'
    Write-Host ' 7 - Tail Tosser log (separate window)'
    Write-Host " 8 - Poll Uplink at $NodeUplink"
    Write-Host ' 9 - Send outbound echo and netmail'
    Write-Host '10 - Process inbound echo and netmail'
    Write-Host ' '
    Write-Host ' X - Exit (and close all windows)'
    Write-Host ' '
    $Sel = Read-Host 'Which will it be?'

    $now = Get-Date -Format "yyyy_MM_dd_HH_mm_ss"   #for temp logfiles
    switch ($Sel)
    {
        1 
        { 
            $GoldEd = Join-Path -Path $GoldRoot -ChildPath 'gedwin64.exe'
            $proc = Start-Process -FilePath $GoldEd -WorkingDirectory $GoldRoot -PassThru
            $OpenedProcesses += $proc
        }
        
        2
        {
            $GoldNode = Join-Path -Path $GoldRoot -ChildPath 'gnwin64.exe'
            $GoldNodeLog = Join-Path -Path $LogRoot -ChildPath "goldnode_$now.log"
            $proc = Start-Process -FilePath $GoldNode -WorkingDirectory $GoldRoot -ArgumentList '-CD' -RedirectStandardOutput $GoldNodeLog -PassThru
            $OpenedProcesses += $proc
            ReviewLog -LogFile $GoldNodeLog
        }
        
        3
        {
            $FToolsW32 = Join-Path -Path $FMailRoot -ChildPath 'ftoolsw32.exe'
            $FToolsLog = Join-Path -Path $LogRoot -ChildPath "maint_$now.log"
            $FtoolsParam = 'maint'
            $proc = Start-Process -FilePath $FToolsW32 -WorkingDirectory $FMailRoot -ArgumentList $FtoolsParam -RedirectStandardOutput $FToolsLog -PassThru
            $OpenedProcesses += $proc 
            ReviewLog -LogFile $FToolsLog
        }
        
        5
        {
            $BinkDlog = Join-Path $LogRoot -ChildPath 'binkd.log'
            $cmd = "Get-Content -Path $BinkDlog -tail 50 -Wait"
            $proc = Start-Process PowerShell.exe -ArgumentList "-command $cmd" -PassThru
            $OpenedProcesses += $proc
        }
        
        6
        {
            $FMaillog = Join-Path $LogRoot -ChildPath 'fmail.log'
            $cmd = "Get-Content -Path $FMaillog -tail 50 -Wait"
            $proc = Start-Process PowerShell.exe -ArgumentList "-command $cmd" -PassThru
            $OpenedProcesses += $proc 
        }
        
        7
        {
            $Tosslog = Join-Path $LogRoot -ChildPath 'toss.log'
            $cmd = "Get-Content -Path $Tosslog -tail 50 -Wait"
            $proc = Start-Process PowerShell.exe -ArgumentList "-command $cmd" -PassThru
            $OpenedProcesses += $proc
        }

        8
        {
            $a = ($NodeUplink.split(":").Split("/"));
            " " | Out-File ("$Outbound\{0:X4}{1:X4}.CLO" -f [int]$a[1],[int]$a[2])
        }
        
        9
        {
            $PackLog = Join-Path -Path $LogRoot -ChildPath "pack_$now"
            $ScanLog = Join-Path -Path $LogRoot -ChildPath "scan_$now"
            $FMailW32 = Join-Path -Path $FMailRoot -ChildPath 'fmailw32.exe'
            $PackParam = 'pack * /C'
            $ScanParam = 'scan'
            $proc1 = Start-Process -FilePath $FMailW32 -WorkingDirectory $FMailRoot -ArgumentList $PackParam -RedirectStandardOutput $PackLog -PassThru
            $proc2 = Start-Process -FilePath $FMailW32 -WorkingDirectory $FMailRoot -ArgumentList $ScanParam -RedirectStandardOutput $ScanLog -PassThru
            $OpenedProcesses += $proc1
            $OpenedProcesses += $proc2 
            ReviewLog -LogFile $PackLog
            ReviewLog -LogFile $ScanLog
        }
        
        10
        {
            $FMailW32 = Join-Path -Path $FMailRoot -ChildPath 'fmailw32.exe'
            $UnknownFilter = Join-Path -Path $UnknownIn -ChildPath '*.pkt'
            if (Test-Path -Path $UnknownFilter)
            {
                Write-Host 'Mail from <Unknown> Node found, transferring for processing...'
                Move-Item -Path $UnknownFilter -Destination $SecureIn
            }
            $TossLog   = Join-Path -Path $LogRoot -ChildPath "toss_$now"
            $ImportLog = Join-Path -Path $LogRoot -ChildPath "import_$now"
            $TossParam   = 'toss /B'
            $ImportParam = 'import'
            $proc1 = Start-Process -FilePath $FMailW32 -WorkingDirectory $FMailRoot -ArgumentList $TossParam -RedirectStandardOutput $Tosslog -Wait -PassThru 
            $proc2 = Start-Process -FilePath $FMailW32 -WorkingDirectory $FMailRoot -ArgumentList $ImportParam -RedirectStandardOutput $ImportLog -Wait -PassThru 
            $OpenedProcesses += $proc1 
            $OpenedProcesses += $proc2 
            ReviewLog -LogFile $Tosslog
            ReviewLog -LogFile $ImportLog
        }

        X
        {
            foreach ($p in $OpenedProcesses)
            {
                Stop-Process -Id $($p.id)
            }
            $loop = $false
        }

    }

} While ($loop -eq $true)


