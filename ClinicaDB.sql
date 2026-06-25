-- ================================================================
-- ClinicaDB.sql  |  Esquema v2 — Clínica IDAT
-- Tablas en SINGULAR, campos de auditoría en todas las tablas,
-- Tarifa (médico-especialidad), Comprobante en vez de Factura,
-- TipoDocumento flexible (DNI/CE/RUC/PASAPORTE), Consultorio optimizado
-- ================================================================

USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ClinicaDB')
BEGIN
    ALTER DATABASE ClinicaDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ClinicaDB;
END
GO
CREATE DATABASE ClinicaDB;
GO
USE ClinicaDB;
GO

-- ================================================================
-- CATÁLOGOS
-- ================================================================

CREATE TABLE Rol (
    IdRol         INT           IDENTITY(1,1) PRIMARY KEY,
    NombreRol     VARCHAR(50)   NOT NULL UNIQUE,
    Descripcion   VARCHAR(200)  NULL,
    Activo        BIT           NOT NULL DEFAULT 1,
    FechaCreacion DATETIME      NOT NULL DEFAULT GETDATE()
);

-- Tipos de documento: DNI, CE (Carnet Extranjería), RUC, PASAPORTE
CREATE TABLE TipoDocumento (
    IdTipoDocumento  INT         IDENTITY(1,1) PRIMARY KEY,
    Codigo           VARCHAR(10) NOT NULL UNIQUE,
    Nombre           VARCHAR(50) NOT NULL,
    Longitud         INT         NULL,   -- longitud fija si aplica (DNI=8, RUC=11)
    Activo           BIT         NOT NULL DEFAULT 1
);

CREATE TABLE Especialidad (
    IdEspecialidad  INT           IDENTITY(1,1) PRIMARY KEY,
    Nombre          VARCHAR(100)  NOT NULL UNIQUE,
    Descripcion     VARCHAR(300)  NULL,
    Activo          BIT           NOT NULL DEFAULT 1,
    FechaCreacion   DATETIME      NOT NULL DEFAULT GETDATE()
);

CREATE TABLE TipoAsegurado (
    IdTipoAsegurado  INT         IDENTITY(1,1) PRIMARY KEY,
    Nombre           VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Empresa (
    IdEmpresa             INT           IDENTITY(1,1) PRIMARY KEY,
    RazonSocial           VARCHAR(200)  NOT NULL,
    RUC                   VARCHAR(11)   NOT NULL UNIQUE,
    Direccion             VARCHAR(200)  NULL,
    Telefono              VARCHAR(20)   NULL,
    Email                 VARCHAR(150)  NULL,
    Activo                BIT           NOT NULL DEFAULT 1,
    FechaCreacion         DATETIME      NOT NULL DEFAULT GETDATE(),
    FechaModificacion     DATETIME      NULL,
    IdUsuarioCreacion     INT           NULL,
    IdUsuarioModificacion INT           NULL
);

CREATE TABLE EstadoCita (
    IdEstadoCita  INT         IDENTITY(1,1) PRIMARY KEY,
    Nombre        VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE MetodoPago (
    IdMetodoPago  INT         IDENTITY(1,1) PRIMARY KEY,
    Nombre        VARCHAR(50) NOT NULL UNIQUE,
    Activo        BIT         NOT NULL DEFAULT 1
);

CREATE TABLE TipoConsulta (
    IdTipoConsulta  INT            IDENTITY(1,1) PRIMARY KEY,
    Nombre          VARCHAR(50)    NOT NULL UNIQUE,
    Descripcion     VARCHAR(200)   NULL,
    TarifaExtra     DECIMAL(10,2)  NULL DEFAULT 0
);

CREATE TABLE Consultorio (
    IdConsultorio         INT           IDENTITY(1,1) PRIMARY KEY,
    Nombre                VARCHAR(100)  NOT NULL,
    Numero                VARCHAR(10)   NOT NULL,
    Piso                  VARCHAR(10)   NULL,
    Descripcion           VARCHAR(200)  NULL,
    Capacidad             INT           NOT NULL DEFAULT 1,
    Telefono              VARCHAR(20)   NULL,
    Activo                BIT           NOT NULL DEFAULT 1,
    FechaCreacion         DATETIME      NOT NULL DEFAULT GETDATE(),
    FechaModificacion     DATETIME      NULL,
    IdUsuarioCreacion     INT           NULL,
    IdUsuarioModificacion INT           NULL
);

-- ================================================================
-- IDENTIDAD
-- ================================================================

CREATE TABLE Usuario (
    IdUsuario             INT           IDENTITY(1,1) PRIMARY KEY,
    IdRol                 INT           NOT NULL,
    Nombres               VARCHAR(100)  NOT NULL,
    Apellidos             VARCHAR(100)  NOT NULL,
    TipoDocumento         VARCHAR(10)   NOT NULL DEFAULT 'DNI',   -- DNI / CE / RUC / PASAPORTE
    NumeroDocumento       VARCHAR(20)   NOT NULL UNIQUE,
    FechaNacimiento       DATE          NULL,
    Genero                CHAR(1)       NULL,
    Direccion             VARCHAR(200)  NULL,
    Username              VARCHAR(50)   NOT NULL UNIQUE,
    PasswordHash          VARCHAR(256)  NOT NULL,
    Activo                BIT           NOT NULL DEFAULT 1,
    FechaCreacion         DATETIME      NOT NULL DEFAULT GETDATE(),
    FechaModificacion     DATETIME      NULL,
    IdUsuarioCreacion     INT           NULL,
    IdUsuarioModificacion INT           NULL,
    CONSTRAINT FK_Usuario_Rol FOREIGN KEY (IdRol) REFERENCES Rol(IdRol)
);

CREATE TABLE Contacto (
    IdContacto    INT           IDENTITY(1,1) PRIMARY KEY,
    IdUsuario     INT           NOT NULL,
    TipoContacto  VARCHAR(20)   NOT NULL,   -- Email, Celular, Fijo
    Valor         VARCHAR(150)  NOT NULL,
    EsPrincipal   BIT           NOT NULL DEFAULT 0,
    FechaCreacion DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Contacto_Usuario FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario)
);

-- ================================================================
-- MÉDICOS
-- ================================================================

CREATE TABLE Medico (
    IdMedico              INT           IDENTITY(1,1) PRIMARY KEY,
    IdUsuario             INT           NOT NULL UNIQUE,
    ColegioMedico         VARCHAR(20)   NOT NULL UNIQUE,
    Activo                BIT           NOT NULL DEFAULT 1,
    FechaCreacion         DATETIME      NOT NULL DEFAULT GETDATE(),
    FechaModificacion     DATETIME      NULL,
    IdUsuarioCreacion     INT           NULL,
    IdUsuarioModificacion INT           NULL,
    CONSTRAINT FK_Medico_Usuario FOREIGN KEY (IdUsuario) REFERENCES Usuario(IdUsuario)
);

-- Un médico puede tener UNA O MÁS especialidades con tarifas distintas
CREATE TABLE Tarifa (
    IdTarifa              INT            IDENTITY(1,1) PRIMARY KEY,
    IdMedico              INT            NOT NULL,
    IdEspecialidad        INT            NOT NULL,
    Monto                 DECIMAL(10,2)  NOT NULL,
    Descripcion           VARCHAR(200)   NULL,
    Activo                BIT            NOT NULL DEFAULT 1,
    FechaCreacion         DATETIME       NOT NULL DEFAULT GETDATE(),
    FechaModificacion     DATETIME       NULL,
    IdUsuarioCreacion     INT            NULL,
    IdUsuarioModificacion INT            NULL,
    CONSTRAINT FK_Tarifa_Medico        FOREIGN KEY (IdMedico)       REFERENCES Medico(IdMedico),
    CONSTRAINT FK_Tarifa_Especialidad  FOREIGN KEY (IdEspecialidad) REFERENCES Especialidad(IdEspecialidad),
    CONSTRAINT UQ_Tarifa_Medico_Esp    UNIQUE (IdMedico, IdEspecialidad)
);

CREATE TABLE HorarioMedico (
    IdHorario             INT      IDENTITY(1,1) PRIMARY KEY,
    IdMedico              INT      NOT NULL,
    IdConsultorio         INT      NULL,
    DiaSemana             INT      NOT NULL CHECK (DiaSemana BETWEEN 1 AND 7),  -- 1=Lun..7=Dom
    HoraInicio            TIME     NOT NULL,
    HoraFin               TIME     NOT NULL,
    Activo                BIT      NOT NULL DEFAULT 1,
    FechaCreacion         DATETIME NOT NULL DEFAULT GETDATE(),
    FechaModificacion     DATETIME NULL,
    IdUsuarioCreacion     INT      NULL,
    IdUsuarioModificacion INT      NULL,
    CONSTRAINT FK_HorarioMedico_Medico      FOREIGN KEY (IdMedico)      REFERENCES Medico(IdMedico),
    CONSTRAINT FK_HorarioMedico_Consultorio FOREIGN KEY (IdConsultorio) REFERENCES Consultorio(IdConsultorio)
);

-- ================================================================
-- PACIENTES
-- ================================================================

CREATE TABLE Paciente (
    IdPaciente            INT           IDENTITY(1,1) PRIMARY KEY,
    IdUsuario             INT           NOT NULL UNIQUE,
    IdTipoAsegurado       INT           NOT NULL,
    IdEmpresa             INT           NULL,
    NumeroSeguro          VARCHAR(50)   NULL,
    GrupoSanguineo        VARCHAR(5)    NULL,
    Alergias              VARCHAR(500)  NULL,
    Activo                BIT           NOT NULL DEFAULT 1,
    FechaCreacion         DATETIME      NOT NULL DEFAULT GETDATE(),
    FechaModificacion     DATETIME      NULL,
    IdUsuarioCreacion     INT           NULL,
    IdUsuarioModificacion INT           NULL,
    CONSTRAINT FK_Paciente_Usuario       FOREIGN KEY (IdUsuario)       REFERENCES Usuario(IdUsuario),
    CONSTRAINT FK_Paciente_TipoAsegurado FOREIGN KEY (IdTipoAsegurado) REFERENCES TipoAsegurado(IdTipoAsegurado),
    CONSTRAINT FK_Paciente_Empresa       FOREIGN KEY (IdEmpresa)       REFERENCES Empresa(IdEmpresa)
);

CREATE TABLE Seguro (
    IdSeguro              INT            IDENTITY(1,1) PRIMARY KEY,
    IdPaciente            INT            NOT NULL,
    NombreSeguro          VARCHAR(100)   NOT NULL,
    TipoCobertura         VARCHAR(50)    NULL,   -- Particular, SIS, ESSALUD, Privado
    NumeroPoliza          VARCHAR(50)    NULL,
    FechaVigencia         DATE           NULL,
    FechaVencimiento      DATE           NULL,
    CoberturaMax          DECIMAL(10,2)  NULL,
    Activo                BIT            NOT NULL DEFAULT 1,
    FechaCreacion         DATETIME       NOT NULL DEFAULT GETDATE(),
    FechaModificacion     DATETIME       NULL,
    IdUsuarioCreacion     INT            NULL,
    IdUsuarioModificacion INT            NULL,
    CONSTRAINT FK_Seguro_Paciente FOREIGN KEY (IdPaciente) REFERENCES Paciente(IdPaciente)
);

-- ================================================================
-- CITAS
-- ================================================================

CREATE TABLE Cita (
    IdCita                INT           IDENTITY(1,1) PRIMARY KEY,
    IdPaciente            INT           NOT NULL,
    IdMedico              INT           NOT NULL,
    IdEspecialidad        INT           NOT NULL,   -- especialidad de la cita
    IdTarifa              INT           NULL,        -- tarifa aplicada
    IdEstadoCita          INT           NOT NULL DEFAULT 1,
    IdConsultorio         INT           NULL,
    IdTipoConsulta        INT           NULL,
    FechaHora             DATETIME      NOT NULL,
    Motivo                VARCHAR(300)  NOT NULL,
    Observaciones         VARCHAR(500)  NULL,
    FechaCreacion         DATETIME      NOT NULL DEFAULT GETDATE(),
    FechaModificacion     DATETIME      NULL,
    IdUsuarioCreacion     INT           NULL,
    IdUsuarioModificacion INT           NULL,
    CONSTRAINT FK_Cita_Paciente     FOREIGN KEY (IdPaciente)     REFERENCES Paciente(IdPaciente),
    CONSTRAINT FK_Cita_Medico       FOREIGN KEY (IdMedico)       REFERENCES Medico(IdMedico),
    CONSTRAINT FK_Cita_Especialidad FOREIGN KEY (IdEspecialidad) REFERENCES Especialidad(IdEspecialidad),
    CONSTRAINT FK_Cita_Tarifa       FOREIGN KEY (IdTarifa)       REFERENCES Tarifa(IdTarifa),
    CONSTRAINT FK_Cita_EstadoCita   FOREIGN KEY (IdEstadoCita)   REFERENCES EstadoCita(IdEstadoCita),
    CONSTRAINT FK_Cita_Consultorio  FOREIGN KEY (IdConsultorio)  REFERENCES Consultorio(IdConsultorio),
    CONSTRAINT FK_Cita_TipoConsulta FOREIGN KEY (IdTipoConsulta) REFERENCES TipoConsulta(IdTipoConsulta)
);

CREATE TABLE CancelacionCita (
    IdCancelacion    INT           IDENTITY(1,1) PRIMARY KEY,
    IdCita           INT           NOT NULL,
    Motivo           VARCHAR(300)  NULL,
    CanceladoPor     VARCHAR(50)   NULL,
    FechaCancelacion DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_CancelacionCita_Cita FOREIGN KEY (IdCita) REFERENCES Cita(IdCita)
);

-- ================================================================
-- CLÍNICO
-- ================================================================

CREATE TABLE Triaje (
    IdTriaje              INT            IDENTITY(1,1) PRIMARY KEY,
    IdCita                INT            NOT NULL UNIQUE,
    Peso                  DECIMAL(5,2)   NULL,
    Talla                 DECIMAL(5,2)   NULL,
    PresionSistolica      INT            NULL,
    PresionDiastolica     INT            NULL,
    FrecuenciaCardiaca    INT            NULL,
    Temperatura           DECIMAL(4,1)   NULL,
    Saturacion            DECIMAL(4,1)   NULL,
    FechaRegistro         DATETIME       NOT NULL DEFAULT GETDATE(),
    IdUsuarioCreacion     INT            NULL,
    CONSTRAINT FK_Triaje_Cita FOREIGN KEY (IdCita) REFERENCES Cita(IdCita)
);

CREATE TABLE Receta (
    IdReceta          INT           IDENTITY(1,1) PRIMARY KEY,
    IdCita            INT           NOT NULL UNIQUE,
    Diagnostico       VARCHAR(500)  NULL,
    Indicaciones      VARCHAR(500)  NULL,
    FechaEmision      DATETIME      NOT NULL DEFAULT GETDATE(),
    IdUsuarioCreacion INT           NULL,
    CONSTRAINT FK_Receta_Cita FOREIGN KEY (IdCita) REFERENCES Cita(IdCita)
);

CREATE TABLE Medicamento (
    IdMedicamento         INT            IDENTITY(1,1) PRIMARY KEY,
    Nombre                VARCHAR(200)   NOT NULL,
    Presentacion          VARCHAR(100)   NULL,
    Concentracion         VARCHAR(50)    NULL,
    Laboratorio           VARCHAR(100)   NULL,
    Precio                DECIMAL(10,2)  NOT NULL DEFAULT 0,
    Stock                 INT            NOT NULL DEFAULT 0,
    Activo                BIT            NOT NULL DEFAULT 1,
    FechaCreacion         DATETIME       NOT NULL DEFAULT GETDATE(),
    FechaModificacion     DATETIME       NULL,
    IdUsuarioCreacion     INT            NULL,
    IdUsuarioModificacion INT            NULL
);

-- Nombre cambiado a singular: ItemReceta (antes DetalleReceta)
CREATE TABLE ItemReceta (
    IdItem         INT           IDENTITY(1,1) PRIMARY KEY,
    IdReceta       INT           NOT NULL,
    IdMedicamento  INT           NOT NULL,
    Dosis          VARCHAR(100)  NULL,
    Frecuencia     VARCHAR(100)  NULL,
    Duracion       VARCHAR(50)   NULL,
    Cantidad       INT           NOT NULL DEFAULT 1,
    CONSTRAINT FK_ItemReceta_Receta      FOREIGN KEY (IdReceta)      REFERENCES Receta(IdReceta),
    CONSTRAINT FK_ItemReceta_Medicamento FOREIGN KEY (IdMedicamento) REFERENCES Medicamento(IdMedicamento)
);

CREATE TABLE HistorialClinico (
    IdHistorial       INT           IDENTITY(1,1) PRIMARY KEY,
    IdPaciente        INT           NOT NULL,
    IdCita            INT           NULL,
    Diagnostico       VARCHAR(500)  NULL,
    Tratamiento       VARCHAR(500)  NULL,
    Evolucion         VARCHAR(500)  NULL,
    FechaRegistro     DATETIME      NOT NULL DEFAULT GETDATE(),
    IdUsuarioCreacion INT           NULL,
    CONSTRAINT FK_HistorialClinico_Paciente FOREIGN KEY (IdPaciente) REFERENCES Paciente(IdPaciente),
    CONSTRAINT FK_HistorialClinico_Cita     FOREIGN KEY (IdCita)     REFERENCES Cita(IdCita)
);

-- ================================================================
-- FINANCIERO
-- ================================================================

-- Reemplaza a Facturas — soporta Boleta y Factura
CREATE TABLE Comprobante (
    IdComprobante         INT            IDENTITY(1,1) PRIMARY KEY,
    IdCita                INT            NOT NULL UNIQUE,
    TipoComprobante       VARCHAR(20)    NOT NULL DEFAULT 'Boleta',   -- Boleta / Factura
    Serie                 VARCHAR(5)     NOT NULL,
    Numero                VARCHAR(20)    NOT NULL UNIQUE,
    Subtotal              DECIMAL(10,2)  NOT NULL,
    IGV                   DECIMAL(10,2)  NOT NULL DEFAULT 0,
    Total                 DECIMAL(10,2)  NOT NULL,
    EstadoPago            VARCHAR(20)    NOT NULL DEFAULT 'Pendiente',
    FechaEmision          DATETIME       NOT NULL DEFAULT GETDATE(),
    IdUsuarioCreacion     INT            NULL,
    IdUsuarioModificacion INT            NULL,
    CONSTRAINT FK_Comprobante_Cita FOREIGN KEY (IdCita) REFERENCES Cita(IdCita)
);

CREATE TABLE Pago (
    IdPago            INT            IDENTITY(1,1) PRIMARY KEY,
    IdComprobante     INT            NOT NULL,
    IdMetodoPago      INT            NOT NULL,
    Monto             DECIMAL(10,2)  NOT NULL,
    NroOperacion      VARCHAR(50)    NULL,
    FechaPago         DATETIME       NOT NULL DEFAULT GETDATE(),
    IdUsuarioCreacion INT            NULL,
    CONSTRAINT FK_Pago_Comprobante FOREIGN KEY (IdComprobante) REFERENCES Comprobante(IdComprobante),
    CONSTRAINT FK_Pago_MetodoPago  FOREIGN KEY (IdMetodoPago)  REFERENCES MetodoPago(IdMetodoPago)
);

GO

-- ================================================================
-- ÍNDICES
-- ================================================================
CREATE INDEX IX_Usuario_NumeroDocumento ON Usuario(NumeroDocumento);
CREATE INDEX IX_Usuario_Username        ON Usuario(Username);
CREATE INDEX IX_Cita_FechaHora         ON Cita(FechaHora);
CREATE INDEX IX_Cita_Paciente          ON Cita(IdPaciente);
CREATE INDEX IX_Cita_Medico            ON Cita(IdMedico);
CREATE INDEX IX_Cita_Especialidad      ON Cita(IdEspecialidad);
CREATE INDEX IX_Tarifa_Medico          ON Tarifa(IdMedico);

GO
PRINT 'ClinicaDB v2 creada exitosamente — 26 tablas, sin AuditoriaLog.';
