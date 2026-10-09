"""Prueba rápida del ASR gallego.

Uso:
    WHISPER_CT2_DIR=/ruta/al/modelo python tools/asr_test.py audio.wav ["frase obxectivo"]
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from voz import evaluar, transcribir  # noqa: E402


def main():
    if len(sys.argv) < 2:
        print("uso: python tools/asr_test.py audio.wav [frase obxectivo]")
        return 1
    with open(sys.argv[1], "rb") as f:
        audio = f.read()
    if len(sys.argv) > 2:
        print(evaluar(audio, sys.argv[2]))
    else:
        print("transcripción:", transcribir(audio))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
