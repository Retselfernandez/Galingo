@echo off
REM Script para compilar el ejecutable nativo de Windows localmente
echo 🚀 Compilando ejecutable Beta de Windows para Galingo...
cd /d "%~dp0.."

call flutter config --enable-windows-desktop
call flutter build windows --release

if not exist "Windows" mkdir "Windows"
xcopy /E /I /Y "build\windows\x64\runner\Release\*" "Windows\Galingo-Windows-Beta\"

echo ✅ Ejecutable compilado en: Windows\Galingo-Windows-Beta\Galingo.exe
pause
