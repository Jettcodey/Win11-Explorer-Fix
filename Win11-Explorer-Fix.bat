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
echo THIS SCRIPT WONT UNINSTALL ANYTHING, IT ONLY DISABLES/ENABLES CERTAIN FEATURES THROUGH REGISTRY KEYS.
echo YOURE IN CONTROL OF WHAT YOU WANT TO ENABLE/DISABLE, SO READ THE PROMPTS CAREFULLY!
echo.
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
:: Search and delete the specified registry keys for removing the "Home" and "Gallery" entries from File Explorer
set /p removeHomeGallery=Do you want to remove the "Home" and "Gallery" entries from File Explorer? (y/n):
if /i "%removeHomeGallery%"=="y" (
    for %%i in ({F874310E-B6B7-47DC-BC84-B9E6B38F5903} {E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}) do (
        for /f "tokens=*" %%a in ('reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop /s /f %%i 2^>nul') do (
            echo Found key: %%a
            reg delete "%%a" /f > nul 2> nul
            echo Registry key %%i deleted.
        )
    )
) else (
    echo Keeping "Home" and "Gallery" entries in File Explorer.
)

:: Change LaunchTo(Explorer Start Page) value from 0(Home Folder) to 1(This PC)
set /p launchTo=Do you want to change the Explorer Start Page to "This PC"? (y/n): 
if /i "%launchTo%"=="y" (
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 1 /f
    echo Changed the Explorer Start Page to "This PC".
) else (
    echo Keeping Explorer Start Page unchanged.
)

:: User Choice to Enable the Classic Context Menu
set /p contextMenu=Do you want to Enable the Windows 10 Context Menu? (y/n): 
if /i "%contextMenu%"=="y" (
    reg add HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32 /ve /d "" /f
    echo Fix applied to Enable the Classic Context Menu.
) else (
    echo Keeping the Windows 11 Context Menu.
)

:: User Choice to delete the OneDrive registry key
set /p deleteOneDrive=Do you want to Remove the OneDrive entry? (y/n): 
if /i "%deleteOneDrive%"=="y" (
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f
    echo OneDrive registry key deleted.
) else (
    echo OneDrive registry key was not deleted.
)

:: Ask if the user wants to disable annoying USB notifications
set /p disableAnnoyingUSB=Do you want to disable annoying USB notifications (e.g. Scan and Fix)? (y/n): 
if /i "%disableAnnoyingUSB%"=="y" (
    reg add HKCU\Software\Microsoft\Shell\USB /v NotifyOnUsbErrors /t REG_DWORD /d 0 /f
    echo Annoying USB notifications have been disabled.
) else (
    echo Annoying USB notifications have not been disabled.
)

:: Ask if the user wants to disable AutoPlay
set /p disableAutoPlay=Do you want to disable AutoPlay? (y/n): 
if /i "%disableAutoPlay%"=="y" (
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoDriveTypeAutoRun /t REG_DWORD /d 255 /f
    echo AutoPlay has been disabled.
) else (
    echo AutoPlay has not been disabled.
)

:: Ask the user if they want to disable the "Look for an app in the Store" Popup
set /p disableStorePopup=Do you want to disable the "Look for an app in the Store" popup? (y/n): 
if /i "%disableStorePopup%"=="y" (
    reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer /f /t REG_DWORD /v "NoUseStoreOpenWith" /d 1
    echo "Look for an app in the Store" popup has been disabled.
) else (
    echo "Look for an app in the Store" popup will not be disabled.
)

:: Hide Start Menu Recommended Section in Start Menu
set /p hideRecommended=Do you want to hide the Recommended section in Start Menu? (y/n): 
if /i "%hideRecommended%"=="y" (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v HideRecommendedSection /t REG_DWORD /d 1 /f
    reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v HideRecommendedSection /t REG_DWORD /d 1 /f
    reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Education" /v IsEducationEnvironment /t REG_DWORD /d 1 /f
    echo Hide Recommended section keys applied.
) else (
    echo Recommended section will not be hidden.
)

:: Ask the user if they use/have the Xbox GameBar/Gaming Overlay installed
set /p xboxOverlay=Do you have Xbox Game Bar/Gaming Overlay installed? (If not, please enter "n" to proceed to the next prompt.) (y/n): 
if /i "%xboxOverlay%"=="y" (
    echo Okay no changes will and need to be made.
    goto :restartExplorer
) else (
    goto :disableXboxGameBar
)

goto :restartExplorer

:unfixExplorer
echo Un-Fixing Windows 11 Explorer...
:: Add the specified registry keys for restoring the "Home" and "Gallery" entries in File Explorer
set /p restoreHomeGallery=Do you want to restore the "Home" and "Gallery" entries in File Explorer? (y/n): 
if /i "%restoreHomeGallery%"=="y" (    
    for %%i in ({F874310E-B6B7-47DC-BC84-B9E6B38F5903} {E88865EA-0E1C-4E20-9AA6-EDCD0212C87C}) do (
        reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\%%i /f
        echo Registry key %%i added.
    )
) else (
    echo Won´t restore "Home" and "Gallery" entries in File Explorer.
)

:: Ask if the user wants to reset the Explorer Start Page to the Home Folder
set /p resetLaunchTo=Do you want to reset the Explorer Start Page back to the "Home" Folder? (y/n): 
if /i "%resetLaunchTo%"=="y" (
    reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 0 /f
    echo Explorer start page was Reset to the "Home" Folder.
) else (
    echo Explorer start page remains "This PC".
)

:: User Choice to Disable or keep the Classic Context Menu
set /p contextMenurevert=Restore Windows 11 Context Menu? (y/n): 
if /i "%contextMenurevert%"=="y" (
    reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
    echo Windows 11 Context Menu Has been restored.
) else (
    echo Windows 11 Context Menu has not been restored.
)

:: Ask if the user wants to restore the OneDrive registry key
set /p restoreOneDrive=Do you want to restore the OneDrive entry? (y/n): 
if /i "%restoreOneDrive%"=="y" (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /ve /d "OneDrive" /f
    echo OneDrive File Explorer entry restored.
) else (
    echo OneDrive File Explorer entry was not restored.
)

:: Ask if the user wants to restore annoying USB notifications
set /p restoreAnnoyingUSB=Do you want to restore the annoying USB notifications (ex. Scan and Fix)? (y/n): 
if /i "%restoreAnnoyingUSB%"=="y" (
    reg add HKCU\Software\Microsoft\Shell\USB /v NotifyOnUsbErrors /t REG_DWORD /d 0 /f
    echo Annoying USB notifications have been restored.
) else (
    echo Annoying USB notifications have not been restored.
)

:: Ask if the user wants to restore AutoPlay
set /p restoreAutoPlay=Do you want to restore AutoPlay? (y/n): 
if /i "%restoreAutoPlay%"=="y" (
    reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer /v NoDriveTypeAutoRun /f
    echo AutoPlay has been restored.
) else (
    echo AutoPlay has not been restored.
)

:: Ask the user if they want to restore the "Look for an app in the Store" Popup
set /p restoreStorePopup=Do you want to restore the "Look for an app in the Store" popup? (y/n): 
if /i "%restoreStorePopup%"=="y" (
    reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer /v "NoUseStoreOpenWith" /f
    echo "Look for an app in the Store" popup has been restored.
) else (
    echo "Look for an app in the Store" popup will not be restored.
)

:: Ask if the user wants to restore the Start Menu Recommended Section keys
set /p unhideRecommended=Do you want to restore the Recommended section in Start Menu? (y/n): 
if /i "%unhideRecommended%"=="y" (
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v HideRecommendedSection /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start" /v HideRecommendedSection /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Education" /v IsEducationEnvironment /f >nul 2>&1
    echo Start Menu Recommended section has been restored.
) else (
    echo Recommended section keys were not changed.
)

:: Ask the user if they use/have the Xbox GameBar/Gaming Overlay installed
set /p xboxOverlay=Did you previously disable the Xbox Game Bar/Gaming Overlay popup because you do not have Xbox Game Bar/Overlay installed? (y/n): 
if /i "%xboxOverlay%"=="y" (
    goto :enableXboxGameBar
) else (
    echo Okay no changes will and need to be made.
    goto :restartExplorer
)

goto :restartExplorer

:: Disable Xbox Game Bar/Overlay Popup "you'll need a new app to open this 'ms-gamingoverlay' link" when Xbox Game Bar is uninstalled 
:disableXboxGameBar
set /p disableOverlay=Do you want to disable the "you'll need a new app to open this 'ms-gamingoverlay' link" popup? (y/n): 
if /i "%disableOverlay%"=="y" (
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f
    echo Xbox Game Bar popup has been disabled.
) else (
    echo Xbox Game Bar popup will not be disabled.
)
goto :restartExplorer

:: Enable Xbox Game Bar/Overlay Popup "you'll need a new app to open this 'ms-gamingoverlay' link" when Xbox Game Bar is uninstalled
:enableXboxGameBar
set /p enableOverlay=Do you want to restore the "you'll need a new app to open this 'ms-gamingoverlay' link" popup when Xbox GameBar/Overlay is uninstalled? (y/n): 
if /i "%enableOverlay%"=="y" (
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 1 /f
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 1 /f
    echo Xbox Game Bar popup has been enabled.
) else (
    echo Xbox Game Bar popup will not be enabled.
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
