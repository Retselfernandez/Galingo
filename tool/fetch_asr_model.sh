#!/usr/bin/env bash
# Descarga el modelo ASR on-device (sherpa-onnx + Whisper small int8).
# NO se versiona en git (assets/models/ está en .gitignore) por tamaño (~370 MB).
# Ejecútalo una vez antes de compilar:
#   bash tool/fetch_asr_model.sh
set -euo pipefail

DIR="$(cd "$(dirname "$0")/.." && pwd)/assets/models/whisper-small"
BASE="https://huggingface.co/csukuangfj/sherpa-onnx-whisper-small/resolve/main"
FILES=(small-encoder.int8.onnx small-decoder.int8.onnx small-tokens.txt)

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
