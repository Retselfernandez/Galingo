# Galingo

Aplicación gamificada para el aprendizaje del gallego. Arquitectura de microservicios con motor de repetición espaciada.

App multiplataforma (Android, iOS, macOS, Windows y Web) construida con Flutter.

## Requisitos

- Flutter ≥ 3.19 (Dart ≥ 3.3)

## Ejecutar

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
flutter analyze
```

## Estructura

- `lib/core` — tema, router, i18n, motores ML (SM-2/HLR), servicios
- `lib/data` — modelos, repositorios, contenido
- `lib/presentation` — pantallas, providers, widgets
- `assets/content` — cursos A1–B2 en JSON
- `TFM` — memoria del Trabajo de Fin de Máster
