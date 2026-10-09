"""Despliegue completo del backend de Galingo en Hugging Face (modelo + Space).

Requisitos:
    pip install huggingface_hub
    huggingface-cli login      # pega un token con permiso de escritura

Uso:
    python deploy/deploy_hf.py

Hace:
    1. Crea el repo de modelo <user>/galingo-whisper-turbo-gl-ct2 y sube el CT2.
    2. Crea el Space Docker <user>/galingo-backend y sube el backend + ficheros.
    3. Imprime la URL pública del Space.
"""
import os
import shutil
import tempfile

from huggingface_hub import HfApi, create_repo

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_DIR = os.path.join(ROOT, "backend", "models", "whisper-large-v3-turbo-gl-ct2")
SPACE_SRC = os.path.join(ROOT, "deploy", "hf_space")
BACKEND = os.path.join(ROOT, "backend")

api = HfApi()
user = api.whoami()["name"]
print(f"Usuario HF: {user}")

# 1) Repo del modelo + subida del CT2
model_repo = f"{user}/galingo-whisper-turbo-gl-ct2"
create_repo(model_repo, repo_type="model", exist_ok=True)
print(f"Subiendo modelo ({MODEL_DIR}) -> {model_repo} …")
api.upload_folder(
    folder_path=MODEL_DIR,
    repo_id=model_repo,
    repo_type="model",
    commit_message="modelo whisper turbo-gl CTranslate2 int8",
)
print("Modelo subido.")

# 2) Space Docker
space_repo = f"{user}/galingo-backend"
create_repo(space_repo, repo_type="space", space_sdk="docker", exist_ok=True)
print(f"Preparando Space {space_repo} …")

tmp = tempfile.mkdtemp()
for name in os.listdir(SPACE_SRC):
    src = os.path.join(SPACE_SRC, name)
    dst = os.path.join(tmp, name)
    shutil.copy(src, dst) if os.path.isfile(src) else shutil.copytree(src, dst)
for f in ("main.py", "models.py", "voz.py"):
    shutil.copy(os.path.join(BACKEND, f), os.path.join(tmp, f))

# Apuntar el Dockerfile al repo del modelo del usuario
dock = os.path.join(tmp, "Dockerfile")
with open(dock) as fh:
    content = fh.read()
content = content.replace(
    "WHISPER_MODEL_REPO=REEMPLAZA_CON_TU_USUARIO/galingo-whisper-turbo-gl-ct2",
    f"WHISPER_MODEL_REPO={model_repo}",
)
with open(dock, "w") as fh:
    fh.write(content)

print("Subiendo Space …")
api.upload_folder(
    folder_path=tmp,
    repo_id=space_repo,
    repo_type="space",
    commit_message="deploy: galingo backend",
)

url = f"https://{user}-galingo-backend.hf.space"
print("\n✅ Desplegado.")
print(f"   Space:  https://huggingface.co/spaces/{space_repo}")
print(f"   API:    {url}")
print(f"\nCompila el APK con:\n   flutter build apk --release --dart-define=API_BASE_URL={url}")
