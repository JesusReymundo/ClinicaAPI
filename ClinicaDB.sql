-- ============================================================
-- CLINICA API - BASE DE DATOS SQL SERVER
-- Desarrollo de Servicios Web - IDAT 5to Ciclo
-- ============================================================

CREATE DATABASE ClinicaDB;
GO

USE ClinicaDB;
GO

-- ============================================================
-- TABLA MADRE: Roles del sistema
-- ============================================================
CREATE TABLE Roles (
    IdRol       INT PRIMARY KEY IDENTITY(1,1),
    NombreRol   VARCHAR(50)  NOT NULL, -- Admin, Medico, Paciente, Recepcionista
    Descripcion VARCHAR(200),
    Activo      BIT          NOT NULL DEFAULT 1,
    FechaCreacion DATETIME   NOT NULL DEFAULT GETDATE()
);

-- ============================================================
-- TABLA MADRE: Usuarios (base de todos los actores del sistema)
-- ============================================================
CREATE TABLE Usuarios (
    IdUsuario     INT PRIMARY KEY IDENTITY(1,1),
    IdRol         INT          NOT NULL,
    Nombres       VARCHAR(100) NOT NULL,
    Apellidos     VARCHAR(100) NOT NULL,
    DNI           VARCHAR(8)   NOT NULL UNIQUE,
    FechaNacimiento DATE,
    Genero        CHAR(1),                    -- M o F
    Direccion     VARCHAR(200),
    Username      VARCHAR(50)  NOT NULL UNIQUE,
    PasswordHash  VARCHAR(256) NOT NULL,
    Activo        BIT          NOT NULL DEFAULT 1,
    FechaCreacion      DATETIME NOT NULL DEFAULT GETDATE(),
    FechaModificacion  DATETIME,
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (IdRol) REFERENCES Roles(IdRol)
);

-- ============================================================
-- Contactos: telefonos y correos de TODOS los usuarios
-- ============================================================
CREATE TABLE Contactos (
    IdContacto   INT PRIMARY KEY IDENTITY(1,1),
    IdUsuario    INT          NOT NULL,
    TipoContacto VARCHAR(20)  NOT NULL, -- Telefono, Email, WhatsApp
    Valor        VARCHAR(150) NOT NULL,
    EsPrincipal  BIT          NOT NULL DEFAULT 0,
    FechaCreacion DATETIME    NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Contactos_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios(IdUsuario)
);

-- ============================================================
-- Empresas: para pacientes corporativos
-- ============================================================
CREATE TABLE Empresas (
    IdEmpresa   INT PRIMARY KEY IDENTITY(1,1),
    RazonSocial VARCHAR(200) NOT NULL,
    RUC         VARCHAR(11)  NOT NULL UNIQUE,
    Direccion   VARCHAR(200),
    Telefono    VARCHAR(20),
    Email       VARCHAR(150),
    Activo      BIT          NOT NULL DEFAULT 1,
    FechaCreacion DATETIME   NOT NULL DEFAULT GETDATE()
);

-- ============================================================
-- Tipo de asegurado (Particular o Corporativo)
-- ============================================================
CREATE TABLE TipoAsegurado (
    IdTipo  INT PRIMARY KEY IDENTITY(1,1),
    Nombre  VARCHAR(50) NOT NULL -- Particular, Corporativo, EsSalud, SIS
);

-- ============================================================
-- Especialidades medicas
-- ============================================================
CREATE TABLE Especialidades (
    IdEspecialidad INT PRIMARY KEY IDENTITY(1,1),
    Nombre         VARCHAR(100) NOT NULL,
    Descripcion    VARCHAR(300),
    Activo         BIT NOT NULL DEFAULT 1
);

-- ============================================================
-- Medicos (hijo de Usuarios)
-- ============================================================
CREATE TABLE Medicos (
    IdMedico       INT PRIMARY KEY IDENTITY(1,1),
    IdUsuario      INT          NOT NULL UNIQUE,
    IdEspecialidad INT          NOT NULL,
    ColegioMedico  VARCHAR(20)  NOT NULL UNIQUE,
    Consultorio    VARCHAR(50),
    TarifaConsulta DECIMAL(10,2),
    FechaCreacion  DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Medicos_Usuarios      FOREIGN KEY (IdUsuario)      REFERENCES Usuarios(IdUsuario),
    CONSTRAINT FK_Medicos_Especialidades FOREIGN KEY (IdEspecialidad) REFERENCES Especialidades(IdEspecialidad)
);

-- ============================================================
-- Pacientes (hijo de Usuarios, puede venir particular o empresa)
-- ============================================================
CREATE TABLE Pacientes (
    IdPaciente      INT PRIMARY KEY IDENTITY(1,1),
    IdUsuario       INT         NOT NULL UNIQUE,
    IdTipoAsegurado INT         NOT NULL,
    IdEmpresa       INT         NULL,          -- NULL si es particular
    NumeroSeguro    VARCHAR(50),
    GrupoSanguineo  VARCHAR(5),
    Alergias        VARCHAR(500),
    FechaCreacion   DATETIME    NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Pacientes_Usuarios      FOREIGN KEY (IdUsuario)       REFERENCES Usuarios(IdUsuario),
    CONSTRAINT FK_Pacientes_TipoAsegurado FOREIGN KEY (IdTipoAsegurado) REFERENCES TipoAsegurado(IdTipo),
    CONSTRAINT FK_Pacientes_Empresas      FOREIGN KEY (IdEmpresa)       REFERENCES Empresas(IdEmpresa)
);

-- ============================================================
-- Estados de Cita (catalogo)
-- ============================================================
CREATE TABLE EstadosCita (
    IdEstado INT PRIMARY KEY IDENTITY(1,1),
    Nombre   VARCHAR(50) NOT NULL -- Pendiente, Confirmada, Cancelada, Completada
);

-- ============================================================
-- Citas medicas
-- ============================================================
CREATE TABLE Citas (
    IdCita            INT PRIMARY KEY IDENTITY(1,1),
    IdPaciente        INT          NOT NULL,
    IdMedico          INT          NOT NULL,
    IdEstado          INT          NOT NULL DEFAULT 1,
    FechaHora         DATETIME     NOT NULL,
    Motivo            VARCHAR(300) NOT NULL,
    Observaciones     VARCHAR(500),
    FechaCreacion     DATETIME     NOT NULL DEFAULT GETDATE(),
    FechaModificacion DATETIME,
    CONSTRAINT FK_Citas_Pacientes   FOREIGN KEY (IdPaciente) REFERENCES Pacientes(IdPaciente),
    CONSTRAINT FK_Citas_Medicos     FOREIGN KEY (IdMedico)   REFERENCES Medicos(IdMedico),
    CONSTRAINT FK_Citas_EstadosCita FOREIGN KEY (IdEstado)   REFERENCES EstadosCita(IdEstado)
);

-- ============================================================
-- Medicamentos
-- ============================================================
CREATE TABLE Medicamentos (
    IdMedicamento INT PRIMARY KEY IDENTITY(1,1),
    Nombre        VARCHAR(200) NOT NULL,
    Presentacion  VARCHAR(100),               -- Tabletas, Jarabe, Inyectable
    Concentracion VARCHAR(50),                -- 500mg, 250ml
    Laboratorio   VARCHAR(100),
    Precio        DECIMAL(10,2) NOT NULL DEFAULT 0,
    Stock         INT           NOT NULL DEFAULT 0,
    Activo        BIT           NOT NULL DEFAULT 1,
    FechaCreacion DATETIME      NOT NULL DEFAULT GETDATE()
);

-- ============================================================
-- Recetas medicas (una por cita)
-- ============================================================
CREATE TABLE Recetas (
    IdReceta     INT PRIMARY KEY IDENTITY(1,1),
    IdCita       INT          NOT NULL UNIQUE,
    Diagnostico  VARCHAR(500),
    Indicaciones VARCHAR(500),
    FechaEmision DATETIME     NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Recetas_Citas FOREIGN KEY (IdCita) REFERENCES Citas(IdCita)
);

-- ============================================================
-- Detalle de Receta (medicamentos por receta)
-- ============================================================
CREATE TABLE DetalleReceta (
    IdDetalle      INT PRIMARY KEY IDENTITY(1,1),
    IdReceta       INT          NOT NULL,
    IdMedicamento  INT          NOT NULL,
    Dosis          VARCHAR(100),              -- 1 tableta
    Frecuencia     VARCHAR(100),              -- Cada 8 horas
    Duracion       VARCHAR(50),               -- 7 dias
    Cantidad       INT          NOT NULL DEFAULT 1,
    CONSTRAINT FK_DetalleReceta_Recetas      FOREIGN KEY (IdReceta)      REFERENCES Recetas(IdReceta),
    CONSTRAINT FK_DetalleReceta_Medicamentos FOREIGN KEY (IdMedicamento) REFERENCES Medicamentos(IdMedicamento)
);

-- ============================================================
-- Facturas
-- ============================================================
CREATE TABLE Facturas (
    IdFactura      INT PRIMARY KEY IDENTITY(1,1),
    IdCita         INT           NOT NULL UNIQUE,
    NumeroFactura  VARCHAR(20)   NOT NULL UNIQUE,
    Serie          VARCHAR(5)    NOT NULL DEFAULT 'F001',
    Subtotal       DECIMAL(10,2) NOT NULL,
    IGV            DECIMAL(10,2) NOT NULL,
    Total          DECIMAL(10,2) NOT NULL,
    EstadoPago     VARCHAR(20)   NOT NULL DEFAULT 'Pendiente', -- Pendiente, Pagado, Anulado
    FechaEmision   DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Facturas_Citas FOREIGN KEY (IdCita) REFERENCES Citas(IdCita)
);

GO

-- ============================================================
-- VISTAS
-- ============================================================

-- Vista 1: Factura completa con todos los datos
CREATE VIEW Vista_Factura AS
SELECT
    f.IdFactura,
    f.NumeroFactura,
    f.Serie,
    f.FechaEmision,
    f.EstadoPago,
    CONCAT(up.Nombres, ' ', up.Apellidos) AS NombrePaciente,
    up.DNI                                AS DNIPaciente,
    ta.Nombre                             AS TipoAsegurado,
    emp.RazonSocial                       AS Empresa,
    CONCAT('Dr. ', um.Nombres, ' ', um.Apellidos) AS NombreMedico,
    e.Nombre                              AS Especialidad,
    m.ColegioMedico,
    c.FechaHora                           AS FechaCita,
    c.Motivo,
    c.Observaciones,
    f.Subtotal,
    f.IGV,
    f.Total
FROM Facturas f
INNER JOIN Citas c          ON f.IdCita         = c.IdCita
INNER JOIN Pacientes p      ON c.IdPaciente     = p.IdPaciente
INNER JOIN Usuarios up      ON p.IdUsuario      = up.IdUsuario
INNER JOIN TipoAsegurado ta ON p.IdTipoAsegurado= ta.IdTipo
LEFT  JOIN Empresas emp     ON p.IdEmpresa      = emp.IdEmpresa
INNER JOIN Medicos m        ON c.IdMedico       = m.IdMedico
INNER JOIN Usuarios um      ON m.IdUsuario      = um.IdUsuario
INNER JOIN Especialidades e ON m.IdEspecialidad = e.IdEspecialidad;
GO

-- Vista 2: Medicamentos por receta
CREATE VIEW Vista_Medicamentos_Receta AS
SELECT
    r.IdReceta,
    c.IdCita,
    c.FechaHora                                    AS FechaCita,
    CONCAT(up.Nombres, ' ', up.Apellidos)          AS NombrePaciente,
    CONCAT('Dr. ', um.Nombres, ' ', um.Apellidos)  AS NombreMedico,
    r.Diagnostico,
    r.Indicaciones,
    med.Nombre                                     AS Medicamento,
    med.Presentacion,
    med.Concentracion,
    dr.Dosis,
    dr.Frecuencia,
    dr.Duracion,
    dr.Cantidad,
    med.Precio                                     AS PrecioUnitario,
    (dr.Cantidad * med.Precio)                     AS Subtotal
FROM Recetas r
INNER JOIN Citas c           ON r.IdCita          = c.IdCita
INNER JOIN Pacientes p       ON c.IdPaciente      = p.IdPaciente
INNER JOIN Usuarios up       ON p.IdUsuario       = up.IdUsuario
INNER JOIN Medicos m         ON c.IdMedico        = m.IdMedico
INNER JOIN Usuarios um       ON m.IdUsuario       = um.IdUsuario
INNER JOIN DetalleReceta dr  ON r.IdReceta        = dr.IdReceta
INNER JOIN Medicamentos med  ON dr.IdMedicamento  = med.IdMedicamento;
GO

-- Vista 3: Contactos de todos los usuarios
CREATE VIEW Vista_Contactos AS
SELECT
    u.IdUsuario,
    CONCAT(u.Nombres, ' ', u.Apellidos) AS NombreCompleto,
    u.DNI,
    rl.NombreRol                        AS Rol,
    c.TipoContacto,
    c.Valor,
    c.EsPrincipal
FROM Usuarios u
INNER JOIN Roles rl    ON u.IdRol     = rl.IdRol
INNER JOIN Contactos c ON u.IdUsuario = c.IdUsuario;
GO

-- Vista 4: Resumen de citas con datos completos
CREATE VIEW Vista_Citas AS
SELECT
    c.IdCita,
    c.FechaHora,
    c.Motivo,
    c.Observaciones,
    ec.Nombre                                      AS Estado,
    CONCAT(up.Nombres, ' ', up.Apellidos)          AS NombrePaciente,
    up.DNI                                         AS DNIPaciente,
    ta.Nombre                                      AS TipoAsegurado,
    CONCAT('Dr. ', um.Nombres, ' ', um.Apellidos)  AS NombreMedico,
    e.Nombre                                       AS Especialidad,
    c.FechaCreacion
FROM Citas c
INNER JOIN Pacientes p       ON c.IdPaciente      = p.IdPaciente
INNER JOIN Usuarios up       ON p.IdUsuario       = up.IdUsuario
INNER JOIN TipoAsegurado ta  ON p.IdTipoAsegurado = ta.IdTipo
INNER JOIN Medicos m         ON c.IdMedico        = m.IdMedico
INNER JOIN Usuarios um       ON m.IdUsuario       = um.IdUsuario
INNER JOIN Especialidades e  ON m.IdEspecialidad  = e.IdEspecialidad
INNER JOIN EstadosCita ec    ON c.IdEstado        = ec.IdEstado;
GO

-- ============================================================
-- DATOS INICIALES
-- ============================================================

INSERT INTO Roles (NombreRol, Descripcion) VALUES
('Administrador', 'Administra el sistema completo'),
('Medico',        'Medico de la clinica'),
('Paciente',      'Paciente registrado'),
('Recepcionista', 'Personal administrativo');

INSERT INTO TipoAsegurado (Nombre) VALUES
('Particular'),
('Corporativo'),
('EsSalud'),
('SIS');

INSERT INTO EstadosCita (Nombre) VALUES
('Pendiente'),
('Confirmada'),
('Cancelada'),
('Completada');

INSERT INTO Especialidades (Nombre, Descripcion) VALUES
('Cardiologia',    'Enfermedades del corazon y sistema cardiovascular'),
('Medicina General','Consultas medicas generales'),
('Pediatria',      'Atencion medica de ninos y adolescentes'),
('Dermatologia',   'Enfermedades de la piel'),
('Traumatologia',  'Lesiones oseas y musculares');

INSERT INTO Medicamentos (Nombre, Presentacion, Concentracion, Laboratorio, Precio, Stock) VALUES
('Paracetamol',  'Tabletas', '500mg',  'Bayer',      2.50,  200),
('Amoxicilina',  'Capsulas', '500mg',  'MK',         5.00,  150),
('Ibuprofeno',   'Tabletas', '400mg',  'Genfar',     3.00,  180),
('Omeprazol',    'Capsulas', '20mg',   'Farmindustria',4.00, 100),
('Loratadina',   'Tabletas', '10mg',   'Bago',       2.00,  120);
GO
