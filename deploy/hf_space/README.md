---
title: Galingo Backend
emoji: 🦅
colorFrom: blue
colorTo: yellow
sdk: docker
app_port: 7860
pinned: false
---

# Galingo Backend (Hugging Face Space)

API FastAPI de Galingo: telemetría + evaluación de voz en gallego
(`POST /api/v1/voz/avaliar` con Whisper turbo-gl en CTranslate2 int8).

El modelo se descarga al arrancar desde un repo de modelos de Hugging Face
(configurable con `WHISPER_MODEL_REPO`).
