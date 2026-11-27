@echo off
title Tema Dracula / Modo Oscuro para Visual Basic 6.0

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [*] Solicitando permisos de Administrador para configurar VBA6.DLL y Registro...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:MENU
cls
echo ===========================================================================
echo   PERSONALIZACION DEL EDITOR DE CODIGO - VISUAL BASIC 6.0
echo ===========================================================================
echo.
echo   [1] Aplicar Tema Dracula Pro (Colores reales #282a36 + Fuente Consolas)
echo   [2] Aplicar Tema Oscuro Seguro (Solo Registro, sin tocar VBA6.DLL)
echo   [3] Restaurar Tema Clasico original de VB6
echo   [0] Salir
echo.
set /p "OPC=Elige una opcion (1/2/3/0): "

if "%OPC%"=="1" goto CHECK_VB6_DRACULA
if "%OPC%"=="2" goto CHECK_VB6_DARK
if "%OPC%"=="3" goto CHECK_VB6_RESTORE
if "%OPC%"=="0" exit /b
goto MENU

:CHECK_VB6_DRACULA
call :VERIFY_VB6_CLOSED
call :APPLY_DRACULA
goto END

:CHECK_VB6_DARK
call :VERIFY_VB6_CLOSED
call :APPLY_DARK_SAFE
goto END

:CHECK_VB6_RESTORE
call :VERIFY_VB6_CLOSED
call :RESTORE_CLASSIC
goto END

:VERIFY_VB6_CLOSED
tasklist /fi "imagename eq VB6.EXE" 2>nul | find /i "VB6.EXE" >nul
if %errorlevel% equ 0 (
    echo.
    echo [AVISO] Visual Basic 6.0 esta abierto. Cierra VB6 primero para que guarde los cambios.
    pause
    goto VERIFY_VB6_CLOSED
)
exit /b 0

:APPLY_DRACULA
echo.
echo [*] Buscando VBA6.DLL...
set "VBA_DLL="
if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\VB98\VBA6.DLL" set "VBA_DLL=%ProgramFiles(x86)%\Microsoft Visual Studio\VB98\VBA6.DLL"
if "%VBA_DLL%"=="" if exist "%ProgramFiles%\Microsoft Visual Studio\VB98\VBA6.DLL" set "VBA_DLL=%ProgramFiles%\Microsoft Visual Studio\VB98\VBA6.DLL"

if "%VBA_DLL%"=="" (
    echo [ERROR] No se encontro VBA6.DLL en Program Files. Prueba la opcion [2] Modo Oscuro Seguro.
    exit /b 1
)

echo [*] Aplicando paleta Dracula en %VBA_DLL% ...
powershell -Command ^
  "$dll='%VBA_DLL%'; $bak=$dll+'.bak';" ^
  "if(!(Test-Path $bak)){ Copy-Item $dll $bak -Force; Write-Host '[OK] Backup creado:' $bak };" ^
  "$bytes=[System.IO.File]::ReadAllBytes($bak);" ^
  "$orig=[byte[]](0xFF,0xFF,0xFF,0x00, 0xC0,0xC0,0xC0,0x00, 0x80,0x80,0x80,0x00, 0x00,0x00,0x00,0x00, 0xFF,0x00,0x00,0x00, 0x80,0x00,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0x80,0x80,0x00,0x00, 0x00,0xFF,0x00,0x00, 0x00,0x80,0x00,0x00, 0x00,0xFF,0xFF,0x00, 0x00,0x80,0x80,0x00, 0x00,0x00,0xFF,0x00, 0x00,0x00,0x80,0x00, 0xFF,0x00,0xFF,0x00, 0x80,0x00,0x80,0x00);" ^
  "$drac=[byte[]](0x28,0x2A,0x36,0x00, 0x44,0x47,0x5A,0x00, 0xF8,0xF8,0xF2,0x00, 0x62,0x72,0xA4,0x00, 0x8B,0xE9,0xFD,0x00, 0x50,0xFA,0x7B,0x00, 0xFF,0xB8,0x6C,0x00, 0xFF,0x79,0xC6,0x00, 0xBD,0x93,0xF9,0x00, 0xFF,0x55,0x55,0x00, 0xF1,0xFA,0x8C,0x00, 0x21,0x22,0x2C,0x00, 0x19,0x1A,0x21,0x00, 0x62,0x72,0xA4,0x00, 0xF8,0xF8,0xF2,0x00, 0x00,0x00,0x00,0x00);" ^
  "$idx=-1; for($i=0; $i -le ($bytes.Length - 64); $i++){ if($bytes[$i] -eq 0xFF -and $bytes[$i+1] -eq 0xFF -and $bytes[$i+2] -eq 0xFF -and $bytes[$i+3] -eq 0x00){ $ok=$true; for($j=4;$j -lt 64;$j++){ if($bytes[$i+$j] -ne $orig[$j]){ $ok=$false; break } }; if($ok){ $idx=$i; break } } };" ^
  "if($idx -lt 0){ Write-Host '[ERROR] No se encontro la tabla de colores en VBA6.DLL'; exit 1 };" ^
  "[Array]::Copy($drac, 0, $bytes, $idx, 64);" ^
  "[System.IO.File]::WriteAllBytes($dll, $bytes);" ^
  "Write-Host ('[OK] Paleta Dracula parcheada en offset 0x{0:X}' -f $idx)"

if %errorlevel% neq 0 exit /b 1

echo [*] Configurando colores y fuente Consolas en el Registro...
powershell -Command ^
  "$reg='HKCU:\Software\Microsoft\VBA\Microsoft Visual Basic';" ^
  "if(!(Test-Path $reg)){ New-Item -Path $reg -Force | Out-Null };" ^
  "Set-ItemProperty -Path $reg -Name 'CodeBackColors' -Value '1 2 1 9 10 1 1 1 1 1 0 0 0 0 0 0' -Type String;" ^
  "Set-ItemProperty -Path $reg -Name 'CodeForeColors' -Value '3 3 10 1 3 4 8 5 11 3 0 0 0 0 0 0' -Type String;" ^
  "Set-ItemProperty -Path $reg -Name 'FontFace' -Value 'Consolas' -Type String;" ^
  "Set-ItemProperty -Path $reg -Name 'FontHeight' -Value 10 -Type DWord;" ^
  "Set-ItemProperty -Path $reg -Name 'FontCharSet' -Value 0 -Type DWord"

echo [OK] Tema Dracula Pro aplicado! Abre Visual Basic 6.0 para verlo.
exit /b 0

:APPLY_DARK_SAFE
echo.
echo [*] Configurando Tema Oscuro seguro en el Registro (sin modificar DLL)...
powershell -Command ^
  "$reg='HKCU:\Software\Microsoft\VBA\Microsoft Visual Basic';" ^
  "if(!(Test-Path $reg)){ New-Item -Path $reg -Force | Out-Null };" ^
  "Set-ItemProperty -Path $reg -Name 'CodeBackColors' -Value '4 14 4 12 6 4 4 4 4 4 0 0 0 0 0 0' -Type String;" ^
  "Set-ItemProperty -Path $reg -Name 'CodeForeColors' -Value '2 1 5 1 1 10 11 1 7 1 0 0 0 0 0 0' -Type String;" ^
  "Set-ItemProperty -Path $reg -Name 'FontFace' -Value 'Consolas' -Type String;" ^
  "Set-ItemProperty -Path $reg -Name 'FontHeight' -Value 10 -Type DWord;" ^
  "Set-ItemProperty -Path $reg -Name 'FontCharSet' -Value 0 -Type DWord"
echo [OK] Tema Oscuro seguro aplicado! Abre Visual Basic 6.0 para verlo.
exit /b 0

:RESTORE_CLASSIC
echo.
echo [*] Restaurando tema clasico original de Visual Basic 6.0...
for %%D in ("%ProgramFiles(x86)%\Microsoft Visual Studio\VB98\VBA6.DLL" "%ProgramFiles%\Microsoft Visual Studio\VB98\VBA6.DLL") do (
    if exist "%%~D.bak" (
        copy /y "%%~D.bak" "%%~D" >nul
        echo [OK] Restaurado %%~D desde backup.
    )
)
powershell -Command ^
  "$reg='HKCU:\Software\Microsoft\VBA\Microsoft Visual Basic';" ^
  "if(Test-Path $reg){ foreach($n in @('CodeBackColors','CodeForeColors','FontFace','FontHeight','FontCharSet')){ Remove-ItemProperty -Path $reg -Name $n -ErrorAction SilentlyContinue } }"
echo [OK] Tema clasico restaurado.
exit /b 0

:END
echo.
pause
