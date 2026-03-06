@echo off
setlocal enabledelayedexpansion

REM Скрипт создания установщиков BetaSharp
REM Создаёт: EXE Installer (Inno Setup)

set VERSION=1.0.0
set PRODUCT_NAME=BetaSharp
set POWERSHELL_PATH=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
set INNO_SETUP_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe
set TEMP_DIR=%TEMP%\betasharp_build_%RANDOM%

echo.
echo %PRODUCT_NAME% Installer Creation
echo.

REM Проверяем наличие папки dist
if not exist "dist" (
    echo ОШИБКА: папка dist не найдена. Сначала запустите build.bat
    pause
    exit /b 1
)

REM Создаём выходную директорию
if not exist "dist_install" mkdir dist_install

REM Очищаем предыдущие сборки
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!" >nul 2>&1
mkdir "!TEMP_DIR!"

echo.
echo [1/1] Создание EXE установщика (Inno Setup)...
call :create_inno_setup_installer
if !errorlevel! neq 0 (
    echo ОШИБКА: не удалось создать EXE установщик
    goto cleanup
)

:cleanup
echo.
echo Установщик создан!
echo.
echo Результаты в: dist_install\
echo.
if exist "dist_install\BetaSharp-Setup.exe" (
    echo Создано: BetaSharp-Setup.exe
)
echo.
echo Для установки запустите BetaSharp-Setup.exe
echo.

REM Очищаем временную директорию
if exist "!TEMP_DIR!" rmdir /s /q "!TEMP_DIR!" >nul 2>&1

pause
exit /b 0

REM ФУНКЦИЯ: Создание EXE установщика с помощью Inno Setup
:create_inno_setup_installer
setlocal enabledelayedexpansion
echo Создание EXE установщика...

REM Проверяем наличие Inno Setup
if not exist "!INNO_SETUP_PATH!" (
    echo ОШИБКА: Inno Setup не найден в !INNO_SETUP_PATH!
    endlocal
    exit /b 1
)

set "INNO_DIR=!TEMP_DIR!\inno"
mkdir "!INNO_DIR!"

REM Копируем файлы установки (исключаем PDB файлы)
echo   Копирование файлов...
if exist "dist\BetaSharp.Launcher" (
    "%POWERSHELL_PATH%" -NoProfile -Command "Copy-Item -Path 'dist\BetaSharp.Launcher\*' -Destination '!INNO_DIR!\' -Recurse -Force -Exclude '*.pdb'" >nul 2>&1
)

if exist "dist\BetaSharp.Client" (
    "%POWERSHELL_PATH%" -NoProfile -Command "Copy-Item -Path 'dist\BetaSharp.Client\*' -Destination '!INNO_DIR!\Client\' -Recurse -Force -Exclude '*.pdb'" >nul 2>&1
)

if exist "dist\BetaSharp.Server" (
    "%POWERSHELL_PATH%" -NoProfile -Command "Copy-Item -Path 'dist\BetaSharp.Server\*' -Destination '!INNO_DIR!\Server\' -Recurse -Force -Exclude '*.pdb'" >nul 2>&1
)

if exist "dist\jar" (
    "%POWERSHELL_PATH%" -NoProfile -Command "Copy-Item -Path 'dist\jar' -Destination '!INNO_DIR!\' -Recurse -Force" >nul 2>&1
)

if exist "dist\font" (
    "%POWERSHELL_PATH%" -NoProfile -Command "Copy-Item -Path 'dist\font\*' -Destination '!INNO_DIR!\font\' -Recurse -Force" >nul 2>&1
)

REM Копируем лицензию
if exist "LICENSE.md" (
    copy "LICENSE.md" "!INNO_DIR!\LICENSE.txt" >nul 2>&1
)

REM Копируем иконку Launcher
if exist "BetaSharp.Launcher\logo.ico" (
    copy "BetaSharp.Launcher\logo.ico" "!INNO_DIR!\logo.ico" >nul 2>&1
)



REM Получаем текущую директорию для абсолютных путей
for /f "delims=" %%A in ('cd') do set "CURRENT_DIR=%%A"
set "ISS_FILE=!INNO_DIR!\BetaSharp.iss"
set "OUTPUT_DIR=!CURRENT_DIR!\dist_install"
set "OUTPUT_EXE=!OUTPUT_DIR!\BetaSharp-Setup.exe"

REM Проверяем что файлы скопированы
if not exist "!INNO_DIR!\BetaSharp.Launcher.exe" (
    echo ОШИБКА: BetaSharp.Launcher.exe не скопирован в !INNO_DIR!
    endlocal
    exit /b 1
)

REM Обновляем .iss файл с абсолютным OutputDir и иконкой
(
    echo ; BetaSharp Inno Setup Script
    echo ; Создаёт профессиональный установщик для Windows
    echo.
    echo [Setup]
    echo AppName=BetaSharp
    echo AppVersion=%VERSION%
    echo AppPublisher=BetaSharp Team
    echo AppPublisherURL=https://github.com/Fazin85/betasharp
    echo AppSupportURL=https://github.com/Fazin85/betasharp
    echo DefaultDirName={pf}\BetaSharp
    echo DefaultGroupName=BetaSharp
    echo AllowNoIcons=yes
    echo LicenseFile=LICENSE.txt
    echo OutputDir=!OUTPUT_DIR!
    echo OutputBaseFilename=BetaSharp-Setup
    echo Compression=lzma
    echo SolidCompression=yes
    echo WizardStyle=modern
    echo ArchitecturesInstallIn64BitMode=x64
    echo SetupIconFile=logo.ico
    echo.
    echo [Languages]
    echo Name: "english"; MessagesFile: "compiler:Default.isl"
    echo Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
    echo Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"
    echo.
    echo [Tasks]
    echo Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
    echo Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1
    echo.
    echo [Files]
    echo Source: "*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.iss"
    echo.
    echo [Icons]
    echo Name: "{commondesktop}\BetaSharp"; Filename: "{app}\BetaSharp.Launcher.exe"; IconFilename: "{app}\logo.ico"; Tasks: desktopicon
    echo Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\BetaSharp"; Filename: "{app}\BetaSharp.Launcher.exe"; IconFilename: "{app}\logo.ico"; Tasks: quicklaunchicon
    echo.
    echo [Run]
    echo Filename: "{app}\BetaSharp.Launcher.exe"; Description: "{cm:LaunchProgram,BetaSharp}"; Flags: nowait postinstall skipifsilent
    echo.
) > "!ISS_FILE!"

REM Компилируем Inno Setup скрипт в EXE
echo   Компиляция установщика...
"!INNO_SETUP_PATH!" "!ISS_FILE!"

if exist "!OUTPUT_EXE!" (
    echo EXE установщик успешно создан
    endlocal
    exit /b 0
) else (
    echo ОШИБКА: не удалось скомпилировать установщик
    echo Проверьте логи выше
    endlocal
    exit /b 1
)
