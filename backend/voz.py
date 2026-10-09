"""Evaluación de voz en gallego con Whisper fine-tuned (HiTZ/whisper-large-v2-gl).

El modelo se sirve en formato CTranslate2 (int8) para ir rápido en CPU.
Ruta configurable con la variable de entorno WHISPER_CT2_DIR.
"""
import io
import os
import re
from typing import Optional

# Ruta por defecto: backend/models/whisper-large-v3-turbo-gl-ct2
_DEFAULT_DIR = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "models",
    "whisper-large-v3-turbo-gl-ct2",
)

_MODEL = None


def _get_model():
    global _MODEL
    if _MODEL is None:
        from faster_whisper import WhisperModel

        model_dir = os.environ.get("WHISPER_CT2_DIR", _DEFAULT_DIR)
        _MODEL = WhisperModel(model_dir, device="cpu", compute_type="int8")
    return _MODEL


def transcribir(audio_bytes: bytes, language: str = "gl") -> str:
    """Transcribe audio (wav/mp3/ogg…) en gallego y devuelve el texto."""
    model = _get_model()
    segments, _info = model.transcribe(
        io.BytesIO(audio_bytes),
        language=language,
        beam_size=5,
        vad_filter=True,
    )
    return " ".join(seg.text.strip() for seg in segments).strip()


def _norm(s: str) -> str:
    s = (s or "").lower()
    s = s.replace("á", "a").replace("é", "e").replace("í", "i")
    s = s.replace("ó", "o").replace("ú", "u").replace("ñ", "n")
    s = re.sub(r"[.,;:!?¿¡\"'()«»\[\]{}]", "", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s


def _levenshtein(a: str, b: str) -> int:
    m, n = len(a), len(b)
    prev = list(range(n + 1))
    for i in range(1, m + 1):
        cur = [i] + [0] * n
        for j in range(1, n + 1):
            cur[j] = min(
                prev[j] + 1,
                cur[j - 1] + 1,
                prev[j - 1] + (a[i - 1] != b[j - 1]),
            )
        prev = cur
    return prev[n]


def similitud(transcript: str, target: str) -> float:
    x, y = _norm(transcript), _norm(target)
    if not x or not y:
        return 0.0
    dist = _levenshtein(x, y)
    return 1.0 - dist / max(len(x), len(y))


def evaluar(audio_bytes: bytes, target: str, umbral: float = 0.7) -> dict:
    """Devuelve transcripción, similitud, aprobado y acierto por palabra."""
    transcript = transcribir(audio_bytes)
    sim = similitud(transcript, target)

    target_words = _norm(target).split()
    heard_words = _norm(transcript).split()
    palabras = []
    for i, w in enumerate(target_words):
        ok = i < len(heard_words) and heard_words[i] == w
        palabras.append({"palabra": w, "acierto": ok})

    return {
        "transcript": transcript,
        "similitud": round(sim, 3),
        "aprobado": sim >= umbral,
        "palabras": palabras,
    }
