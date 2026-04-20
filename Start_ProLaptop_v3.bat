@echo off
title Pro Laptop Ultimate v2.0 - Launcher
color 0A

:: ============================================================
::  Admin Check
:: ============================================================
NET SESSION >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [!] Right-click this file and select "Run as Administrator"
    echo.
    pause
    exit /b 1
)

:: ============================================================
::  Check PS1 exists in same folder
:: ============================================================
if not exist "%~dp0ProLaptop_Ultimate_v3.ps1" (
    echo.
    echo  [!] ERROR: ProLaptop_Ultimate_v3.ps1 not found!
    echo  [!] Both files must be in the SAME folder.
    echo  [!] Current folder: %~dp0
    echo.
    pause
    exit /b 1
)

set "SCRIPT=%~dp0ProLaptop_Ultimate_v3.ps1"

:: ============================================================
::  Try Windows Terminal first (better display), then fallback
:: ============================================================
where wt.exe >nul 2>&1
if %ERRORLEVEL% == 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "Start-Process wt.exe -ArgumentList 'powershell -NoExit -ExecutionPolicy Bypass -File \"%SCRIPT%\"' -Verb RunAs"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
      "Start-Process PowerShell -ArgumentList '-NoExit -ExecutionPolicy Bypass -File \"%SCRIPT%\"' -Verb RunAs"
)
