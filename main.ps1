$BASE_URL = 'https://raw.githubusercontent.com/AyaG-Sippi/sippicom-tools/main'
$esc = [char]27
$orange = "$esc[38;2;243;139;0m"
$gold   = "$esc[38;2;255;184;28m"
$reset  = "$esc[0m"

# Construct Unicode shade blocks at runtime to guarantee 100% codepage immunity
$b0 = ' '
$b1 = [char]0x2591 # light shade
$b2 = [char]0x2592 # medium shade
$b3 = [char]0x2593 # dark shade
$b4 = [char]0x2588 # full block

function Show-Header {
    Clear-Host
    Write-Host ''
    Write-Host ("               $orange" + '      ' + ($b1 * 2) + ($b2 * 15) + "$reset")
    Write-Host ("               $orange" + '     ' + $b1 + $b3 + ($b1 * 2) + '             ' + $b1 + $b2 + $b1 + "$reset")
    Write-Host ("               $orange" + '   ' + ($b1 * 2) + $b3 + ($b1 * 3) + $b2 + $b1 + $b2 + $b1 + $b2 + $b1 + $b2 + $b1 + $b2 + $b1 + $b2 + $b1 + ($b2 * 4) + ($b1 * 3) + "$reset")
    Write-Host ("               $orange" + ' ' + $b2 + $b3 + $b1 + ' ' + $b3 + $b1 + ' ' + ($b1 * 14) + ' ' + $b1 + $b2 + $b1 + ($b2 * 3) + "$reset")
    Write-Host ("               $orange" + ($b2 * 2) + '  ' + $b1 + $b2 + $b1 + '                ' + $b1 + $b3 + '   ' + $b3 + $b2 + "$reset")
    Write-Host ("               $orange" + $b2 + $b3 + '  ' + $b1 + $b3 + $b1 + '                      ' + $b1 + "$reset")
    Write-Host ("               $orange" + $b1 + ($b2 * 2) + $b1 + ' ' + $b2 + $b1 + "$reset")
    Write-Host ("               $orange" + '  ' + $b1 + ($b2 * 24) + $b1 + "$reset")
    Write-Host ("               $orange" + '     ' + $b2 + $b1 + '                   ' + $b1 + $b2 + $b3 + $b1 + "$reset")
    Write-Host ("               $orange" + $b1 + '   ' + $b1 + $b3 + $b1 + '                 ' + $b1 + '   ' + ($b2 * 2) + "$reset")
    Write-Host ("               $orange" + $b2 + $b3 + '   ' + $b3 + $b1 + '                ' + $b1 + $b3 + $b1 + '  ' + $b3 + $b2 + "$reset")
    Write-Host ("               $orange" + ' ' + ($b2 * 3) + $b1 + $b2 + ($b1 * 18) + $b2 + ($b1 * 2) + ($b2 * 2) + "$reset")
    Write-Host ("               $orange" + '   ' + $b1 + $b2 + $b1 + $b2 + ($b1 * 2) + $b2 + $b1 + $b2 + $b1 + $b2 + $b1 + $b2 + $b1 + $b2 + $b1 + $b2 + $b1 + $b2 + ($b1 * 2) + $b3 + ' ' + ($b1 * 2) + "$reset")
    Write-Host ("               $orange" + '     ' + $b1 + ($b2 * 2) + '              ' + $b1 + $b3 + $b1 + "$reset")
    Write-Host ("               $orange" + '      ' + ($b1 * 2) + ($b2 * 15) + "$reset")
    Write-Host "          $gold--== SIPPICOM IT-SOLUTIONS ==--$reset"
    Write-Host '==================================================================' -ForegroundColor DarkYellow
    Write-Host '   SIPPICOM IT-SOLUTIONS - CLOUD SUITE & DEPLOYMENT HUB' -ForegroundColor Yellow
    Write-Host '   Live GitHub Execution Engine (irm | iex)' -ForegroundColor Gray
    Write-Host '==================================================================' -ForegroundColor DarkYellow
    Write-Host ''
}

function Launch-Tool ($ToolName, $ExeName) {
    Write-Host ''
    Write-Host ('--> Launching ' + $ToolName + ' from Cloud...') -ForegroundColor Cyan
    $exeUrl = $BASE_URL + '/bin/' + $ExeName
    $targetPath = Join-Path $env:TEMP $ExeName
    try {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($exeUrl, $targetPath)
        Start-Process -FilePath $targetPath
        Write-Host ('[OK] ' + $ToolName + ' launched successfully!') -ForegroundColor Green
    } catch {
        Write-Host ('[Error] Could not fetch ' + $ExeName) -ForegroundColor Yellow
    }
}

do {
    Show-Header
    Write-Host 'Select a SIPPICOM Cloud Tool:' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '  [1] > CertRDP          - RDP Code Signing & PKI Trust Suite' -ForegroundColor White
    Write-Host '  [2] > PrinterFix       - Multi-Threaded Print Spooler & IP Hub' -ForegroundColor White
    Write-Host '  [3] > AutoDeploy       - Workstation Software & Setup Deployer' -ForegroundColor White
    Write-Host '  [4] > AutoDeploy Fast  - Unattended Silent Workstation Deployer' -ForegroundColor White
    Write-Host '  [5] > CtrlAltPass      - Enterprise Password Generator' -ForegroundColor White
    Write-Host '  [6] > Download All     - Save standalone binaries locally' -ForegroundColor White
    Write-Host '  [Q] > Exit' -ForegroundColor Red
    Write-Host ''
    Write-Host 'Enter selection [1-6, Q]: ' -NoNewline -ForegroundColor Yellow

    $choice = Read-Host

    switch ($choice) {
        '1' { Launch-Tool 'CertRDP' 'CertRDP.exe'; Start-Sleep -Seconds 1 }
        '2' { Launch-Tool 'PrinterFix' 'SippicomPrinterFix.exe'; Start-Sleep -Seconds 1 }
        '3' { Launch-Tool 'AutoDeploy' 'SippicomAutoDeploy.exe'; Start-Sleep -Seconds 1 }
        '4' { Launch-Tool 'AutoDeploy Fast' 'SippicomAutoDeployFast.exe'; Start-Sleep -Seconds 1 }
        '5' { Launch-Tool 'CtrlAltPass' 'SippicomCtrlAltPass.exe'; Start-Sleep -Seconds 1 }
        '6' {
            Write-Host ''
            Write-Host '--> Downloading standalone binaries to current directory...' -ForegroundColor Cyan
            $bins = @('CertRDP.exe', 'SippicomPrinterFix.exe', 'SippicomAutoDeploy.exe', 'SippicomAutoDeployFast.exe', 'SippicomCtrlAltPass.exe')
            $wc = New-Object System.Net.WebClient
            foreach ($b in $bins) {
                Write-Host ('    Downloading ' + $b + ' ... ') -NoNewline
                try {
                    $wc.DownloadFile($BASE_URL + '/bin/' + $b, '.\' + $b)
                    Write-Host 'OK' -ForegroundColor Green
                } catch {
                    Write-Host 'Failed' -ForegroundColor Red
                }
            }
            Write-Host ''
            Write-Host 'All binaries downloaded. Press any key to continue...'
            [void][Console]::ReadKey($true)
        }
        'Q' {
            Write-Host ''
            Write-Host 'Exiting SIPPICOM Cloud Hub. Have a great day!' -ForegroundColor Yellow
            break
        }
    }
} while ($choice -ne 'Q')
