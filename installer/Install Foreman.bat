@echo off
title Foreman setup
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0files\install.ps1" %*
pause
