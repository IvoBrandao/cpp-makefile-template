@echo off
:: Ensure the script is run as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo This script must be run as administrator
    exit /b 1
)

:: Install gcc, g++, and make using winget
winget install --id=GNU.gcc --silent
winget install --id=GnuWin32.make --silent

echo Installation complete.
Please restart the terminal to apply changes.
