"""
Router CRUD completo para Pólizas de Seguro.

Endpoints:
  POST   /polizas/          → Crear póliza
  GET    /polizas/          → Listar todas las pólizas
  GET    /polizas/{id}      → Obtener póliza por ID
  GET    /polizas/codigo/{codigo} → Obtener póliza por código
  PUT    /polizas/{id}      → Actualizar póliza completa
  PATCH  /polizas/{id}      → Actualizar póliza parcial
  DELETE /polizas/{id}      → Eliminar póliza
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import Optional

from database import get_db
from models.models import Poliza
from schemas.poliza_schemas import (
    PolizaCreate,
    PolizaUpdate,
    PolizaResponse,
    PolizaListResponse,
)

router = APIRouter(
    prefix="/polizas",
    tags=["Pólizas de Seguro"],
)


# ── Helper ─────────────────────────────────────────────────────────────────────

def _get_or_404(poliza_id: int, db: Session) -> Poliza:
    poliza = db.query(Poliza).filter(Poliza.id == poliza_id).first()
    if not poliza:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Póliza con id={poliza_id} no encontrada.",
        )
    return poliza


# ── CREATE ─────────────────────────────────────────────────────────────────────

@router.post(
    "/",
    response_model=PolizaResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Registrar una nueva póliza de seguro",
)
def crear_poliza(payload: PolizaCreate, db: Session = Depends(get_db)):
    """
    Crea una póliza de seguro nueva.

    - **codigo**: Código único de la póliza (ej. POL-2025-001)
    - **cliente**: Nombre del titular
    - **tipo_seguro**: Categoría del seguro (Vida, Vehículo, Hogar…)
    - **fecha_inicio** / **fecha_vencimiento**: Vigencia
    - **valor_asegurado**: Monto asegurado en USD
    """
    poliza = Poliza(**payload.model_dump())
    db.add(poliza)
    try:
        db.commit()
        db.refresh(poliza)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Ya existe una póliza con el código '{payload.codigo}'.",
        )
    return poliza


# ── READ ALL ───────────────────────────────────────────────────────────────────

@router.get(
    "/",
    response_model=PolizaListResponse,
    summary="Listar todas las pólizas",
)
def listar_polizas(
    skip: int = Query(0, ge=0, description="Registros a omitir"),
    limit: int = Query(100, ge=1, le=500, description="Máximo de registros"),
    cliente: Optional[str] = Query(None, description="Filtrar por nombre de cliente"),
    tipo_seguro: Optional[str] = Query(None, description="Filtrar por tipo de seguro"),
    db: Session = Depends(get_db),
):
    """Devuelve la lista de pólizas con filtros opcionales y paginación."""
    query = db.query(Poliza)
    if cliente:
        query = query.filter(Poliza.cliente.ilike(f"%{cliente}%"))
    if tipo_seguro:
        query = query.filter(Poliza.tipo_seguro.ilike(f"%{tipo_seguro}%"))

    total = query.count()
    polizas = query.order_by(Poliza.id.desc()).offset(skip).limit(limit).all()
    return {"total": total, "polizas": polizas}


# ── READ ONE by ID ─────────────────────────────────────────────────────────────

@router.get(
    "/{poliza_id}",
    response_model=PolizaResponse,
    summary="Obtener póliza por ID",
)
def obtener_poliza(poliza_id: int, db: Session = Depends(get_db)):
    """Retorna una póliza específica por su ID numérico."""
    return _get_or_404(poliza_id, db)


# ── READ ONE by Codigo ─────────────────────────────────────────────────────────

@router.get(
    "/codigo/{codigo}",
    response_model=PolizaResponse,
    summary="Obtener póliza por código",
)
def obtener_poliza_por_codigo(codigo: str, db: Session = Depends(get_db)):
    """Retorna una póliza específica por su código alfanumérico."""
    poliza = db.query(Poliza).filter(Poliza.codigo == codigo).first()
    if not poliza:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Póliza con código '{codigo}' no encontrada.",
        )
    return poliza


# ── UPDATE (PUT - completo) ────────────────────────────────────────────────────

@router.put(
    "/{poliza_id}",
    response_model=PolizaResponse,
    summary="Actualizar póliza completa (PUT)",
)
def actualizar_poliza(
    poliza_id: int,
    payload: PolizaCreate,
    db: Session = Depends(get_db),
):
    """
    Reemplaza todos los campos de una póliza existente.
    El campo **codigo** también puede cambiar (si es único).
    """
    poliza = _get_or_404(poliza_id, db)
    for field, value in payload.model_dump().items():
        setattr(poliza, field, value)
    try:
        db.commit()
        db.refresh(poliza)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"El código '{payload.codigo}' ya pertenece a otra póliza.",
        )
    return poliza


# ── UPDATE (PATCH - parcial) ───────────────────────────────────────────────────

@router.patch(
    "/{poliza_id}",
    response_model=PolizaResponse,
    summary="Actualizar póliza parcialmente (PATCH)",
)
def actualizar_poliza_parcial(
    poliza_id: int,
    payload: PolizaUpdate,
    db: Session = Depends(get_db),
):
    """Actualiza solo los campos enviados en el cuerpo de la petición."""
    poliza = _get_or_404(poliza_id, db)
    update_data = payload.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(poliza, field, value)
    db.commit()
    db.refresh(poliza)
    return poliza


# ── DELETE ─────────────────────────────────────────────────────────────────────

@router.delete(
    "/{poliza_id}",
    status_code=status.HTTP_200_OK,
    summary="Eliminar póliza",
)
def eliminar_poliza(poliza_id: int, db: Session = Depends(get_db)):
    """Elimina permanentemente una póliza por su ID."""
    poliza = _get_or_404(poliza_id, db)
    db.delete(poliza)
    db.commit()
    return {
        "mensaje": f"Póliza id={poliza_id} eliminada correctamente.",
        "id": poliza_id,
    }
