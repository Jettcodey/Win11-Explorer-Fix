@echo off
:: Check if the script is running as Admin.
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :adminCheckPassed
) else (
    goto :runAsAdmin
)

:adminCheckPassed
echo Running as Admin. Script by https://github.com/Jettcodey
echo.
echo !WARNING! This Script Modifies Your Windows Registry! Use at your own Risk!
echo Choose an option:
echo 1: Fix Windows 11 Explorer
echo 2: Un-Fix Windows 11 Explorer
echo.
set /p choice=Enter your choice (1 or 2): 

if "%choice%" == "1" (
    goto :fixExplorer
) else if "%choice%" == "2" (
    goto :unfixExplorer
) else (
    echo Invalid choice. Exiting...
    goto :EOF
)

:fixExplorer
echo Fixing Windows 11 Explorer...
:: Search and delete the specified registry keys
for %%i in ({F874310E-B6B7-47DC-BC84-B9E6B38F5903} {E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}) do (
    for /f "tokens=*" %%a in ('reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop /s /f %%i 2^>nul') do (
        echo Found key: %%a
        reg delete "%%a" /f > nul 2> nul
        echo Registry key %%i deleted.
    )
)
:: User Choice to Enable the Classic Context Menu
set /p contextMenu=Do you want to Enable the Windows 10 Context Menu? (y/n):
if /i "%contextMenu%"=="y" (
    reg add HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32 /ve /d "" /f
    echo Fix applied to Enable the Classic Context Menu.
) else (
    echo Keeping Windows 11 Context Menu.
)

:: Change LaunchTo(Explorer Start Page) value from 0(Home Folder) to 1(This PC)
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 1 /f
echo Changed the Explorer Start Page to "This PC".

:: User Choice to delete the OneDrive registry key
set /p deleteOneDrive=Do you want to Remove the OneDrive entry?"(OneDrive will not be uninstalled)"  (y/n): 
if /i "%deleteOneDrive%"=="y" (
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
    echo OneDrive registry key deleted.
) else (
    echo OneDrive registry key was not deleted.
)
goto :restartExplorer

:unfixExplorer
echo Un-Fixing Windows 11 Explorer...
:: Add the specified registry keys
for %%i in ({F874310E-B6B7-47DC-BC84-B9E6B38F5903} {E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}) do (
    reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\%%i /f
    echo Registry key %%i added.
)

:: User Choice to Disable or keep the Classic Context Menu
set /p contextMenurevert=Restore Windows 11 Context Menu? (y/n):
if /i "%contextMenurevert%"=="y" (
    reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
    echo Windows 11 Context Has been restored.
) else (
    echo Keeping Windows 10 Context Menu.
)

:: Ask if the user wants to reset the Explorer Start Page to the Home Folder
set /p resetLaunchTo=Do you want to reset the Explorer Start Page back to the Home Folder? (y/n): 
if /i "%resetLaunchTo%"=="y" (
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 0 /f
    echo Explorer start page was Reset to the "Home Folder".
) else (
    echo Explorer start page remains "This PC".
)

:: Ask if the user wants to restore the OneDrive registry key
set /p restoreOneDrive=Do you want to restore the OneDrive entry? (y/n): 
if /i "%restoreOneDrive%"=="y" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /ve /d "OneDrive" /f
    echo OneDrive entry restored.
) else (
    echo OneDrive entry was not restored.
)

set /p disableAnnoyingUSB=Do you want to disable annoying USB notifications (ex. Scan and Fix)? (y/n): 
if /i "%disableAnnoyingUSB%"=="y" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /ve /d "OneDrive" /f
    echo Annoying USB notifications have been disabled.
) else (
    echo Annoying USB notifications have not been disabled.
)

goto :restartExplorer

:restartExplorer
echo Restarting explorer.exe...
taskkill /f /im explorer.exe
timeout /t 2 /nobreak >nul
start explorer.exe
echo Explorer.exe restarted.
goto :EOF

:runAsAdmin
echo Not running as admin. Attempting to run re-open as Admin...
:: Re-run the script as Admin.
cd /d %~dp0
powershell -Command "Start-Process '%~s0' -Verb runAs"
goto :EOF
