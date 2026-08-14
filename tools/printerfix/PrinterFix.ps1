<#
.SYNOPSIS
    SIPPICOM PrinterFix (Web-Executable Edition)
.DESCRIPTION
    irm https://raw.githubusercontent.com/sippicom/tools/main/tools/printerfix/PrinterFix.ps1 | iex
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(544)
if (!$isAdmin) {
    try {
        $url = "https://raw.githubusercontent.com/sippicom/tools/main/tools/printerfix/PrinterFix.ps1"
        $cmd = "& { irm '$url' | iex }"
        Start-Process powershell.exe -ArgumentList "-sta -NoProfile -ExecutionPolicy Bypass -Command `"$cmd`"" -Verb RunAs -ErrorAction Stop
        exit
    } catch {}
}

function Show-PrinterMenu {
    Clear-Host
    Write-Host "==================================================================" -ForegroundColor DarkYellow
    Write-Host "   SIPPICOM PRINTERFIX — MULTI-THREADED PRINT QUEUE & SPOOLER HUB" -ForegroundColor Yellow
    Write-Host "==================================================================" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "Actions:" -ForegroundColor Cyan
    Write-Host "  [1] 🧹 Flush Print Spooler & Purge Stuck Jobs (.SPL / .SHD)" -ForegroundColor White
    Write-Host "  [2] 🌐 Force All Offline / Paused Printers Online" -ForegroundColor White
    Write-Host "  [3] 🔄 Restart Print Spooler & Notification Services" -ForegroundColor White
    Write-Host "  [4] ➕ Add Network TCP/IP Printer" -ForegroundColor White
    Write-Host "  [5] 🗑️  Delete Printer Queue" -ForegroundColor White
    Write-Host "  [6] 💾 Export Printers Migration Package (PrintBrm .printerExport)" -ForegroundColor White
    Write-Host "  [7] 📥 Import Printers Migration Package (PrintBrm .printerExport)" -ForegroundColor White
    Write-Host "  [8] 🖨️  Send Test Print ('Test von Sippicom!')" -ForegroundColor White
    Write-Host "  [L] 📋 List Installed Printers & Status" -ForegroundColor White
    Write-Host "  [Q] ❌ Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "Select an action [1-8, L, Q]: " -NoNewline -ForegroundColor Yellow
}

function Flush-Spooler {
    Write-Host "`n--> Stopping Print Spooler Service..." -ForegroundColor Cyan
    Stop-Service -Name spooler -Force -ErrorAction SilentlyContinue
    net stop spooler 2>$null

    $dir = "C:\Windows\System32\spool\PRINTERS"
    $count = 0
    if (Test-Path $dir) {
        $files = Get-ChildItem -Path $dir -File
        foreach ($f in $files) {
            Remove-Item $f.FullName -Force -ErrorAction SilentlyContinue
            $count++
        }
    }
    Write-Host "--> Purged $count stuck spool file(s)." -ForegroundColor Green

    Write-Host "--> Starting Print Spooler Service..." -ForegroundColor Cyan
    Start-Service -Name spooler -ErrorAction SilentlyContinue
    net start spooler 2>$null
    Write-Host "✓ Spooler service reset successfully!" -ForegroundColor Green
}

function Force-PrintersOnline {
    Write-Host "`n--> Forcing all printer queues online..." -ForegroundColor Cyan
    Get-Printer | Set-Printer -WorkOffline $false -Paused $false -ErrorAction SilentlyContinue
    Write-Host "✓ All printer queues set to Online and Unpaused!" -ForegroundColor Green
}

function Restart-PrintServices {
    Write-Host "`n--> Restarting print services (spooler, PrintNotify, DeviceAssociationService)..." -ForegroundColor Cyan
    Restart-Service -Name spooler, PrintNotify, DeviceAssociationService -Force -ErrorAction SilentlyContinue
    Write-Host "✓ Services restarted successfully!" -ForegroundColor Green
}

function Add-IpPrinter {
    Write-Host "`n--- ADD NETWORK PRINTER OVER IP ---" -ForegroundColor Yellow
    $ip = Read-Host "Enter Printer IP Address (e.g. 192.168.1.100)"
    if ([string]::IsNullOrWhiteSpace($ip)) { return }

    $name = Read-Host "Enter Printer Queue Name"
    if ([string]::IsNullOrWhiteSpace($name)) { return }

    $driver = Read-Host "Enter Printer Driver Name (or press Enter for 'Generic / Text Only')"
    if ([string]::IsNullOrWhiteSpace($driver)) { $driver = "Generic / Text Only" }

    $portName = "IP_$ip"
    if (!(Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue)) {
        Add-PrinterPort -Name $portName -PrinterHostAddress $ip -ErrorAction SilentlyContinue
    }

    Add-Printer -Name $name -PortName $portName -DriverName $driver -ErrorAction SilentlyContinue
    Write-Host "✓ Printer '$name' added on port '$portName'!" -ForegroundColor Green
}

function Delete-PrinterQueue {
    Write-Host "`n--- DELETE PRINTER QUEUE ---" -ForegroundColor Yellow
    $name = Read-Host "Enter exact Printer Name to delete"
    if ([string]::IsNullOrWhiteSpace($name)) { return }

    Remove-Printer -Name $name -ErrorAction SilentlyContinue
    Write-Host "✓ Printer queue '$name' removed." -ForegroundColor Green
}

function Export-PrintBrm {
    Add-Type -AssemblyName System.Windows.Forms
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Filter = "Printer Migration (*.printerExport)|*.printerExport|All (*.*)|*.*"
    $sfd.FileName = "SippicomPrinters_Backup.printerExport"
    $sfd.Title = "Export Windows Printers Migration Package"
    if ($sfd.ShowDialog() -eq "OK") {
        $path = [System.IO.Path]::GetFullPath($sfd.FileName).Trim()
        if (Test-Path $path) { Remove-Item $path -Force -ErrorAction SilentlyContinue }
        Write-Host "`n--> Exporting to $path..." -ForegroundColor Cyan
        & "C:\Windows\System32\spool\tools\PrintBrm.exe" -b -f "$path"
        if (Test-Path $path) {
            Write-Host "✓ Export completed successfully!" -ForegroundColor Green
        }
    }
}

function Import-PrintBrm {
    Add-Type -AssemblyName System.Windows.Forms
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "Printer Migration (*.printerExport)|*.printerExport|All (*.*)|*.*"
    $ofd.Title = "Import Windows Printers Migration Package"
    if ($ofd.ShowDialog() -eq "OK") {
        $path = [System.IO.Path]::GetFullPath($ofd.FileName).Trim()
        Write-Host "`n--> Restoring printers from $path..." -ForegroundColor Cyan
        & "C:\Windows\System32\spool\tools\PrintBrm.exe" -r -f "$path"
        Write-Host "✓ Import process finished!" -ForegroundColor Green
    }
}

function List-Printers {
    Write-Host "`n--- INSTALLED PRINTER QUEUES ---" -ForegroundColor Yellow
    Get-Printer | Select-Object Name, PortName, DriverName, PrinterStatus, WorkOffline | Format-Table -AutoSize
}

do {
    Show-PrinterMenu
    $opt = Read-Host

    switch ($opt) {
        "1" { Flush-Spooler; Start-Sleep -Seconds 2 }
        "2" { Force-PrintersOnline; Start-Sleep -Seconds 2 }
        "3" { Restart-PrintServices; Start-Sleep -Seconds 2 }
        "4" { Add-IpPrinter; Start-Sleep -Seconds 2 }
        "5" { Delete-PrinterQueue; Start-Sleep -Seconds 2 }
        "6" { Export-PrintBrm; Start-Sleep -Seconds 2 }
        "7" { Import-PrintBrm; Start-Sleep -Seconds 2 }
        "8" { 
            $printers = [System.Drawing.Printing.PrinterSettings]::InstalledPrinters
            $default = (New-Object System.Drawing.Printing.PrinterSettings).PrinterName
            Write-Host "`nSending 'Test von Sippicom!' to default printer: $default" -ForegroundColor Cyan
            $pd = New-Object System.Drawing.Printing.PrintDocument
            $pd.PrinterSettings.PrinterName = $default
            $pd.add_PrintPage({
                param($s, $e)
                $font = New-Object System.Drawing.Font("Segoe UI", 10.5)
                $e.Graphics.DrawString("Test von Sippicom!", $font, [System.Drawing.Brushes]::Black, 50, 50)
            })
            $pd.Print()
            Write-Host "✓ Test print dispatched!" -ForegroundColor Green
            Start-Sleep -Seconds 2
        }
        "L" { List-Printers; Write-Host "`nPress any key to continue..."; [void][Console]::ReadKey($true) }
        "Q" { break }
    }
} while ($opt -ne "Q")
