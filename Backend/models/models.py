"""
Modelos de base de datos para el sistema de Pólizas de Seguro.
Tabla: polizas
"""
from datetime import datetime

from sqlalchemy import Column, DateTime, Integer, Numeric, String
from database import Base


# ── Tabla: polizas ─────────────────────────────────────────────────────────────

class Poliza(Base):
    __tablename__ = "polizas"

    id                  = Column(Integer, primary_key=True, index=True)
    codigo              = Column(String(30), unique=True, nullable=False, index=True)
    cliente             = Column(String(150), nullable=False)
    tipo_seguro         = Column(String(100), nullable=False)
    fecha_inicio        = Column(DateTime, nullable=False)
    fecha_vencimiento   = Column(DateTime, nullable=False)
    valor_asegurado     = Column(Numeric(14, 2), nullable=False)
    creado_en           = Column(DateTime, default=datetime.utcnow)
    actualizado_en      = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
