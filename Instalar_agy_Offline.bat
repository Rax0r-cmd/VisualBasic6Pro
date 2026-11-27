@echo off
title Instalador Offline de Antigravity CLI (agy)
echo ===========================================================================
echo   INSTALADOR OFFLINE DE ANTIGRAVITY CLI (agy)
echo ===========================================================================
echo.

set "BASE_DIR=%~dp0"
set "AGY_ZIP=%BASE_DIR%Complemento_VB6\agy.zip"
set "AGY_DIR=%LOCALAPPDATA%\agy\bin"
set "AGY_EXE=%AGY_DIR%\agy.exe"

if not exist "%AGY_ZIP%" (
    echo [ERROR] No se encontro el paquete offline: %AGY_ZIP%
    pause
    exit /b 1
)

echo [*] Extrayendo agy.exe en %AGY_DIR% ...
if not exist "%AGY_DIR%" mkdir "%AGY_DIR%"
powershell -Command "Expand-Archive -Path '%AGY_ZIP%' -DestinationPath '%AGY_DIR%' -Force"
if %errorlevel% neq 0 (
    echo [ERROR] No se pudo extraer %AGY_ZIP%.
    pause
    exit /b 1
)

if not exist "%AGY_EXE%" (
    echo [ERROR] No se encontro %AGY_EXE% despues de extraer.
    pause
    exit /b 1
)

echo [*] Agregando %AGY_DIR% al PATH del usuario...
powershell -Command "$d='%AGY_DIR%'; $p=[Environment]::GetEnvironmentVariable('Path','User'); if(($p -split ';') -notcontains $d){ if($p -and -not $p.EndsWith(';')){$p+=';'}; [Environment]::SetEnvironmentVariable('Path', $p+$d, 'User') }"

echo [*] Verificando agy.exe ...
"%AGY_EXE%" --version
if %errorlevel% neq 0 (
    echo [ERROR] agy.exe no respondio correctamente.
    pause
    exit /b 1
)

echo.
echo [OK] Antigravity CLI (agy) instalado correctamente sin necesidad de internet.
echo [!] Si es la primera vez en esta PC, abre una terminal, ejecuta 'agy' e inicia sesion con Google.
echo ===========================================================================
pause
