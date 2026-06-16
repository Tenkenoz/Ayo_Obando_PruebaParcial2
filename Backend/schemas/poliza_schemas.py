"""
Schemas Pydantic para Pólizas de Seguro.
"""
from datetime import datetime
from decimal import Decimal
from typing import Optional

from pydantic import BaseModel, Field


# ── Base ────────────────────────────────────────────────────────────────────────

class PolizaBase(BaseModel):
    codigo: str = Field(..., max_length=30, example="POL-2025-001")
    cliente: str = Field(..., max_length=150, example="Juan Pérez")
    tipo_seguro: str = Field(..., max_length=100, example="Seguro de Vida")
    fecha_inicio: datetime = Field(..., example="2025-01-01T00:00:00")
    fecha_vencimiento: datetime = Field(..., example="2026-01-01T00:00:00")
    valor_asegurado: Decimal = Field(..., gt=0, example=50000.00)


# ── Create ──────────────────────────────────────────────────────────────────────

class PolizaCreate(PolizaBase):
    pass


# ── Update ──────────────────────────────────────────────────────────────────────

class PolizaUpdate(BaseModel):
    """Todos los campos son opcionales para soportar PATCH parcial."""
    cliente: Optional[str] = Field(None, max_length=150)
    tipo_seguro: Optional[str] = Field(None, max_length=100)
    fecha_inicio: Optional[datetime] = None
    fecha_vencimiento: Optional[datetime] = None
    valor_asegurado: Optional[Decimal] = Field(None, gt=0)


# ── Response ────────────────────────────────────────────────────────────────────

class PolizaResponse(PolizaBase):
    id: int
    creado_en: datetime
    actualizado_en: datetime

    class Config:
        from_attributes = True


# ── List Response ───────────────────────────────────────────────────────────────

class PolizaListResponse(BaseModel):
    total: int
    polizas: list[PolizaResponse]
