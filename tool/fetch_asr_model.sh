#!/usr/bin/env bash
# Descarga o modelo ASR on-device (sherpa-onnx + Whisper) en assets/models/whisper/
# con nomes xenéricos, para que o código non dependa do tamaño do modelo.
#
#   bash tool/fetch_asr_model.sh            # small (por defecto, seguro en iOS)
#   bash tool/fetch_asr_model.sh medium     # medium (máis preciso, ~945 MB)
#   bash tool/fetch_asr_model.sh base|tiny
#
# O modelo NO se versiona (assets/models/ está en .gitignore) por tamaño.
set -euo pipefail

SIZE="${1:-small}"
DIR="$(cd "$(dirname "$0")/.." && pwd)/assets/models/whisper"
BASE="https://huggingface.co/csukuangfj/sherpa-onnx-whisper-${SIZE}/resolve/main"

mkdir -p "$DIR"
fetch() { # $1=ficheiro orixe  $2=destino
  echo "↓ $SIZE / $1 -> $2"
  curl -L -C - "$BASE/$1" -o "$DIR/$2"
}
fetch "${SIZE}-encoder.int8.onnx" encoder.int8.onnx
fetch "${SIZE}-decoder.int8.onnx" decoder.int8.onnx
fetch "${SIZE}-tokens.txt" tokens.txt

echo "Modelo '$SIZE' listo en $DIR"
du -sh "$DIR"
