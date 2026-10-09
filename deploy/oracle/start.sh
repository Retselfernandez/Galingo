#!/usr/bin/env bash
set -e

echo "==> Descargando modelo ASR (se omite si ya existe)…"
python download_model.py

echo "==> Arrancando API en :8000…"
exec uvicorn main:app --host 0.0.0.0 --port 8000
