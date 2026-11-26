@echo off
title Instalador del Generador de Codigo para Visual Basic 6.0
echo ===========================================================================
echo   INSTALADOR DEL GENERADOR DE CODIGO PARA VISUAL BASIC 6.0
echo ===========================================================================
echo.

:: Solicitar permisos de Administrador para registrar el DLL e ini de Windows
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Solicitando permisos de Administrador...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "BASE_DIR=%~dp0"
set "COMP_DIR=%BASE_DIR%Complemento_VB6"
set "TARGET_DIR=%LOCALAPPDATA%\AntigravityVB6AddIn"
set "SKILL_DIR=%USERPROFILE%\.gemini\config\skills\vb6-algoritmos-archivos"

if not exist "%COMP_DIR%\Addin.dll" (
    echo [ERROR] No se encontro la carpeta Complemento_VB6 en: %COMP_DIR%
    pause
    exit /b 1
)

echo [*] Instalando archivos en este usuario (%USERNAME%)...

:: 1. Copiar archivos usando variables dinamicas (%LOCALAPPDATA% y %USERPROFILE%)
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
copy /y "%COMP_DIR%\Addin.dll" "%TARGET_DIR%\" >nul
copy /y "%COMP_DIR%\prepare_and_run.py" "%TARGET_DIR%\" >nul
copy /y "%COMP_DIR%\fix_vb6_encoding.py" "%TARGET_DIR%\" >nul
copy /y "%COMP_DIR%\run_agy.bat" "%TARGET_DIR%\" >nul

if not exist "%SKILL_DIR%" mkdir "%SKILL_DIR%"
copy /y "%COMP_DIR%\SKILL.md" "%SKILL_DIR%\SKILL.md" >nul

:: 2. Registrar Addin.dll (SysWOW64 en 64-bit o System32 en 32-bit)
if exist "%SystemRoot%\SysWOW64\regsvr32.exe" (
    "%SystemRoot%\SysWOW64\regsvr32.exe" /s "%TARGET_DIR%\Addin.dll"
) else (
    regsvr32 /s "%TARGET_DIR%\Addin.dll"
)

:: 3. Habilitar complemento en vbaddin.ini (Windows y VirtualStore) y Registro HKCU
powershell -Command "$entry='MyAddIn.Connect=3'; foreach($p in @(\"$env:windir\vbaddin.ini\",\"$env:LOCALAPPDATA\VirtualStore\Windows\vbaddin.ini\")){ $d=Split-Path $p; if(!(Test-Path $d)){New-Item -ItemType Directory -Force -Path $d|Out-Null}; if(Test-Path $p){$lines=Get-Content $p | Where-Object {$_ -notmatch '^MyAddIn\.Connect='}; $lines += $entry; Set-Content -Path $p -Value $lines -Encoding Default}else{Set-Content -Path $p -Value @('[Add-Ins32]',$entry) -Encoding Default} }; $reg='HKCU:\Software\Microsoft\Visual Basic\6.0\Addins\MyAddIn.Connect'; if(!(Test-Path $reg)){New-Item -Path $reg -Force|Out-Null}; Set-ItemProperty -Path $reg -Name 'LoadBehavior' -Value 3 -Type DWord; Set-ItemProperty -Path $reg -Name 'FriendlyName' -Value 'Generador de Codigo' -Type String; Set-ItemProperty -Path $reg -Name 'Description' -Value 'Generador de Codigo para VB6' -Type String"

echo [OK] Complemento y Skill instalados correctamente.
echo.

:: 4. Verificar Python, Pillow y Antigravity CLI en esta PC
where pythonw >nul 2>&1
if %errorlevel% neq 0 (
    echo [AVISO] No se detecto Python 3 en esta PC. Instalalo desde python.org ^(marcando Add to PATH^).
) else (
    echo [OK] Python detectado. Verificando libreria Pillow...
    python -c "import PIL" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [*] Instalando Pillow para soporte de capturas de pantalla...
        python -m pip install pillow --quiet
    )
)

set "AGY_OK=0"
if exist "%LOCALAPPDATA%\agy\bin\agy.exe" set "AGY_OK=1"
if exist "%USERPROFILE%\.gemini\bin\agy.exe" set "AGY_OK=1"
where agy >nul 2>&1
if %errorlevel% equ 0 set "AGY_OK=1"

if "%AGY_OK%"=="0" (
    echo [AVISO] No se detecto Antigravity CLI ^(agy^) en esta PC. Instalalo e inicia sesion para usar el generador.
) else (
    echo [OK] Antigravity CLI detectado.
)

echo.
echo ===========================================================================
echo   LISTO! YA PUEDES ABRIR VISUAL BASIC 6.0 EN ESTA PC.
echo ===========================================================================
pause
