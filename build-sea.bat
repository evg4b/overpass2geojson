@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo 🔨 Building SEA (Single Executable Application)...
echo.

REM Проверяем Node.js
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Node.js не найден. Установите Node.js версии 20 или выше
    exit /b 1
)

echo [1/5] Создание бандла с rsbuild...
call npm run build
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Ошибка при создании бандла
    exit /b 1
)

echo [2/5] Генерация blob файла...
node --experimental-sea-config sea-config.json
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Ошибка при генерации blob
    exit /b 1
)

echo [3/5] Копирование Node.js binary...
for /f "tokens=*" %%i in ('where node') do set NODE_PATH=%%i
copy "%NODE_PATH%" overpass2geojson.exe >nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Ошибка при копировании node.exe
    exit /b 1
)

echo [4/5] Удаление signature...
signtool remove /s overpass2geojson.exe >nul 2>&1

echo [5/5] Внедрение blob в исполняемый файл...
npx postject overpass2geojson.exe NODE_SEA_BLOB sea-prep.blob --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Ошибка при внедрении blob
    exit /b 1
)

echo.
echo ✅ Сборка завершена!
echo.
echo Исполняемый файл: overpass2geojson.exe
echo.
echo Для запуска:
echo   overpass2geojson.exe
echo.

REM Показываем размер файла
for %%A in (overpass2geojson.exe) do echo Размер: %%~zA байт

pause
