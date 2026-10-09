# Galingo

Aplicación gamificada para el aprendizaje del gallego. Arquitectura de microservicios con motor de repetición espaciada.

App multiplataforma (Android, iOS, macOS, Windows y Web) construida con Flutter.

> **Alcance actual (octubre 2026):** el desarrollo se centra en el **nivel A1** (540 preguntas).
> Los niveles **A2/B1/B2 están desactivados temporalmente** en la interfaz; sus JSON se conservan
> en el repositorio. Se reactivan añadiendo el nivel a `AppConstants.enabledLevels`.

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
- `assets/content` — curso **A1** en JSON (A2/B1/B2 conservados pero desactivados)
- `assets/audio/exercises` — 81 audios de la categoría E (voz gallega)
- `TFM` — memoria del Trabajo de Fin de Máster

## Voz (TTS + ASR en gallego)

### Audio de los ejercicios (TTS)
- Los 81 audios de la categoría **E** (escucha + dictado) se generan con **Proxecto Nós (voz *Celtia*)**
  en formato ONNX, vía [`phoonnx`](https://github.com/TigreGotico/phoonnx) (grafemas, **sin Cotovía**).
- Modelo: `OpenVoiceOS/proxectonos-celtia-vits-graphemes-onnx` (alternativa masculina: *Brais*).
- Salida: `assets/audio/exercises/{id}.mp3` (referenciados desde `audioAsset` en el JSON).

### Evaluación de voz (ASR)
- Endpoint: `POST /api/v1/voz/avaliar` (multipart `audio` + `target`) → `{transcript, similitud, aprobado, palabras[]}`.
- Modelo: **`proxectonos/whisper-large-v3-turbo-gl-v1.0`** convertido a **CTranslate2 int8** y servido con
  `faster-whisper` (`language="gl"`).
- Ruta del modelo: `backend/models/whisper-large-v3-turbo-gl-ct2` (no versionado) o variable `WHISPER_CT2_DIR`.
- La app graba con `record` y sube el audio; si el backend no responde, cae al ASR local (`speech_to_text`).
- Umbral de aprobado: `AppConstants.speechPassThreshold` (0.7).

### Arrancar el backend en local

```bash
cd backend
pip install -r requirements.txt
DATABASE_URL="sqlite:///./galingo.db" \
WHISPER_CT2_DIR="$PWD/models/whisper-large-v3-turbo-gl-ct2" \
  uvicorn main:app --port 8000
```

> El modelo CT2 (~783 MB) y los modelos TTS no se versionan (ver `.gitignore` → `backend/models/`).

## Beta (Android)

- **APK**: https://github.com/Retselfernandez/Galingo/releases/tag/v1.1.0-beta
- **Backend desplegado** (Modal, serverless + HTTPS): https://retselfernandez--galingo-backend.modal.run
- Opciones de despliegue: `deploy/modal/` (Modal, gratis) · `deploy/oracle/` (VM Always Free) ·
  `deploy/hf_space/` (requiere HF PRO). La app se compila con
  `--dart-define=API_BASE_URL=<url>`.


