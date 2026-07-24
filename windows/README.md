# Galingo — Paquete Beta para Windows (.exe)

Esta carpeta está destinada a la distribución del ejecutable nativo **Windows Desktop (.exe)** de Galingo.

## 💻 Opciones de Obtención del Ejecutable:

### Opción 1: Descarga directa desde GitHub Actions (Recomendado)
Debido a que la compilación binaria nativa de Windows C++/WinUI requiere un sistema host Windows, la pipeline automatizada del proyecto (`.github/workflows/build_beta.yml`) compila el binario ejecutable en la nube:
1. Ir a la pestaña **Actions** de GitHub.
2. Hacer clic en el workflow `Galingo Multiplatform Beta Build Pipeline`.
3. Descargar el artefacto `Galingo-Windows-Beta-Zip`.
4. Extraer el zip e iniciar `Galingo.exe`.

### Opción 2: Compilación Local en un PC con Windows
Si estás trabajando desde un equipo con Windows 10/11 y Visual Studio 2022 ("Desktop development with C++" instalado):
1. Abrir una consola de comandos o PowerShell.
2. Ejecutar `Windows\build_windows.bat`.
3. El ejecutable y sus bibliotecas DLL se copiarán en `Windows\Galingo-Windows-Beta\`.
