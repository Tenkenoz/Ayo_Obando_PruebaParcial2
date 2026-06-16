-- ============================================================
-- SeguroApp – Script de inicialización de la base de datos
-- PostgreSQL 14+
-- ============================================================

-- Crear base de datos y usuario (ejecutar como superusuario)
-- CREATE USER segurouser WITH PASSWORD 'seguro_pass';
-- CREATE DATABASE segurodb OWNER segurouser;

-- Conectarse a segurodb antes de ejecutar el resto
-- \c segurodb;

-- ── Tabla: polizas ──────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS polizas (
    id                SERIAL PRIMARY KEY,
    codigo            VARCHAR(30)     NOT NULL UNIQUE,
    cliente           VARCHAR(150)    NOT NULL,
    tipo_seguro       VARCHAR(100)    NOT NULL,
    fecha_inicio      TIMESTAMP       NOT NULL,
    fecha_vencimiento TIMESTAMP       NOT NULL,
    valor_asegurado   NUMERIC(14, 2)  NOT NULL CHECK (valor_asegurado > 0),
    creado_en         TIMESTAMP       NOT NULL DEFAULT NOW(),
    actualizado_en    TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- Índices útiles para búsquedas frecuentes
CREATE INDEX IF NOT EXISTS idx_polizas_cliente     ON polizas (cliente);
CREATE INDEX IF NOT EXISTS idx_polizas_tipo_seguro ON polizas (tipo_seguro);
CREATE INDEX IF NOT EXISTS idx_polizas_vencimiento ON polizas (fecha_vencimiento);

-- ── Datos de ejemplo ────────────────────────────────────────────────────────

INSERT INTO polizas (codigo, cliente, tipo_seguro, fecha_inicio, fecha_vencimiento, valor_asegurado)
VALUES
  ('POL-2025-001', 'Ana Lucía Torres',    'Seguro de Vida',     '2025-01-15', '2026-01-15', 100000.00),
  ('POL-2025-002', 'Roberto Cárdenas',    'Seguro de Vehículo', '2025-03-01', '2026-03-01',  25000.00),
  ('POL-2025-003', 'María Elena Vega',    'Seguro de Hogar',    '2025-05-10', '2026-05-10',  80000.00),
  ('POL-2025-004', 'Carlos Mendoza',      'Seguro de Salud',    '2025-06-01', '2026-06-01',  50000.00),
  ('POL-2025-005', 'Patricia Loor',       'Seguro de Vida',     '2025-07-20', '2027-07-20', 200000.00)
ON CONFLICT (codigo) DO NOTHING;