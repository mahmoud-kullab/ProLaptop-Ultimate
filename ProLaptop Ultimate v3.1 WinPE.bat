@echo off
setlocal EnableDelayedExpansion
title PRO LAPTOP ULTIMATE - True WinPE Edition ^| Eng. Mahmoud Kullab
color 0B

:: ============================================================
::  AUTO-DETECT OFFLINE WINDOWS DRIVE (CRITICAL FOR WINPE)
:: ============================================================
set "WINDRIVE="
for %%d in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%d:\Windows\System32\cmd.exe" set "WINDRIVE=%%d"
)
:: Fallback to C if detection fails
if "%WINDRIVE%"=="" set "WINDRIVE=C"

:MAIN_MENU
cls
color 0B
echo  +====================================================================+
echo  ^|               PRO LAPTOP ULTIMATE - TRUE WINPE                     ^|
echo  ^|               Eng. Mahmoud Kullab - Pro Laptop                     ^|
echo  ^|               Target Offline Windows: %WINDRIVE%:                           ^|
echo  +====================================================================+
echo.
echo   --- BOOT ^& RECOVERY ---
echo   [1] SFC Offline Repair       (Fix corrupted system files)
echo   [2] DISM Offline Restore     (Repair offline Windows image)
echo   [3] Revert Pending Updates   (Fix Boot Loops caused by bad updates)
echo   [4] CHKDSK Target Drive      (Fix bad sectors on %WINDRIVE%:)
echo   [5] UEFI Boot Repair         (Rebuild UEFI boot files via bcdboot)
echo   [6] MBR Boot Repair          (Rebuild Legacy boot files via bootrec)
echo   [7] Stop Auto-Repair Loop    (Bypass "Preparing Auto Repair" screen)
echo   [8] Force Safe Mode          (Force next boot into Safe Mode)
echo   [9] Offline System Restore   (Rollback Windows to a previous state)
echo.
echo   --- CLEANING ^& BACKUP ---
echo   [10] Deep Clean Temp Files   (Wipe offline Windows ^& Users Temp)
echo   [11] Clean Update Cache      (Clear offline SoftwareDistribution)
echo   [12] Quick Data Rescue       (Fast Robocopy backup of User Data)
echo.
echo   --- DISK, SECURITY ^& UTILITIES ---
echo   [13] Password Bypass         (Utilman Trick - Unlock Windows)
echo   [14] Export Offline Drivers  (Extract all drivers from dead PC)
echo   [15] USB Virus Unhider       (Clean connected flash drives)
echo   [16] BitLocker Status Check  (Check if %WINDRIVE%: is encrypted)
echo   [17] MBR to GPT Converter    (Convert disk to GPT without data loss)
echo   [18] Enable WinPE Network    (Start network services ^& get IP)
echo   [19] Open Notepad            (Use as File Browser to copy files)
echo   [20] Open Registry Editor    (regedit)
echo.
echo   [0] Exit
echo  +====================================================================+
echo.

set "choice="
set /p "choice=  Select option (0-20): "

if "%choice%"=="1"  goto :SFC_OFFLINE
if "%choice%"=="2"  goto :DISM_OFFLINE
if "%choice%"=="3"  goto :REVERT_UPDATES
if "%choice%"=="4"  goto :CHKDSK_OFFLINE
if "%choice%"=="5"  goto :BOOT_UEFI
if "%choice%"=="6"  goto :BOOT_MBR
if "%choice%"=="7"  goto :STOP_REPAIR
if "%choice%"=="8"  goto :SAFE_MODE
if "%choice%"=="9"  goto :SYS_RESTORE
if "%choice%"=="10" goto :CLEAN_TEMP
if "%choice%"=="11" goto :CLEAN_UPDATE
if "%choice%"=="12" goto :DATA_RESCUE
if "%choice%"=="13" goto :PASS_BYPASS
if "%choice%"=="14" goto :DRV_EXPORT
if "%choice%"=="15" goto :USB_UNHIDE
if "%choice%"=="16" goto :BITLOCKER_CHK
if "%choice%"=="17" goto :MBR_TO_GPT
if "%choice%"=="18" goto :ENABLE_NET
if "%choice%"=="19" goto :OPEN_NOTEPAD
if "%choice%"=="20" goto :OPEN_REG
if "%choice%"=="0"  exit

echo  [!] Invalid choice. Please try again.
ping 127.0.0.1 -n 3 >nul
goto :MAIN_MENU

:: ============================================================
::  BOOT & RECOVERY
:: ============================================================
:SFC_OFFLINE
cls
echo  === OFFLINE SFC REPAIR ===
echo  [*] Running SFC Scan on offline Windows (%WINDRIVE%:\)...
sfc /scannow /OFFBOOTDIR=%WINDRIVE%:\ /OFFWINDIR=%WINDRIVE%:\Windows
pause & goto :MAIN_MENU

:DISM_OFFLINE
cls
echo  === OFFLINE DISM RESTORE ===
echo  [*] Running DISM RestoreHealth on offline image (%WINDRIVE%:\)...
DISM /Image:%WINDRIVE%:\ /Cleanup-Image /RestoreHealth
pause & goto :MAIN_MENU

:REVERT_UPDATES
cls
echo  === REVERT PENDING UPDATES ===
echo  [*] Reverting pending Windows Updates that might cause a boot loop...
DISM /Image:%WINDRIVE%:\ /Cleanup-Image /RevertPendingActions
echo  [OK] Done. Restart the PC to apply changes.
pause & goto :MAIN_MENU

:CHKDSK_OFFLINE
cls
echo  === CHKDSK %WINDRIVE%: ===
echo  [*] Running CHKDSK on %WINDRIVE%: (Fixing errors and recovering bad sectors)...
chkdsk %WINDRIVE%: /f /r /x
pause & goto :MAIN_MENU

:BOOT_UEFI
cls
echo  === UEFI BOOT REPAIR ===
echo  [*] Rebuilding UEFI Boot Files for %WINDRIVE%:\Windows...
bcdboot %WINDRIVE%:\Windows /f UEFI
if %errorlevel%==0 ( echo  [OK] UEFI Boot files successfully created. ) else ( echo  [!] Repair failed. )
pause & goto :MAIN_MENU

:BOOT_MBR
cls
echo  === MBR/LEGACY BOOT REPAIR ===
echo  [*] Running bootrec suite for MBR...
bootrec /fixmbr
bootrec /fixboot
bootrec /scanos
bootrec /rebuildbcd
echo  [OK] MBR Repair sequence completed.
pause & goto :MAIN_MENU

:STOP_REPAIR
cls
echo  === STOP AUTOMATIC REPAIR LOOP ===
echo  [*] Disabling Recovery Enabled flag in BCD...
bcdedit /set {default} recoveryenabled No
if %errorlevel%==0 (
    echo  [OK] Automatic repair loop disabled.
    echo  [i] Now when you restart, it will show the true BSOD error code instead of looping.
) else (
    echo  [!] Failed to modify BCD.
)
pause & goto :MAIN_MENU

:SAFE_MODE
cls
echo  === FORCE SAFE MODE ===
echo  [*] Setting Windows on %WINDRIVE%: to boot into Safe Mode...
bcdedit /set {default} safeboot minimal
if %errorlevel%==0 (
    echo  [OK] Success! Restart the PC. 
    echo  [i] Remember to run "msconfig" inside Safe Mode to turn it off later.
) else (
    echo  [!] Failed. You may need to rebuild BCD first.
)
pause & goto :MAIN_MENU

:SYS_RESTORE
cls
echo  === OFFLINE SYSTEM RESTORE ===
echo  [*] Launching GUI System Restore for %WINDRIVE%:\Windows...
rstrui.exe /OFFLINE:%WINDRIVE%:\Windows
goto :MAIN_MENU

:: ============================================================
::  CLEANING & BACKUP
:: ============================================================
:CLEAN_TEMP
cls
echo  === DEEP CLEAN TEMP FILES ===
echo  [*] Cleaning offline Windows Temp...
del /q /f /s "%WINDRIVE%:\Windows\Temp\*.*" >nul 2>&1
for /d %%x in ("%WINDRIVE%:\Windows\Temp\*") do rd /s /q "%%x" >nul 2>&1

echo  [*] Cleaning offline Users Temp...
for /d %%u in ("%WINDRIVE%:\Users\*") do (
    if exist "%%u\AppData\Local\Temp" (
        del /q /f /s "%%u\AppData\Local\Temp\*.*" >nul 2>&1
        for /d %%x in ("%%u\AppData\Local\Temp\*") do rd /s /q "%%x" >nul 2>&1
    )
)
echo  [OK] Offline Temp files wiped successfully.
pause & goto :MAIN_MENU

:CLEAN_UPDATE
cls
echo  === CLEAN UPDATE CACHE ===
echo  [*] Clearing offline Windows Update Cache...
if exist "%WINDRIVE%:\Windows\SoftwareDistribution\Download" (
    del /q /f /s "%WINDRIVE%:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
    for /d %%x in ("%WINDRIVE%:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%x" >nul 2>&1
    echo  [OK] Windows Update Cache cleared.
) else (
    echo  [!] Path not found.
)
pause & goto :MAIN_MENU

:DATA_RESCUE
cls
echo  === QUICK USER DATA RESCUE ===
echo  Existing users on %WINDRIVE%:
dir /b "%WINDRIVE%:\Users"
echo.
set /p "uname=  Enter the exact Username to backup: "
if not exist "%WINDRIVE%:\Users\%uname%" (
    echo  [!] User profile not found.
    pause & goto :MAIN_MENU
)
echo.
echo list volume | diskpart | findstr /i "Volume"
echo.
set /p "usbdrv=  Enter your Backup Drive Letter (e.g. E): "
set "usbdrv=%usbdrv:~0,1%"
if not exist "%usbdrv%:\" (
    echo  [!] Destination drive not found.
    pause & goto :MAIN_MENU
)

set "DEST=%usbdrv%:\ProLaptop_Backup_%uname%"
echo  [*] Backing up to: %DEST%
echo  [!] This uses Robocopy (Multi-threaded). Please wait...
echo.
robocopy "%WINDRIVE%:\Users\%uname%\Desktop" "%DEST%\Desktop" /E /MT:4 /R:0 /W:0 /NFL /NDL /NJH
robocopy "%WINDRIVE%:\Users\%uname%\Documents" "%DEST%\Documents" /E /MT:4 /R:0 /W:0 /NFL /NDL /NJH
robocopy "%WINDRIVE%:\Users\%uname%\Pictures" "%DEST%\Pictures" /E /MT:4 /R:0 /W:0 /NFL /NDL /NJH
robocopy "%WINDRIVE%:\Users\%uname%\Downloads" "%DEST%\Downloads" /E /MT:4 /R:0 /W:0 /NFL /NDL /NJH
echo.
echo  [OK] Backup completed successfully!
pause & goto :MAIN_MENU

:: ============================================================
::  DISK, SECURITY & UTILITIES
:: ============================================================
:PASS_BYPASS
cls
echo  === PASSWORD BYPASS (WinPE TRICK) ===
if not exist "%WINDRIVE%:\Windows\System32\utilman.exe" (
    echo  [!] Could not find utilman.exe on %WINDRIVE%:
    pause & goto :MAIN_MENU
)
echo  [*] Backing up original utilman.exe...
copy /y "%WINDRIVE%:\Windows\System32\utilman.exe" "%WINDRIVE%:\Windows\System32\utilman.exe.bak" >nul
echo  [*] Injecting cmd.exe into utilman.exe...
copy /y "%WINDRIVE%:\Windows\System32\cmd.exe" "%WINDRIVE%:\Windows\System32\utilman.exe" >nul
echo  [OK] Bypass injected successfully!
echo  [i] Restart the PC normally. At the login screen, click the Accessibility icon.
echo  [i] CMD will open. Type: net user "username" "newpassword"
pause & goto :MAIN_MENU

:DRV_EXPORT
cls
echo  === EXPORT OFFLINE DRIVERS ===
echo  This tool uses native DISM to extract drivers from the dead OS.
set /p dest="  Enter destination USB path (e.g. E:\DriversBackup): "
if "%dest%"=="" goto :MAIN_MENU
mkdir "%dest%" >nul 2>&1
echo  [*] Extracting drivers to %dest%...
dism /image:%WINDRIVE%:\ /export-driver /destination:"%dest%"
echo  [OK] Process completed. Check the folder.
pause & goto :MAIN_MENU

:USB_UNHIDE
cls
echo  === USB VIRUS UNHIDER ===
echo  Current Volumes:
echo list volume | diskpart | findstr /i "Volume"
echo.
set /p "usbdrv=  Enter USB drive letter (e.g. E, F): "
set "usbdrv=%usbdrv:~0,1%"
if not exist "%usbdrv%:\" (
    echo  [!] Drive %usbdrv%: not found.
    pause & goto :MAIN_MENU
)
echo  [*] Clearing hidden attributes...
attrib -h -r -s /s /d "%usbdrv%:\*.*"
echo  [*] Removing malicious .lnk shortcuts...
del /s /f /q "%usbdrv%:\*.lnk" >nul 2>&1
echo  [OK] Drive %usbdrv%: cleaned.
pause & goto :MAIN_MENU

:BITLOCKER_CHK
cls
echo  === BITLOCKER STATUS ===
echo  [*] Checking if drives are locked...
manage-bde -status
echo.
echo  [i] If %WINDRIVE%: is locked, commands like SFC or DISM will fail!
echo  [i] To unlock it manually, use: manage-bde -unlock %WINDRIVE%: -RecoveryPassword YOUR-KEY
pause & goto :MAIN_MENU

:MBR_TO_GPT
cls
echo  === MBR TO GPT CONVERTER ===
echo  [!] Converts an MBR disk to GPT WITHOUT modifying or deleting data.
echo  [!] Required if you want to upgrade an older PC to Windows 11.
echo.
echo list disk | diskpart
echo.
set /p "diskNum=  Enter Disk Number to validate/convert (e.g. 0): "
if "%diskNum%"=="" goto :MAIN_MENU
echo.
echo  [*] Step 1: Validating Disk %diskNum%...
mbr2gpt /validate /disk:%diskNum%
if %errorlevel% neq 0 (
    echo  [!] Validation failed. Cannot safely convert this disk.
    pause & goto :MAIN_MENU
)
echo.
set /p "doConv=  [OK] Validation successful! Proceed with conversion? (Y/N): "
if /i "%doConv%"=="Y" (
    mbr2gpt /convert /disk:%diskNum%
    echo  [OK] Conversion Done! 
    echo  [!] CRITICAL: You MUST restart and change BIOS boot mode from Legacy to UEFI!
)
pause & goto :MAIN_MENU

:ENABLE_NET
cls
echo  === ENABLE WINPE NETWORK ===
echo  [*] Initializing network components (wpeinit)...
wpeinit
echo  [*] Waiting for IP Address (please wait 5 seconds)...
ping 127.0.0.1 -n 6 >nul
ipconfig
echo  [OK] Network services started.
pause & goto :MAIN_MENU

:DISK_INFO
cls
echo  === DISK AND VOLUME SUMMARY ===
echo list disk | diskpart
echo.
echo list volume | diskpart
pause & goto :MAIN_MENU

:OPEN_NOTEPAD
cls
echo  [i] Notepad opened. 
echo  Hint: Go to File -^> Open, change "Text Documents" to "All Files".
echo  You can now use this as a Mini File Explorer to copy/paste files!
start notepad
goto :MAIN_MENU

:OPEN_REG
cls
echo  [i] Registry Editor opened.
echo  Hint: To edit the offline registry: 
echo  1. Select HKEY_LOCAL_MACHINE
echo  2. Go to File -^> Load Hive
echo  3. Open %WINDRIVE%:\Windows\System32\config\SOFTWARE (or SYSTEM).
start regedit
goto :MAIN_MENU