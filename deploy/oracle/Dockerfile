FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1

WORKDIR /app

# ffmpeg para decodificar el audio de la app
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ .
COPY deploy/oracle/start.sh deploy/oracle/download_model.py ./

ENV WHISPER_CT2_DIR=/models/whisper-large-v3-turbo-gl-ct2 \
    WHISPER_MODEL_REPO=Galingo/galingo-whisper-turbo-gl-ct2 \
    DATABASE_URL=sqlite:////data/galingo.db

EXPOSE 8000

CMD ["bash", "start.sh"]
