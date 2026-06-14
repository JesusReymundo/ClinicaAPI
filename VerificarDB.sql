USE ClinicaDB;
GO

-- ============================================================
-- 1. VERIFICAR TODAS LAS TABLAS CREADAS
-- ============================================================
SELECT
    TABLE_NAME          AS Tabla,
    TABLE_TYPE          AS Tipo
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- ============================================================
-- 2. VERIFICAR TODAS LAS VISTAS CREADAS
-- ============================================================
SELECT
    TABLE_NAME          AS Vista
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'VIEW'
ORDER BY TABLE_NAME;

-- ============================================================
-- 3. CONTAR REGISTROS EN CADA TABLA
-- ============================================================
SELECT 'Roles'          AS Tabla, COUNT(*) AS Registros FROM Roles          UNION ALL
SELECT 'TipoAsegurado'  AS Tabla, COUNT(*) AS Registros FROM TipoAsegurado  UNION ALL
SELECT 'EstadosCita'    AS Tabla, COUNT(*) AS Registros FROM EstadosCita     UNION ALL
SELECT 'Especialidades' AS Tabla, COUNT(*) AS Registros FROM Especialidades  UNION ALL
SELECT 'Medicamentos'   AS Tabla, COUNT(*) AS Registros FROM Medicamentos    UNION ALL
SELECT 'Consultorios'   AS Tabla, COUNT(*) AS Registros FROM Consultorios    UNION ALL
SELECT 'MetodosPago'    AS Tabla, COUNT(*) AS Registros FROM MetodosPago     UNION ALL
SELECT 'TipoConsulta'   AS Tabla, COUNT(*) AS Registros FROM TipoConsulta    UNION ALL
SELECT 'Empresas'       AS Tabla, COUNT(*) AS Registros FROM Empresas        UNION ALL
SELECT 'Usuarios'       AS Tabla, COUNT(*) AS Registros FROM Usuarios        UNION ALL
SELECT 'Contactos'      AS Tabla, COUNT(*) AS Registros FROM Contactos       UNION ALL
SELECT 'Medicos'        AS Tabla, COUNT(*) AS Registros FROM Medicos         UNION ALL
SELECT 'Pacientes'      AS Tabla, COUNT(*) AS Registros FROM Pacientes       UNION ALL
SELECT 'Citas'          AS Tabla, COUNT(*) AS Registros FROM Citas           UNION ALL
SELECT 'Recetas'        AS Tabla, COUNT(*) AS Registros FROM Recetas         UNION ALL
SELECT 'DetalleReceta'  AS Tabla, COUNT(*) AS Registros FROM DetalleReceta   UNION ALL
SELECT 'Facturas'       AS Tabla, COUNT(*) AS Registros FROM Facturas        UNION ALL
SELECT 'Pagos'          AS Tabla, COUNT(*) AS Registros FROM Pagos           UNION ALL
SELECT 'Seguros'        AS Tabla, COUNT(*) AS Registros FROM Seguros         UNION ALL
SELECT 'HorariosMedico' AS Tabla, COUNT(*) AS Registros FROM HorariosMedico  UNION ALL
SELECT 'Triaje'         AS Tabla, COUNT(*) AS Registros FROM Triaje          UNION ALL
SELECT 'HistorialClinico'    AS Tabla, COUNT(*) AS Registros FROM HistorialClinico    UNION ALL
SELECT 'CancelacionesCita'   AS Tabla, COUNT(*) AS Registros FROM CancelacionesCita  UNION ALL
SELECT 'AuditoriaLog'        AS Tabla, COUNT(*) AS Registros FROM AuditoriaLog
ORDER BY Tabla;

-- ============================================================
-- 4. VER COLUMNAS DE CADA TABLA IMPORTANTE
-- ============================================================
SELECT
    TABLE_NAME          AS Tabla,
    COLUMN_NAME         AS Columna,
    DATA_TYPE           AS Tipo,
    IS_NULLABLE         AS Nulo,
    CHARACTER_MAXIMUM_LENGTH AS Longitud
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'Usuarios','Pacientes','Medicos','Citas',
    'Facturas','Recetas','Medicamentos','Contactos'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- ============================================================
-- 5. VER RELACIONES (FOREIGN KEYS)
-- ============================================================
SELECT
    fk.name                         AS RelacionNombre,
    tp.name                         AS TablaOrigen,
    cp.name                         AS ColumnaOrigen,
    tr.name                         AS TablaDestino,
    cr.name                         AS ColumnaDestino
FROM sys.foreign_keys fk
INNER JOIN sys.tables tp    ON fk.parent_object_id   = tp.object_id
INNER JOIN sys.tables tr    ON fk.referenced_object_id = tr.object_id
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.columns cp   ON fkc.parent_object_id  = cp.object_id  AND fkc.parent_column_id  = cp.column_id
INNER JOIN sys.columns cr   ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
ORDER BY TablaOrigen, RelacionNombre;

-- ============================================================
-- 6. VER DATOS INICIALES INSERTADOS
-- ============================================================
SELECT 'Roles:'          AS [--- DATOS INICIALES ---], '' AS Valor
UNION ALL SELECT '  ' + NombreRol, Descripcion FROM Roles

UNION ALL SELECT '--- Especialidades ---', ''
UNION ALL SELECT '  ' + Nombre, Descripcion FROM Especialidades

UNION ALL SELECT '--- EstadosCita ---', ''
UNION ALL SELECT '  ' + Nombre, '' FROM EstadosCita

UNION ALL SELECT '--- TipoAsegurado ---', ''
UNION ALL SELECT '  ' + Nombre, '' FROM TipoAsegurado

UNION ALL SELECT '--- Medicamentos ---', ''
UNION ALL SELECT '  ' + Nombre, 'S/.' + CAST(Precio AS VARCHAR) FROM Medicamentos

UNION ALL SELECT '--- MetodosPago ---', ''
UNION ALL SELECT '  ' + Nombre, '' FROM MetodosPago

UNION ALL SELECT '--- Consultorios ---', ''
UNION ALL SELECT '  ' + Nombre, Piso FROM Consultorios;
