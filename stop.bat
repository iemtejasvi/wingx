@echo off
setlocal
echo Stopping miner and removing persistent installation...

:: Variables
set "installDir=%APPDATA%\SystemMaintenance"
set "startupDir=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "shortcutName=SystemMaintenance.lnk"
set "minerExe=wingx.exe"
set "batchFile=run_miner.bat"
set "vbsFile=run_miner.vbs"

:: Kill running miner process (force stop)
taskkill /IM %minerExe% /F >nul 2>&1
taskkill /IM cscript.exe /F >nul 2>&1
taskkill /IM wscript.exe /F >nul 2>&1

:: Delete startup shortcut
if exist "%startupDir%\%shortcutName%" (
    echo Deleting startup shortcut...
    del "%startupDir%\%shortcutName%"
)

:: Delete miner files and scripts
if exist "%installDir%\%minerExe%" (
    echo Deleting miner executable...
    del "%installDir%\%minerExe%"
)
if exist "%installDir%\%batchFile%" (
    echo Deleting mining batch file...
    del "%installDir%\%batchFile%"
)
if exist "%installDir%\%vbsFile%" (
    echo Deleting VBScript...
    del "%installDir%\%vbsFile%"
)

:: Ensure no hidden scripts are running
wmic process where "commandline like '%%run_miner%%'" call terminate >nul 2>&1

:: Remove the installation directory if it's empty
if exist "%installDir%" (
    echo Removing install directory...
    rd /s /q "%installDir%"
)

:: Clear possible registry persistence (just in case)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "SystemMaintenance" /f >nul 2>&1

echo Cleanup complete. Restart your PC to ensure all traces are removed.
pause
exit
