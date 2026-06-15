# ClinicaAPI — Sistema de Gestión de Citas Médicas

API RESTful desarrollada con **.NET 8 ASP.NET Core** + **React 18** para gestionar citas médicas de una clínica privada, con base de datos **SQL Server** (ClinicaDB).

---

## Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| Backend API | .NET 8 ASP.NET Core · Entity Framework Core |
| Base de datos | SQL Server (ClinicaDB) |
| Frontend | React 18 + Vite · react-router-dom |
| Documentación | Swagger UI (Swashbuckle) |
| Estilos | CSS puro (App.css) |

---

## Requisitos

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- SQL Server (2019 o superior) o SQL Server Express
- Node.js 18+ y npm (para el frontend)

---

## Instalación y ejecución

### 1. Base de datos

```sql
-- En SSMS, abrir y ejecutar en orden:
-- 1. ClinicaDB.sql        → Crea la BD, tablas principales y vistas
-- 2. ClinicaDB_Extra.sql  → Tablas adicionales (Triaje, Historial, Pagos, etc.)
-- 3. SeedData.sql         → Carga ~3,000+ registros de prueba
```

### 2. Backend API

```bash
# Clonar el repositorio
git clone https://github.com/JesusReymundo/ClinicaAPI.git
cd ClinicaAPI

# Restaurar dependencias
dotnet restore

# Ejecutar (puerto 5024)
dotnet run
```

La API estará disponible en:
- **Swagger UI**: `http://localhost:5024`
- **API Base URL**: `http://localhost:5024/api`

### 3. Frontend React

```bash
cd clinica-frontend
npm install
npm run dev
```

El frontend estará en `http://localhost:5173`

**Credenciales de prueba:**

| Usuario | Contraseña | Rol |
|---------|-----------|-----|
| `admin` | `admin123` | Administrador |
| `doctor` | `medico123` | Médico |
| `paciente` | `cita123` | Paciente |

---

## Estructura del proyecto

```
ClinicaAPI/
├── Controllers/              # Controladores REST
│   ├── CitasController.cs
│   ├── MedicosController.cs
│   └── PacientesController.cs
├── Services/                 # Lógica de negocio
│   ├── Interfaces/
│   │   ├── ICitaService.cs
│   │   ├── IMedicoService.cs
│   │   └── IPacienteService.cs
│   ├── CitaService.cs
│   ├── MedicoService.cs
│   └── PacienteService.cs
├── Models/                   # Entidades del dominio
│   ├── Cita.cs
│   ├── Medico.cs
│   └── Paciente.cs
├── DTOs/                     # Objetos de transferencia
│   ├── CitaDto.cs
│   ├── MedicoDto.cs
│   └── PacienteDto.cs
├── Exceptions/               # Manejo centralizado de errores
│   ├── AppExceptions.cs
│   └── GlobalExceptionHandler.cs
├── Data/                     # Contexto EF Core
├── Program.cs
├── ClinicaDB.sql             # Script principal de base de datos
├── ClinicaDB_Extra.sql       # Tablas adicionales
├── SeedData.sql              # Datos de prueba (~3,000+ registros)
├── DiagramaER.html           # Diagrama ER interactivo (abrir en navegador)
└── clinica-frontend/         # Aplicación React
    └── src/
        ├── pages/
        │   ├── Dashboard.jsx
        │   ├── Citas.jsx
        │   ├── Pacientes.jsx
        │   ├── Medicos.jsx
        │   ├── SolicitarCita.jsx
        │   ├── MisCitasPaciente.jsx
        │   ├── Boletas.jsx
        │   ├── Tickets.jsx
        │   └── GestionTickets.jsx
        ├── context/AuthContext.jsx
        ├── api/clinicaApi.js
        └── App.jsx / App.css
```

---

## Base de Datos — ClinicaDB

### Resumen: 24 tablas · 7 vistas

```
ClinicaDB.sql         → 14 tablas + 4 vistas
ClinicaDB_Extra.sql   → 10 tablas adicionales + 3 vistas
SeedData.sql          → carga de datos en 15 pasos (set-based, sin WHILE loops)
```

---

### Tablas Catálogo (valores fijos)

| Tabla | Descripción | Valores pre-cargados |
|-------|-------------|----------------------|
| **Roles** | Roles del sistema | 1=Administrador · 2=Medico · 3=Paciente · 4=Recepcionista |
| **EstadosCita** | Estados de una cita | 1=Pendiente · 2=Confirmada · 3=Cancelada · 4=Completada · 5=Anulada |
| **Especialidades** | Especialidades médicas | Cardiología · Med. General · Pediatría · Dermatología · Traumatología |
| **TipoAsegurado** | Tipo de cobertura | 1=Particular · 2=Corporativo · 3=EsSalud · 4=SIS |
| **TipoConsulta** | Tipo de consulta | Primera Vez · Seguimiento · Urgencia (+S/30) · Teleconsulta (−S/20) |
| **MetodosPago** | Métodos de pago | Efectivo · Tarjeta Crédito/Débito · Transferencia · Seguro · Yape/Plin |

---

### Tablas Principales

#### `Usuarios` — Tabla madre de todos los actores
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdUsuario | INT IDENTITY | PK |
| IdRol | INT | FK → Roles |
| Nombres | VARCHAR(100) | NOT NULL |
| Apellidos | VARCHAR(100) | NOT NULL |
| DNI | VARCHAR(8) | UNIQUE |
| FechaNacimiento | DATE | — |
| Genero | CHAR(1) | M / F |
| Direccion | VARCHAR(200) | — |
| Username | VARCHAR(50) | UNIQUE |
| PasswordHash | VARCHAR(256) | NOT NULL |
| Activo | BIT | DEFAULT 1 |
| FechaCreacion | DATETIME | DEFAULT GETDATE() |
| FechaModificacion | DATETIME | — |

#### `Contactos` — Teléfonos, emails, WhatsApp de cada usuario
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdContacto | INT IDENTITY | PK |
| IdUsuario | INT | FK → Usuarios |
| TipoContacto | VARCHAR(20) | Telefono / Email / WhatsApp |
| Valor | VARCHAR(150) | NOT NULL |
| EsPrincipal | BIT | DEFAULT 0 |

#### `Medicos` — Extiende Usuarios para médicos
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdMedico | INT IDENTITY | PK |
| IdUsuario | INT | FK UNIQUE → Usuarios |
| IdEspecialidad | INT | FK → Especialidades |
| ColegioMedico | VARCHAR(20) | UNIQUE |
| Consultorio | VARCHAR(50) | — |
| TarifaConsulta | DECIMAL(10,2) | S/80–S/120 según especialidad |

#### `Pacientes` — Extiende Usuarios para pacientes
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdPaciente | INT IDENTITY | PK |
| IdUsuario | INT | FK UNIQUE → Usuarios |
| IdTipoAsegurado | INT | FK → TipoAsegurado |
| IdEmpresa | INT | FK nullable → Empresas |
| NumeroSeguro | VARCHAR(50) | — |
| GrupoSanguineo | VARCHAR(5) | A+/A-/B+/B-/AB+/AB-/O+/O- |
| Alergias | VARCHAR(500) | — |

> Un mismo Usuario puede ser simultáneamente Médico y Paciente (IdUsuario aparece en ambas tablas).

#### `Empresas` — Empresas para pacientes corporativos
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdEmpresa | INT IDENTITY | PK |
| RazonSocial | VARCHAR(200) | NOT NULL |
| RUC | VARCHAR(11) | UNIQUE |
| Direccion | VARCHAR(200) | — |
| Telefono | VARCHAR(20) | — |
| Email | VARCHAR(150) | — |

#### `Citas` — Centro del sistema
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdCita | INT IDENTITY | PK |
| IdPaciente | INT | FK → Pacientes |
| IdMedico | INT | FK → Medicos |
| IdEstado | INT | FK → EstadosCita · DEFAULT 1 |
| FechaHora | DATETIME | NOT NULL |
| Motivo | VARCHAR(300) | NOT NULL |
| Observaciones | VARCHAR(500) | — |
| FechaCreacion | DATETIME | DEFAULT GETDATE() |
| FechaModificacion | DATETIME | — |

#### `HorariosMedico` — Disponibilidad semanal de cada médico
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdHorario | INT IDENTITY | PK |
| IdMedico | INT | FK → Medicos |
| DiaSemana | TINYINT | 1=Lunes … 7=Domingo |
| HoraInicio | TIME | NOT NULL |
| HoraFin | TIME | NOT NULL |
| IdConsultorio | INT | FK nullable → Consultorios |
| Activo | BIT | DEFAULT 1 |

#### `Consultorios` — Salas físicas de la clínica
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdConsultorio | INT IDENTITY | PK |
| Nombre | VARCHAR(50) | NOT NULL |
| Piso | VARCHAR(10) | — |
| Disponible | BIT | DEFAULT 1 |

---

### Tablas Clínicas

#### `Recetas` — Una por cita completada (1:0-1)
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdReceta | INT IDENTITY | PK |
| IdCita | INT | FK UNIQUE → Citas |
| Diagnostico | VARCHAR(500) | — |
| Indicaciones | VARCHAR(500) | — |
| FechaEmision | DATETIME | DEFAULT GETDATE() |

#### `Medicamentos` — Catálogo de medicamentos
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdMedicamento | INT IDENTITY | PK |
| Nombre | VARCHAR(200) | NOT NULL |
| Presentacion | VARCHAR(100) | Tabletas / Cápsulas / Jarabe / Inyectable |
| Concentracion | VARCHAR(50) | — |
| Laboratorio | VARCHAR(100) | — |
| Precio | DECIMAL(10,2) | DEFAULT 0 |
| Stock | INT | DEFAULT 0 |

#### `DetalleReceta` — Medicamentos de cada receta
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdDetalle | INT IDENTITY | PK |
| IdReceta | INT | FK → Recetas |
| IdMedicamento | INT | FK → Medicamentos |
| Dosis | VARCHAR(100) | — |
| Frecuencia | VARCHAR(100) | — |
| Duracion | VARCHAR(50) | — |
| Cantidad | INT | DEFAULT 1 |

#### `Triaje` — Signos vitales antes de la consulta (1:0-1)
| Columna | Tipo | Descripción |
|---------|------|-------------|
| IdTriaje | INT IDENTITY | PK |
| IdCita | INT | FK UNIQUE → Citas |
| Peso | DECIMAL(5,2) | kg |
| Talla | DECIMAL(5,2) | cm |
| PresionSistolica | INT | mmHg |
| PresionDiastolica | INT | mmHg |
| FrecuenciaCardiaca | INT | lat/min |
| Temperatura | DECIMAL(4,1) | °C |
| Saturacion | DECIMAL(4,1) | % O₂ |

#### `HistorialClinico` — Historial médico acumulado del paciente
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdHistorial | INT IDENTITY | PK |
| IdPaciente | INT | FK → Pacientes |
| IdCita | INT | FK → Citas |
| Diagnostico | VARCHAR(500) | NOT NULL |
| Tratamiento | VARCHAR(500) | — |
| Evolucion | VARCHAR(500) | — |

#### `Seguros` — Pólizas de seguro del paciente
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdSeguro | INT IDENTITY | PK |
| IdPaciente | INT | FK → Pacientes |
| NombreSeguro | VARCHAR(100) | NOT NULL (Rimac / Pacífico / La Positiva / Mapfre) |
| NumeroPoliza | VARCHAR(50) | NOT NULL |
| FechaVigencia | DATE | NOT NULL |
| CoberturaMax | DECIMAL(10,2) | S/5,000 – S/15,000 |

---

### Tablas Financieras

#### `Facturas` — Una por cita completada (1:0-1)
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdFactura | INT IDENTITY | PK |
| IdCita | INT | FK UNIQUE → Citas |
| NumeroFactura | VARCHAR(20) | UNIQUE (formato F001-XXXXXX) |
| Serie | VARCHAR(5) | DEFAULT 'F001' |
| Subtotal | DECIMAL(10,2) | NOT NULL (tarifa del médico) |
| IGV | DECIMAL(10,2) | 18% del subtotal |
| Total | DECIMAL(10,2) | Subtotal + IGV |
| EstadoPago | VARCHAR(20) | Pendiente / Pagado / Anulado |

#### `Pagos` — Pagos realizados contra una factura
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdPago | INT IDENTITY | PK |
| IdFactura | INT | FK → Facturas |
| IdMetodo | INT | FK → MetodosPago |
| Monto | DECIMAL(10,2) | NOT NULL |
| NroOperacion | VARCHAR(50) | Para transferencias/POS |
| FechaPago | DATETIME | DEFAULT GETDATE() |

---

### Tablas de Soporte

#### `CancelacionesCita` — Motivo de cancelación o anulación
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdCancelacion | INT IDENTITY | PK |
| IdCita | INT | FK UNIQUE → Citas |
| Motivo | VARCHAR(300) | NOT NULL |
| CanceladoPor | VARCHAR(20) | Paciente / Medico / Sistema |
| FechaCancelacion | DATETIME | DEFAULT GETDATE() |

#### `AuditoriaLog` — Trazabilidad de cambios críticos
| Columna | Tipo | Restricción |
|---------|------|-------------|
| IdLog | INT IDENTITY | PK |
| IdUsuario | INT | FK → Usuarios |
| Tabla | VARCHAR(50) | NOT NULL |
| Accion | VARCHAR(20) | INSERT / UPDATE / DELETE |
| Descripcion | VARCHAR(500) | — |
| FechaAccion | DATETIME | DEFAULT GETDATE() |

---

## Relaciones del Modelo (24 Foreign Keys)

```
Roles            → Usuarios           (1:N)   FK_Usuarios_Roles
Usuarios         → Contactos          (1:N)   FK_Contactos_Usuarios
Usuarios         → Medicos            (1:0-1) FK_Medicos_Usuarios         [UNIQUE]
Usuarios         → Pacientes          (1:0-1) FK_Pacientes_Usuarios       [UNIQUE]
Usuarios         → AuditoriaLog       (1:N)   FK_Auditoria_Usuarios
Especialidades   → Medicos            (1:N)   FK_Medicos_Especialidades
TipoAsegurado    → Pacientes          (1:N)   FK_Pacientes_TipoAsegurado
Empresas         → Pacientes          (1:N)   FK_Pacientes_Empresas       [nullable]
Medicos          → Citas              (1:N)   FK_Citas_Medicos
Medicos          → HorariosMedico     (1:N)   FK_Horarios_Medicos
Consultorios     → HorariosMedico     (1:N)   FK_Horarios_Consultorios    [nullable]
Pacientes        → Citas              (1:N)   FK_Citas_Pacientes
Pacientes        → HistorialClinico   (1:N)   FK_Historial_Pacientes
Pacientes        → Seguros            (1:N)   FK_Seguros_Pacientes
EstadosCita      → Citas              (1:N)   FK_Citas_EstadosCita
Citas            → Recetas            (1:0-1) FK_Recetas_Citas            [UNIQUE]
Citas            → Triaje             (1:0-1) FK_Triaje_Citas             [UNIQUE]
Citas            → Facturas           (1:0-1) FK_Facturas_Citas           [UNIQUE]
Citas            → HistorialClinico   (1:N)   FK_Historial_Citas
Citas            → CancelacionesCita  (1:0-1) FK_Cancelaciones_Citas      [UNIQUE]
Recetas          → DetalleReceta      (1:N)   FK_DetalleReceta_Recetas
Medicamentos     → DetalleReceta      (1:N)   FK_DetalleReceta_Medicamentos
Facturas         → Pagos              (1:N)   FK_Pagos_Facturas
MetodosPago      → Pagos              (1:N)   FK_Pagos_MetodosPago
```

---

## Vistas SQL (7 vistas)

| Vista | Descripción |
|-------|-------------|
| `Vista_Factura` | Factura completa: paciente + empresa + médico + especialidad + totales |
| `Vista_Medicamentos_Receta` | Medicamentos por receta con subtotal por ítem |
| `Vista_Contactos` | Teléfonos y emails de todos los usuarios con su rol |
| `Vista_Citas` | Citas con nombre completo de paciente, médico, especialidad y estado |
| `Vista_HistorialPaciente` | Historial clínico completo con diagnóstico, tratamiento y evolución |
| `Vista_Pagos` | Pagos con detalle de factura, método y datos del paciente |
| `Vista_HorariosMedicos` | Horarios activos por médico con día en español y consultorio |

---

## Datos de Prueba — SeedData.sql

El script carga **~3,200+ registros** en 15 pasos ordenados respetando todas las FK.

| Tabla | Registros | Detalle |
|-------|-----------|---------|
| Empresas | 10 | Corporaciones peruanas con RUC único |
| Usuarios | 100 | 2 Admin + 28 Médicos + 70 Pacientes |
| Contactos | 200 | 1 teléfono + 1 email por usuario |
| Médicos | 28 | Usuarios 3–30 · 5 especialidades rotativas |
| HorariosMedico | 140 | 28 médicos × 5 días (Lunes–Viernes) |
| Pacientes | 100 | Todos los usuarios son también pacientes |
| Seguros | 30 | Pacientes Corporativo (51–65) + EsSalud (66–80) |
| Citas | ~952 | 70 pacientes × 12 fechas + 28 médicos × 4 fechas |
| HistorialClinico | ~485 | 1 por cada cita Completada |
| Recetas | ~388 | 80% de citas completadas |
| DetalleReceta | ~582 | 1–2 medicamentos por receta |
| Facturas | ~485 | 1 por cita completada · serie F001 |
| Pagos | ~404 | ~5/6 de facturas en estado Pagado |
| CancelacionesCita | ~90 | Citas con estado 3=Cancelada o 5=Anulada |

**Distribución de pacientes por tipo de seguro:**
- IDs 1–50 → Particular
- IDs 51–65 → Corporativo (vinculado a una de las 10 empresas)
- IDs 66–80 → EsSalud (NumeroSeguro: `ES-XXXXXX`)
- IDs 81–100 → SIS (NumeroSeguro: `SISXXXXXX`)

**Distribución de estados de citas:**
- Citas con fecha −180d a −30d: ~60% Completada · ~20% Cancelada · ~20% Anulada
- Citas con fecha −15d a −5d: ~67% Completada · ~33% Cancelada
- Citas con fecha +5d a +20d: Pendiente / Confirmada

---

## Endpoints API

### Citas — `/api/citas`

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/citas` | Listar todas las citas |
| GET | `/api/citas/{id}` | Obtener cita por ID |
| GET | `/api/citas/paciente/{pacienteId}` | Citas de un paciente |
| GET | `/api/citas/medico/{medicoId}` | Citas de un médico |
| GET | `/api/citas/estado/{estado}` | Filtrar por estado |
| POST | `/api/citas` | Crear nueva cita |
| PUT | `/api/citas/{id}` | Actualizar cita |
| PATCH | `/api/citas/{id}/cancelar` | Cancelar cita |
| DELETE | `/api/citas/{id}` | Eliminar cita |

### Pacientes — `/api/pacientes`

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/pacientes` | Listar todos los pacientes |
| GET | `/api/pacientes/{id}` | Obtener paciente por ID |
| POST | `/api/pacientes` | Registrar nuevo paciente |
| PUT | `/api/pacientes/{id}` | Actualizar paciente |
| DELETE | `/api/pacientes/{id}` | Eliminar paciente |

### Médicos — `/api/medicos`

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/medicos` | Listar todos los médicos |
| GET | `/api/medicos/{id}` | Obtener médico por ID |
| GET | `/api/medicos/especialidad/{especialidad}` | Buscar por especialidad |
| POST | `/api/medicos` | Registrar nuevo médico |
| PUT | `/api/medicos/{id}` | Actualizar médico |
| DELETE | `/api/medicos/{id}` | Eliminar médico |

---

## Formato de respuesta API

```json
{
  "success": true,
  "data": { ... }
}
```

### Ejemplo — Crear cita

```json
POST /api/citas
{
  "pacienteId": 31,
  "medicoId": 1,
  "fechaHora": "2026-07-15T10:00:00",
  "motivo": "Control cardiológico anual",
  "observaciones": "Paciente con historial de hipertensión"
}
```

### Ejemplo — Crear paciente

```json
POST /api/pacientes
{
  "nombre": "Luis",
  "apellido": "Ramirez",
  "dni": "45678901",
  "telefono": "956789012",
  "email": "luis@email.com",
  "fechaNacimiento": "1995-03-10T00:00:00"
}
```

### Estados de cita válidos

| Valor numérico | Texto | Descripción |
|----------------|-------|-------------|
| 1 | `Pendiente` | Cita agendada, sin confirmar |
| 2 | `Confirmada` | Confirmada por el médico |
| 3 | `Cancelada` | Cancelada por el paciente |
| 4 | `Completada` | Consulta realizada |
| 5 | `Anulada` | Anulada administrativamente |

---

## Frontend React

### Roles y permisos

| Módulo | Admin | Médico | Paciente |
|--------|-------|--------|----------|
| Dashboard | ✅ Panel admin | ✅ Panel médico | ✅ Panel paciente |
| Pacientes | ✅ CRUD completo | ✅ Solo lectura | ❌ No visible |
| Médicos | ✅ CRUD completo | ❌ | ❌ |
| Citas (admin) | ✅ Todas las citas | ✅ Sus citas como médico | ❌ |
| Mis Citas (paciente) | ✅ Sus citas como paciente | ✅ Sus citas como paciente | ✅ Sus citas |
| Solicitar Cita | ❌ | ❌ | ✅ Wizard 4 pasos |
| Mis Boletas | ✅ | ✅ | ✅ |
| Tickets | ✅ Gestión completa | ✅ Reportar problema | ✅ Reportar problema |

### Reglas de negocio (frontend)
- Un paciente puede tener **máximo 2 citas de la misma especialidad por mes**
- Un paciente puede tener **máximo 6 citas en total por mes**
- Solo el **Admin puede crear pacientes** desde el módulo Pacientes
- El **Paciente no puede ver la lista de médicos** directamente; los ve al solicitar una cita por especialidad
- Las **boletas** se generan automáticamente de citas en estado Completada
- Los **tickets** se guardan en `localStorage` con ciclo de vida: Abierto → En proceso → Resuelto → Cerrado
- Al cerrar un ticket se registra **quién lo atendió** (nombre del admin)

---

## Diagrama ER

Abrir `DiagramaER.html` en el navegador para ver el diagrama interactivo completo con todas las tablas, columnas, tipos y relaciones.

---

## Integrantes del equipo

| Nombre | Rol |
|--------|-----|
| Jesus Reymundo Román | Backend - Módulo Citas / Líder técnico |
| Aldair Santos Cahuana | Backend - Módulo Pacientes |
| Reyes Zarate Leomarc | Backend - Módulo Médicos |
| Ivan Zarate Soncco | Backend - Validaciones y DTOs |
| Crhistian Meza Cardenas | Backend - Manejo de excepciones |
| Alexandee Morillo Campos | Documentación y pruebas Postman |

---

*IDAT · 5to Ciclo · Desarrollo de Servicios Web · 2024*
