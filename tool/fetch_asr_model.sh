#!/usr/bin/env bash
# Descarga el modelo ASR on-device (sherpa-onnx + Whisper small int8).
# NO se versiona en git (assets/models/ está en .gitignore) por tamaño (~370 MB).
# Ejecútalo una vez antes de compilar:
#   bash tool/fetch_asr_model.sh
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)/assets/models/whisper-medium"
BASE="https://huggingface.co/csukuangfj/sherpa-onnx-whisper-medium/resolve/main"
FILES=(medium-encoder.int8.onnx medium-decoder.int8.onnx medium-tokens.txt)

mkdir -p "$DIR"
for f in "${FILES[@]}"; do
  if [ -f "$DIR/$f" ]; then
    echo "✔ xa existe: $f"
  else
    echo "↓ descargando $f ..."
    curl -L -C - "$BASE/$f" -o "$DIR/$f"
  fi
done
echo "Modelo listo en $DIR"
du -sh "$DIR"
