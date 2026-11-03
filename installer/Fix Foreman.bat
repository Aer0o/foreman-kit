@echo off
title Foreman repair
echo Reinstalling anything Foreman needs that has gone missing...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0files\install.ps1" -Yes %*
pause
