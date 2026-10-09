FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# ffmpeg para decodificar el audio que sube la app
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# Hugging Face Spaces ejecuta como uid 1000
RUN useradd -m -u 1000 user && chown -R user /app
USER user

ENV HOME=/home/user \
    WHISPER_CT2_DIR=/home/user/models/whisper-large-v3-turbo-gl-ct2 \
    DATABASE_URL=sqlite:////home/user/galingo.db \
    WHISPER_MODEL_REPO=REEMPLAZA_CON_TU_USUARIO/galingo-whisper-turbo-gl-ct2

EXPOSE 7860

CMD ["bash", "start.sh"]
