@echo off
setlocal enabledelayedexpansion

set DOTNET_PATH=C:\Program Files\dotnet\dotnet.exe
set POWERSHELL_PATH=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

echo BetaSharp Build Script
echo.

REM Создаём папку dist если её нет
if not exist "dist" (
    echo Creating dist directory...
    mkdir dist
)

REM Очищаем dist перед сборкой
echo Cleaning dist directory...
rmdir /s /q dist\* 2>nul

REM Сборка основной библиотеки
echo.
echo Building BetaSharp core library...
cd BetaSharp
"%DOTNET_PATH%" build --configuration Release
if !errorlevel! neq 0 (
    echo ERROR: Failed to build BetaSharp
    cd ..
    exit /b 1
)
cd ..

REM Сборка клиента
echo.
echo Building BetaSharp.Client...
cd BetaSharp.Client
"%DOTNET_PATH%" build --configuration Release
if !errorlevel! neq 0 (
    echo ERROR: Failed to build BetaSharp.Client
    cd ..
    exit /b 1
)
cd ..

REM Сборка сервера
echo.
echo Building BetaSharp.Server...
cd BetaSharp.Server
"%DOTNET_PATH%" build --configuration Release
if !errorlevel! neq 0 (
    echo ERROR: Failed to build BetaSharp.Server
    cd ..
    exit /b 1
)
cd ..

REM Сборка лаунчера
echo.
echo Building BetaSharp.Launcher...
cd BetaSharp.Launcher
"%DOTNET_PATH%" build --configuration Release
if !errorlevel! neq 0 (
    echo ERROR: Failed to build BetaSharp.Launcher
    cd ..
    exit /b 1
)
cd ..

REM Копируем файлы в dist
echo.
echo Copying build artifacts to dist...

REM Ищем output папки и копируем их
for /d %%D in (BetaSharp BetaSharp.Client BetaSharp.Server BetaSharp.Launcher) do (
    for /d %%O in ("%%D\bin\Release\net*") do (
        echo Copying %%D...
        if exist "dist\%%D" rmdir /s /q "dist\%%D"
        "%POWERSHELL_PATH%" -NoProfile -Command "Copy-Item -Path '%%O' -Destination 'dist\%%D' -Recurse -Force" >nul
    )
)

REM Копируем JAR файл если существует
if exist "jar" (
    echo Copying JAR files...
    if exist "dist\jar" rmdir /s /q "dist\jar"
    "%POWERSHELL_PATH%" -NoProfile -Command "Copy-Item -Path 'jar' -Destination 'dist\jar' -Recurse -Force" >nul
)

REM Копируем шрифты если существуют
if exist "font" (
    echo Copying font files...
    if exist "dist\font" rmdir /s /q "dist\font"
    "%POWERSHELL_PATH%" -NoProfile -Command "Copy-Item -Path 'font' -Destination 'dist\font' -Recurse -Force" >nul
)

echo.
echo Build completed successfully!
echo Output directory: dist\
