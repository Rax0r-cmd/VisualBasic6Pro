@echo off
chcp 65001 >nul
title Consola de Desarrollo - Visual Basic 6.0

set "WORKDIR=%~1"
set "PROMPT=%~2"

if "%WORKDIR%"=="" set "WORKDIR=%OneDrive%\Desktop"
if not exist "%WORKDIR%\*" set "WORKDIR=%OneDrive%\Desktop"
if not exist "%WORKDIR%\*" set "WORKDIR=%USERPROFILE%\OneDrive\Desktop"
if not exist "%WORKDIR%\*" set "WORKDIR=%USERPROFILE%\Desktop"
if not exist "%WORKDIR%\*" set "WORKDIR=%USERPROFILE%"

cd /d "%WORKDIR%"

echo ===================================================================
echo           CONSOLA DE DESARROLLO - VISUAL BASIC 6.0
echo ===================================================================
echo [*] Directorio de proyecto: %CD%
if not "%PROMPT%"=="" echo [*] Peticion inicial: %PROMPT%
echo ===================================================================
echo.

python "%~dp0prepare_and_run.py" "%WORKDIR%" "%PROMPT%"

echo.
echo [*] Proceso finalizado. Puedes cerrar esta ventana o volver a Visual Basic.
pause
