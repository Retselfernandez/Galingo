"""Despliegue del backend de Galingo en Modal (serverless, HTTPS, escala a cero).

Uso:
    pip install modal
    modal setup            # autentica (login por navegador)
    modal deploy deploy/modal/modal_app.py

Da una URL tipo https://<usuario>--galingo-backend-web.modal.run
"""
import modal

APP_NAME = "galingo-backend"
MODEL_DIR = "/models/whisper-large-v3-turbo-gl-ct2"
MODEL_REPO = "Galingo/galingo-whisper-turbo-gl-ct2"

image = (
    modal.Image.debian_slim(python_version="3.11")
    .apt_install("ffmpeg")
    .pip_install(
        "fastapi==0.115.0",
        "uvicorn==0.30.6",
        "sqlalchemy==2.0.35",
        "pydantic==2.9.2",
        "python-multipart==0.0.9",
        "faster-whisper==1.2.1",
        "huggingface_hub>=0.24",
    )
    .add_local_file("backend/main.py", "/app/main.py")
    .add_local_file("backend/models.py", "/app/models.py")
    .add_local_file("backend/voz.py", "/app/voz.py")
)

app = modal.App(APP_NAME)
models_vol = modal.Volume.from_name("galingo-models", create_if_missing=True)
data_vol = modal.Volume.from_name("galingo-data", create_if_missing=True)


@app.function(
    image=image,
    volumes={"/models": models_vol, "/data": data_vol},
    cpu=2,
    memory=4096,
    timeout=600,
    scaledown_window=300,
)
@modal.asgi_app(label="galingo-backend")
def web():
    import os
    import sys

    # Modelo (se descarga una sola vez al volumen)
    if not os.path.exists(os.path.join(MODEL_DIR, "model.bin")):
        from huggingface_hub import snapshot_download

        snapshot_download(MODEL_REPO, local_dir=MODEL_DIR)
        models_vol.commit()

    os.environ.setdefault("WHISPER_CT2_DIR", MODEL_DIR)
    os.environ.setdefault("DATABASE_URL", "sqlite:////data/galingo.db")

    sys.path.insert(0, "/app")
    from main import app as web_app  # noqa: E402

    return web_app
