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
   V    Date        Author                 Notes
   ------------------------------------------------------------------------
   1.0  15.05.2021  Fermin Sanchez         First release
#>
$Version = '1.0'

#Path definitions
$NodeRoot  = 'f:\fido'
$GoldRoot  = Join-Path -Path $NodeRoot -ChildPath 'golded'
$FMailRoot = Join-Path -Path $NodeRoot -ChildPath 'fmail'
$LogRoot   = Join-Path -Path $NodeRoot -ChildPath 'log'
$SecureIn  = Join-Path -Path $NodeRoot -ChildPath 'transfer\in'
$UnknownIn = Join-Path -Path $NodeRoot -ChildPath 'transfer\in.unknown'


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

$loop = $true
do
{
    Clear-Host
    Write-Host ' '
    Write-Host ' 1 - Start GoldEd'
    Write-Host ' 2 - Start GoldNode (compile Nodelist)'
    Write-Host ' '
    Write-Host ' 5 - Tail BinkD log (separate window)'
    Write-Host ' 6 - Tail FMail log (separate window)'
    Write-Host ' 7 - Tail Tosser log (separate window)'
    Write-Host ' '
    Write-Host ' 9 - Send outbound echo and netmail'
    Write-Host '10 - Manually process inbound echo an netmail'
    Write-Host ' '
    Write-Host ' X - Exit'
    Write-Host ' '
    $Sel = Read-Host 'Which will it be?'

    $now = Get-Date -Format "yyyy_MM_dd_HH_mm_ss"  #for temp logfiles
    switch ($Sel)
    {
        1 
        { 
            $GoldEd = Join-Path -Path $GoldRoot -ChildPath 'golded.exe'
            Start-Process -FilePath $GoldEd -WorkingDirectory $GoldRoot
        }
        
        2
        {
            $GoldNode = Join-Path -Path $GoldRoot -ChildPath 'goldnode.exe'
            $GoldNodeLog = Join-Path -Path $LogRoot -ChildPath "goldnode_$now.log"
            Start-Process -FilePath $GoldNode -WorkingDirectory $GoldRoot -ArgumentList '-CD' -RedirectStandardOutput $GoldNodeLog
            ReviewLog -LogFile $GoldNodeLog
        }
        
        5
        {
            $BinkDlog = Join-Path $LogRoot -ChildPath 'binkd.log'
            $cmd = "Get-Content -Path $BinkDlog -tail 50 -Wait"
            Start-Process PowerShell.exe -ArgumentList "-command $cmd"
        }
        
        6
        {
            $FMaillog = Join-Path $LogRoot -ChildPath 'fmail.log'
            $cmd = "Get-Content -Path $FMaillog -tail 50 -Wait"
            Start-Process PowerShell.exe -ArgumentList "-command $cmd"
        }
        
        7
        {
            $Tosslog = Join-Path $LogRoot -ChildPath 'toss.log'
            $cmd = "Get-Content -Path $Tosslog -tail 50 -Wait"
            Start-Process PowerShell.exe -ArgumentList "-command $cmd"
        }
        
        9
        {
            $PackLog = Join-Path -Path $LogRoot -ChildPath "pack_$now"
            $ScanLog = Join-Path -Path $LogRoot -ChildPath "scan_$now"
            $FMailW32 = Join-Path -Path $FMailRoot -ChildPath 'fmailw32.exe'
            $PackParam = 'pack * /C'
            $ScanParam = 'scan'
            Start-Process -FilePath $FMailW32 -WorkingDirectory $FMailRoot -ArgumentList $PackParam -RedirectStandardOutput $PackLog
            Start-Process -FilePath $FMailW32 -WorkingDirectory $FMailRoot -ArgumentList $ScanParam -RedirectStandardOutput $ScanLog
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
            Start-Process -FilePath $FMailW32 -WorkingDirectory $FMailRoot -ArgumentList $TossParam -RedirectStandardOutput $Tosslog -Wait
            Start-Process -FilePath $FMailW32 -WorkingDirectory $FMailRoot -ArgumentList $ImportParam -RedirectStandardOutput $ImportLog -Wait
            ReviewLog -LogFile $Tosslog
            ReviewLog -LogFile $ImportLog
        }

        X
        {
            $loop = $false
        }

    }

} While ($loop -eq $true)


