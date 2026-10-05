from sqlalchemy import Column, String, Integer, Float, DateTime, Text, create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
import os, datetime

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://galingo:galingo@db:5432/galingo")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

class ItemLexico(Base):
    __tablename__ = "item_lexico"
    id = Column(String, primary_key=True)
    vocabulario = Column(String, nullable=False)
    categoria_gramatical = Column(String)
    complejidad = Column(Float, default=0.5)

class EstadoMemoria(Base):
    __tablename__ = "estado_memoria"
    id = Column(String, primary_key=True)  # user_id + item_id
    user_id = Column(String, index=True)
    item_id = Column(String, index=True)
    vida_media = Column(Float, default=1.0)
    proximo_repaso = Column(DateTime)

class TrazaInteraccion(Base):
    __tablename__ = "traza_interaccion"
    event_id = Column(String, primary_key=True)  # idempotente
    user_id = Column(String, index=True)
    item_id = Column(String, index=True)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)
    latencia_ms = Column(Float)
    resultado = Column(Float)  # 1.0 acierto / 0.0 fallo
    intervalo_dias = Column(Float)
    aciertos = Column(Integer, default=0)
    fallos = Column(Integer, default=0)
    dificultad = Column(Float, default=0.5)

class SesionDiaria(Base):
    __tablename__ = "sesion_diaria"
    id = Column(String, primary_key=True)  # user_id + fecha (YYYY-MM-DD)
    user_id = Column(String, index=True)
    fecha = Column(String, index=True)
    inicio = Column(DateTime, default=datetime.datetime.utcnow)
    plataforma = Column(String)

class ReporteFeedback(Base):
    __tablename__ = "reportes_feedback"
    report_id = Column(String, primary_key=True)
    user_id = Column(String, index=True)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)
    categoria = Column(String)  # bug | sugerencia | contenido
    texto = Column(Text)
    plataforma = Column(String)
    version_app = Column(String)
    pantalla = Column(String)
    mae_hlr = Column(Float)
    mae_sm2 = Column(Float)
    eventos_recientes = Column(Text)  # JSON serializado
