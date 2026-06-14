-- ============================================================
-- TABLAS ADICIONALES - ClinicaDB
-- Para un sistema de clinica mas completo y real
-- ============================================================

USE ClinicaDB;
GO

-- ============================================================
-- 1. TIPO DE CONSULTA (primera vez, seguimiento, urgencia)
-- ============================================================
CREATE TABLE TipoConsulta (
    IdTipoConsulta INT PRIMARY KEY IDENTITY(1,1),
    Nombre         VARCHAR(50)   NOT NULL, -- Primera Vez, Seguimiento, Urgencia
    Descripcion    VARCHAR(200),
    TarifaExtra    DECIMAL(10,2) NOT NULL DEFAULT 0
);

-- ============================================================
-- 2. SALAS / CONSULTORIOS
-- ============================================================
CREATE TABLE Consultorios (
    IdConsultorio INT PRIMARY KEY IDENTITY(1,1),
    Nombre        VARCHAR(50)  NOT NULL, -- Consultorio 1, Sala de Urgencias
    Piso          VARCHAR(10),
    Disponible    BIT          NOT NULL DEFAULT 1
);

-- ============================================================
-- 3. HORARIOS DE MEDICOS (dias y horas que atiende)
-- ============================================================
CREATE TABLE HorariosMedico (
    IdHorario     INT PRIMARY KEY IDENTITY(1,1),
    IdMedico      INT         NOT NULL,
    DiaSemana     TINYINT     NOT NULL, -- 1=Lunes ... 7=Domingo
    HoraInicio    TIME        NOT NULL,
    HoraFin       TIME        NOT NULL,
    IdConsultorio INT,
    Activo        BIT         NOT NULL DEFAULT 1,
    CONSTRAINT FK_Horarios_Medicos      FOREIGN KEY (IdMedico)      REFERENCES Medicos(IdMedico),
    CONSTRAINT FK_Horarios_Consultorios FOREIGN KEY (IdConsultorio) REFERENCES Consultorios(IdConsultorio)
);

-- ============================================================
-- 4. TRIAJE (signos vitales antes de la consulta)
-- ============================================================
CREATE TABLE Triaje (
    IdTriaje        INT PRIMARY KEY IDENTITY(1,1),
    IdCita          INT           NOT NULL UNIQUE,
    Peso            DECIMAL(5,2),           -- kg
    Talla           DECIMAL(5,2),           -- cm
    PresionSistolica   INT,                 -- mmHg
    PresionDiastolica  INT,                 -- mmHg
    FrecuenciaCardiaca INT,                 -- latidos/min
    Temperatura     DECIMAL(4,1),           -- °C
    Saturacion      DECIMAL(4,1),           -- % O2
    FechaRegistro   DATETIME     NOT NULL DEFAULT GETDATE(),
    Observaciones   VARCHAR(300),
    CONSTRAINT FK_Triaje_Citas FOREIGN KEY (IdCita) REFERENCES Citas(IdCita)
);

-- ============================================================
-- 5. HISTORIAL CLINICO del paciente
-- ============================================================
CREATE TABLE HistorialClinico (
    IdHistorial   INT PRIMARY KEY IDENTITY(1,1),
    IdPaciente    INT          NOT NULL,
    IdCita        INT          NOT NULL,
    Diagnostico   VARCHAR(500) NOT NULL,
    Tratamiento   VARCHAR(500),
    Evolucion     VARCHAR(500),
    FechaRegistro DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Historial_Pacientes FOREIGN KEY (IdPaciente) REFERENCES Pacientes(IdPaciente),
    CONSTRAINT FK_Historial_Citas     FOREIGN KEY (IdCita)     REFERENCES Citas(IdCita)
);

-- ============================================================
-- 6. METODOS DE PAGO
-- ============================================================
CREATE TABLE MetodosPago (
    IdMetodo INT PRIMARY KEY IDENTITY(1,1),
    Nombre   VARCHAR(50) NOT NULL -- Efectivo, Tarjeta, Transferencia, Seguro
);

-- ============================================================
-- 7. PAGOS (asociado a la factura)
-- ============================================================
CREATE TABLE Pagos (
    IdPago        INT PRIMARY KEY IDENTITY(1,1),
    IdFactura     INT           NOT NULL,
    IdMetodo      INT           NOT NULL,
    Monto         DECIMAL(10,2) NOT NULL,
    NroOperacion  VARCHAR(50),              -- numero de transferencia o voucher
    FechaPago     DATETIME      NOT NULL DEFAULT GETDATE(),
    Observaciones VARCHAR(200),
    CONSTRAINT FK_Pagos_Facturas     FOREIGN KEY (IdFactura) REFERENCES Facturas(IdFactura),
    CONSTRAINT FK_Pagos_MetodosPago  FOREIGN KEY (IdMetodo)  REFERENCES MetodosPago(IdMetodo)
);

-- ============================================================
-- 8. SEGUROS MEDICOS del paciente
-- ============================================================
CREATE TABLE Seguros (
    IdSeguro      INT PRIMARY KEY IDENTITY(1,1),
    IdPaciente    INT         NOT NULL,
    NombreSeguro  VARCHAR(100) NOT NULL,   -- Rimac, Pacifico, EsSalud
    NumeroPoliza  VARCHAR(50)  NOT NULL,
    FechaVigencia DATE         NOT NULL,
    CoberturaMax  DECIMAL(10,2),
    Activo        BIT          NOT NULL DEFAULT 1,
    CONSTRAINT FK_Seguros_Pacientes FOREIGN KEY (IdPaciente) REFERENCES Pacientes(IdPaciente)
);

-- ============================================================
-- 9. MOTIVOS DE CANCELACION
-- ============================================================
CREATE TABLE CancelacionesCita (
    IdCancelacion INT PRIMARY KEY IDENTITY(1,1),
    IdCita        INT          NOT NULL UNIQUE,
    Motivo        VARCHAR(300) NOT NULL,
    CanceladoPor  VARCHAR(20)  NOT NULL, -- Paciente, Medico, Sistema
    FechaCancelacion DATETIME  NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Cancelaciones_Citas FOREIGN KEY (IdCita) REFERENCES Citas(IdCita)
);

-- ============================================================
-- 10. AUDITORIA (registro de cambios importantes)
-- ============================================================
CREATE TABLE AuditoriaLog (
    IdLog       INT PRIMARY KEY IDENTITY(1,1),
    IdUsuario   INT          NOT NULL,
    Tabla       VARCHAR(50)  NOT NULL,
    Accion      VARCHAR(20)  NOT NULL, -- INSERT, UPDATE, DELETE
    Descripcion VARCHAR(500),
    FechaAccion DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Auditoria_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario)
);

GO

-- ============================================================
-- VISTAS ADICIONALES
-- ============================================================

-- Vista: Historial clinico completo del paciente
CREATE VIEW Vista_HistorialPaciente AS
SELECT
    h.IdHistorial,
    CONCAT(u.Nombres, ' ', u.Apellidos)           AS NombrePaciente,
    u.DNI,
    c.FechaHora                                    AS FechaCita,
    CONCAT('Dr. ', um.Nombres, ' ', um.Apellidos)  AS NombreMedico,
    e.Nombre                                       AS Especialidad,
    h.Diagnostico,
    h.Tratamiento,
    h.Evolucion,
    h.FechaRegistro
FROM HistorialClinico h
INNER JOIN Pacientes p      ON h.IdPaciente     = p.IdPaciente
INNER JOIN Usuarios u       ON p.IdUsuario      = u.IdUsuario
INNER JOIN Citas c          ON h.IdCita         = c.IdCita
INNER JOIN Medicos m        ON c.IdMedico       = m.IdMedico
INNER JOIN Usuarios um      ON m.IdUsuario      = um.IdUsuario
INNER JOIN Especialidades e ON m.IdEspecialidad = e.IdEspecialidad;
GO

-- Vista: Pagos con detalle de factura
CREATE VIEW Vista_Pagos AS
SELECT
    p.IdPago,
    f.NumeroFactura,
    CONCAT(u.Nombres, ' ', u.Apellidos) AS NombrePaciente,
    mp.Nombre                           AS MetodoPago,
    p.Monto,
    p.NroOperacion,
    p.FechaPago,
    f.Total                             AS TotalFactura,
    f.EstadoPago
FROM Pagos p
INNER JOIN Facturas f       ON p.IdFactura  = f.IdFactura
INNER JOIN MetodosPago mp   ON p.IdMetodo   = mp.IdMetodo
INNER JOIN Citas c          ON f.IdCita     = c.IdCita
INNER JOIN Pacientes pa     ON c.IdPaciente = pa.IdPaciente
INNER JOIN Usuarios u       ON pa.IdUsuario = u.IdUsuario;
GO

-- Vista: Horarios disponibles por medico
CREATE VIEW Vista_HorariosMedicos AS
SELECT
    CONCAT('Dr. ', u.Nombres, ' ', u.Apellidos) AS NombreMedico,
    e.Nombre                                     AS Especialidad,
    CASE h.DiaSemana
        WHEN 1 THEN 'Lunes'
        WHEN 2 THEN 'Martes'
        WHEN 3 THEN 'Miercoles'
        WHEN 4 THEN 'Jueves'
        WHEN 5 THEN 'Viernes'
        WHEN 6 THEN 'Sabado'
        WHEN 7 THEN 'Domingo'
    END                                          AS Dia,
    h.HoraInicio,
    h.HoraFin,
    con.Nombre                                   AS Consultorio
FROM HorariosMedico h
INNER JOIN Medicos m        ON h.IdMedico       = m.IdMedico
INNER JOIN Usuarios u       ON m.IdUsuario      = u.IdUsuario
INNER JOIN Especialidades e ON m.IdEspecialidad = e.IdEspecialidad
LEFT  JOIN Consultorios con ON h.IdConsultorio  = con.IdConsultorio
WHERE h.Activo = 1;
GO

-- ============================================================
-- DATOS INICIALES ADICIONALES
-- ============================================================

INSERT INTO TipoConsulta (Nombre, Descripcion, TarifaExtra) VALUES
('Primera Vez',  'Primera consulta del paciente con el medico', 0),
('Seguimiento',  'Consulta de control o seguimiento',          -10),
('Urgencia',     'Atencion de emergencia',                      30),
('Teleconsulta', 'Consulta virtual por videollamada',          -20);

INSERT INTO MetodosPago (Nombre) VALUES
('Efectivo'),
('Tarjeta de Credito'),
('Tarjeta de Debito'),
('Transferencia Bancaria'),
('Seguro Medico'),
('POS / Yape / Plin');

INSERT INTO Consultorios (Nombre, Piso, Disponible) VALUES
('Consultorio 1 - Cardiologia',   'Piso 1', 1),
('Consultorio 2 - Medicina General','Piso 1', 1),
('Consultorio 3 - Pediatria',     'Piso 2', 1),
('Consultorio 4 - Dermatologia',  'Piso 2', 1),
('Sala de Urgencias',             'Piso 1', 1);
GO
