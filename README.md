# ClinicaAPI - Sistema de Gestión de Citas Médicas

API RESTful desarrollada con .NET 8 para gestionar citas médicas de una clínica privada.

## Requisitos

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)

## Instalación y ejecución

```bash
# Clonar el repositorio
git clone <URL_DEL_REPOSITORIO>
cd ClinicaAPI

# Restaurar dependencias
dotnet restore

# Ejecutar la aplicación
dotnet run
```

La API estará disponible en:
- **Swagger UI**: `http://localhost:5024` (documentación interactiva)
- **API Base URL**: `http://localhost:5024/api`

## Estructura del proyecto

```
ClinicaAPI/
├── Controllers/          # Controladores REST (endpoints)
│   ├── CitasController.cs
│   ├── MedicosController.cs
│   └── PacientesController.cs
├── Services/             # Lógica de negocio
│   ├── Interfaces/       # Contratos de servicio
│   │   ├── ICitaService.cs
│   │   ├── IMedicoService.cs
│   │   └── IPacienteService.cs
│   ├── CitaService.cs
│   ├── MedicoService.cs
│   └── PacienteService.cs
├── Models/               # Entidades del dominio
│   ├── Cita.cs
│   ├── Medico.cs
│   └── Paciente.cs
├── DTOs/                 # Objetos de transferencia de datos
│   ├── CitaDto.cs
│   ├── MedicoDto.cs
│   └── PacienteDto.cs
├── Exceptions/           # Manejo centralizado de errores
│   ├── AppExceptions.cs
│   └── GlobalExceptionHandler.cs
└── Program.cs            # Configuración y arranque
```

## Endpoints disponibles

### Citas (`/api/citas`)

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

### Pacientes (`/api/pacientes`)

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/pacientes` | Listar todos los pacientes |
| GET | `/api/pacientes/{id}` | Obtener paciente por ID |
| POST | `/api/pacientes` | Registrar nuevo paciente |
| PUT | `/api/pacientes/{id}` | Actualizar paciente |
| DELETE | `/api/pacientes/{id}` | Eliminar paciente |

### Médicos (`/api/medicos`)

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/api/medicos` | Listar todos los médicos |
| GET | `/api/medicos/{id}` | Obtener médico por ID |
| GET | `/api/medicos/especialidad/{especialidad}` | Buscar por especialidad |
| POST | `/api/medicos` | Registrar nuevo médico |
| PUT | `/api/medicos/{id}` | Actualizar médico |
| DELETE | `/api/medicos/{id}` | Eliminar médico |

## Ejemplos de uso con Postman

### Crear un paciente
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

### Crear una cita
```json
POST /api/citas
{
  "pacienteId": 1,
  "medicoId": 1,
  "fechaHora": "2026-07-15T10:00:00",
  "motivo": "Control cardiológico anual",
  "observaciones": "Paciente con historial de hipertensión"
}
```

### Estados de cita válidos
- `Pendiente`
- `Confirmada`
- `Cancelada`
- `Completada`

## Integrantes del equipo

| Nombre | Rol |
|--------|-----|
| Integrante 1 | Backend - Módulo Citas |
| Integrante 2 | Backend - Módulo Pacientes |
| Integrante 3 | Backend - Módulo Médicos / Documentación |
