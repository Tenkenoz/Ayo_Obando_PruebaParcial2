"""
SeguroApp – API REST para gestión de Pólizas de Seguro
Punto de entrada principal.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from core.config import settings
from database import create_tables

# Registrar modelos antes de create_tables()
import models.models  # noqa: F401

from routers import polizas

# ── App ────────────────────────────────────────────────────────────────────────

app = FastAPI(
    title=settings.APP_NAME,
    description="API REST para administración de Pólizas de Seguro – CRUD completo",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── CORS ───────────────────────────────────────────────────────────────────────

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],        # En producción limitar al dominio del frontend
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routers ────────────────────────────────────────────────────────────────────

app.include_router(polizas.router)

# ── Eventos ────────────────────────────────────────────────────────────────────

@app.on_event("startup")
def on_startup():
    """Inicializa la base de datos al arrancar."""
    create_tables()
    print("✅  Tablas verificadas/creadas en PostgreSQL")

# ── Health / Root ──────────────────────────────────────────────────────────────

@app.get("/", tags=["Root"])
def root():
    return {
        "app": settings.APP_NAME,
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs",
        "redoc": "/redoc",
    }


@app.get("/health", tags=["Root"])
def health():
    return {"status": "ok", "database": "connected"}