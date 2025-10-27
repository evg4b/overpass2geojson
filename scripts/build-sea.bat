@echo off
setlocal enabledelayedexpansion

REM Определяем архитектуру
set ARCH=%PROCESSOR_ARCHITECTURE%
if "%ARCH%"=="AMD64" set ARCH=x64
if "%ARCH%"=="ARM64" set ARCH=arm64

set OUTPUT_NAME=overpass2geojson-windows-%ARCH%.exe

echo.
echo 🔨 Building Node.js SEA for Windows %ARCH%...
echo    Output: %OUTPUT_NAME%
echo.

REM 1. Сборка с rspack
echo 📦 Step 1: Building with rspack...
call yarn build
if errorlevel 1 (
    echo ❌ Build failed
    exit /b 1
)

REM 2. Генерация blob
echo.
echo 🗜️  Step 2: Generating SEA blob...
node --experimental-sea-config sea-config.json
if errorlevel 1 (
    echo ❌ SEA blob generation failed
    exit /b 1
)

REM 3. Копирование Node.js binary
echo.
echo 📋 Step 3: Copying Node.js binary...

REM Используем process.execPath для получения настоящего пути к Node.js
for /f "delims=" %%i in ('node -e "console.log(process.execPath)"') do set NODE_PATH=%%i
echo    Using Node.js binary: %NODE_PATH%

copy "%NODE_PATH%" "%OUTPUT_NAME%" >nul
if errorlevel 1 (
    echo ❌ Failed to copy Node.js binary
    exit /b 1
)

REM 4. Инжект blob в binary
echo.
echo 💉 Step 4: Injecting SEA blob into binary...
call npx postject "%OUTPUT_NAME%" NODE_SEA_BLOB sea-prep.blob --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2
if errorlevel 1 (
    echo ❌ Injection failed
    exit /b 1
)

REM 5. Очистка
echo.
echo 🧹 Step 5: Cleaning up...
if exist sea-prep.blob del sea-prep.blob

echo.
echo ✅ Done! Executable created: %OUTPUT_NAME%
for %%A in ("%OUTPUT_NAME%") do echo    Size: %%~zA bytes

echo.
echo 📝 To test the executable:
echo    %OUTPUT_NAME%
echo.

endlocal
