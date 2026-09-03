@echo off
setlocal enabledelayedexpansion

echo ============================================
echo   DS4Windows Local Installer (Custom Build)
echo ============================================
echo.

set INSTALL_PATH=%LOCALAPPDATA%\DS4Windows
set PUBLISH_PATH=%~dp0publish\x64

:: 1. Check if published release exists; build if missing
if not exist "%PUBLISH_PATH%\DS4Windows.exe" (
    echo Building and publishing DS4Windows Release x64...
    dotnet publish "%~dp0DS4Windows\DS4WinWPF.csproj" -c Release /p:platform=x64 -o "%PUBLISH_PATH%"
    if %errorLevel% neq 0 (
        echo [ERROR] Build failed!
        pause
        exit /b 1
    )
)

:: 2. Close any active instance of DS4Windows
echo Closing any running DS4Windows instances...
taskkill /F /IM DS4Windows.exe >nul 2>&1

:: 3. Copy files to %LOCALAPPDATA%\DS4Windows
if not exist "%INSTALL_PATH%" mkdir "%INSTALL_PATH%"
echo Installing to %INSTALL_PATH%...
xcopy /E /I /Y /Q "%PUBLISH_PATH%\*" "%INSTALL_PATH%\" >nul

:: 4. Create Desktop Shortcut
echo Creating Desktop shortcut...
set DESKTOP_LINK=%USERPROFILE%\Desktop\DS4Windows.lnk
powershell -NoProfile -Command "$ws = New-Object -COMObject WScript.Shell; $s = $ws.CreateShortcut('%DESKTOP_LINK%'); $s.TargetPath = '%INSTALL_PATH%\DS4Windows.exe'; $s.WorkingDirectory = '%INSTALL_PATH%'; $s.IconLocation = '%INSTALL_PATH%\DS4Windows.exe'; $s.Save()"

:: 5. Create Start Menu Shortcut
echo Creating Start Menu shortcut...
set STARTMENU_LINK=%APPDATA%\Microsoft\Windows\Start Menu\Programs\DS4Windows.lnk
powershell -NoProfile -Command "$ws = New-Object -COMObject WScript.Shell; $s = $ws.CreateShortcut('%STARTMENU_LINK%'); $s.TargetPath = '%INSTALL_PATH%\DS4Windows.exe'; $s.WorkingDirectory = '%INSTALL_PATH%'; $s.IconLocation = '%INSTALL_PATH%\DS4Windows.exe'; $s.Save()"

echo.
echo ============================================
echo   Installation completed successfully!
echo ============================================
echo Location: %INSTALL_PATH%\DS4Windows.exe
echo Shortcuts created on Desktop and Start Menu.
echo.
pause
