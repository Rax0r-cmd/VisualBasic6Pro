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
set "CONFIG_DIR=%USERPROFILE%\.gemini\config"

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
powershell -Command "$entry='MyAddIn.Connect=3'; foreach($p in @(\"$env:windir\vbaddin.ini\",\"$env:LOCALAPPDATA\VirtualStore\Windows\vbaddin.ini\")){ $d=Split-Path $p; if(!(Test-Path $d)){New-Item -ItemType Directory -Force -Path $d|Out-Null}; if(Test-Path $p){$lines=@(Get-Content $p | ForEach-Object { $_ -replace 'MyAddIn\.Connect=\d+','' } | Where-Object { $_.Trim() -ne '' }); if($lines -notcontains '[Add-Ins32]'){$lines=@('[Add-Ins32]')+$lines}; $lines += $entry; Set-Content -Path $p -Value $lines -Encoding Default}else{Set-Content -Path $p -Value @('[Add-Ins32]',$entry) -Encoding Default} }; $reg='HKCU:\Software\Microsoft\Visual Basic\6.0\Addins\MyAddIn.Connect'; if(!(Test-Path $reg)){New-Item -Path $reg -Force|Out-Null}; Set-ItemProperty -Path $reg -Name 'LoadBehavior' -Value 3 -Type DWord; Set-ItemProperty -Path $reg -Name 'FriendlyName' -Value 'Generador de Codigo' -Type String; Set-ItemProperty -Path $reg -Name 'Description' -Value 'Generador de Codigo para VB6' -Type String"

echo [OK] Complemento y Skill instalados correctamente.
echo.

:: 4. Configurar modo automatico en Antigravity (config.json)
if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"
powershell -Command "$cfgPath='%CONFIG_DIR%\config.json'; if(Test-Path $cfgPath){ try{$j=Get-Content $cfgPath -Raw | ConvertFrom-Json}catch{$j=[pscustomobject]@{}} } else { $j=[pscustomobject]@{} }; if(-not $j.userSettings){ $j | Add-Member -NotePropertyName 'userSettings' -NotePropertyValue ([pscustomobject]@{}) -Force }; $j.userSettings | Add-Member -NotePropertyName 'artifactReviewMode' -NotePropertyValue 'ARTIFACT_REVIEW_MODE_TURBO' -Force; $j.userSettings | Add-Member -NotePropertyName 'autoExecutionPolicy' -NotePropertyValue 'CASCADE_COMMANDS_AUTO_EXECUTION_EAGER' -Force; $j | ConvertTo-Json -Depth 10 | Set-Content -Path $cfgPath -Encoding UTF8"
echo [OK] Politica de ejecucion automatica configurada.
echo.

:: 5. Verificar / Instalar Python 3 + Pillow
set "PY_EXE="
if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" set "PY_EXE=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
if "%PY_EXE%"=="" if exist "%ProgramFiles%\Python312\python.exe" set "PY_EXE=%ProgramFiles%\Python312\python.exe"
if "%PY_EXE%"=="" (
    for /f "delims=" %%P in ('where python 2^>nul') do (
        echo %%P | findstr /i "Inkscape WindowsApps" >nul
        if errorlevel 1 if "%PY_EXE%"=="" set "PY_EXE=%%P"
    )
)

if "%PY_EXE%"=="" (
    echo [*] Python 3 no detectado. Instalando Python 3.12 automaticamente...
    where winget >nul 2>&1
    if %errorlevel% equ 0 (
        winget install -e --id Python.Python.3.12 --accept-package-agreements --accept-source-agreements --silent
    )
    if not exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" if not exist "%ProgramFiles%\Python312\python.exe" (
        echo [*] Descargando instalador oficial de Python 3.12...
        powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.7/python-3.12.7-amd64.exe' -OutFile \"$env:TEMP\python_setup.exe\"; Start-Process -FilePath \"$env:TEMP\python_setup.exe\" -ArgumentList '/quiet','InstallAllUsers=1','PrependPath=1' -Wait; Remove-Item \"$env:TEMP\python_setup.exe\" -ErrorAction SilentlyContinue"
    )
    if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" set "PY_EXE=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
    if "%PY_EXE%"=="" if exist "%ProgramFiles%\Python312\python.exe" set "PY_EXE=%ProgramFiles%\Python312\python.exe"
) else (
    echo [OK] Python detectado: %PY_EXE%
)

if not "%PY_EXE%"=="" (
    "%PY_EXE%" -c "import PIL" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [*] Instalando libreria Pillow para capturas de pantalla...
        "%PY_EXE%" -m pip --version >nul 2>&1
        if %errorlevel% neq 0 "%PY_EXE%" -m ensurepip --upgrade >nul 2>&1
        "%PY_EXE%" -m pip install pillow --quiet
    )
)

:: 6. Verificar / Instalar Antigravity CLI (agy)
set "AGY_OK=0"
if exist "%LOCALAPPDATA%\agy\bin\agy.exe" set "AGY_OK=1"
if exist "%USERPROFILE%\.gemini\bin\agy.exe" set "AGY_OK=1"
where agy >nul 2>&1
if %errorlevel% equ 0 set "AGY_OK=1"

if "%AGY_OK%"=="0" (
    if exist "%COMP_DIR%\agy.zip" (
        echo [*] Instalando Antigravity CLI ^(agy^) desde paquete offline local...
        if not exist "%LOCALAPPDATA%\agy\bin" mkdir "%LOCALAPPDATA%\agy\bin"
        powershell -Command "Expand-Archive -Path '%COMP_DIR%\agy.zip' -DestinationPath '%LOCALAPPDATA%\agy\bin' -Force; $d='%LOCALAPPDATA%\agy\bin'; $p=[Environment]::GetEnvironmentVariable('Path','User'); if(($p -split ';') -notcontains $d){ if($p -and -not $p.EndsWith(';')){$p+=';'}; [Environment]::SetEnvironmentVariable('Path', $p+$d, 'User') }"
    )
    if not exist "%LOCALAPPDATA%\agy\bin\agy.exe" (
        echo [*] Antigravity CLI ^(agy^) no detectado. Intentando instalar desde internet...
        where winget >nul 2>&1
        if %errorlevel% equ 0 (
            winget install -e --id Google.Antigravity --accept-package-agreements --accept-source-agreements --silent >nul 2>&1
        )
        if not exist "%LOCALAPPDATA%\agy\bin\agy.exe" (
            powershell -Command "try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $meta = Invoke-RestMethod -Uri 'https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/api/releases/latest?platform=win32-x64'; if($meta.url){ New-Item -ItemType Directory -Force -Path \"$env:LOCALAPPDATA\agy\bin\" | Out-Null; Invoke-WebRequest -Uri $meta.url -OutFile \"$env:LOCALAPPDATA\agy\bin\agy.exe\" } } catch {}"
        )
    )
    if exist "%LOCALAPPDATA%\agy\bin\agy.exe" (
        echo [OK] Antigravity CLI instalado en %LOCALAPPDATA%\agy\bin\agy.exe
        echo [!] Importante: abre una terminal, ejecuta 'agy' e inicia sesion con tu cuenta de Google una vez.
    ) else (
        echo [AVISO] No se pudo instalar Antigravity CLI automaticamente. Ejecuta Instalar_agy_Offline.bat o instalalo manualmente.
    )
) else (
    echo [OK] Antigravity CLI detectado.
)

:: 7. Verificacion final integral de la instalacion
echo.
echo [*] Verificando instalacion completa...
set "VERIFY_ERR=0"

if not exist "%TARGET_DIR%\Addin.dll" (
    echo [ERROR] Falta Addin.dll en %TARGET_DIR%
    set "VERIFY_ERR=1"
) else (
    echo [OK] Addin.dll copiado
)

powershell -Command "if((Get-Content '%windir%\vbaddin.ini' -ErrorAction SilentlyContinue) -contains 'MyAddIn.Connect=3'){exit 0}else{exit 1}"
if %errorlevel% neq 0 (
    echo [ERROR] vbaddin.ini no contiene MyAddIn.Connect=3 en linea separada
    set "VERIFY_ERR=1"
) else (
    echo [OK] vbaddin.ini configurado correctamente
)

if "%PY_EXE%"=="" (
    echo [ERROR] Python 3 no disponible
    set "VERIFY_ERR=1"
) else (
    "%PY_EXE%" -c "from PIL import ImageGrab, Image" >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Pillow ^(PIL^) no funciona en %PY_EXE%
        set "VERIFY_ERR=1"
    ) else (
        echo [OK] Python y Pillow ^(PIL^) verificados
    )
)

set "AGY_BIN="
if exist "%LOCALAPPDATA%\agy\bin\agy.exe" set "AGY_BIN=%LOCALAPPDATA%\agy\bin\agy.exe"
if "%AGY_BIN%"=="" if exist "%USERPROFILE%\.gemini\bin\agy.exe" set "AGY_BIN=%USERPROFILE%\.gemini\bin\agy.exe"
if "%AGY_BIN%"=="" (
    where agy >nul 2>&1
    if %errorlevel% equ 0 set "AGY_BIN=agy"
)
if "%AGY_BIN%"=="" (
    echo [ERROR] agy.exe no encontrado
    set "VERIFY_ERR=1"
) else (
    "%AGY_BIN%" --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo [AVISO] agy.exe encontrado pero no respondio a --version
    ) else (
        echo [OK] Antigravity CLI ^(agy^) verificado
    )
)

echo.
echo ===========================================================================
if "%VERIFY_ERR%"=="0" (
    echo   LISTO! TODAS LAS COMPROBACIONES PASARON. YA PUEDES ABRIR VB6.
) else (
    echo   ATENCION: HUBO ERRORES EN LA VERIFICACION. REVISA LOS MENSAJES ARRIBA.
)
echo ===========================================================================
pause
