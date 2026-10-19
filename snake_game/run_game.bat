@echo off
set "PATH=%LOCALAPPDATA%\LOVE;%PATH%"
cd /d "%~dp0"
start "" "%LOCALAPPDATA%\LOVE\love.exe" .
