# Galingo — Paquete Beta para iOS (.app / .ipa / Xcode)

Esta carpeta está destinada a la distribución y pruebas del paquete ejecutable **iOS** de Galingo para iPhone y iPad.

## 📱 Opciones de Instalación y Pruebas en Dispositivos iOS:

### Opción 1: Pruebas con Xcode (Recomendado para desarrollo/beta)
1. Conectar tu iPhone/iPad por cable USB al Mac.
2. Abrir el proyecto en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. Seleccionar tu dispositivo de la lista y pulsar **Run (⌘R)**.

### Opción 2: Sideloading (AltStore / SideStore / Sideloadly / Scarlet)
1. Ejecutar `./iOS/build_ios.sh` o descargar `iOS/Galingo-iOS-Beta.ipa`.
2. Importar el archivo `.ipa` desde AltStore / SideStore / Sideloadly para firmar con tu cuenta gratuita de Apple ID e instalarlo en tu iPhone sin necesidad de jailbreak.

### Opción 3: TestFlight (App Store Connect)
Para subir la beta a TestFlight público:
```bash
flutter build ipa
```
Subir la estructura creada en `build/ios/ipa/` usando **Transporter** de macOS.
