<#
.SYNOPSIS
    PRO LAPTOP ULTIMATE v3
.DESCRIPTION
    Complete PC Maintenance, Repair & Cybersecurity Framework
    Eng. Mahmoud Kullab - Pro Laptop, Khan Younis, Gaza
    Phone   : +970 599 548 716
    Email   : mahmood.kullab2004@gmail.com
    Web     : mahmoud-kullab.github.io
    GitHub  : github.com/mahmoud-kullab
    LinkedIn: linkedin.com/in/m-kullab
#>

# ==============================================================================
# SELF-ELEVATION (Fixes auto-close issue)
# ==============================================================================
$myPath = $MyInvocation.MyCommand.Path
if ($myPath -and $Host.Name -match "ConsoleHost") {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        try { Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$myPath`"" -Verb RunAs -ErrorAction Stop }
        catch { Write-Host "`n  [!] ERROR: You must grant Administrator privileges." -ForegroundColor Red; Start-Sleep -Seconds 3 }
        exit
    }
}

# ==============================================================================
# INITIALIZATION
# ==============================================================================
$ErrorActionPreference = "SilentlyContinue"
Set-StrictMode -Off

# Safe Clear-Host wrapper
function Clear-Host {
    try   { Microsoft.PowerShell.Utility\Clear-Host }
    catch { try { [Console]::Clear() } catch { Write-Host "`n`n`n`n`n" } }
}

# Logging
$LogFile = "$PSScriptRoot\ProLaptop_Log.txt"
Add-Content -Path $LogFile -Value "`n================================================================" -Encoding UTF8
Add-Content -Path $LogFile -Value "  Session: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Encoding UTF8
Add-Content -Path $LogFile -Value "================================================================" -Encoding UTF8

function Write-Log ($Msg, $Level = "INFO") {
    $t = Get-Date -Format "HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$t][$Level] $Msg" -Encoding UTF8
}

# Disk Detection
$Global:DiskInfo = Get-PhysicalDisk -ErrorAction SilentlyContinue | Select-Object -First 1
$Global:DiskType = if ($Global:DiskInfo) { $Global:DiskInfo.MediaType } else { "Unknown" }

# ==============================================================================
# SHARED HELPERS
# ==============================================================================
function Confirm-Action ($Message) {
    Write-Host "`n  [!] WARNING: $Message" -ForegroundColor Red
    $r = Read-Host "  Are you sure? (Y/N)"
    return ($r -match '^[Yy]$')
}

function Show-OK  ($Msg) { Write-Host "  [OK] $Msg" -ForegroundColor Green;  Write-Log "OK: $Msg" }
function Show-ERR ($Msg) { Write-Host "  [!!] $Msg" -ForegroundColor Red;    Write-Log $Msg "ERROR" }
function Show-INF ($Msg) { Write-Host "  [*]  $Msg" -ForegroundColor Cyan;   Write-Log $Msg }
function Show-WRN ($Msg) { Write-Host "  [~]  $Msg" -ForegroundColor Yellow; Write-Log $Msg "WARN" }
function Show-Sep        { Write-Host "  --------------------------------------------------" -ForegroundColor DarkGray }

function Invoke-SafeRemove ($Path) {
    if (Test-Path $Path) {
        try {
            Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            Show-OK "Cleaned: $Path"
        } catch { Show-WRN "Some files in use (normal): $Path" }
    } else {
        Write-Host "  [--] Not found (skip): $Path" -ForegroundColor DarkGray
    }
}

function Make-RestorePoint ($Desc) {
    Show-INF "Creating restore point: $Desc"
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description $Desc -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Show-OK "Restore point created."
        Write-Log "Restore point: $Desc"
    } catch { Show-WRN "Could not create restore point. (May be too frequent or System Restore disabled)" }
}

function Wait-Enter { $null = Read-Host "`n  Press Enter to return to menu..." }

# ==============================================================================
# MAIN MENU
# ==============================================================================
function Show-MainMenu {
    Clear-Host
    Write-Host ""
    Write-Host "  +====================================================================+" -ForegroundColor Cyan
    Write-Host "  |                                                                  |" -ForegroundColor Cyan
    Write-Host "  |          PRO LAPTOP ULTIMATE  v3                                 |" -ForegroundColor Green
    Write-Host "  |          PC Maintenance and Cybersecurity Framework              |" -ForegroundColor DarkGreen
    Write-Host "  |                                                                  |" -ForegroundColor Cyan
    Write-Host "  |          Eng. Mahmoud Kullab  |  Khan Younis, Gaza               |" -ForegroundColor Yellow
    Write-Host "  |          Phone   :  +970 599 548 716                             |" -ForegroundColor DarkGray
    Write-Host "  |          Email   :  mahmood.kullab2004@gmail.com                 |" -ForegroundColor DarkGray
    Write-Host "  |          Web     :  mahmoud-kullab.github.io                     |" -ForegroundColor DarkGray
    Write-Host "  |          GitHub  :  github.com/mahmoud-kullab                    |" -ForegroundColor DarkGray
    Write-Host "  |          LinkedIn:  linkedin.com/in/m-kullab                     |" -ForegroundColor DarkGray
    Write-Host "  |                                                                  |" -ForegroundColor Cyan
    Write-Host "  +====================================================================+" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   --- POWER & PERFORMANCE ---" -ForegroundColor DarkGray
    Write-Host "   [1]  Setup All Power Plans          [2]  Fix Battery Alerts (20%)" -ForegroundColor Yellow
    Write-Host "   [3]  Reset Power Plans to Default   [4]  CPU Performance Boost" -ForegroundColor Yellow
    Write-Host "   [5]  Battery Health Report          [6]  Power Efficiency Report" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   --- SYSTEM CLEANING ---" -ForegroundColor DarkGray
    Write-Host "   [7]  Deep System Cleaner            [8]  Clear All Browser Caches" -ForegroundColor Cyan
    Write-Host "   [9]  Clean Windows Update Cache     [10] Remove Windows.old" -ForegroundColor Cyan
    Write-Host "   [11] Empty Recycle Bin + Cache      [12] Clear Windows Event Logs" -ForegroundColor Cyan
    Write-Host "   [13] Disk Cleanup (cleanmgr)        [14] Broken Shortcut Finder & Fixer" -ForegroundColor Cyan
    Write-Host "   [15] Wipe Free Space (Zero Fill)    [16] Remove Orphaned App Data" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   --- SYSTEM REPAIR ---" -ForegroundColor DarkGray
    Write-Host "   [17] SFC VerifyOnly (no changes)    [18] SFC Repair (/scannow)" -ForegroundColor Magenta
    Write-Host "   [19] DISM CheckHealth               [20] DISM ScanHealth" -ForegroundColor Magenta
    Write-Host "   [21] DISM RestoreHealth             [22] DISM ComponentCleanup" -ForegroundColor Magenta
    Write-Host "   [23] Repair Disk (CHKDSK C:)        [24] Fix Windows Update Services" -ForegroundColor Magenta
    Write-Host "   [25] Fix Windows Store & Apps       [26] Fix Windows Search" -ForegroundColor Magenta
    Write-Host "   [27] Fix Windows Audio              [28] Fix Windows Time Sync" -ForegroundColor Magenta
    Write-Host "   [29] Reset Windows Firewall         [30] Boot Repair & BCD Manager" -ForegroundColor Magenta
    Write-Host "   [31] Re-register DLL Libraries      [32] Fix Windows Installer (MSI)" -ForegroundColor Magenta
    Write-Host "   [33] Reset Windows Update Policy    [34] Repair WMI Repository" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "   --- NETWORK & INTERNET ---" -ForegroundColor DarkGray
    Write-Host "   [35] Full Network Reset             [36] Set Google DNS (8.8.8.8)" -ForegroundColor Blue
    Write-Host "   [37] Set Cloudflare DNS (1.1.1.1)   [38] Reset DNS to Auto (DHCP)" -ForegroundColor Blue
    Write-Host "   [39] Network Diagnostics            [40] Show Full ipconfig /all" -ForegroundColor Blue
    Write-Host "   [41] Open Network Connections       [42] Reset Proxy Settings" -ForegroundColor Blue
    Write-Host "   [43] Show WiFi Profiles             [44] Firewall Manager" -ForegroundColor Blue
    Write-Host "   [45] Show Open Ports & Connections  [46] Test Internet Speed (Ping)" -ForegroundColor Blue
    Write-Host "   [47] Export Network Config Backup" -ForegroundColor Blue
    Write-Host ""
    Write-Host "   --- CYBER SECURITY ---" -ForegroundColor DarkGray
    Write-Host "   [48] Malware Quick Scan             [49] Defender Management (Full Control)" -ForegroundColor DarkYellow
    Write-Host "   [50] Malware Full Scan              [51] Disable Telemetry & Tracking" -ForegroundColor DarkYellow
    Write-Host "   [52] Startup Analyzer               [53] Suspicious Process Check" -ForegroundColor DarkYellow
    Write-Host "   [54] Kill Unsigned Temp Processes   [55] Enable Firewall + Defender" -ForegroundColor DarkYellow
    Write-Host "   [56] Certificate Manager            [57] Local Security Policy" -ForegroundColor DarkYellow
    Write-Host "   [58] Driver Verifier                [59] Local Users & Groups" -ForegroundColor DarkYellow
    Write-Host "   [60] Audit Policy Status            [61] Check for Rootkit Indicators" -ForegroundColor DarkYellow
    Write-Host "   [62] Hosts File Viewer/Editor"      -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "   --- DIAGNOSTICS & INFO ---" -ForegroundColor DarkGray
    Write-Host "   [63] Full System Info Report        [64] CPU + Motherboard + RAM" -ForegroundColor White
    Write-Host "   [65] RAM Details (Physical Modules) [66] Disk Health & SMART" -ForegroundColor White
    Write-Host "   [67] GPU & Driver Details           [68] Driver Error Checker" -ForegroundColor White
    Write-Host "   [69] Windows Activation Status      [70] Uptime & Services Status" -ForegroundColor White
    Write-Host "   [71] Remote Desktop (mstsc)         [72] Group Policy Editor" -ForegroundColor White
    Write-Host "   [73] Windows Apps Folder            [74] Installed Programs List" -ForegroundColor White
    Write-Host "   [75] Running Processes (Top CPU/RAM)[76] Environment Variables" -ForegroundColor White
    Write-Host "   [77] Windows Error / BSOD Log       [78] Reliability History" -ForegroundColor White
    Write-Host ""
    Write-Host "   --- ADVANCED ---" -ForegroundColor DarkGray
    Write-Host "   [79] FULL MAINTENANCE (All Safe)    [80] Create System Restore Point" -ForegroundColor DarkCyan
    Write-Host "   [81] Defrag HDD (Auto-Skips SSD)    [82] Trim SSD (Auto-Skips HDD)" -ForegroundColor DarkCyan
    Write-Host "   [83] Optimize All SSDs              [84] Driver Management" -ForegroundColor DarkCyan
    Write-Host "   [85] Scheduled Task Manager         [86] Disable Startup Programs" -ForegroundColor DarkCyan
    Write-Host "   [87] Export Registry Backup         [88] Open Log File" -ForegroundColor DarkCyan
    Write-Host "   [89] Windows Memory Diagnostic      [90] System Configuration (msconfig)" -ForegroundColor DarkCyan
    Write-Host "   [91] Resource Monitor               [92] Performance Monitor" -ForegroundColor DarkCyan
    Write-Host "   [93] Event Viewer                   [94] Services Manager" -ForegroundColor DarkCyan
    Write-Host "   [95] Disk Management                [96] Computer Management" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "   --- SHOP TOOLS ---" -ForegroundColor DarkGray
    Write-Host "   [97] USB Virus Unhider              [98] Driver Exporter (Backup All)" -ForegroundColor Green
    Write-Host "   [99] Silent App Installer (Winget)  [100] Hardware Test Helpers" -ForegroundColor Green
    Write-Host "   [101] Password Bypass (WinPE ONLY)" -ForegroundColor Red
    Write-Host ""
    Write-Host "   [0]  Exit" -ForegroundColor Red
    Write-Host "  +====================================================================+" -ForegroundColor Cyan
    Write-Host ""
}

function Invoke-PowerPlans {
    Clear-Host; Write-Host "`n  === SETUP ALL POWER PLANS ===" -ForegroundColor Cyan
    Show-INF "Unlocking advanced power plans in registry..."
    reg add "HKLM\System\CurrentControlSet\Control\Power" /v PlatformAoAcOverride /t REG_DWORD /d 0 /f 2>$null | Out-Null
    Show-OK "Registry unlocked."
    Show-INF "Adding Ultimate Performance plan..."
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null | Out-Null
    Show-OK "Ultimate Performance added."
    Show-INF "Adding Battery Saver plan..."
    powercfg -duplicatescheme a1841308-3541-4fab-bc81-f71556f20b4a 2>$null | Out-Null
    Show-OK "Battery Saver added."
    Show-INF "Setting battery alerts 20% / critical 5% on all plans..."
    $plans = powercfg -list | Select-String "GUID" | ForEach-Object { ($_ -split '\s+')[3] }
    foreach ($g in $plans) {
        powercfg -setdcvalueindex $g SUB_BATTERY BATALRMDO   1  2>$null | Out-Null
        powercfg -setdcvalueindex $g SUB_BATTERY BATLOGLEVEL 20 2>$null | Out-Null
        powercfg -setdcvalueindex $g SUB_BATTERY BATALRMACT  0  2>$null | Out-Null
        powercfg -setdcvalueindex $g SUB_BATTERY BATCRITICAL 5  2>$null | Out-Null
    }
    powercfg -setactive SCHEME_CURRENT 2>$null | Out-Null
    Show-Sep; Show-OK "All power plans configured! Restart PC to see them."
    Show-WRN "Restart required for full effect."
}

function Invoke-FixBattery {
    Clear-Host; Write-Host "`n  === FIX BATTERY ALERTS ===" -ForegroundColor Cyan
    $plans = powercfg -list | Select-String "GUID" | ForEach-Object { ($_ -split '\s+')[3] }
    foreach ($g in $plans) {
        powercfg -setdcvalueindex $g SUB_BATTERY BATALRMDO   1  2>$null | Out-Null
        powercfg -setdcvalueindex $g SUB_BATTERY BATLOGLEVEL 20 2>$null | Out-Null
        powercfg -setdcvalueindex $g SUB_BATTERY BATALRMACT  0  2>$null | Out-Null
        powercfg -setdcvalueindex $g SUB_BATTERY BATCRITICAL 5  2>$null | Out-Null
        Write-Host "  [+] Updated: $g" -ForegroundColor DarkGray
    }
    powercfg -setactive SCHEME_CURRENT 2>$null | Out-Null
    Show-OK "Battery alert = 20%, Critical = 5% on all plans."
    Show-WRN "Restart PC to activate alerts."
}

function Invoke-ResetPower {
    if (-not (Confirm-Action "Delete all custom power plans and restore Windows defaults?")) { return }
    Clear-Host; Write-Host "`n  === RESET POWER PLANS ===" -ForegroundColor Cyan
    $plans = powercfg -list | Select-String "GUID" | ForEach-Object { ($_ -split '\s+')[3] }
    foreach ($g in $plans) { powercfg -delete $g 2>$null | Out-Null }
    powercfg -restoredefaultschemes 2>$null | Out-Null
    powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null | Out-Null
    Show-OK "Power plans restored to factory defaults."
}

function Invoke-CpuBoost {
    Clear-Host; Write-Host "`n  === CPU PERFORMANCE BOOST ===" -ForegroundColor Cyan
    Show-INF "Setting processor scheduling to Programs..."
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" "Win32PrioritySeparation" 2 -ErrorAction SilentlyContinue
    Show-OK "Processor scheduling optimized."
    Show-INF "Disabling CPU core parking on all plans..."
    $plans = powercfg -list | Select-String "GUID" | ForEach-Object { ($_ -split '\s+')[3] }
    foreach ($g in $plans) { powercfg -setacvalueindex $g SUB_PROCESSOR CPMINCORES 100 2>$null | Out-Null }
    powercfg -setactive SCHEME_CURRENT 2>$null | Out-Null
    Show-OK "CPU core parking disabled. Restart to fully apply."
}

function Invoke-BatteryReport {
    Clear-Host; Write-Host "`n  === BATTERY HEALTH REPORT ===" -ForegroundColor Cyan
    $rep = "$env:USERPROFILE\Desktop\BatteryReport.html"
    Show-INF "Generating report..."
    powercfg /batteryreport /output $rep 2>$null | Out-Null
    if (Test-Path $rep) { Show-OK "Report saved to Desktop: BatteryReport.html"; Invoke-Item $rep }
    else                { Show-ERR "No battery detected on this device." }
}

function Invoke-DeepClean {
    Clear-Host; Write-Host "`n  === DEEP SYSTEM CLEANER ===" -ForegroundColor Cyan
    @($env:TEMP, "$env:WINDIR\Temp", "$env:WINDIR\Prefetch",
      "$env:LOCALAPPDATA\Microsoft\Windows\Explorer",
      "$env:LOCALAPPDATA\D3DSCache", "$env:LOCALAPPDATA\Temp") | ForEach-Object { Invoke-SafeRemove $_ }
    Get-ChildItem "$env:WINDIR\*.bak" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Show-OK "System clean completed safely."
}

function Invoke-BrowserClean {
    Clear-Host; Write-Host "`n  === CLEAR BROWSER CACHES ===" -ForegroundColor Cyan
    Show-WRN "Close all browsers first!"
    $null = Read-Host "  Press Enter when browsers are closed"
    @{
        "Chrome"  = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
        "Edge"    = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
        "Firefox" = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"
        "Brave"   = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache"
        "Opera"   = "$env:APPDATA\Opera Software\Opera Stable\Cache"
    }.GetEnumerator() | ForEach-Object {
        Write-Host "  [+] $($_.Key)..." -ForegroundColor Cyan -NoNewline
        if (Test-Path $_.Value) {
            Get-ChildItem $_.Value -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host " [OK]" -ForegroundColor Green
        } else { Write-Host " [Not installed]" -ForegroundColor DarkGray }
    }
    Show-OK "All installed browser caches cleared."
}

function Invoke-CleanUpdateCache {
    Clear-Host; Write-Host "`n  === CLEAN WINDOWS UPDATE CACHE ===" -ForegroundColor Cyan
    Show-INF "Stopping update services..."
    Stop-Service wuauserv, bits -Force -ErrorAction SilentlyContinue
    Show-INF "Deleting download cache (installed updates safe)..."
    Invoke-SafeRemove "C:\Windows\SoftwareDistribution\Download"
    Show-INF "Restarting services..."
    Start-Service wuauserv, bits -ErrorAction SilentlyContinue
    Show-OK "Windows Update download cache cleared."
}

function Invoke-RemoveOldWindows {
    if (-not (Confirm-Action "Remove Windows.old? You CANNOT roll back to old Windows after this!")) { return }
    Clear-Host; Write-Host "`n  === REMOVE WINDOWS.OLD ===" -ForegroundColor Cyan
    Make-RestorePoint "Before removing Windows.old"
    if (Test-Path "C:\Windows.old") {
        takeown /f "C:\Windows.old" /r /d y 2>$null | Out-Null
        icacls "C:\Windows.old" /grant administrators:F /t 2>$null | Out-Null
        Remove-Item "C:\Windows.old" -Recurse -Force -ErrorAction SilentlyContinue
        Show-OK "Windows.old removed!"
    } else { Show-WRN "Windows.old not found on this system." }
}

function Invoke-EmptyBin {
    Clear-Host; Write-Host "`n  === EMPTY RECYCLE BIN ===" -ForegroundColor Cyan
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue; Show-OK "Recycle Bin emptied."
    Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db"  -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Show-OK "Thumbnail + icon cache cleared."
}

function Invoke-ClearEventLogs {
    if (-not (Confirm-Action "Clear ALL Windows Event Logs?")) { return }
    Clear-Host; Write-Host "`n  === CLEAR EVENT LOGS ===" -ForegroundColor Cyan
    Show-INF "Clearing logs..."
    $count = 0
    wevtutil.exe el 2>$null | ForEach-Object { wevtutil.exe cl "$_" 2>$null; $count++ }
    Show-OK "Cleared $count event logs."
}

function Invoke-DiskCleanup {
    Clear-Host; Write-Host "`n  === DISK CLEANUP ===" -ForegroundColor Cyan
    Show-INF "Launching Windows Disk Cleanup (cleanmgr)..."
    Start-Process "cleanmgr.exe" -ErrorAction SilentlyContinue
    Show-OK "Disk Cleanup window opened."
}

function Invoke-BrokenShortcuts {
    Clear-Host; Write-Host "`n  === BROKEN SHORTCUT FINDER & FIXER ===" -ForegroundColor Cyan
    $shortcutPaths = @(
        "C:\ProgramData\Microsoft\Windows\Start Menu",
        "$env:APPDATA\Microsoft\Windows\Start Menu",
        "$env:USERPROFILE\Desktop",
        "C:\Users\Public\Desktop"
    )
    $shell = New-Object -ComObject WScript.Shell -ErrorAction SilentlyContinue
    $found = 0
    foreach ($path in $shortcutPaths) {
        if (-not (Test-Path $path)) { continue }
        Write-Host "`n  Scanning: $path" -ForegroundColor Cyan
        Get-ChildItem -Path $path -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $target = $shell.CreateShortcut($_.FullName).TargetPath
                if ($target -and $target -notmatch '^shell:|^::{' -and -not (Test-Path $target)) {
                    Write-Host "  [BROKEN] $($_.FullName)" -ForegroundColor Yellow
                    Write-Host "           Target missing: $target" -ForegroundColor DarkGray
                    $del = Read-Host "  Delete this broken shortcut? (Y/N)"
                    if ($del -match '^[Yy]$') {
                        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                        Show-OK "Deleted: $($_.Name)"
                    }
                    $found++
                }
            } catch { }
        }
    }
    if ($found -eq 0) { Show-OK "No broken shortcuts found." }
    else { Show-WRN "Processed $found broken shortcuts." }
}

function Invoke-SfcVerifyOnly {
    Clear-Host; Write-Host "`n  === SFC VERIFY ONLY (Read-Only Scan) ===" -ForegroundColor Cyan
    Show-INF "Scanning for integrity violations without making changes..."
    Show-WRN "This may take several minutes."
    sfc /verifyonly
    if ($LASTEXITCODE -eq 0) { Show-OK "SFC VerifyOnly: No integrity violations found." }
    else { Show-WRN "SFC VerifyOnly found violations (code $LASTEXITCODE). Run SFC /scannow to repair." }
}

function Invoke-SfcScannow {
    Clear-Host; Write-Host "`n  === SFC REPAIR (/scannow) ===" -ForegroundColor Cyan
    Show-WRN "This may take 10-15 minutes. Do NOT close this window!"
    sfc /scannow
    if ($LASTEXITCODE -eq 0) { Show-OK "SFC: No integrity violations found." }
    else { Show-WRN "SFC finished with code $LASTEXITCODE. Restart and run again if needed." }
}

function Invoke-DismCheckHealth {
    Clear-Host; Write-Host "`n  === DISM CheckHealth (Fast Check) ===" -ForegroundColor Cyan
    Show-INF "Checking if the image is flagged as corrupted (no repair)..."
    DISM /Online /Cleanup-Image /CheckHealth
    if ($LASTEXITCODE -eq 0) { Show-OK "DISM CheckHealth: Image is healthy." }
    else { Show-WRN "Image may be flagged. Run ScanHealth or RestoreHealth." }
}

function Invoke-DismScanHealth {
    Clear-Host; Write-Host "`n  === DISM ScanHealth (Deep Scan) ===" -ForegroundColor Cyan
    Show-WRN "This may take 5-10 minutes. No changes will be made."
    DISM /Online /Cleanup-Image /ScanHealth
    if ($LASTEXITCODE -eq 0) { Show-OK "DISM ScanHealth: No corruption detected." }
    else { Show-WRN "Corruption detected (code $LASTEXITCODE). Run RestoreHealth to fix." }
}

function Invoke-DismRestoreHealth {
    Clear-Host; Write-Host "`n  === DISM RestoreHealth (Full Repair) ===" -ForegroundColor Cyan
    Show-WRN "This may take 10-20 minutes. Requires internet. Do NOT close!"
    Write-Host ""
    Write-Host "  [1] DISM /RestoreHealth          (classic, shows live progress)" -ForegroundColor Cyan
    Write-Host "  [2] Repair-WindowsImage          (PowerShell native, structured output)" -ForegroundColor Cyan
    Write-Host "  [3] Both methods (most thorough)" -ForegroundColor Green
    Write-Host ""
    $dc = Read-Host "  Select method (1/2/3, Enter=1)"
    if ($dc -eq '') { $dc = '1' }
    if ($dc -in @('1','3')) {
        Show-INF "Running DISM /Online /Cleanup-Image /RestoreHealth..."
        DISM /Online /Cleanup-Image /RestoreHealth
        if ($LASTEXITCODE -eq 0) { Show-OK "DISM RestoreHealth: Completed successfully." }
        else { Show-WRN "DISM exit code: $LASTEXITCODE" }
    }
    if ($dc -in @('2','3')) {
        Show-INF "Running Repair-WindowsImage -Online -RestoreHealth..."
        try {
            $result = Repair-WindowsImage -Online -RestoreHealth -ErrorAction Stop
            Write-Host "  ImageHealthState : $($result.ImageHealthState)" -ForegroundColor White
            if ($result.ImageHealthState -eq 'Healthy') { Show-OK "Repair-WindowsImage: Image is Healthy." }
            else { Show-WRN "ImageHealthState: $($result.ImageHealthState). Further repair may be needed." }
        } catch { Show-WRN "Repair-WindowsImage error: $_" }
    }
    Show-Sep
    Show-OK "Done. Run SFC Repair (tool 18) next for best results."
}

function Invoke-DismComponentCleanup {
    Clear-Host; Write-Host "`n  === DISM Component Store Cleanup ===" -ForegroundColor Cyan
    Show-INF "Cleaning up superseded components (frees WinSxS space)..."
    Show-WRN "This may take several minutes."
    DISM /Online /Cleanup-Image /StartComponentCleanup
    if ($LASTEXITCODE -eq 0) { Show-OK "Component cleanup completed. WinSxS folder reduced." }
    else { Show-WRN "Finished with code $LASTEXITCODE." }
}

function Invoke-RepairDisk {
    if (-not (Confirm-Action "Schedule CHKDSK on C: at next restart?")) { return }
    Clear-Host; Write-Host "`n  === CHECK DISK (CHKDSK C:) ===" -ForegroundColor Cyan
    Show-WRN "Type Y when prompted to schedule at next restart."
    chkdsk C: /f /r
    Show-OK "Disk check scheduled. Restart your PC now."
    Write-Log "CHKDSK scheduled on C:"
}

function Invoke-FixUpdate {
    Clear-Host; Write-Host "`n  === FIX WINDOWS UPDATE SERVICES ===" -ForegroundColor Cyan
    $svcs = @("wuauserv","cryptSvc","bits","msiserver","appidsvc","usosvc","trustedinstaller")
    Show-INF "Stopping update services..."
    foreach ($s in $svcs) { Stop-Service $s -Force -ErrorAction SilentlyContinue; Write-Host "  [+] Stopped: $s" -ForegroundColor DarkGray }
    Show-INF "Removing corrupted cache..."
    @("C:\Windows\SoftwareDistribution.old","C:\Windows\System32\catroot2.old") | ForEach-Object {
        if (Test-Path $_) { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
    }
    if (Test-Path "C:\Windows\SoftwareDistribution") { Rename-Item "C:\Windows\SoftwareDistribution" "SoftwareDistribution.old" -ErrorAction SilentlyContinue }
    if (Test-Path "C:\Windows\System32\catroot2")    { Rename-Item "C:\Windows\System32\catroot2"    "catroot2.old"             -ErrorAction SilentlyContinue }
    Show-INF "Re-registering update DLLs..."
    @("wuapi.dll","wuaueng.dll","wups.dll","wups2.dll","qmgr.dll","qmgrprxy.dll") | ForEach-Object { regsvr32 /s $_ 2>$null | Out-Null }
    Show-INF "Restarting update services..."
    foreach ($s in @("wuauserv","cryptSvc","bits","msiserver")) { Start-Service $s -ErrorAction SilentlyContinue; Write-Host "  [+] Started: $s" -ForegroundColor DarkGray }
    Show-OK "Windows Update reset! Go to Settings > Windows Update."
}

function Invoke-FixStore {
    Clear-Host; Write-Host "`n  === FIX WINDOWS STORE & APPS ===" -ForegroundColor Cyan
    Show-INF "Resetting Windows Store cache..."
    wsreset.exe
    Show-INF "Re-registering all built-in apps (may take a moment)..."
    Get-AppXPackage -AllUsers -ErrorAction SilentlyContinue | ForEach-Object {
        Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue
    }
    Show-OK "Windows Store and apps repaired. Restart if issues remain."
}

function Invoke-FixSearch {
    Clear-Host; Write-Host "`n  === FIX WINDOWS SEARCH ===" -ForegroundColor Cyan
    Stop-Service "Windows Search" -Force -ErrorAction SilentlyContinue
    Show-INF "Deleting old search index..."
    $idxPath = "C:\ProgramData\Microsoft\Search\Data\Applications\Windows"
    if (Test-Path $idxPath) { Get-ChildItem $idxPath -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue }
    Start-Service "Windows Search" -ErrorAction SilentlyContinue
    Set-Service "wsearch" -StartupType Automatic -ErrorAction SilentlyContinue
    Show-OK "Search index is rebuilding in the background."
}

function Invoke-FixAudio {
    Clear-Host; Write-Host "`n  === FIX WINDOWS AUDIO ===" -ForegroundColor Cyan
    foreach ($s in @("AudioSrv","AudioEndpointBuilder")) {
        Restart-Service $s -Force -ErrorAction SilentlyContinue
        Set-Service    $s -StartupType Automatic -ErrorAction SilentlyContinue
        Show-OK "$s restarted."
    }
    Start-Process "ms-settings:sound" -ErrorAction SilentlyContinue
    Show-OK "Audio services restarted. Sound settings opened."
}

function Invoke-FixTime {
    Clear-Host; Write-Host "`n  === FIX WINDOWS TIME SYNC ===" -ForegroundColor Cyan
    Stop-Service w32time -Force -ErrorAction SilentlyContinue
    w32tm /unregister 2>$null | Out-Null; w32tm /register 2>$null | Out-Null
    Start-Service w32time -ErrorAction SilentlyContinue
    w32tm /config /manualpeerlist:"time.windows.com" /syncfromflags:manual /reliable:YES /update 2>$null | Out-Null
    w32tm /resync /force 2>$null | Out-Null
    Show-OK "Windows time sync completed."
}

function Invoke-ResetFirewall {
    if (-not (Confirm-Action "Reset ALL custom firewall rules to Windows defaults?")) { return }
    Clear-Host; Write-Host "`n  === RESET WINDOWS FIREWALL ===" -ForegroundColor Cyan
    netsh advfirewall reset 2>$null | Out-Null
    netsh advfirewall set allprofiles state on 2>$null | Out-Null
    Show-OK "Firewall reset and enabled on all profiles."
}

function Invoke-RebuildBCD {
    Clear-Host
    Write-Host "`n  === BOOT REPAIR & BCD MANAGER ===" -ForegroundColor Cyan
    Write-Host "  Use ONLY if you have boot or startup problems." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   [1] Full BCD Rebuild  (bootrec /fixmbr + /fixboot + /rebuildbcd)" -ForegroundColor Magenta
    Write-Host "   [2] Repair UEFI Boot Files  (bcdboot - recommended for UEFI systems)" -ForegroundColor Cyan
    Write-Host "   [3] Both - Full repair  (BCD rebuild + bcdboot UEFI)" -ForegroundColor Green
    Write-Host "   [4] Show current BCD entries  (bcdedit)" -ForegroundColor White
    Write-Host "   [0] Back" -ForegroundColor DarkGray
    Write-Host ""
    $bc = Read-Host "  Select"
    if ($bc -eq '0') { return }

    # Detect Windows drive automatically
    $winDrive = ($env:WINDIR).Substring(0,2)   # e.g. "C:"

    switch ($bc) {
        '1' {
            if (-not (Confirm-Action "Run full BCD rebuild? (bootrec /fixmbr, /fixboot, /rebuildbcd)")) { return }
            Make-RestorePoint "Before BCD Rebuild"
            Show-INF "Step 1/4 - bootrec /fixmbr"
            bootrec /fixmbr
            Show-INF "Step 2/4 - bootrec /fixboot"
            bootrec /fixboot
            Show-INF "Step 3/4 - bootrec /scanos"
            bootrec /scanos
            Show-INF "Step 4/4 - bootrec /rebuildbcd"
            bootrec /rebuildbcd
            Show-OK "BCD rebuild completed. Restart your PC."
        }
        '2' {
            if (-not (Confirm-Action "Repair UEFI boot files using bcdboot on drive ${winDrive}?")) { return }
            Make-RestorePoint "Before bcdboot UEFI repair"
            Show-INF "Running bcdboot on Windows at ${winDrive}\Windows (UEFI mode)..."
            $result = bcdboot "${winDrive}\Windows" /f UEFI 2>&1
            $result | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            if ($LASTEXITCODE -eq 0) {
                Show-OK "bcdboot UEFI repair successful."
                Show-WRN "Restart your PC now to verify boot."
            } else {
                Show-WRN "bcdboot exited with code $LASTEXITCODE."
                Show-INF "If this failed, try option [3] or run from Windows Recovery (WinRE)."
            }
            Write-Log "bcdboot UEFI repair exit: $LASTEXITCODE"
        }
        '3' {
            if (-not (Confirm-Action "Run FULL boot repair (bootrec + bcdboot UEFI) on drive ${winDrive}?")) { return }
            Make-RestorePoint "Before Full Boot Repair"
            Show-INF "Step 1/5 - bootrec /fixmbr"
            bootrec /fixmbr
            Show-INF "Step 2/5 - bootrec /fixboot"
            bootrec /fixboot
            Show-INF "Step 3/5 - bootrec /scanos"
            bootrec /scanos
            Show-INF "Step 4/5 - bootrec /rebuildbcd"
            bootrec /rebuildbcd
            Show-INF "Step 5/5 - bcdboot ${winDrive}\Windows /f UEFI"
            $result = bcdboot "${winDrive}\Windows" /f UEFI 2>&1
            $result | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
            if ($LASTEXITCODE -eq 0) { Show-OK "Full boot repair completed successfully." }
            else { Show-WRN "bcdboot step finished with code $LASTEXITCODE. Check output above." }
            Show-OK "Restart your PC now."
            Write-Log "Full boot repair completed. bcdboot exit: $LASTEXITCODE"
        }
        '4' {
            Write-Host "`n  --- Current BCD Entries (bcdedit) ---" -ForegroundColor Yellow
            bcdedit 2>&1 | Out-String | Write-Host -ForegroundColor White
        }
        default { Show-WRN "Invalid selection." }
    }
}

function Invoke-NetworkReset {
    if (-not (Confirm-Action "Full network reset? Internet disconnects briefly.")) { return }
    Clear-Host; Write-Host "`n  === FULL NETWORK RESET ===" -ForegroundColor Cyan
    @(
        @{ D="Flush DNS";         C={ Clear-DnsClientCache } },
        @{ D="Register DNS";      C={ ipconfig /registerdns 2>$null | Out-Null } },
        @{ D="Release IP";        C={ ipconfig /release     2>$null | Out-Null } },
        @{ D="Renew IP";          C={ ipconfig /renew       2>$null | Out-Null } },
        @{ D="Reset Winsock";     C={ netsh winsock reset   2>$null | Out-Null } },
        @{ D="Reset TCP/IP";      C={ netsh int ip reset    2>$null | Out-Null } },
        @{ D="Reset IPv4";        C={ netsh int ipv4 reset  2>$null | Out-Null } },
        @{ D="Reset IPv6";        C={ netsh int ipv6 reset  2>$null | Out-Null } },
        @{ D="Clear ARP cache";   C={ arp -d "*" 2>$null    | Out-Null } },
        @{ D="Reset Proxy";       C={ netsh winhttp reset proxy 2>$null | Out-Null } }
    ) | ForEach-Object { Show-INF $_.D; & $_.C; Show-OK $_.D }
    Show-OK "Full network reset done! Restart your PC."
}

function Invoke-SetGoogleDNS {
    Clear-Host; Write-Host "`n  === SET GOOGLE DNS ===" -ForegroundColor Cyan
    Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
        try {
            Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses "8.8.8.8","8.8.4.4","2001:4860:4860::8888","2001:4860:4860::8844" -ErrorAction Stop
            Show-OK "$($_.Name): Google DNS set."
        } catch { Show-WRN "$($_.Name): $_" }
    }
    Clear-DnsClientCache
    Show-OK "Google DNS configured. Run Network Diagnostics to verify."
}

function Invoke-SetCloudflareDNS {
    Clear-Host; Write-Host "`n  === SET CLOUDFLARE DNS ===" -ForegroundColor Cyan
    Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
        try {
            Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses "1.1.1.1","1.0.0.1","2606:4700:4700::1111","2606:4700:4700::1001" -ErrorAction Stop
            Show-OK "$($_.Name): Cloudflare DNS set."
        } catch { Show-WRN "$($_.Name): $_" }
    }
    Clear-DnsClientCache; Show-OK "Cloudflare DNS configured."
}

function Invoke-ResetDnsAuto {
    Clear-Host; Write-Host "`n  === RESET DNS TO AUTOMATIC (DHCP) ===" -ForegroundColor Cyan
    Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
        try {
            Set-DnsClientServerAddress -InterfaceAlias $_.Name -ResetServerAddresses -ErrorAction Stop
            Show-OK "$($_.Name): DNS set to automatic."
        } catch { Show-WRN "$($_.Name): $_" }
    }
    Clear-DnsClientCache; Show-OK "DNS reset to DHCP on all adapters."
}

function Invoke-NetDiag {
    Clear-Host; Write-Host "`n  === NETWORK DIAGNOSTICS ===" -ForegroundColor Cyan
    Write-Host "`n  --- Active Adapters ---" -ForegroundColor Yellow
    Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Format-Table Name,InterfaceDescription,LinkSpeed -AutoSize | Out-String | Write-Host
    Write-Host "  --- IP Addresses ---" -ForegroundColor Yellow
    Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" -and $_.IPAddress -notmatch "^127" } | Format-Table InterfaceAlias,IPAddress,PrefixLength -AutoSize | Out-String | Write-Host
    Write-Host "  --- DNS Servers ---" -ForegroundColor Yellow
    Get-DnsClientServerAddress | Where-Object { $_.ServerAddresses } | Format-Table InterfaceAlias,ServerAddresses -AutoSize | Out-String | Write-Host
    Write-Host "  --- Ping Tests ---" -ForegroundColor Yellow
    foreach ($t in @("8.8.8.8","1.1.1.1","google.com")) {
        $p = Test-Connection $t -Count 2 -ErrorAction SilentlyContinue
        if ($p) { $avg = [int](($p | Measure-Object -Property ResponseTime -Average).Average); Write-Host "  [OK]   $t  -> ${avg}ms" -ForegroundColor Green }
        else    { Write-Host "  [FAIL] $t  -> No response" -ForegroundColor Red }
    }
    Write-Host "`n  --- Active Connections (ESTABLISHED) ---" -ForegroundColor Yellow
    netstat -ano 2>$null | Select-String "ESTABLISHED" | Select-Object -First 20 | Out-String | Write-Host
}

function Invoke-IpconfigAll {
    Clear-Host; Write-Host "`n  === FULL NETWORK INFO (ipconfig /all) ===" -ForegroundColor Cyan
    ipconfig /all
}

function Invoke-OpenNetworkConnections {
    Clear-Host; Write-Host "`n  === NETWORK CONNECTIONS ===" -ForegroundColor Cyan
    Show-INF "Opening Network Connections (ncpa.cpl)..."
    Start-Process "ncpa.cpl" -ErrorAction SilentlyContinue
    Show-OK "Network Connections window opened."
}

function Invoke-ResetProxy {
    Clear-Host; Write-Host "`n  === RESET PROXY SETTINGS ===" -ForegroundColor Cyan
    netsh winhttp reset proxy 2>$null | Out-Null
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /f 2>$null | Out-Null
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f 2>$null | Out-Null
    Show-OK "All proxy settings cleared."
}

function Invoke-WifiProfiles {
    Clear-Host; Write-Host "`n  === WIFI PROFILES ===" -ForegroundColor Cyan
    netsh wlan show profiles 2>$null | Out-String | Write-Host
}

function Invoke-FirewallManager {
    while ($true) {
        Clear-Host
        Write-Host "`n  === FIREWALL MANAGER ===" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   [1] Enable Firewall (All Profiles)"       -ForegroundColor Green
        Write-Host "   [2] Disable Firewall (All Profiles)"      -ForegroundColor Red
        Write-Host "   [3] Show Firewall Status"                 -ForegroundColor White
        Write-Host "   [4] List Enabled Firewall Rules"          -ForegroundColor White
        Write-Host "   [5] Block Inbound on Public Profile"      -ForegroundColor Yellow
        Write-Host "   [6] Export Rules to Desktop (CSV)"        -ForegroundColor Cyan
        Write-Host "   [7] Reset Firewall to Defaults"           -ForegroundColor Red
        Write-Host "   [0] Back to Main Menu"                    -ForegroundColor DarkGray
        Write-Host ""
        $fc = Read-Host "  Select"
        switch ($fc) {
            '1' { netsh advfirewall set allprofiles state on  2>$null | Out-Null; Show-OK "Firewall ENABLED on all profiles." }
            '2' {
                if (Confirm-Action "Disable firewall on ALL profiles?") {
                    netsh advfirewall set allprofiles state off 2>$null | Out-Null; Show-OK "Firewall DISABLED."
                }
            }
            '3' { netsh advfirewall show allprofiles 2>$null | Out-String | Write-Host }
            '4' {
                Write-Host "`n  Enabled Firewall Rules:" -ForegroundColor Yellow
                Get-NetFirewallRule | Where-Object { $_.Enabled -eq $true } | Select-Object DisplayName,Direction,Action,Profile | Format-Table -AutoSize | Out-String | Write-Host
            }
            '5' { netsh advfirewall set publicprofile firewallpolicy blockinbound,allowoutbound 2>$null | Out-Null; Show-OK "Public profile: Inbound BLOCKED." }
            '6' {
                $f = "$env:USERPROFILE\Desktop\FirewallRules_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
                Get-NetFirewallRule | Export-Csv $f -NoTypeInformation -ErrorAction SilentlyContinue
                Show-OK "Firewall rules exported to Desktop: $(Split-Path $f -Leaf)"
            }
            '7' {
                if (Confirm-Action "Reset ALL firewall rules to Windows defaults?") {
                    netsh advfirewall reset 2>$null | Out-Null
                    netsh advfirewall set allprofiles state on 2>$null | Out-Null
                    Show-OK "Firewall reset to defaults and re-enabled."
                }
            }
            '0' { return }
            default { Show-WRN "Invalid selection." }
        }
        if ($fc -ne '0') { Wait-Enter }
    }
}

function Invoke-MalwareScan {
    Clear-Host; Write-Host "`n  === MALWARE QUICK SCAN ===" -ForegroundColor Cyan
    $mpCmd = "C:\Program Files\Windows Defender\MpCmdRun.exe"
    if (-not (Test-Path $mpCmd)) { Show-ERR "Windows Defender not found."; return }
    Show-INF "Updating virus definitions..."
    Start-Process $mpCmd -ArgumentList "-SignatureUpdate" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
    Show-OK "Definitions updated."
    Show-INF "Running Quick Scan (this takes a few minutes)..."
    $r = Start-Process $mpCmd -ArgumentList "-Scan -ScanType 1" -Wait -PassThru -ErrorAction SilentlyContinue
    if ($r.ExitCode -eq 0) { Show-OK "Scan complete. No threats found." }
    else                   { Show-WRN "Scan finished with code $($r.ExitCode). Check Windows Security for details." }
    Start-Process "windowsdefender:" -ErrorAction SilentlyContinue
    Write-Log "Malware scan exit: $($r.ExitCode)"
}

function Invoke-DisableTelemetry {
    if (-not (Confirm-Action "Disable Windows telemetry and data collection services?")) { return }
    Clear-Host; Write-Host "`n  === DISABLE TELEMETRY & TRACKING ===" -ForegroundColor Cyan
    @(
        @{ P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection";                         N="AllowTelemetry";                      V=0 },
        @{ P="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection";          N="AllowTelemetry";                      V=0 },
        @{ P="HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo";                  N="Enabled";                             V=0 },
        @{ P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System";                                 N="EnableActivityFeed";                  V=0 },
        @{ P="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System";                                 N="PublishUserActivities";               V=0 },
        @{ P="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager";           N="SubscribedContent-338388Enabled";     V=0 },
        @{ P="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager";           N="SubscribedContent-353694Enabled";     V=0 }
    ) | ForEach-Object {
        try {
            if (-not (Test-Path $_.P)) { New-Item -Path $_.P -Force | Out-Null }
            Set-ItemProperty -Path $_.P -Name $_.N -Value $_.V -Type DWord -ErrorAction Stop
            Write-Host "  [OK] $($_.N)" -ForegroundColor Green
        } catch { Write-Host "  [--] Skipped: $($_.N)" -ForegroundColor DarkGray }
    }
    foreach ($svc in @("DiagTrack","dmwappushsvc")) {
        Stop-Service  $svc -Force -ErrorAction SilentlyContinue
        Set-Service   $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Show-OK "Disabled: $svc"
    }
    Show-OK "Telemetry disabled. Restart to fully apply."
}

function Invoke-StartupAnalyzer {
    Clear-Host; Write-Host "`n  === STARTUP ANALYZER ===" -ForegroundColor Cyan
    $suspPatterns = @("temp","appdata.*\.exe","cmd.*hidden","powershell.*-e","-enc","-w hidden","\.vbs$","\.js$")
    Write-Host "`n  --- User Startup (HKCU) ---" -ForegroundColor Yellow
    $hkcu = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
    if ($hkcu) {
        $hkcu.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" } | ForEach-Object {
            $susp = $suspPatterns | Where-Object { $_.Value -match $_ }
            $col  = if ($susp) { "Red" } else { "White" }
            $tag  = if ($susp) { "  [!! SUSPICIOUS]" } else { "" }
            Write-Host "  $($_.Name): $($_.Value)$tag" -ForegroundColor $col
        }
    }
    Write-Host "`n  --- System Startup (HKLM) ---" -ForegroundColor Yellow
    $hklm = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue
    if ($hklm) {
        $hklm.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" } | ForEach-Object {
            $susp = $suspPatterns | Where-Object { $_.Value -match $_ }
            $col  = if ($susp) { "Red" } else { "White" }
            $tag  = if ($susp) { "  [!! SUSPICIOUS]" } else { "" }
            Write-Host "  $($_.Name): $($_.Value)$tag" -ForegroundColor $col
        }
    }
    Write-Host "`n  --- User-Created Scheduled Tasks ---" -ForegroundColor Yellow
    Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskPath -notmatch "\\Microsoft\\" } |
        Format-Table TaskName,State,TaskPath -AutoSize | Out-String | Write-Host
    Write-Host "  [i] Red = possibly suspicious. Use Task Manager > Startup to disable." -ForegroundColor Yellow
}

function Invoke-SuspiciousProcs {
    Clear-Host; Write-Host "`n  === SUSPICIOUS PROCESS CHECK ===" -ForegroundColor Cyan
    Write-Host "`n  --- Processes from Temp / AppData ---" -ForegroundColor Yellow
    $fromTemp = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.Path -match "temp|appdata" }
    if ($fromTemp) { $fromTemp | Format-Table Name,Id,Path -AutoSize | Out-String | Write-Host -ForegroundColor Red; Show-WRN "Review these carefully!" }
    else           { Show-OK "No processes running from Temp/AppData." }
    Write-Host "`n  --- Processes with no file path (possible injection) ---" -ForegroundColor Yellow
    $noPaths = Get-Process -ErrorAction SilentlyContinue | Where-Object {
        (-not $_.Path) -and ($_.Name -notmatch "^(System|Idle|Registry|smss|csrss|wininit|winlogon|svchost|lsass|services|fontdrvhost|dwm)$")
    }
    if ($noPaths) { $noPaths | Format-Table Name,Id -AutoSize | Out-String | Write-Host -ForegroundColor Yellow }
    else          { Show-OK "No injected processes detected." }
}

function Invoke-KillUnsignedProcs {
    if (-not (Confirm-Action "Kill unsigned processes running from Temp/AppData?")) { return }
    Clear-Host; Write-Host "`n  === KILL UNSIGNED TEMP PROCESSES ===" -ForegroundColor Cyan
    $procs  = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.ExecutablePath -match "temp|appdata" }
    $killed = 0
    foreach ($p in $procs) {
        if ($p.ExecutablePath) {
            $sig = Get-AuthenticodeSignature $p.ExecutablePath -ErrorAction SilentlyContinue
            if ($sig -and $sig.Status -ne "Valid") {
                Write-Host "  [KILL] $($p.Name) PID:$($p.ProcessId) | $($p.ExecutablePath)" -ForegroundColor Red
                Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
                Write-Log "Killed unsigned: $($p.Name) PID:$($p.ProcessId)" "WARN"
                $killed++
            }
        }
    }
    if ($killed -eq 0) { Show-OK "No unsigned threats found in Temp/AppData." }
    else               { Show-WRN "Killed $killed unsigned process(es). Run malware scan to confirm clean." }
}

function Invoke-EnableSecurity {
    Clear-Host; Write-Host "`n  === ENABLE FIREWALL + DEFENDER ===" -ForegroundColor Cyan
    netsh advfirewall set allprofiles state on 2>$null | Out-Null; Show-OK "Firewall enabled on all profiles."
    Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue; Show-OK "Real-Time Protection enabled."
}

function Invoke-CertManager {
    Clear-Host; Write-Host "`n  === CERTIFICATE MANAGER ===" -ForegroundColor Cyan
    Show-INF "Opening Certificate Manager (certmgr.msc)..."
    Start-Process "certmgr.msc" -ErrorAction SilentlyContinue
    Show-OK "Certificate Manager opened."
}

function Invoke-LocalSecurityPolicy {
    Clear-Host; Write-Host "`n  === LOCAL SECURITY POLICY ===" -ForegroundColor Cyan
    Show-INF "Opening Local Security Policy (secpol.msc)..."
    Start-Process "secpol.msc" -ErrorAction SilentlyContinue
    Show-OK "Local Security Policy opened."
}

function Invoke-DriverVerifier {
    Clear-Host; Write-Host "`n  === DRIVER VERIFIER ===" -ForegroundColor Cyan
    Write-Host "`n  Driver Verifier helps detect faulty kernel drivers." -ForegroundColor White
    Write-Host "  WARNING: Enabling verification on wrong drivers can cause BSODs." -ForegroundColor Red
    Write-Host ""
    Write-Host "   [1] Open Driver Verifier GUI (verifier)"   -ForegroundColor Yellow
    Write-Host "   [2] Show current verification settings"    -ForegroundColor White
    Write-Host "   [3] Reset / Disable all verifications"     -ForegroundColor Green
    Write-Host "   [0] Back" -ForegroundColor DarkGray
    Write-Host ""
    $vc = Read-Host "  Select"
    switch ($vc) {
        '1' { Start-Process "verifier" -ErrorAction SilentlyContinue; Show-OK "Driver Verifier GUI opened." }
        '2' { verifier /query 2>$null | Out-String | Write-Host }
        '3' {
            if (Confirm-Action "Reset and disable all driver verifications?") {
                verifier /reset 2>$null | Out-Null
                Show-OK "Driver Verifier reset. Restart your PC."
            }
        }
        '0' { return }
        default { Show-WRN "Invalid selection." }
    }
}

function Invoke-LocalUsersGroups {
    Clear-Host; Write-Host "`n  === LOCAL USERS & GROUPS ===" -ForegroundColor Cyan
    Show-INF "Opening Local Users and Groups Manager (lusrmgr.msc)..."
    Start-Process "lusrmgr.msc" -ErrorAction SilentlyContinue
    Show-OK "Local Users and Groups opened."
}

function Invoke-SysInfo {
    Clear-Host; Write-Host "`n  === FULL SYSTEM INFO REPORT ===" -ForegroundColor Cyan
    Show-INF "Collecting system information..."
    $wanted = @("Host Name","OS Name","OS Version","OS Architecture","System Type",
                "Total Physical Memory","Available Physical","Windows Directory","Boot Time")
    $info = systeminfo 2>$null
    $info | ForEach-Object { foreach ($w in $wanted) { if ($_ -match "^$w") { Write-Host "  $_" -ForegroundColor White } } }
    $rep = "$env:USERPROFILE\Desktop\SystemReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $info | Out-File $rep -Encoding UTF8
    Show-Sep; Show-OK "Full report saved to Desktop: $(Split-Path $rep -Leaf)"
}

function Invoke-CpuRamInfo {
    Clear-Host; Write-Host "`n  === CPU + MOTHERBOARD + RAM ===" -ForegroundColor Cyan
    Write-Host "`n  --- CPU ---" -ForegroundColor Yellow
    Get-CimInstance Win32_Processor | Format-List Name,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed,LoadPercentage | Out-String | Write-Host
    Write-Host "  --- Motherboard & BIOS ---" -ForegroundColor Yellow
    Get-CimInstance Win32_BaseBoard | Format-List Manufacturer,Product,SerialNumber | Out-String | Write-Host
    Get-CimInstance Win32_BIOS      | Format-List Manufacturer,Name,SMBIOSBIOSVersion,ReleaseDate | Out-String | Write-Host
    Write-Host "  --- RAM Summary ---" -ForegroundColor Yellow
    $total = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    $free  = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)
    Write-Host "  Total RAM: ${total} GB   |   Free: ${free} GB" -ForegroundColor Cyan
    Write-Host "`n  --- RAM Modules ---" -ForegroundColor Yellow
    Get-CimInstance Win32_PhysicalMemory | Format-Table BankLabel,Manufacturer,Capacity,Speed -AutoSize | Out-String | Write-Host
}

function Invoke-RamDetails {
    Clear-Host; Write-Host "`n  === RAM PHYSICAL MODULES (Get-CimInstance Win32_PhysicalMemory) ===" -ForegroundColor Cyan
    $modules = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue
    if ($modules) {
        $modules | ForEach-Object {
            $capGB = [math]::Round($_.Capacity / 1GB, 1)
            Write-Host ""
            Write-Host "  Slot        : $($_.BankLabel)" -ForegroundColor Yellow
            Write-Host "  Manufacturer: $($_.Manufacturer)"
            Write-Host "  Part Number : $($_.PartNumber)"
            Write-Host "  Capacity    : ${capGB} GB"
            Write-Host "  Speed       : $($_.Speed) MHz"
            Write-Host "  Type        : $($_.SMBIOSMemoryType)"
            Write-Host "  Form Factor : $($_.FormFactor)"
            Write-Host "  Serial      : $($_.SerialNumber)"
        }
        $total = [math]::Round(($modules | Measure-Object -Property Capacity -Sum).Sum / 1GB, 1)
        Write-Host "`n  Total Installed RAM: ${total} GB" -ForegroundColor Cyan
    } else { Show-WRN "Could not retrieve RAM module details." }
}

function Invoke-DiskHealth {
    Clear-Host; Write-Host "`n  === DISK HEALTH & SMART ===" -ForegroundColor Cyan

    # --- 1. Get-PhysicalDisk (modern, health status) ---
    Write-Host "`n  --- Physical Disks (Get-PhysicalDisk) ---" -ForegroundColor Yellow
    Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
        $sizeGB = [math]::Round($_.Size / 1GB, 0)
        $hcol   = if ($_.HealthStatus -eq "Healthy") { "Green" } else { "Red" }
        Write-Host "  $($_.FriendlyName)" -ForegroundColor Yellow
        Write-Host "    Type   : $($_.MediaType)"
        Write-Host "    Size   : ${sizeGB} GB"
        Write-Host "    Health : $($_.HealthStatus)" -ForegroundColor $hcol
        Write-Host "    Status : $($_.OperationalStatus)"
        Write-Host "    Serial : $($_.SerialNumber)"
    }

    # --- 2. Win32_DiskDrive via CimInstance (replaces old WMI, adds interface/firmware) ---
    Write-Host "`n  --- Drive Details (Get-CimInstance Win32_DiskDrive) ---" -ForegroundColor Yellow
    Get-CimInstance Win32_DiskDrive -ErrorAction SilentlyContinue | ForEach-Object {
        $sizeGB = [math]::Round($_.Size / 1GB, 1)
        Write-Host "  $($_.DeviceID) | $($_.Model) | ${sizeGB}GB | $($_.InterfaceType) | Firmware: $($_.FirmwareRevision) | Status: $($_.Status)"
    }

    # --- 3. SMART failure prediction via CimInstance (replaces old WMI namespace query) ---
    Write-Host "`n  --- SMART Failure Prediction (MSStorageDriver_FailurePredictStatus) ---" -ForegroundColor Yellow
    try {
        $smartData = Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction Stop
        if ($smartData) {
            foreach ($s in $smartData) {
                $col = if ($s.PredictFailure -eq $false) { "Green" } else { "Red" }
                $status = if ($s.PredictFailure -eq $false) { "No failure predicted (Healthy)" } else { "FAILURE PREDICTED - Backup NOW!" }
                Write-Host "  Instance : $($s.InstanceName)" -ForegroundColor White
                Write-Host "  SMART    : $status" -ForegroundColor $col
                Write-Host "  Reason   : $($s.Reason)" -ForegroundColor DarkGray
            }
        } else { Show-WRN "No SMART data returned (may not be supported on this hardware)." }
    } catch { Show-WRN "SMART query not supported on this system: $_" }

    # --- 4. Logical drives free space ---
    Write-Host "`n  --- Logical Drives ---" -ForegroundColor Yellow
    Get-CimInstance Win32_LogicalDisk | Where-Object { $_.Size -gt 0 } | ForEach-Object {
        $sizeGB = [math]::Round($_.Size     / 1GB, 1)
        $freeGB = [math]::Round($_.FreeSpace / 1GB, 1)
        $pct    = [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 0)
        $col    = if ($pct -gt 90) { "Red" } elseif ($pct -gt 75) { "Yellow" } else { "Green" }
        Write-Host "  $($_.DeviceID)  Total:${sizeGB}GB  Free:${freeGB}GB  Used:${pct}%" -ForegroundColor $col
    }
}

function Invoke-GpuInfo {
    Clear-Host; Write-Host "`n  === GPU & DRIVER DETAILS ===" -ForegroundColor Cyan
    Get-CimInstance Win32_VideoController | ForEach-Object {
        $vram = if ($_.AdapterRAM) { [math]::Round($_.AdapterRAM / 1GB, 1) } else { "N/A" }
        Write-Host "`n  $($_.Name)" -ForegroundColor Yellow
        Write-Host "  VRAM     : ${vram} GB"
        Write-Host "  Driver   : $($_.DriverVersion)"
        Write-Host "  Status   : $($_.Status)"
        Write-Host "  Date     : $($_.DriverDate)"
        Write-Host "  Resolution: $($_.CurrentHorizontalResolution) x $($_.CurrentVerticalResolution)"
    }
}

function Invoke-DriverCheck {
    Clear-Host; Write-Host "`n  === DRIVER ERROR CHECKER ===" -ForegroundColor Cyan
    Show-INF "Scanning all devices for errors..."
    $bad = Get-CimInstance Win32_PnPEntity -ErrorAction SilentlyContinue | Where-Object { $_.ConfigManagerErrorCode -ne 0 }
    if ($bad) {
        Write-Host "`n  --- Drivers with Errors ---" -ForegroundColor Red
        foreach ($d in $bad) {
            Write-Host "  [!!] $($d.Name)  |  Error Code: $($d.ConfigManagerErrorCode)" -ForegroundColor Red
            Write-Log "Driver error: $($d.Name) Code:$($d.ConfigManagerErrorCode)" "WARN"
        }
        Show-WRN "Open Device Manager to update/reinstall these drivers."
    } else { Show-OK "No driver errors found on this system." }
    Write-Host "`n  --- Installed Drivers (summary) ---" -ForegroundColor Yellow
    driverquery /fo csv 2>$null | ConvertFrom-Csv | Select-Object "Module Name","Type","Link Date" |
        Format-Table -AutoSize | Out-String | Write-Host
}

function Invoke-CheckActivation {
    Clear-Host; Write-Host "`n  === WINDOWS ACTIVATION STATUS ===" -ForegroundColor Cyan
    Write-Host ""

    # --- 1. Standard slmgr activation expiry ---
    Show-INF "Checking activation expiry (slmgr /xpr)..."
    cscript //nologo "$env:WINDIR\System32\slmgr.vbs" /xpr
    Write-Host ""

    # --- 2. License details ---
    Show-INF "License details (slmgr /dli)..."
    cscript //nologo "$env:WINDIR\System32\slmgr.vbs" /dli
    Write-Host ""

    # --- 3. Windows Install Date (CimInstance, clean method) ---
    Show-INF "Windows Installation Date..."
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $installDate = $os.InstallDate
        Write-Host "  Install Date : $installDate" -ForegroundColor White
        $upDays = [math]::Round(((Get-Date) - $installDate).TotalDays, 0)
        Write-Host "  Days Since Install: $upDays days" -ForegroundColor Cyan
    } catch { Show-WRN "Could not retrieve install date." }
    Write-Host ""

    # --- 4. OEM embedded product key from BIOS (CimInstance, replaces old WMI query) ---
    Show-INF "Checking for OEM embedded product key in BIOS (OA3xOriginalProductKey)..."
    try {
        $sls = Get-CimInstance -ClassName SoftwareLicensingService -ErrorAction Stop
        $oemKey = $sls.OA3xOriginalProductKey
        if ($oemKey -and $oemKey.Trim() -ne '') {
            Write-Host "  OEM Key Found : $oemKey" -ForegroundColor Green
            Write-Host "  [i] This is the original key embedded in your BIOS/UEFI." -ForegroundColor DarkGray
        } else {
            Write-Host "  OEM Key       : Not found (may be retail or volume license)" -ForegroundColor Yellow
        }
    } catch {
        Show-WRN "Could not query SoftwareLicensingService: $_"
    }
    Write-Host ""

    # --- 5. Current activation status via CimInstance ---
    Show-INF "Current activation status..."
    try {
        $sli = Get-CimInstance -ClassName SoftwareLicensingProduct -ErrorAction Stop |
            Where-Object { $_.Name -match "Windows" -and $_.LicenseStatus -ne 0 } |
            Select-Object -First 1
        if ($sli) {
            $statusMap = @{ 0="Unlicensed"; 1="Licensed"; 2="OOBGrace"; 3="OOTGrace"; 4="NonGenuineGrace"; 5="Notification"; 6="ExtendedGrace" }
            $statusText = $statusMap[[int]$sli.LicenseStatus]
            $col = if ($sli.LicenseStatus -eq 1) { "Green" } else { "Red" }
            Write-Host "  Activation    : $statusText" -ForegroundColor $col
            Write-Host "  Product Name  : $($sli.Name)" -ForegroundColor White
        }
    } catch { Show-WRN "Could not query license product status." }
}

function Invoke-UptimeServices {
    Clear-Host; Write-Host "`n  === UPTIME & SERVICES STATUS ===" -ForegroundColor Cyan
    $os     = Get-CimInstance Win32_OperatingSystem
    $boot   = $os.LastBootUpTime
    $uptime = (Get-Date) - $boot
    Write-Host "`n  Last Boot : $boot" -ForegroundColor White
    Write-Host "  Uptime    : $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m" -ForegroundColor Cyan
    Write-Host "`n  --- Critical Services ---" -ForegroundColor Yellow
    @("wuauserv","AudioSrv","Dhcp","Dnscache","W32Time","WinDefend","MpsSvc","LanmanWorkstation","BITS") | ForEach-Object {
        $svc = Get-Service $_ -ErrorAction SilentlyContinue
        if ($svc) {
            $col = if ($svc.Status -eq "Running") { "Green" } else { "Red" }
            Write-Host "  [$($svc.Status.ToString().PadRight(7))] $_" -ForegroundColor $col
        }
    }
}

function Invoke-RemoteDesktop {
    Clear-Host; Write-Host "`n  === REMOTE DESKTOP (mstsc) ===" -ForegroundColor Cyan
    Show-INF "Opening Remote Desktop Connection (mstsc)..."
    Start-Process "mstsc" -ErrorAction SilentlyContinue
    Show-OK "Remote Desktop Connection opened."
}

function Invoke-GroupPolicyEditor {
    Clear-Host; Write-Host "`n  === GROUP POLICY EDITOR ===" -ForegroundColor Cyan
    Show-INF "Opening Group Policy Editor (gpedit.msc)..."
    $gpedit = "$env:WINDIR\System32\gpedit.msc"
    if (Test-Path $gpedit) {
        Start-Process "gpedit.msc" -ErrorAction SilentlyContinue
        Show-OK "Group Policy Editor opened."
    } else {
        Show-ERR "gpedit.msc not found. This tool is not available on Windows Home editions."
        Show-WRN "Upgrade to Windows Pro/Enterprise to access Group Policy Editor."
    }
}

function Invoke-AppsFolder {
    Clear-Host; Write-Host "`n  === WINDOWS APPS FOLDER ===" -ForegroundColor Cyan
    Show-INF "Opening Windows Apps Folder..."
    Start-Process "explorer.exe" -ArgumentList "shell:AppsFolder" -ErrorAction SilentlyContinue
    Show-OK "Apps Folder opened in File Explorer."
}

function Invoke-FullMaintenance {
    if (-not (Confirm-Action "Run ALL safe maintenance tasks? This takes 20-40 minutes.")) { return }
    Clear-Host
    Write-Host "`n  +============================================================+" -ForegroundColor Green
    Write-Host "  |              FULL MAINTENANCE MODE                        |" -ForegroundColor Green
    Write-Host "  |  Do NOT close this window until finished!                 |" -ForegroundColor Yellow
    Write-Host "  +============================================================+" -ForegroundColor Green
    Write-Log "START: Full Maintenance"
    Make-RestorePoint "Before Full Maintenance"
    $steps = @(
        @{ N="1/12  Power Plans";        F={ Invoke-PowerPlans } },
        @{ N="2/12  Battery Alerts";     F={ Invoke-FixBattery } },
        @{ N="3/12  Deep System Clean";  F={ @($env:TEMP,"$env:WINDIR\Temp","$env:WINDIR\Prefetch","$env:LOCALAPPDATA\Microsoft\Windows\Explorer","$env:LOCALAPPDATA\D3DSCache") | ForEach-Object { Invoke-SafeRemove $_ } } },
        @{ N="4/12  Browser Caches";     F={ @("$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache","$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache","$env:LOCALAPPDATA\Mozilla\Firefox\Profiles") | ForEach-Object { Invoke-SafeRemove $_ } } },
        @{ N="5/12  Update Cache";       F={ Stop-Service wuauserv,bits -Force -ErrorAction SilentlyContinue; Invoke-SafeRemove "C:\Windows\SoftwareDistribution\Download"; Start-Service wuauserv,bits -ErrorAction SilentlyContinue } },
        @{ N="6/12  Time Sync";          F={ Stop-Service w32time -Force -EA SilentlyContinue; w32tm /unregister 2>$null | Out-Null; w32tm /register 2>$null | Out-Null; Start-Service w32time -EA SilentlyContinue; w32tm /resync /force 2>$null | Out-Null } },
        @{ N="7/12  Network Reset";      F={ Clear-DnsClientCache; netsh winsock reset 2>$null | Out-Null; netsh int ip reset 2>$null | Out-Null } },
        @{ N="8/12  Firewall Enable";    F={ netsh advfirewall set allprofiles state on 2>$null | Out-Null } },
        @{ N="9/12  Windows Update Svc"; F={ Stop-Service wuauserv,cryptSvc,bits,msiserver -Force -EA SilentlyContinue; if (Test-Path "C:\Windows\SoftwareDistribution") { Rename-Item "C:\Windows\SoftwareDistribution" "SoftwareDistribution.old" -EA SilentlyContinue }; Start-Service wuauserv,cryptSvc,bits,msiserver -EA SilentlyContinue } },
        @{ N="10/12 DISM CheckHealth";   F={ DISM /Online /Cleanup-Image /CheckHealth } },
        @{ N="11/12 DISM RestoreHealth"; F={ DISM /Online /Cleanup-Image /RestoreHealth } },
        @{ N="12/12 SFC Scannow";        F={ sfc /scannow } }
    )
    foreach ($step in $steps) {
        Write-Host "`n  === $($step.N) ===" -ForegroundColor Cyan
        try { & $step.F; Show-OK "$($step.N) done."; Write-Log "Full Maintenance OK: $($step.N)" }
        catch { Show-WRN "$($step.N) error: $_"; Write-Log "Full Maintenance WARN: $($step.N) - $_" "WARN" }
    }
    Write-Log "DONE: Full Maintenance"
    Write-Host ""
    Write-Host "  +============================================================+" -ForegroundColor Green
    Write-Host "  |   FULL MAINTENANCE COMPLETED SUCCESSFULLY!                |" -ForegroundColor Green
    Write-Host "  |   Please restart your PC for best results.                |" -ForegroundColor Yellow
    Write-Host "  +============================================================+" -ForegroundColor Green
    $r = Read-Host "`n  Restart now? (Y/N)"
    if ($r -match '^[Yy]$') { shutdown /r /t 10 /c "Restart after Full Maintenance - Pro Laptop" }
}

function Invoke-RestorePoint {
    Clear-Host; Write-Host "`n  === CREATE SYSTEM RESTORE POINT ===" -ForegroundColor Cyan
    Make-RestorePoint "Manual - Pro Laptop Tool"
}

function Invoke-DefragHDD {
    if ($Global:DiskType -match "SSD|Solid") { Show-ERR "SSD detected! Defrag is HARMFUL to SSDs. Use Trim SSD instead."; return }
    if (-not (Confirm-Action "Defragment drive C:? (HDD only, may take a long time)")) { return }
    Clear-Host; Write-Host "`n  === DEFRAG HDD ===" -ForegroundColor Cyan
    defrag C: /U /V; Show-OK "Defragmentation completed."
}

function Invoke-TrimSSD {
    if ($Global:DiskType -match "HDD") { Show-ERR "HDD detected! TRIM only works on SSDs. Use Defrag HDD instead."; return }
    if (-not (Confirm-Action "Run SSD Trim on drive C:?")) { return }
    Clear-Host; Write-Host "`n  === SSD TRIM ===" -ForegroundColor Cyan
    defrag C: /L /U
    fsutil behavior set DisableDeleteNotify 0 2>$null | Out-Null
    $st = fsutil behavior query DisableDeleteNotify 2>$null
    Write-Host "  Trim status: $st" -ForegroundColor White
    Show-OK "SSD Trim completed."
}

function Invoke-OptimizeAllSSDs {
    Clear-Host; Write-Host "`n  === OPTIMIZE ALL SSDs ===" -ForegroundColor Cyan
    $ssds = Get-PhysicalDisk -ErrorAction SilentlyContinue | Where-Object MediaType -eq "SSD"
    if (-not $ssds) { Show-WRN "No SSDs detected on this system."; return }
    $log = "$env:USERPROFILE\Desktop\SSD_Optimize_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    $logContent = @("SSD Optimize Log - $(Get-Date)")
    foreach ($ssd in $ssds) {
        $disk = Get-Disk -ErrorAction SilentlyContinue | Where-Object { $_.FriendlyName -eq $ssd.FriendlyName }
        if ($disk) {
            $vols = $disk | Get-Partition | Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter }
            foreach ($vol in $vols) {
                Show-INF "Optimizing SSD: $($vol.DriveLetter):"
                $result = Optimize-Volume -DriveLetter $vol.DriveLetter -ReTrim -Verbose 4>&1
                $logContent += $result | Out-String
                Show-OK "SSD $($vol.DriveLetter): optimized."
            }
        }
    }
    $logContent | Out-File $log -Encoding UTF8 -ErrorAction SilentlyContinue
    Show-OK "SSD optimization complete. Log saved to Desktop: $(Split-Path $log -Leaf)"
}

function Invoke-DriverManagement {
    while ($true) {
        Clear-Host
        Write-Host "`n  === DRIVER MANAGEMENT ===" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   [1] Save Full Driver Report to Desktop"           -ForegroundColor White
        Write-Host "   [2] List and Remove Hidden (Unknown) Devices"     -ForegroundColor Yellow
        Write-Host "   [3] Disable Automatic Driver Updates"             -ForegroundColor Yellow
        Write-Host "   [4] Enable Automatic Driver Updates"              -ForegroundColor Green
        Write-Host "   [5] Open Device Manager"                          -ForegroundColor Cyan
        Write-Host "   [0] Back to Main Menu"                            -ForegroundColor DarkGray
        Write-Host ""
        $dc = Read-Host "  Select"
        switch ($dc) {
            '1' {
                $out = "$env:USERPROFILE\Desktop\Installed_Drivers_$(Get-Date -Format 'yyyyMMdd').txt"
                driverquery /v > $out
                if (Test-Path $out) { Show-OK "Driver report saved to Desktop: $(Split-Path $out -Leaf)" }
                else                { Show-WRN "Could not save driver report." }
            }
            '2' {
                $hidden = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Unknown" }
                if ($hidden) {
                    $hidden | Format-Table FriendlyName,InstanceId -AutoSize | Out-String | Write-Host
                    if (Confirm-Action "Remove all $($hidden.Count) hidden/unknown devices?") {
                        foreach ($d in $hidden) { pnputil /remove-device $d.InstanceId 2>$null | Out-Null }
                        Show-OK "Hidden devices removed."
                    }
                } else { Show-OK "No hidden devices found." }
            }
            '3' {
                Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" "SearchOrderConfig" 0 -ErrorAction SilentlyContinue
                $p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
                if (-not (Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
                Set-ItemProperty $p "ExcludeWUDriversInQualityUpdate" 1 -Type DWord -ErrorAction SilentlyContinue
                Show-OK "Automatic driver updates DISABLED."
            }
            '4' {
                Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" "SearchOrderConfig" 1 -ErrorAction SilentlyContinue
                $p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
                Remove-ItemProperty $p "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue
                Show-OK "Automatic driver updates ENABLED."
            }
            '5' { Start-Process "devmgmt.msc" -ErrorAction SilentlyContinue; Show-OK "Device Manager opened." }
            '0' { return }
            default { Show-WRN "Invalid selection." }
        }
        if ($dc -ne '0') { Wait-Enter }
    }
}

function Invoke-ScheduledTaskManager {
    Clear-Host; Write-Host "`n  === SCHEDULED TASK MANAGER ===" -ForegroundColor Cyan
    Write-Host "`n  Microsoft tasks shown in Gray, third-party tasks in Yellow." -ForegroundColor White
    $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.State -ne "Disabled" }
    if (-not $tasks) { Show-WRN "No active scheduled tasks found."; return }
    Write-Host "`n  --- Active Third-Party Tasks ---" -ForegroundColor Yellow
    $tasks | Where-Object { $_.TaskPath -notmatch "\\Microsoft\\" } |
        Format-Table TaskName,State,TaskPath -AutoSize | Out-String | Write-Host -ForegroundColor Yellow
    Write-Host "  --- Microsoft Tasks (sample) ---" -ForegroundColor DarkGray
    $tasks | Where-Object { $_.TaskPath -match "\\Microsoft\\" } | Select-Object -First 10 |
        Format-Table TaskName,State,TaskPath -AutoSize | Out-String | Write-Host -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [1] Open Task Scheduler GUI" -ForegroundColor Cyan
    Write-Host "  [0] Back" -ForegroundColor DarkGray
    $tc = Read-Host "  Select"
    if ($tc -eq '1') { Start-Process "taskschd.msc" -ErrorAction SilentlyContinue; Show-OK "Task Scheduler opened." }
}

function Invoke-StartupPrograms {
    Clear-Host; Write-Host "`n  === STARTUP PROGRAMS ===" -ForegroundColor Cyan
    Show-INF "Opening Task Manager (Startup tab)..."
    Start-Process "taskmgr" -ErrorAction SilentlyContinue
    Write-Host "  [i] Click Startup tab, right-click any program, select Disable." -ForegroundColor Yellow
}

function Invoke-RegBackup {
    if (-not (Confirm-Action "Export full HKLM registry backup to Desktop?")) { return }
    Clear-Host; Write-Host "`n  === REGISTRY BACKUP ===" -ForegroundColor Cyan
    $file = "$env:USERPROFILE\Desktop\RegistryBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
    Show-INF "Exporting registry (may take a moment)..."
    reg export HKLM "$file" /y 2>$null | Out-Null
    if (Test-Path $file) { Show-OK "Backup saved to Desktop: $(Split-Path $file -Leaf)"; Write-Log "Registry backup: $file" }
    else                 { Show-WRN "Export may have partially failed. Check Desktop." }
}

function Invoke-OpenLog {
    if (Test-Path $LogFile) { Show-INF "Opening log file..."; Invoke-Item $LogFile }
    else                    { Show-WRN "No log file found yet." }
}

function Invoke-PowerEfficiencyReport {
    Clear-Host; Write-Host "`n  === POWER EFFICIENCY REPORT ===" -ForegroundColor Cyan
    $rep = "$env:USERPROFILE\Desktop\EnergyReport.html"
    Show-INF "Running 30-second energy analysis (powercfg /energy)..."
    powercfg /energy /output "$rep" /duration 30 2>$null | Out-Null
    if (Test-Path $rep) { Show-OK "Energy report saved to Desktop: EnergyReport.html"; Invoke-Item $rep }
    else                { Show-WRN "Report could not be generated." }
}

function Invoke-WipeFreeSpace {
    if (-not (Confirm-Action "Zero-fill free space on C: with cipher /w? Securely removes deleted data. May take a very long time.")) { return }
    Clear-Host; Write-Host "`n  === WIPE FREE SPACE ===" -ForegroundColor Cyan
    Show-WRN "This may take 30-90+ minutes. Safe to cancel with Ctrl+C."
    cipher /w:C:\
    Show-OK "Free space wipe completed."
}

function Invoke-RemoveOrphanedAppData {
    Clear-Host; Write-Host "`n  === ORPHANED APP DATA SCANNER ===" -ForegroundColor Cyan
    Show-INF "Scanning AppData\Local for folders with no matching registry entry..."
    $appLocal = $env:LOCALAPPDATA
    $found = 0
    Get-ChildItem $appLocal -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $name = $_.Name
        $regCheck = Get-ItemProperty "HKCU:\Software\$name" -ErrorAction SilentlyContinue
        $regCheck2 = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue |
            Where-Object { (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).DisplayName -match [regex]::Escape($name) }
        if (-not $regCheck -and -not $regCheck2) {
            $sz  = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            $mb  = [math]::Round($sz / 1MB, 1)
            Write-Host ("  {0,-45} {1,6} MB" -f $name, $mb) -ForegroundColor Yellow
            $found++
        }
    }
    if ($found -eq 0) { Show-OK "No clearly orphaned app data found." }
    else { Show-WRN "$found possibly orphaned folders shown. Review and delete manually if sure." }
}

function Invoke-ShowOpenPorts {
    Clear-Host; Write-Host "`n  === OPEN PORTS & ACTIVE CONNECTIONS ===" -ForegroundColor Cyan
    Write-Host "`n  --- Listening Ports ---" -ForegroundColor Yellow
    netstat -ano 2>$null | Select-String "LISTENING" | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    Write-Host "`n  --- Established Connections (top 25) ---" -ForegroundColor Yellow
    netstat -ano 2>$null | Select-String "ESTABLISHED" | Select-Object -First 25 | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
    Write-Host "`n  --- Routing Table ---" -ForegroundColor Yellow
    route print 2>$null | Select-Object -First 30 | Out-String | Write-Host
}

function Invoke-TestInternetSpeed {
    Clear-Host; Write-Host "`n  === INTERNET LATENCY TEST ===" -ForegroundColor Cyan
    Show-INF "Testing latency to major servers (4 pings each)..."
    Write-Host ""
    @(
        @{ Name="Google DNS      "; Host="8.8.8.8" },
        @{ Name="Cloudflare DNS  "; Host="1.1.1.1" },
        @{ Name="Google.com      "; Host="google.com" },
        @{ Name="Microsoft.com   "; Host="microsoft.com" },
        @{ Name="OpenDNS         "; Host="208.67.222.222" }
    ) | ForEach-Object {
        $p = Test-Connection $_.Host -Count 4 -ErrorAction SilentlyContinue
        if ($p) {
            $avg = [int](($p | Measure-Object ResponseTime -Average).Average)
            $min = ($p | Measure-Object ResponseTime -Minimum).Minimum
            $max = ($p | Measure-Object ResponseTime -Maximum).Maximum
            $col = if ($avg -lt 50) { "Green" } elseif ($avg -lt 150) { "Yellow" } else { "Red" }
            Write-Host ("  {0}  Avg:{1,4}ms  Min:{2,3}ms  Max:{3,4}ms" -f $_.Name, $avg, $min, $max) -ForegroundColor $col
        } else { Write-Host "  $($_.Name)  [UNREACHABLE]" -ForegroundColor Red }
    }
    Write-Host ""
    Show-INF "For bandwidth speed test, visit speedtest.net or fast.com in your browser."
}

function Invoke-ExportNetworkConfig {
    Clear-Host; Write-Host "`n  === EXPORT NETWORK CONFIG BACKUP ===" -ForegroundColor Cyan
    $file = "$env:USERPROFILE\Desktop\NetworkConfig_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    Show-INF "Collecting full network configuration..."
    @(
        "=== PRO LAPTOP v3.1 - NETWORK CONFIG BACKUP ===",
        "Date: $(Get-Date)", "",
        "=== ipconfig /all ===",
        (ipconfig /all 2>$null | Out-String),
        "=== DNS Servers ===",
        (Get-DnsClientServerAddress | Format-Table * -AutoSize | Out-String),
        "=== Firewall Profiles ===",
        (netsh advfirewall show allprofiles 2>$null | Out-String),
        "=== WiFi Profiles ===",
        (netsh wlan show profiles 2>$null | Out-String),
        "=== Routing Table ===",
        (route print 2>$null | Out-String)
    ) | Out-File $file -Encoding UTF8 -ErrorAction SilentlyContinue
    if (Test-Path $file) { Show-OK "Network config saved to Desktop: $(Split-Path $file -Leaf)" }
    else                 { Show-WRN "Could not save config." }
}

function Invoke-MalwareFullScan {
    Clear-Host; Write-Host "`n  === MALWARE FULL SCAN ===" -ForegroundColor Cyan
    $mpCmd = "C:\Program Files\Windows Defender\MpCmdRun.exe"
    if (-not (Test-Path $mpCmd)) { Show-ERR "Windows Defender not found."; return }
    Show-INF "Updating virus definitions..."
    Start-Process $mpCmd -ArgumentList "-SignatureUpdate" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
    Show-OK "Definitions updated."
    Show-WRN "Full Scan started in background (ScanType 2). May take 30-60+ minutes."
    $r = Start-Process $mpCmd -ArgumentList "-Scan -ScanType 2" -PassThru -ErrorAction SilentlyContinue
    if ($r) { Show-OK "Full scan running (PID: $($r.Id)). Check Windows Security for results." }
    else    { Show-ERR "Could not start full scan." }
    Start-Process "windowsdefender:" -ErrorAction SilentlyContinue
    Write-Log "Malware Full Scan started PID: $($r.Id)"
}

function Invoke-DefenderMgmt {
    while ($true) {
        Clear-Host
        Write-Host "`n  === WINDOWS DEFENDER MANAGEMENT ===" -ForegroundColor Cyan
        Write-Host ""
        $mpCmd = "C:\Program Files\Windows Defender\MpCmdRun.exe"
        try {
            $mpStatus = Get-MpComputerStatus -ErrorAction Stop
            $rtCol = if ($mpStatus.RealTimeProtectionEnabled) { "Green" } else { "Red" }
            Write-Host "  Real-Time Protection : $($mpStatus.RealTimeProtectionEnabled)" -ForegroundColor $rtCol
            Write-Host "  Antivirus Enabled    : $($mpStatus.AntivirusEnabled)"          -ForegroundColor White
            Write-Host "  Definition Version   : $($mpStatus.AntivirusSignatureVersion)" -ForegroundColor White
            Write-Host "  Last Scan Time       : $($mpStatus.LastQuickScanStartTime)"    -ForegroundColor White
            Write-Host "  Last Full Scan       : $($mpStatus.LastFullScanStartTime)"     -ForegroundColor White
        } catch { Show-WRN "Could not read Defender status." }
        Write-Host ""
        Write-Host "   [1] Update Virus Definitions Now"               -ForegroundColor Green
        Write-Host "   [2] Quick Scan  (ScanType 1, ~10 min)"          -ForegroundColor Yellow
        Write-Host "   [3] Full Scan   (ScanType 2, 30-60+ min)"       -ForegroundColor Yellow
        Write-Host "   [4] Custom Path Scan"                            -ForegroundColor Yellow
        Write-Host "   [5] Enable Real-Time Protection"                 -ForegroundColor Green
        Write-Host "   [6] Disable Real-Time Protection (temp)"         -ForegroundColor Red
        Write-Host "   [7] Show Threat History"                         -ForegroundColor White
        Write-Host "   [8] Remove All Quarantined Threats"              -ForegroundColor Red
        Write-Host "   [9] Open Windows Security Center"                -ForegroundColor Cyan
        Write-Host "   [0] Back to Main Menu"                           -ForegroundColor DarkGray
        Write-Host ""
        $dc = Read-Host "  Select"
        switch ($dc) {
            '1' {
                Show-INF "Updating definitions..."
                if (Test-Path $mpCmd) {
                    Start-Process $mpCmd -ArgumentList "-SignatureUpdate" -Wait -WindowStyle Normal -ErrorAction SilentlyContinue
                    Show-OK "Definitions updated."
                } else { Show-WRN "MpCmdRun.exe not found." }
            }
            '2' {
                Show-INF "Starting Quick Scan (ScanType 1)..."
                if (Test-Path $mpCmd) {
                    $r = Start-Process $mpCmd -ArgumentList "-Scan -ScanType 1" -Wait -PassThru -ErrorAction SilentlyContinue
                    if ($r.ExitCode -eq 0) { Show-OK "Quick Scan: No threats found." }
                    else { Show-WRN "Scan complete. Exit code: $($r.ExitCode). Check Windows Security." }
                }
            }
            '3' {
                Show-WRN "Full scan runs in background. Check Windows Security for results."
                if (Test-Path $mpCmd) {
                    $r = Start-Process $mpCmd -ArgumentList "-Scan -ScanType 2" -PassThru -ErrorAction SilentlyContinue
                    if ($r) { Show-OK "Full scan started (PID: $($r.Id))." }
                }
            }
            '4' {
                $scanPath = Read-Host "  Enter folder path to scan (e.g. C:\Users\Downloads)"
                if (Test-Path $scanPath) {
                    Show-INF "Scanning: $scanPath"
                    if (Test-Path $mpCmd) {
                        $r = Start-Process $mpCmd -ArgumentList "-Scan -ScanType 3 -File `"$scanPath`"" -Wait -PassThru -ErrorAction SilentlyContinue
                        if ($r.ExitCode -eq 0) { Show-OK "Custom scan: Clean." }
                        else { Show-WRN "Scan exit code: $($r.ExitCode). Check Windows Security." }
                    }
                } else { Show-ERR "Path not found: $scanPath" }
            }
            '5' {
                Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
                Show-OK "Real-Time Protection ENABLED."
                Write-Log "Defender RTP enabled"
            }
            '6' {
                if (Confirm-Action "Disable Real-Time Protection? This reduces security!") {
                    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
                    Show-WRN "Real-Time Protection DISABLED. Re-enable after your task."
                    Write-Log "Defender RTP disabled" "WARN"
                }
            }
            '7' {
                Show-INF "Threat history..."
                try {
                    $threats = Get-MpThreatDetection -ErrorAction Stop | Select-Object -First 20
                    if ($threats) { $threats | Format-Table ThreatName,ActionSuccess,DetectionTime -AutoSize | Out-String | Write-Host }
                    else { Show-OK "No threat detections found." }
                } catch { Show-WRN "Could not retrieve threat history." }
            }
            '8' {
                if (Confirm-Action "Remove ALL quarantined threats permanently?") {
                    if (Test-Path $mpCmd) {
                        Start-Process $mpCmd -ArgumentList "-RemoveDefinitions -DynamicSignatures" -Wait -WindowStyle Hidden -ErrorAction SilentlyContinue
                        Show-INF "Running quarantine cleanup..."
                        try {
                            Get-MpThreat -ErrorAction Stop | ForEach-Object {
                                Remove-MpThreat -ThreatID $_.ThreatID -ErrorAction SilentlyContinue
                            }
                            Show-OK "Quarantine cleared."
                        } catch { Show-WRN "Use Windows Security UI to clear quarantine manually." }
                    }
                }
            }
            '9' { Start-Process "windowsdefender:" -ErrorAction SilentlyContinue; Show-OK "Windows Security opened." }
            '0' { return }
            default { Show-WRN "Invalid selection." }
        }
        if ($dc -ne '0') { Wait-Enter }
    }
}

function Invoke-AuditPolicyStatus {
    Clear-Host; Write-Host "`n  === AUDIT POLICY STATUS ===" -ForegroundColor Cyan
    Show-INF "Reading current audit policy settings..."
    Write-Host ""
    auditpol /get /category:* 2>$null | Out-String | Write-Host -ForegroundColor White
    Write-Host ""
    Write-Host "  [i] To enable logon auditing run:" -ForegroundColor Yellow
    Write-Host "      auditpol /set /subcategory:'Logon' /success:enable /failure:enable" -ForegroundColor DarkGray
}

function Invoke-CheckRootkitIndicators {
    Clear-Host; Write-Host "`n  === ROOTKIT INDICATOR CHECK ===" -ForegroundColor Cyan
    Show-WRN "Basic heuristic check only. Not a full rootkit scanner."
    Write-Host ""
    $suspicious = 0
    Show-INF "Comparing WMI process list vs Get-Process (hidden process check)..."
    $wmiIds = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ProcessId
    $psIds  = Get-Process -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id
    $wmiIds | Where-Object { $psIds -notcontains $_ } | ForEach-Object {
        Write-Host "  [!] PID $_ visible in WMI but hidden from Get-Process" -ForegroundColor Red; $suspicious++
    }
    Show-INF "Checking for processes with no image path..."
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
        -not $_.ExecutablePath -and $_.Name -notmatch "^(System|smss|csrss|wininit|winlogon|lsass|svchost|services|Idle|Registry)$"
    } | ForEach-Object { Write-Host "  [!] No path: $($_.Name) PID:$($_.ProcessId)" -ForegroundColor Red; $suspicious++ }
    Show-INF "Checking hosts file for non-standard entries..."
    Get-Content "$env:WINDIR\System32\drivers\etc\hosts" -ErrorAction SilentlyContinue |
        Where-Object { $_ -notmatch "^#" -and $_ -notmatch "localhost|::1" -and $_.Trim() -ne "" } |
        ForEach-Object { Write-Host "  [~] Custom hosts entry: $_" -ForegroundColor Yellow; $suspicious++ }
    Show-INF "Checking for unsigned drivers in System32\drivers..."
    Get-ChildItem "$env:WINDIR\System32\drivers\*.sys" -ErrorAction SilentlyContinue | ForEach-Object {
        $sig = Get-AuthenticodeSignature $_.FullName -ErrorAction SilentlyContinue
        if ($sig -and $sig.Status -ne "Valid") { Write-Host "  [!] Unsigned driver: $($_.Name)" -ForegroundColor Red; $suspicious++ }
    }
    Write-Host ""
    if ($suspicious -eq 0) { Show-OK "No obvious rootkit indicators found." }
    else { Show-WRN "Found $suspicious indicator(s). Consider Malwarebytes or GMER for deeper analysis." }
}

function Invoke-HostsFileEditor {
    Clear-Host; Write-Host "`n  === HOSTS FILE VIEWER / EDITOR ===" -ForegroundColor Cyan
    $hostsPath = "$env:WINDIR\System32\drivers\etc\hosts"

    $attr = Get-ItemProperty $hostsPath -ErrorAction SilentlyContinue
    $isReadOnly = $attr -and $attr.IsReadOnly
    $lockStatus = if ($isReadOnly) { "LOCKED (Read-Only)" } else { "Unlocked (Writable)" }
    $lockColor  = if ($isReadOnly) { "Yellow" } else { "Green" }
    Write-Host "  Lock Status: $lockStatus" -ForegroundColor $lockColor
    Write-Host ""

    Write-Host "  --- Current hosts file entries ---" -ForegroundColor Yellow
    Get-Content $hostsPath -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_ -match "^#" -or $_.Trim() -eq "") { Write-Host "  $_" -ForegroundColor DarkGray }
        else { Write-Host "  $_" -ForegroundColor White }
    }
    Write-Host ""
    Write-Host "  [1] Open in Notepad (as Admin)"                             -ForegroundColor Cyan
    Write-Host "  [2] Lock hosts file  (attrib +r - blocks malware edits)"   -ForegroundColor Yellow
    Write-Host "  [3] Unlock hosts file (attrib -r - allows editing)"        -ForegroundColor Green
    Write-Host "  [4] Flush DNS cache after editing"                          -ForegroundColor Cyan
    Write-Host "  [5] Reset hosts to Windows default (removes all custom)"   -ForegroundColor Red
    Write-Host "  [0] Back"                                                    -ForegroundColor DarkGray
    Write-Host ""
    $hc = Read-Host "  Select"
    switch ($hc) {
        '1' {
            if ($isReadOnly) { Show-WRN "File is locked (Read-Only). Unlock it first with option [3]." }
            else {
                Start-Process notepad -ArgumentList $hostsPath -Verb RunAs -ErrorAction SilentlyContinue
                Show-OK "Hosts file opened in Notepad (Admin)."
            }
        }
        '2' {
            attrib +r $hostsPath 2>$null | Out-Null
            Show-OK "Hosts file LOCKED (Read-Only). Malware cannot modify it."
            Show-WRN "Remember to unlock it with option [3] if you need to edit it later."
        }
        '3' {
            attrib -r $hostsPath 2>$null | Out-Null
            Show-OK "Hosts file UNLOCKED (Writable). You can now edit it."
        }
        '4' {
            Clear-DnsClientCache
            Show-OK "DNS cache flushed. New hosts entries are now active."
        }
        '5' {
            if (-not (Confirm-Action "Reset hosts file to Windows default? All custom entries will be deleted!")) { return }
            if ($isReadOnly) { attrib -r $hostsPath 2>$null | Out-Null }
            $defaultHosts = @(
                "# Copyright (c) 1993-2009 Microsoft Corp.",
                "#",
                "# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.",
                "#",
                "127.0.0.1       localhost",
                "::1             localhost"
            )
            $defaultHosts | Out-File $hostsPath -Encoding ASCII -ErrorAction SilentlyContinue
            Clear-DnsClientCache
            Show-OK "Hosts file reset to Windows default and DNS flushed."
        }
    }
}

function Invoke-InstalledPrograms {
    Clear-Host; Write-Host "`n  === INSTALLED PROGRAMS LIST ===" -ForegroundColor Cyan
    Show-INF "Collecting installed programs from registry..."
    $progs = @()
    @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    ) | ForEach-Object {
        Get-ItemProperty $_ -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } |
            Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | ForEach-Object { $progs += $_ }
    }
    $progs = $progs | Sort-Object DisplayName -Unique
    Write-Host "`n  Total: $($progs.Count) programs" -ForegroundColor Cyan
    $progs | Format-Table DisplayName, DisplayVersion, Publisher -AutoSize | Out-String | Write-Host
    $file = "$env:USERPROFILE\Desktop\InstalledPrograms_$(Get-Date -Format 'yyyyMMdd').txt"
    $progs | Format-Table * -AutoSize | Out-File $file -Encoding UTF8 -ErrorAction SilentlyContinue
    Show-OK "List saved to Desktop: $(Split-Path $file -Leaf)"
}

function Invoke-TopProcesses {
    Clear-Host; Write-Host "`n  === TOP PROCESSES (CPU & RAM) ===" -ForegroundColor Cyan
    Write-Host "`n  --- Top 15 by CPU ---" -ForegroundColor Yellow
    Get-Process -ErrorAction SilentlyContinue | Sort-Object CPU -Descending | Select-Object -First 15 |
        Format-Table Name, Id, CPU, @{N='RAM(MB)';E={[math]::Round($_.WorkingSet64/1MB,0)}} -AutoSize | Out-String | Write-Host
    Write-Host "  --- Top 15 by RAM ---" -ForegroundColor Yellow
    Get-Process -ErrorAction SilentlyContinue | Sort-Object WorkingSet64 -Descending | Select-Object -First 15 |
        Format-Table Name, Id, @{N='RAM(MB)';E={[math]::Round($_.WorkingSet64/1MB,0)}}, CPU -AutoSize | Out-String | Write-Host
    $cpuUse = [math]::Round((Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average, 0)
    $os     = Get-CimInstance Win32_OperatingSystem
    $usedGB = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 1)
    $totalGB= [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    Write-Host "  System CPU: ${cpuUse}%   RAM Used: ${usedGB} / ${totalGB} GB" -ForegroundColor Cyan
}

function Invoke-EnvironmentVariables {
    Clear-Host; Write-Host "`n  === ENVIRONMENT VARIABLES ===" -ForegroundColor Cyan
    Write-Host "`n  --- System ---" -ForegroundColor Yellow
    [System.Environment]::GetEnvironmentVariables("Machine").GetEnumerator() | Sort-Object Name |
        Format-Table Name, Value -AutoSize | Out-String | Write-Host
    Write-Host "  --- User ---" -ForegroundColor Yellow
    [System.Environment]::GetEnvironmentVariables("User").GetEnumerator() | Sort-Object Name |
        Format-Table Name, Value -AutoSize | Out-String | Write-Host
}

function Invoke-BsodLog {
    Clear-Host; Write-Host "`n  === WINDOWS ERROR / BSOD LOG ===" -ForegroundColor Cyan
    Show-INF "Checking Event Log for critical errors and BSODs..."
    Write-Host "`n  --- Recent Critical System Errors ---" -ForegroundColor Red
    try {
        Get-WinEvent -FilterHashtable @{LogName='System'; Level=1} -MaxEvents 10 -ErrorAction Stop |
            Format-Table TimeCreated, Id, Message -AutoSize | Out-String | Write-Host
    } catch { Show-WRN "No critical errors found." }
    Write-Host "  --- Recent BSOD / Unexpected Shutdown Events ---" -ForegroundColor Red
    try {
        Get-WinEvent -FilterHashtable @{LogName='System'; Id=41,1001,6008} -MaxEvents 10 -ErrorAction Stop |
            Format-Table TimeCreated, Id, Message -AutoSize | Out-String | Write-Host
    } catch { Show-WRN "No BSOD events found." }
    Write-Host "  --- Minidump Files ---" -ForegroundColor Yellow
    $dumps = Get-ChildItem "$env:WINDIR\Minidump\*.dmp" -ErrorAction SilentlyContinue
    if ($dumps) { $dumps | Format-Table Name, LastWriteTime, @{N='Size(KB)';E={[math]::Round($_.Length/1KB,0)}} | Out-String | Write-Host }
    else        { Write-Host "  No minidump files found." -ForegroundColor DarkGray }
}

function Invoke-ReliabilityHistory {
    Clear-Host; Write-Host "`n  === RELIABILITY HISTORY ===" -ForegroundColor Cyan
    Show-INF "Opening Reliability Monitor (perfmon /rel)..."
    Start-Process "perfmon" -ArgumentList "/rel" -ErrorAction SilentlyContinue
    Show-OK "Reliability Monitor opened."
}

function Invoke-MemoryDiagnostic {
    Clear-Host; Write-Host "`n  === WINDOWS MEMORY DIAGNOSTIC ===" -ForegroundColor Cyan
    Show-WRN "This will schedule a RAM test at next restart."
    if (-not (Confirm-Action "Schedule Windows Memory Diagnostic (mdsched) at next restart?")) { return }
    mdsched.exe 2>$null
    Show-OK "Memory Diagnostic scheduled. Restart your PC when ready."
}

function Invoke-MsConfig {
    Clear-Host; Write-Host "`n  === SYSTEM CONFIGURATION (msconfig) ===" -ForegroundColor Cyan
    Start-Process "msconfig" -ErrorAction SilentlyContinue
    Show-OK "System Configuration opened."
}

function Invoke-ResourceMonitor {
    Clear-Host; Write-Host "`n  === RESOURCE MONITOR ===" -ForegroundColor Cyan
    Start-Process "perfmon" -ArgumentList "/res" -ErrorAction SilentlyContinue
    Show-OK "Resource Monitor opened."
}

function Invoke-PerfMonitor {
    Clear-Host; Write-Host "`n  === PERFORMANCE MONITOR ===" -ForegroundColor Cyan
    Start-Process "perfmon.exe" -ErrorAction SilentlyContinue
    Show-OK "Performance Monitor opened."
}

function Invoke-EventViewer {
    Clear-Host; Write-Host "`n  === EVENT VIEWER ===" -ForegroundColor Cyan
    Start-Process "eventvwr.msc" -ErrorAction SilentlyContinue
    Show-OK "Event Viewer opened."
}

function Invoke-ServicesManager {
    Clear-Host; Write-Host "`n  === SERVICES MANAGER ===" -ForegroundColor Cyan
    Start-Process "services.msc" -ErrorAction SilentlyContinue
    Show-OK "Services Manager opened."
}

function Invoke-DiskManagement {
    Clear-Host; Write-Host "`n  === DISK MANAGEMENT ===" -ForegroundColor Cyan
    Start-Process "diskmgmt.msc" -ErrorAction SilentlyContinue
    Show-OK "Disk Management opened."
}

function Invoke-ComputerManagement {
    Clear-Host; Write-Host "`n  === COMPUTER MANAGEMENT ===" -ForegroundColor Cyan
    Start-Process "compmgmt.msc" -ErrorAction SilentlyContinue
    Show-OK "Computer Management opened."
}

function Invoke-UsbUnhider {
    Clear-Host; Write-Host "`n  === USB VIRUS UNHIDER ===" -ForegroundColor Cyan
    $drive = Read-Host "  Enter USB Drive Letter (e.g., F)"
    if ($drive -match "^[a-zA-Z]$") {
        $path = "$($drive):\"
        if (Test-Path $path) {
            cmd.exe /c "attrib -h -r -s /s /d $($path)*.*"
            Get-ChildItem -Path $path -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force
            Show-OK "USB Drive $path cleaned successfully!"
        }
    }
}

function Invoke-DriverExporter {
    Clear-Host; Write-Host "`n  === EXPORT ALL DRIVERS ===" -ForegroundColor Cyan
    $dest = Read-Host "  Enter path to save (e.g. E:\Drivers)"
    if ($dest) { New-Item -ItemType Directory -Force -Path $dest | Out-Null; Export-WindowsDriver -Online -Destination $dest -ErrorAction SilentlyContinue | Out-Null; Show-OK "Exported to $dest" }
}

function Invoke-HardwareTestHelpers {
    Clear-Host; Write-Host "`n  === HARDWARE TEST HELPERS ===" -ForegroundColor Cyan
    Start-Process "https://keyboardtester.com/tester/" -ErrorAction SilentlyContinue
    Start-Process "https://lcdtech.info/en/tests/dead.pixel.htm" -ErrorAction SilentlyContinue
    Show-OK "Diagnostic tools opened in browser."
}

function Invoke-PasswordBypass {
    Clear-Host; Write-Host "`n  === PASSWORD BYPASS (WinPE TRICK) ===" -ForegroundColor Cyan
    Show-WRN "Use this ONLY from a Bootable USB (WinPE)!"
    $winDrive = if (Test-Path "C:\Windows\System32") { "C:" } elseif (Test-Path "D:\Windows\System32") { "D:" } else { $null }
    if ($winDrive) {
        Copy-Item "$winDrive\Windows\System32\utilman.exe" "$winDrive\Windows\System32\utilman.exe.bak" -Force -ErrorAction SilentlyContinue
        Copy-Item "$winDrive\Windows\System32\cmd.exe" "$winDrive\Windows\System32\utilman.exe" -Force -ErrorAction SilentlyContinue
        Show-OK "Bypass injected! Restart and click Accessibility icon."
    }
}

function Invoke-BasicAppsInstall {
    Clear-Host; Write-Host "`n  === SILENT APP INSTALLER (Winget) ===" -ForegroundColor Cyan
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $apps = @("Google.Chrome", "RARLab.WinRAR", "VideoLAN.VLC", "Adobe.Acrobat.Reader.64-bit")
        foreach ($app in $apps) { winget install --id=$app -e --accept-package-agreements --accept-source-agreements --silent 2>$null; Show-OK "$app installed." }
    } else { Show-ERR "Winget not found." }
}

# ==============================================================================
# DISPATCH TABLE
# ==============================================================================
$dispatchTable = @{
    '1'={Invoke-PowerPlans}; '2'={Invoke-FixBattery}; '3'={Invoke-ResetPower}; '4'={Invoke-CpuBoost}; '5'={Invoke-BatteryReport}; '6'={Invoke-PowerEfficiencyReport};
    '7'={Invoke-DeepClean}; '8'={Invoke-BrowserClean}; '9'={Invoke-CleanUpdateCache}; '10'={Invoke-RemoveOldWindows}; '11'={Invoke-EmptyBin}; '12'={Invoke-ClearEventLogs};
    '13'={Invoke-DiskCleanup}; '14'={Invoke-BrokenShortcuts}; '15'={Invoke-WipeFreeSpace}; '16'={Invoke-RemoveOrphanedAppData};
    '17'={Invoke-SfcVerifyOnly}; '18'={Invoke-SfcScannow}; '19'={Invoke-DismCheckHealth}; '20'={Invoke-DismScanHealth}; '21'={Invoke-DismRestoreHealth}; '22'={Invoke-DismComponentCleanup};
    '23'={Invoke-RepairDisk}; '24'={Invoke-FixUpdate}; '25'={Invoke-FixStore}; '26'={Invoke-FixSearch}; '27'={Invoke-FixAudio}; '28'={Invoke-FixTime}; '29'={Invoke-ResetFirewall}; '30'={Invoke-RebuildBCD};
    '31'={Invoke-ReRegisterDLLs}; '32'={Invoke-FixMSI}; '33'={Invoke-ResetUpdatePolicy}; '34'={Invoke-RepairWMI};
    '35'={Invoke-NetworkReset}; '36'={Invoke-SetGoogleDNS}; '37'={Invoke-SetCloudflareDNS}; '38'={Invoke-ResetDnsAuto}; '39'={Invoke-NetDiag}; '40'={Invoke-IpconfigAll};
    '41'={Invoke-OpenNetworkConnections}; '42'={Invoke-ResetProxy}; '43'={Invoke-WifiProfiles}; '44'={Invoke-FirewallManager}; '45'={Invoke-ShowOpenPorts}; '46'={Invoke-TestInternetSpeed}; '47'={Invoke-ExportNetworkConfig};
    '48'={Invoke-MalwareScan}; '49'={Invoke-DefenderMgmt}; '50'={Invoke-MalwareFullScan}; '51'={Invoke-DisableTelemetry}; '52'={Invoke-StartupAnalyzer}; '53'={Invoke-SuspiciousProcs}; '54'={Invoke-KillUnsignedProcs}; '55'={Invoke-EnableSecurity};
    '56'={Invoke-CertManager}; '57'={Invoke-LocalSecurityPolicy}; '58'={Invoke-DriverVerifier}; '59'={Invoke-LocalUsersGroups}; '60'={Invoke-AuditPolicyStatus}; '61'={Invoke-CheckRootkitIndicators}; '62'={Invoke-HostsFileEditor};
    '63'={Invoke-SysInfo}; '64'={Invoke-CpuRamInfo}; '65'={Invoke-RamDetails}; '66'={Invoke-DiskHealth}; '67'={Invoke-GpuInfo}; '68'={Invoke-DriverCheck}; '69'={Invoke-CheckActivation}; '70'={Invoke-UptimeServices};
    '71'={Invoke-RemoteDesktop}; '72'={Invoke-GroupPolicyEditor}; '73'={Invoke-AppsFolder}; '74'={Invoke-InstalledPrograms}; '75'={Invoke-TopProcesses}; '76'={Invoke-EnvironmentVariables}; '77'={Invoke-BsodLog}; '78'={Invoke-ReliabilityHistory};
    '79'={Invoke-FullMaintenance}; '80'={Invoke-RestorePoint}; '81'={Invoke-DefragHDD}; '82'={Invoke-TrimSSD}; '83'={Invoke-OptimizeAllSSDs}; '84'={Invoke-DriverManagement}; '85'={Invoke-ScheduledTaskManager};
    '86'={Invoke-StartupPrograms}; '87'={Invoke-RegBackup}; '88'={Invoke-OpenLog}; '89'={Invoke-MemoryDiagnostic}; '90'={Invoke-MsConfig}; '91'={Invoke-ResourceMonitor}; '92'={Invoke-PerfMonitor}; '93'={Invoke-EventViewer}; '94'={Invoke-ServicesManager}; '95'={Invoke-DiskManagement}; '96'={Invoke-ComputerManagement};
    '97'={Invoke-UsbUnhider}; '98'={Invoke-DriverExporter}; '99'={Invoke-BasicAppsInstall}; '100'={Invoke-HardwareTestHelpers}; '101'={Invoke-PasswordBypass}
}

while ($true) {
    Show-MainMenu
    $choice = (Read-Host "`n  Select an option (0-101)").Trim()

    if ($choice -eq '0') {
        Write-Host "`n  Thank you for using Pro Laptop Ultimate v3.1 - Stay Secure!" -ForegroundColor Green
        Write-Host "  Eng. Mahmoud Kullab  |  +970 599 548 716" -ForegroundColor DarkGray
        Write-Host "  mahmoud-kullab.github.io  |  github.com/mahmoud-kullab" -ForegroundColor DarkGray
        Write-Log "SESSION ENDED"
        Start-Sleep -Seconds 2
        break
    }

    if ($dispatchTable.ContainsKey($choice)) {
        Write-Log "Running tool: $choice"
        try   { & $dispatchTable[$choice] }
        catch { Show-ERR "Unexpected error in tool $choice : $_"; Write-Log "Crash in tool $choice : $_" "ERROR" }
        Wait-Enter
    } else {
        Write-Host "`n  [!] Invalid selection. Enter a number between 0 and 101." -ForegroundColor Red
        Start-Sleep -Seconds 1
    }
}
