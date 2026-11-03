@echo off
title SPARK repair
echo Reinstalling anything SPARK needs that has gone missing...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0files\install.ps1" -Yes %*
pause
