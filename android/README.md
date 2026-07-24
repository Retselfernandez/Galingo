# Galingo — Paquete Beta para Android (.apk)

Esta carpeta está destinada a la distribución del ejecutable **Android APK** de Galingo.

## 📱 Opciones de Obtención del Ejecutable:

### Opción 1: Descarga directa desde GitHub Actions (Recomendado)
El proyecto cuenta con un pipeline de integración continua (`.github/workflows/build_beta.yml`). Al subir este repositorio a GitHub:
1. Navegar a la pestaña **Actions** en el repositorio.
2. Seleccionar la última ejecución del workflow `Galingo Multiplatform Beta Build Pipeline`.
3. En la sección **Artifacts**, descargar `Galingo-Android-Beta-APK`.

### Opción 2: Compilación Local
Si tienes instalado **Android Studio** o el **Android SDK + Java JDK 17**, puedes generar el APK localmente ejecutando:

```bash
chmod +x Android/build_android.sh
./Android/build_android.sh
```

El binario `.apk` se generará automáticamente en `Android/Galingo-Android-Beta.apk`.

## 📦 Instalación en Dispositivo Android
1. Transfiere el archivo `Galingo-Android-Beta.apk` a tu teléfono Android (vía WhatsApp, Drive, cable USB o correo).
2. Toca el archivo `.apk` para instalar.
3. Si Android muestra la advertencia *"Instalar aplicaciones de fuentes desconocidas"*, permite la instalación para tu navegador/explorador de archivos.
