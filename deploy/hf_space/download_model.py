"""Descarga el modelo CTranslate2 (turbo-gl int8) desde Hugging Face al arrancar.

Configurable con WHISPER_MODEL_REPO y WHISPER_CT2_DIR.
"""
import os

from huggingface_hub import snapshot_download

repo = os.environ.get("WHISPER_MODEL_REPO", "")
target = os.environ.get("WHISPER_CT2_DIR", "models/whisper-large-v3-turbo-gl-ct2")

if os.path.exists(os.path.join(target, "model.bin")):
    print(f"Modelo ya presente en {target}")
else:
    if not repo:
        raise SystemExit("Falta WHISPER_MODEL_REPO (repo HF con el modelo CT2)")
    print(f"Descargando {repo} -> {target}")
    os.makedirs(target, exist_ok=True)
    snapshot_download(repo_id=repo, local_dir=target)
    print("Modelo descargado")
