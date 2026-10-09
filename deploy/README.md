# Despliegue del backend de Galingo (gratis, con HTTPS) — Hugging Face Spaces

Objetivo: exponer la API (telemetría + evaluación de voz) en una URL pública HTTPS
para que la beta de Android pueda usarla.

## 0. Requisitos
- Cuenta de Hugging Face (gratis): https://huggingface.co/join
- Token con permiso de escritura: https://huggingface.co/settings/tokens
- `git` y `git-lfs` (para subir el modelo)
- `huggingface_hub` (`pip install huggingface_hub`)

Exporta tu usuario y token:
```bash
export HF_USER=tu_usuario
export HF_TOKEN=hf_xxxxxxxx
```

## 1. Subir el modelo ASR (CTranslate2 int8, ~783 MB)
Crea un repo de modelos y sube el modelo ya convertido:
```bash
huggingface-cli login            # pega el token
huggingface-cli repo create galingo-whisper-turbo-gl-ct2 --type model
huggingface-cli upload $HF_USER/galingo-whisper-turbo-gl-ct2 \
  backend/models/whisper-large-v3-turbo-gl-ct2 .
```

## 2. Crear el Space (Docker) y desplegar el backend
```bash
# Crea el Space vacío (Docker) en la web: https://huggingface.co/new-space
#   SDK: Docker · Hardware: CPU basic (gratis) · Visibilidad: Public

# Clona y rellena
git clone https://huggingface.co/spaces/$HF_USER/galingo-backend /tmp/galingo-space
cp deploy/hf_space/. /tmp/galingo-space/ -r
cp backend/main.py backend/models.py backend/voz.py /tmp/galingo-space/
# Edita el Dockerfile: pon tu repo del modelo
sed -i '' "s#REEMPLAZA_CON_TU_USUARIO#$HF_USER#" /tmp/galingo-space/Dockerfile

cd /tmp/galingo-space
git add -A && git commit -m "deploy: galingo backend" && git push
```
> El Space se construye y arranca solo. URL: `https://$HF_USER-galingo-backend.hf.space`

Prueba:
```bash
curl https://$HF_USER-galingo-backend.hf.space/api/v1/metricas
```

## 3. Apuntar la app a esa URL y compilar el APK
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://$HF_USER-galingo-backend.hf.space
```
APK en `build/app/outputs/flutter-apk/app-release.apk` (firmado con `android/key.properties`).

## 4. Publicar el APK
Súbelo a GitHub Releases (tag `v1.1.0-beta`) o Play (internal testing).

---

## Notas
- **Telemetría persistente**: en el Space, SQLite se pierde al reconstruir/reiniciar.
  Para datos sólidos, usa un Postgres gratis (Neon/Supabase) y define `DATABASE_URL`
  en los *Settings → Variables* del Space.
- **Frío**: los Spaces gratis pueden dormir tras inactividad; la primera petición tarda
  ~30 s (recarga el modelo). Para la beta es aceptable.
- **Firma**: `android/key.properties` (alias `galingo`) permite firmar el release; el
  keystore está en `android/app/galingo-release.keystore` (no se versiona).
