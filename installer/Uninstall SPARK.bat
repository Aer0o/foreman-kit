@echo off
title Remove SPARK
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0files\install.ps1" -Uninstall %*
pause
