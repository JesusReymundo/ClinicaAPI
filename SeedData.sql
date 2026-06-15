-- ============================================================
-- SEED DATA - ClinicaDB  (set-based, FK-aware, sin WHILE loops)
-- ============================================================
USE ClinicaDB;
GO

-- ============================================================
-- PASO 1: LIMPIEZA EN ORDEN FK (hijo -> padre)
-- ============================================================
DELETE FROM AuditoriaLog;
DELETE FROM CancelacionesCita;
DELETE FROM DetalleReceta;
DELETE FROM Pagos;
DELETE FROM Facturas;
DELETE FROM Seguros;
DELETE FROM Triaje;
DELETE FROM HistorialClinico;
DELETE FROM Recetas;
DELETE FROM Citas;
DELETE FROM HorariosMedico;
DELETE FROM Pacientes;
DELETE FROM Medicos;
DELETE FROM Contactos;
DELETE FROM Usuarios;
DELETE FROM Consultorios;
DELETE FROM Empresas;

DBCC CHECKIDENT ('AuditoriaLog',     RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('CancelacionesCita',RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('DetalleReceta',    RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Pagos',            RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Facturas',         RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Seguros',          RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Triaje',           RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('HistorialClinico', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Recetas',          RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Citas',            RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('HorariosMedico',   RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Pacientes',        RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Medicos',          RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Contactos',        RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Usuarios',         RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Consultorios',     RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Empresas',         RESEED, 0) WITH NO_INFOMSGS;
GO

-- ============================================================
-- PASO 2: DATOS DE APOYO (lookup no limpiado)
-- ============================================================

-- Estado Anulada (5) si no existe
IF NOT EXISTS (SELECT 1 FROM EstadosCita WHERE Nombre = 'Anulada')
    INSERT INTO EstadosCita (Nombre) VALUES ('Anulada');

-- Consultorios
INSERT INTO Consultorios (Nombre, Piso, Disponible) VALUES
('Consultorio 101', '1', 1),
('Consultorio 102', '1', 1),
('Consultorio 201', '2', 1),
('Consultorio 202', '2', 1),
('Consultorio 301', '3', 1);

-- Empresas (10 empresas para pacientes corporativos)
INSERT INTO Empresas (RazonSocial, RUC, Direccion, Telefono, Email, Activo) VALUES
('Corporacion IDAT S.A.C.',    '20123456789', 'Av. Javier Prado 1234, San Isidro', '014567890', 'contacto@idat.pe',    1),
('Minera Andina S.A.',         '20234567890', 'Jr. Camana 456, Lima Centro',        '014678901', 'info@minera.pe',     1),
('Pesquera Del Mar S.A.',      '20345678901', 'Av. Argentina 789, Callao',          '014789012', 'admin@delmar.pe',    1),
('Retail Peru S.A.C.',         '20456789012', 'Av. Larco 321, Miraflores',          '014890123', 'gerencia@retail.pe', 1),
('Constructora Andina S.A.',   '20567890123', 'Av. J. Prado 567, La Molina',        '014901234', 'obras@andina.pe',    1),
('BancoPeru S.A.',             '20678901234', 'Jr. de la Union 100, Lima',          '014012345', 'clientes@banco.pe',  1),
('TecnoSoft S.A.C.',           '20789012345', 'Av. La Marina 890, San Miguel',      '014123456', 'info@tecno.pe',      1),
('Agroexport Sur S.A.',        '20890123456', 'Carretera Panamericana 456, Ica',    '564567890', 'export@agro.pe',     1),
('Salud Integral S.A.C.',      '20901234567', 'Av. Benavides 654, Surco',           '014234567', 'admin@salud.pe',     1),
('Educacion Futura S.A.C.',    '20012345678', 'Av. Universitaria 987, Los Olivos',  '014345678', 'info@eduf.pe',       1);
GO

-- ============================================================
-- PASO 3: USUARIOS  (100 registros)
-- IdRol: 1=Administrador, 2=Medico, 3=Paciente
-- ============================================================

-- 6 usuarios nombrados (admins + medicos del equipo)
INSERT INTO Usuarios (IdRol, Nombres, Apellidos, DNI, FechaNacimiento, Genero, Direccion, Username, PasswordHash, Activo)
VALUES
(1,'Jesus Reymundo','Roman',          '70123456','1998-05-15','M','Miraflores, Lima',   'admin',        'Admin@2024',   1),
(1,'Leomarc',       'Reyes Torres',   '70234567','1997-03-20','M','San Isidro, Lima',   'admin2',       'Admin@2024',   1),
(2,'Aldair Santos', 'Cahuana Paz',    '70345678','1990-07-10','M','Surco, Lima',         'dr_aldair',    'Doctor@2024',  1),
(2,'Ivan',          'Zarate Lopez',   '70456789','1988-11-25','M','La Molina, Lima',     'dr_ivan',      'Doctor@2024',  1),
(2,'Crhistian',     'Meza Quispe',    '70567890','1992-04-08','M','San Borja, Lima',     'dr_crhistian', 'Doctor@2024',  1),
(2,'Alexandee',     'Morillo Vega',   '70678901','1991-09-14','M','Pueblo Libre, Lima',  'dr_alexandee', 'Doctor@2024',  1);
GO

-- 94 usuarios restantes (24 medicos ficticios + 70 pacientes) via CTE
WITH Nums AS (
    SELECT TOP 94 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.all_objects
),
Datos AS (
    SELECT
        rn,
        CASE WHEN rn <= 24 THEN 2 ELSE 3 END AS IdRol,
        CASE WHEN rn <= 24 THEN 'M'
             WHEN rn % 3 = 0 THEN 'F' ELSE 'M' END AS Genero,
        CASE
          WHEN rn <= 24 OR rn % 3 != 0 THEN
            CHOOSE(((rn-1) % 24) + 1,
              'Roberto','Miguel','Carlos','Fernando','Eduardo','Ricardo',
              'Jorge','Pablo','Mario','Cesar','Luis','Antonio',
              'Rafael','David','Daniel','Alberto','Victor','Manuel',
              'Jose','Diego','Alejandro','Sebastian','Nicolas','Andres')
          ELSE
            CHOOSE(((rn-1) % 20) + 1,
              'Maria','Ana','Rosa','Carmen','Laura','Patricia',
              'Isabel','Sofia','Beatriz','Adriana','Luisa','Monica',
              'Claudia','Sandra','Veronica','Gabriela','Alexandra','Vanessa',
              'Natalia','Valeria')
        END AS Nombres,
        CHOOSE(((rn-1) % 15) + 1,
          'Lopez','Garcia','Martinez','Rodriguez','Hernandez',
          'Gonzalez','Perez','Sanchez','Ramirez','Flores',
          'Torres','Vargas','Diaz','Cruz','Morales') AS Ape1,
        CHOOSE(((rn+5) % 10) + 1,
          'Reyes','Jimenez','Ortega','Mendoza','Castillo',
          'Castro','Rojas','Alvarez','Gutierrez','Navarro') AS Ape2,
        RIGHT('00000000' + CAST(20000000 + rn AS VARCHAR(10)), 8) AS DNI,
        DATEFROMPARTS(
            CASE WHEN rn <= 24 THEN 1975 + (rn % 15) ELSE 1960 + (rn % 40) END,
            (rn % 12) + 1,
            (rn % 25) + 1) AS FechaNac,
        CHOOSE((rn % 8) + 1,
          'Miraflores','San Isidro','Surco','La Molina',
          'San Borja','Pueblo Libre','Barranco','Jesus Maria') + ', Lima' AS Dir,
        CASE WHEN rn <= 24
             THEN 'medico' + CAST(rn + 6 AS VARCHAR)
             ELSE 'paciente' + CAST(rn - 24 AS VARCHAR)
        END AS Uname,
        CASE WHEN rn <= 24 THEN 'Medico@2024' ELSE 'Paciente123' END AS Pass
    FROM Nums
)
INSERT INTO Usuarios (IdRol, Nombres, Apellidos, DNI, FechaNacimiento, Genero, Direccion, Username, PasswordHash, Activo)
SELECT IdRol, Nombres, Ape1 + ' ' + Ape2, DNI, FechaNac, Genero, Dir, Uname, Pass, 1
FROM Datos;
GO

-- ============================================================
-- PASO 4: CONTACTOS (telefono + email por usuario)
-- ============================================================
INSERT INTO Contactos (IdUsuario, TipoContacto, Valor, EsPrincipal)
SELECT IdUsuario, 'Telefono',
       '9' + RIGHT('000000000' + CAST(ABS(IdUsuario * 7 + 12345678) AS VARCHAR(10)), 8),
       1
FROM Usuarios;

INSERT INTO Contactos (IdUsuario, TipoContacto, Valor, EsPrincipal)
SELECT IdUsuario, 'Email',
       LOWER(REPLACE(Nombres, ' ', '')) + CAST(IdUsuario AS VARCHAR) + '@gmail.com',
       0
FROM Usuarios;
GO

-- ============================================================
-- PASO 5: MEDICOS (usuarios 3-30, IdMedico 1-28)
-- Especialidades: 1=Cardiologia 2=MedGeneral 3=Pediatria 4=Dermatologia 5=Traumatologia
-- ============================================================
INSERT INTO Medicos (IdUsuario, IdEspecialidad, ColegioMedico, Consultorio, TarifaConsulta)
SELECT
    u.IdUsuario,
    ((u.IdUsuario - 3) % 5) + 1,
    'CM' + RIGHT('000000' + CAST(u.IdUsuario - 2 AS VARCHAR(6)), 6),
    'Consultorio ' + CAST(((u.IdUsuario - 3) % 5) + 1 AS VARCHAR) +
    '0' + CAST(((u.IdUsuario - 3) % 2) + 1 AS VARCHAR),
    CHOOSE(((u.IdUsuario - 3) % 5) + 1, 120.00, 80.00, 90.00, 100.00, 110.00)
FROM Usuarios u
WHERE u.IdUsuario BETWEEN 3 AND 30
ORDER BY u.IdUsuario;
GO

-- ============================================================
-- PASO 6: HORARIOS MEDICO (Lunes a Viernes por cada medico)
-- ============================================================
INSERT INTO HorariosMedico (IdMedico, DiaSemana, HoraInicio, HoraFin, IdConsultorio, Activo)
SELECT
    m.IdMedico,
    d.DiaSemana,
    CASE WHEN m.IdMedico % 2 = 0 THEN '09:00:00' ELSE '14:00:00' END,
    CASE WHEN m.IdMedico % 2 = 0 THEN '13:00:00' ELSE '18:00:00' END,
    ((m.IdMedico - 1) % 5) + 1,
    1
FROM Medicos m
CROSS JOIN (VALUES (1),(2),(3),(4),(5)) AS d(DiaSemana);
GO

-- ============================================================
-- PASO 7: PACIENTES (todos los 100 usuarios son pacientes)
-- IdPaciente  1-50  : Particular (1)
-- IdPaciente 51-65  : Corporativo (2) con empresa 1-10
-- IdPaciente 66-80  : EsSalud (3)
-- IdPaciente 81-100 : SIS (4)
-- ============================================================
INSERT INTO Pacientes (IdUsuario, IdTipoAsegurado, IdEmpresa, NumeroSeguro, GrupoSanguineo, Alergias)
SELECT
    u.IdUsuario,
    CASE
        WHEN u.IdUsuario BETWEEN  1 AND 50 THEN 1
        WHEN u.IdUsuario BETWEEN 51 AND 65 THEN 2
        WHEN u.IdUsuario BETWEEN 66 AND 80 THEN 3
        ELSE                                     4
    END,
    CASE
        WHEN u.IdUsuario BETWEEN 51 AND 65
        THEN ((u.IdUsuario - 51) % 10) + 1
        ELSE NULL
    END,
    CASE
        WHEN u.IdUsuario BETWEEN 66 AND 80
        THEN 'ES-' + RIGHT('000000' + CAST(u.IdUsuario AS VARCHAR(6)), 6)
        WHEN u.IdUsuario > 80
        THEN 'SIS' + RIGHT('000000' + CAST(u.IdUsuario AS VARCHAR(6)), 6)
        ELSE NULL
    END,
    CHOOSE((u.IdUsuario % 8) + 1, 'A+','A-','B+','B-','AB+','AB-','O+','O-'),
    CASE WHEN u.IdUsuario % 4 = 0
         THEN CHOOSE((u.IdUsuario % 5) + 1,
                'Penicilina','Sulfas','Latex','Polvo ambiental','Mariscos')
         ELSE NULL
    END
FROM Usuarios u
ORDER BY u.IdUsuario;
GO

-- ============================================================
-- PASO 8: SEGUROS (para pacientes Corporativo y EsSalud)
-- ============================================================
INSERT INTO Seguros (IdPaciente, NombreSeguro, NumeroPoliza, FechaVigencia, CoberturaMax, Activo)
SELECT
    p.IdPaciente,
    CHOOSE((p.IdPaciente % 4) + 1,
        'Rimac Seguros','Pacifico Seguros','La Positiva','Mapfre Seguros'),
    'POL-' + RIGHT('000000' + CAST(p.IdPaciente AS VARCHAR(6)), 6),
    CAST(DATEADD(YEAR, 1, GETDATE()) AS DATE),
    CHOOSE((p.IdPaciente % 3) + 1, 5000.00, 10000.00, 15000.00),
    1
FROM Pacientes p
WHERE p.IdTipoAsegurado IN (2, 3);
GO

-- ============================================================
-- PASO 9: CITAS
-- IMPORTANTE: @hoy es DATETIME para que DATEADD(HOUR,...) funcione
-- (evita Msg 9810: datepart hour not supported for DATE)
-- ============================================================
DECLARE @hoy DATETIME = CAST(CAST(GETDATE() AS DATE) AS DATETIME);

-- Pacientes regulares (IdPaciente 31-100): 12 fechas c/u = 840 citas
WITH Fechas AS (
    SELECT d, h FROM (VALUES
        (-180, 9),(-165,10),(-150,14),(-135, 9),
        (-120,11),( -90,10),( -60,14),( -30, 9),
        ( -15,11),(  -5,10),(   5,14),(  20,  9)
    ) v(d, h)
)
INSERT INTO Citas (IdPaciente, IdMedico, IdEstado, FechaHora, Motivo, Observaciones, FechaCreacion)
SELECT
    p.IdPaciente,
    (((p.IdPaciente - 1 + ABS(f.d)) % 28) + 1) AS IdMedico,
    CASE
        WHEN f.d <= -30
        THEN CHOOSE(((p.IdPaciente + ABS(f.d)) % 5) + 1, 4,4,4,3,5)
        WHEN f.d < 0
        THEN CHOOSE(((p.IdPaciente + ABS(f.d)) % 3) + 1, 4,4,3)
        ELSE CHOOSE( (p.IdPaciente + f.d)       % 2  + 1, 1,2)
    END AS IdEstado,
    DATEADD(HOUR, f.h, DATEADD(DAY, f.d, @hoy)) AS FechaHora,
    CHOOSE(((p.IdPaciente + ABS(f.d) - 1) % 12) + 1,
        'Dolor de cabeza y mareos',
        'Control de presion arterial',
        'Fiebre y congestion nasal',
        'Chequeo general preventivo',
        'Dolor lumbar cronico',
        'Infeccion respiratoria aguda',
        'Control post-operatorio',
        'Evaluacion cardiovascular',
        'Problema dermatologico',
        'Consulta pediatrica',
        'Trauma en extremidades',
        'Consulta de seguimiento') AS Motivo,
    NULL AS Observaciones,
    DATEADD(DAY, -1, DATEADD(HOUR, f.h, DATEADD(DAY, f.d, @hoy))) AS FechaCreacion
FROM Pacientes p
CROSS JOIN Fechas f
WHERE p.IdPaciente BETWEEN 31 AND 100;

-- Medicos como pacientes (IdPaciente 3-30): 4 fechas c/u = 112 citas
WITH FechasMed AS (
    SELECT d, h FROM (VALUES (-60,9),(-30,11),(-10,14),(5,10)) v(d,h)
)
INSERT INTO Citas (IdPaciente, IdMedico, IdEstado, FechaHora, Motivo, Observaciones, FechaCreacion)
SELECT
    p.IdPaciente,
    CASE
        WHEN (p.IdPaciente % 28) + 1 = (SELECT TOP 1 IdMedico FROM Medicos WHERE IdUsuario = p.IdUsuario)
        THEN (p.IdPaciente % 27) + 2
        ELSE (p.IdPaciente % 28) + 1
    END AS IdMedico,
    CHOOSE(((p.IdPaciente + ABS(fm.d)) % 3) + 1, 4, 4, 2) AS IdEstado,
    DATEADD(HOUR, fm.h, DATEADD(DAY, fm.d, @hoy)) AS FechaHora,
    CHOOSE((p.IdPaciente % 5) + 1,
        'Chequeo anual preventivo',
        'Control de salud ocupacional',
        'Evaluacion cardiovascular',
        'Seguimiento de tratamiento',
        'Consulta medica general') AS Motivo,
    NULL AS Observaciones,
    DATEADD(DAY, -1, DATEADD(HOUR, fm.h, DATEADD(DAY, fm.d, @hoy))) AS FechaCreacion
FROM Pacientes p
CROSS JOIN FechasMed fm
WHERE p.IdPaciente BETWEEN 3 AND 30;
GO

-- ============================================================
-- PASO 10: HISTORIAL CLINICO (una entrada por cita completada)
-- ============================================================
INSERT INTO HistorialClinico (IdPaciente, IdCita, Diagnostico, Tratamiento, Evolucion, FechaRegistro)
SELECT
    c.IdPaciente,
    c.IdCita,
    CHOOSE((c.IdCita % 10) + 1,
        'Hipertension arterial grado I',
        'Infeccion respiratoria aguda',
        'Gastritis cronica leve',
        'Lumbalgia mecanica',
        'Dermatitis atopica',
        'Taquicardia sinusal',
        'Lesion muscular consolidada',
        'Otitis media aguda',
        'Rinitis alergica cronica',
        'Trastorno de ansiedad leve'),
    CHOOSE((c.IdCita % 8) + 1,
        'Reposo relativo y antihipertensivos',
        'Antibioterapia 7 dias y reposo',
        'Dieta blanda, antiácidos y protector gastrico',
        'Fisioterapia 10 sesiones y analgesicos',
        'Crema corticoide topica y antihistaminico',
        'Betabloqueante oral, control en 4 semanas',
        'Control radiologico mensual y analgesicos',
        'Gotas oticas, analgesicos y control en 7 dias'),
    CHOOSE((c.IdCita % 5) + 1,
        'Evolucion favorable sin complicaciones',
        'Mejoria progresiva con tratamiento',
        'Sin complicaciones, alta medica',
        'Requiere seguimiento en 4 semanas',
        'Estabilizado, continuar tratamiento'),
    DATEADD(HOUR, 2, c.FechaHora)
FROM Citas c
WHERE c.IdEstado = 4;
GO

-- ============================================================
-- PASO 11: RECETAS (80% de citas completadas)
-- ============================================================
INSERT INTO Recetas (IdCita, Diagnostico, Indicaciones, FechaEmision)
SELECT
    c.IdCita,
    CHOOSE((c.IdCita % 10) + 1,
        'Hipertension arterial','Infeccion respiratoria','Gastritis cronica',
        'Lumbalgia mecanica','Dermatitis atopica','Taquicardia sinusal',
        'Lesion muscular','Otitis media','Rinitis alergica','Ansiedad'),
    'Tomar segun indicaciones medicas. Reposo. Control en ' +
        CAST(CHOOSE((c.IdCita % 3) + 1, 7, 14, 30) AS VARCHAR) + ' dias.',
    DATEADD(HOUR, 1, c.FechaHora)
FROM Citas c
WHERE c.IdEstado = 4 AND c.IdCita % 5 != 0;
GO

-- ============================================================
-- PASO 12: DETALLE RECETA
-- ============================================================
INSERT INTO DetalleReceta (IdReceta, IdMedicamento, Dosis, Frecuencia, Duracion, Cantidad)
SELECT
    r.IdReceta,
    ((r.IdReceta - 1) % 5) + 1,
    CHOOSE((r.IdReceta % 4) + 1, '1 tableta','2 tabletas','1 capsula','5ml'),
    CHOOSE((r.IdReceta % 3) + 1, 'Cada 8 horas','Cada 12 horas','Una vez al dia'),
    CHOOSE((r.IdReceta % 3) + 1, '7 dias','14 dias','30 dias'),
    CHOOSE((r.IdReceta % 3) + 1, 21, 14, 30)
FROM Recetas r;

-- Segundo medicamento para la mitad de las recetas (cuando no coincide con el primero)
INSERT INTO DetalleReceta (IdReceta, IdMedicamento, Dosis, Frecuencia, Duracion, Cantidad)
SELECT
    r.IdReceta,
    (r.IdReceta % 5) + 1,
    '1 tableta',
    'Cada 24 horas',
    '14 dias',
    14
FROM Recetas r
WHERE r.IdReceta % 2 = 0
  AND (r.IdReceta % 5) + 1 != ((r.IdReceta - 1) % 5) + 1;
GO

-- ============================================================
-- PASO 13: FACTURAS (una por cita completada)
-- ============================================================
INSERT INTO Facturas (IdCita, NumeroFactura, Serie, Subtotal, IGV, Total, EstadoPago, FechaEmision)
SELECT
    c.IdCita,
    'F001-' + RIGHT('000000' + CAST(c.IdCita AS VARCHAR(10)), 6),
    'F001',
    ISNULL(m.TarifaConsulta, 80.00),
    ROUND(ISNULL(m.TarifaConsulta, 80.00) * 0.18, 2),
    ROUND(ISNULL(m.TarifaConsulta, 80.00) * 1.18, 2),
    CASE WHEN c.IdCita % 6 = 0 THEN 'Pendiente' ELSE 'Pagado' END,
    DATEADD(HOUR, 1, c.FechaHora)
FROM Citas c
INNER JOIN Medicos m ON c.IdMedico = m.IdMedico
WHERE c.IdEstado = 4;
GO

-- ============================================================
-- PASO 14: PAGOS (facturas en estado Pagado)
-- ============================================================
INSERT INTO Pagos (IdFactura, IdMetodo, Monto, NroOperacion, FechaPago, Observaciones)
SELECT
    f.IdFactura,
    ((f.IdFactura % 6) + 1),
    f.Total,
    CASE WHEN (f.IdFactura % 6) IN (4, 5)
         THEN 'TRF' + RIGHT('000000' + CAST(f.IdFactura AS VARCHAR(10)), 6)
         ELSE NULL END,
    DATEADD(MINUTE, 30, f.FechaEmision),
    NULL
FROM Facturas f
WHERE f.EstadoPago = 'Pagado';
GO

-- ============================================================
-- PASO 15: CANCELACIONES (citas Cancelada=3 y Anulada=5)
-- ============================================================
INSERT INTO CancelacionesCita (IdCita, Motivo, CanceladoPor, FechaCancelacion)
SELECT
    c.IdCita,
    CHOOSE((c.IdCita % 5) + 1,
        'Paciente no pudo asistir',
        'Emergencia personal del paciente',
        'Medico no disponible en el horario',
        'Reagendamiento solicitado',
        'Cita duplicada por error del sistema'),
    CASE c.IdEstado WHEN 3 THEN 'Paciente' ELSE 'Medico' END,
    DATEADD(HOUR, -2, c.FechaHora)
FROM Citas c
WHERE c.IdEstado IN (3, 5);
GO

-- ============================================================
-- VERIFICACION FINAL
-- ============================================================
SELECT 'Usuarios'            AS Tabla, COUNT(*) AS Total FROM Usuarios         UNION ALL
SELECT 'Medicos',            COUNT(*) FROM Medicos                              UNION ALL
SELECT 'Pacientes',          COUNT(*) FROM Pacientes                            UNION ALL
SELECT 'Contactos',          COUNT(*) FROM Contactos                            UNION ALL
SELECT 'HorariosMedico',     COUNT(*) FROM HorariosMedico                      UNION ALL
SELECT 'Seguros',            COUNT(*) FROM Seguros                              UNION ALL
SELECT 'Citas',              COUNT(*) FROM Citas                                UNION ALL
SELECT 'HistorialClinico',   COUNT(*) FROM HistorialClinico                     UNION ALL
SELECT 'Recetas',            COUNT(*) FROM Recetas                              UNION ALL
SELECT 'DetalleReceta',      COUNT(*) FROM DetalleReceta                        UNION ALL
SELECT 'Facturas',           COUNT(*) FROM Facturas                             UNION ALL
SELECT 'Pagos',              COUNT(*) FROM Pagos                                UNION ALL
SELECT 'CancelacionesCita',  COUNT(*) FROM CancelacionesCita
ORDER BY Tabla;
GO
