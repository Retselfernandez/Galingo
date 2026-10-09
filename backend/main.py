from fastapi import FastAPI, Depends, HTTPException, File, UploadFile, Form
from pydantic import BaseModel
from sqlalchemy.orm import Session
from typing import Optional, List
import datetime, json
from models import Base, engine, SessionLocal, TrazaInteraccion, ReporteFeedback, EstadoMemoria, SesionDiaria

Base.metadata.create_all(engine)
app = FastAPI(title="Galingo API", version="1.0.0")

def get_db():
    db = SessionLocal()
    try: yield db
    finally: db.close()

class InteraccionIn(BaseModel):
    event_id: str
    user_id: str
    item_id: str
    latencia_ms: Optional[float] = None
    resultado: float
    intervalo_dias: Optional[float] = None
    aciertos: int = 0
    fallos: int = 0
    dificultad: float = 0.5

class FeedbackIn(BaseModel):
    report_id: str
    user_id: str
    categoria: str
    texto: str
    plataforma: Optional[str] = None
    version_app: Optional[str] = None
    pantalla: Optional[str] = None
    mae_hlr: Optional[float] = None
    mae_sm2: Optional[float] = None
    eventos_recientes: Optional[list] = None

@app.post("/api/v1/interaccion", status_code=201)
def ingestar_interaccion(ev: InteraccionIn, db: Session = Depends(get_db)):
    if db.get(TrazaInteraccion, ev.event_id):
        return {"status": "duplicado", "event_id": ev.event_id}
    db.add(TrazaInteraccion(**ev.model_dump()))
    db.commit()
    return {"status": "ok", "event_id": ev.event_id}

@app.post("/api/v1/feedback", status_code=201)
def ingestar_feedback(fb: FeedbackIn, db: Session = Depends(get_db)):
    if db.get(ReporteFeedback, fb.report_id):
        return {"status": "duplicado", "report_id": fb.report_id}
    data = fb.model_dump()
    data["eventos_recientes"] = json.dumps(data.get("eventos_recientes") or [])
    db.add(ReporteFeedback(**data))
    db.commit()
    return {"status": "ok", "report_id": fb.report_id}

@app.get("/api/v1/estado_memoria/{user_id}")
def estado_memoria(user_id: str, db: Session = Depends(get_db)):
    rows = db.query(EstadoMemoria).filter_by(user_id=user_id).all()
    return [{"item_id": r.item_id, "vida_media": r.vida_media,
             "proximo_repaso": r.proximo_repaso} for r in rows]

class SesionIn(BaseModel):
    user_id: str
    fecha: str
    plataforma: Optional[str] = None

@app.post("/api/v1/sesion", status_code=201)
def registrar_sesion(s: SesionIn, db: Session = Depends(get_db)):
    sid = f"{s.user_id}_{s.fecha}"
    if db.get(SesionDiaria, sid):
        return {"status": "duplicado", "id": sid}
    db.add(SesionDiaria(id=sid, user_id=s.user_id, fecha=s.fecha, plataforma=s.plataforma))
    db.commit()
    return {"status": "ok", "id": sid}

@app.get("/api/v1/metricas")
def metricas(db: Session = Depends(get_db)):
    total = db.query(TrazaInteraccion).count()
    feedbacks = db.query(ReporteFeedback).count()
    sesiones = db.query(SesionDiaria).count()
    return {"eventos_totales": total, "reportes_totales": feedbacks, "sesiones_diarias": sesiones}


# ─── Evaluación de voz (Whisper gallego) ─────────────────────────────────────
@app.post("/api/v1/voz/avaliar")
async def voz_avaliar(
    audio: UploadFile = File(...),
    target: str = Form(...),
    umbral: float = Form(0.7),
):
    """Recibe un audio y la frase objetivo; devuelve transcripción y puntuación."""
    try:
        from voz import evaluar
    except Exception as e:  # pragma: no cover
        raise HTTPException(status_code=500, detail=f"voz no disponible: {e}")
    data = await audio.read()
    if not data:
        raise HTTPException(status_code=400, detail="audio vacío")
    try:
        return evaluar(data, target, umbral=umbral)
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"modelo de voz no disponible: {e}")

