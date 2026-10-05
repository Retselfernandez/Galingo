"""Informe de la beta: retención D1/D7 y volumen de telemetría.
Uso: python analisis_beta.py
"""
import json
from collections import defaultdict
from models import SessionLocal, SesionDiaria, TrazaInteraccion, ReporteFeedback

def main():
    db = SessionLocal()
    sesiones = db.query(SesionDiaria).all()
    por_usuario = defaultdict(set)
    for s in sesiones:
        por_usuario[s.user_id].add(s.fecha)

    usuarios = len(por_usuario)
    d1 = sum(1 for _, fechas in por_usuario.items() if len(fechas) >= 1)
    d7 = sum(1 for _, fechas in por_usuario.items() if len(fechas) >= 7)

    eventos = db.query(TrazaInteraccion).count()
    feedback = db.query(ReporteFeedback).count()
    print(json.dumps({
        "usuarios_beta": usuarios,
        "retencion_dia1_pct": round(d1 / usuarios * 100, 1) if usuarios else 0,
        "retencion_dia7_pct": round(d7 / usuarios * 100, 1) if usuarios else 0,
        "sesiones_totales": len(sesiones),
        "eventos_totales": eventos,
        "reportes_totales": feedback,
    }, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()
