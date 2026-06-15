# Clínica IDAT — Frontend React

Portal web del sistema de gestión de citas médicas. Consume la API RESTful `ClinicaAPI` (.NET 8) y presenta una interfaz diferenciada por rol con control de acceso basado en roles (RBAC).

---

## Stack Tecnológico

| Tecnología | Versión | Uso |
|---|---|---|
| React | 18 | Librería de UI (SPA) |
| Vite | 6 | Bundler y servidor de desarrollo |
| React Router DOM | v7 | Enrutamiento protegido por rol |
| CSS personalizado | ~900 líneas | Diseño propio (sin frameworks de UI) |
| Fetch API | nativa | Comunicación con la API REST |
| localStorage | nativa | Persistencia de sesión y tickets |

---

## Requisitos previos

- Node.js 18+ instalado
- API backend corriendo en `http://localhost:5024`

## Instalación y ejecución

```bash
cd clinica-frontend
npm install
npm run dev
# → http://localhost:5173
```

---

## Credenciales de acceso

Las credenciales se leen directamente de la tabla `Usuarios` en la base de datos.

| Rol | Username | Contraseña | Nombre |
|---|---|---|---|
| Administrador | `jesus_admin` | `Admin@2024` | Jesus Reymundo Roman |
| Administrador | `leomarc_admin` | `Admin@2024` | Leomarc Reyes Zarate |
| Médico (equipo) | `aldair_santos` | `Doctor@2024` | Aldair Santos Cahuana |
| Médico (equipo) | `ivan_zarate` | `Doctor@2024` | Ivan Zarate Soncco |
| Médico (equipo) | `crhistian_meza` | `Doctor@2024` | Crhistian Meza Cardenas |
| Médico (equipo) | `alex_morillo` | `Doctor@2024` | Alexandee Morillo Campos |
| Médico adicional | `pedro_vega` … `dario_fuentes` | `Medico@2024` | (24 médicos ficticios) |
| Paciente | `paola_medina` | `Paciente123` | Paola Medina Espinoza |
| Paciente | `carlos_garcia` … `cynthia_lima` | `Paciente123` | (70 pacientes) |

> La autenticación llama a `POST http://localhost:5024/api/auth/login`. Si la API no está disponible, el sistema usa un fallback por patrón de contraseña.

---

## Estructura del proyecto

```
clinica-frontend/
├── src/
│   ├── context/
│   │   └── AuthContext.jsx       → Sesión, login/logout, rol activo
│   ├── pages/
│   │   ├── Login.jsx             → Pantalla de inicio de sesión
│   │   ├── Dashboard.jsx         → Panel principal (vista por rol)
│   │   ├── Pacientes.jsx         → Gestión de pacientes (Admin)
│   │   ├── Medicos.jsx           → Gestión de médicos (Admin/Doctor)
│   │   ├── Citas.jsx             → Gestión de citas (Admin/Doctor)
│   │   ├── SolicitarCita.jsx     → Solicitar nueva cita (Paciente)
│   │   ├── MisCitasPaciente.jsx  → Mis citas + historial (Paciente)
│   │   ├── Boletas.jsx           → Boletas y facturas (Paciente)
│   │   ├── Tickets.jsx           → Reportar problema (Paciente)
│   │   └── GestionTickets.jsx    → Gestionar tickets de soporte (Admin)
│   ├── App.jsx                   → Layout, sidebar, rutas protegidas
│   ├── App.css                   → Estilos globales (~900 líneas)
│   └── main.jsx                  → Entry point
├── public/
│   ├── favicon.svg
│   └── icons.svg
├── index.html
├── vite.config.js
└── package.json
```

---

## Páginas y funcionalidades

### Login.jsx
- Formulario de usuario y contraseña con validación
- Panel izquierdo con branding de la clínica
- Acordeón de accesos rápidos con credenciales demo por rol
- Llama a `POST /api/auth/login` → asigna rol desde la BD

### Dashboard.jsx
Vista adaptada al rol del usuario autenticado:

**Admin:** 4 tarjetas de estadísticas (total citas, pendientes, pacientes, médicos), tabla de citas recientes con estado badge, accesos rápidos a gestión.

**Médico:** Sus citas de hoy y próximas, información de su especialidad y consultorio.

**Paciente:** Próxima cita destacada, resumen de historial, accesos a Solicitar Cita y Mis Citas.

### Pacientes.jsx *(Admin)*
- Tabla con avatar de iniciales, edad calculada, badge de grupo sanguíneo
- Búsqueda por nombre, DNI o email
- Panel lateral deslizante con perfil completo + historial de citas del paciente
- CRUD completo: crear, editar, eliminar paciente
- Solo Admin puede crear y editar; Doctor y Paciente tienen vista de solo lectura

### Medicos.jsx *(Admin / Doctor)*
- Vista doble: tarjetas de especialidad con colores por área + tabla
- Filtro por especialidad
- Panel lateral con perfil médico y sus citas asignadas
- CRUD completo (solo Admin puede crear/editar/eliminar)

### Citas.jsx *(Admin / Doctor)*
- 5 tabs: Todas / Pendientes / Confirmadas / Canceladas / Anuladas (con contadores)
- Acciones inline según estado y rol:
  - **Admin/Doctor:** Confirmar, Completar, Cancelar
  - **Paciente:** solo Anular sus propias citas
- Filtro por médico y por fecha
- Panel lateral con detalle completo de la cita

### SolicitarCita.jsx *(Paciente)*
- Flujo paso a paso: seleccionar especialidad → seleccionar médico → elegir fecha/hora → confirmar
- Muestra disponibilidad del médico según sus horarios registrados
- Valida que la fecha sea futura
- Llama a `POST /api/citas`

### MisCitasPaciente.jsx *(Paciente)*
- Lista de todas las citas del paciente autenticado
- Tabs: Próximas / Completadas / Canceladas
- Detalle de cada cita con médico, especialidad, motivo y fecha
- Botón para Anular citas pendientes o confirmadas

### Boletas.jsx *(Paciente)*
- Lista de todas las facturas/boletas del paciente
- Muestra número de factura, fecha, médico, monto (subtotal + IGV + total)
- Estado de pago: Pagado / Pendiente con badges de color
- Modal de detalle con información completa de la consulta

### Tickets.jsx *(Paciente)*
- Formulario para reportar un problema o solicitud de soporte
- Campos: Asunto, Categoría, Descripción, Prioridad
- Lista de tickets propios con estado: Abierto / En proceso / Resuelto / Cerrado
- Estado guardado en `localStorage`

### GestionTickets.jsx *(Admin)*
- Vista completa de todos los tickets del sistema
- Ordenados por prioridad y estado: Abierto → En proceso → Resuelto → Cerrado
- Puede cambiar el estado y agregar respuesta
- Guarda quién resolvió el ticket (`resueltoPor`) y la fecha de respuesta
- Muestra "Cerrado por **nombre del admin**" en la lista

---

## Permisos por rol (RBAC)

| Acción | Admin | Médico | Paciente |
|---|:---:|:---:|:---:|
| Ver todos los pacientes | ✅ | ✅ | ❌ |
| Crear / Editar paciente | ✅ | ❌ | ❌ |
| Ver todos los médicos | ✅ | ✅ | ✅ |
| Crear / Editar médico | ✅ | ❌ | ❌ |
| Ver todas las citas | ✅ | ✅ (solo las suyas) | ❌ |
| Confirmar / Completar cita | ✅ | ✅ | ❌ |
| Cancelar cita (clínica) | ✅ | ✅ | ❌ |
| Anular cita (paciente) | ❌ | ❌ | ✅ |
| Solicitar nueva cita | ❌ | ❌ | ✅ |
| Ver mis citas | ❌ | ❌ | ✅ |
| Ver boletas / facturas | ❌ | ❌ | ✅ |
| Reportar ticket de soporte | ❌ | ❌ | ✅ |
| Gestionar tickets (admin) | ✅ | ❌ | ❌ |
| Ver Dashboard completo | ✅ | ❌ | ❌ |

---

## Comunicación con la API

El frontend consume directamente la API REST en `http://localhost:5024/api` usando `fetch`.

```js
// Ejemplo de llamada autenticada
const res = await fetch('http://localhost:5024/api/citas', {
  headers: { 'Content-Type': 'application/json' }
});
const json = await res.json();
// json.data contiene el array de citas
```

Endpoints principales usados:

| Endpoint | Método | Página |
|---|---|---|
| `/api/auth/login` | POST | Login |
| `/api/pacientes` | GET / POST / PUT / DELETE | Pacientes |
| `/api/medicos` | GET / POST / PUT / DELETE | Medicos |
| `/api/citas` | GET / POST / PUT | Citas, SolicitarCita |
| `/api/citas/{id}/cancelar` | PATCH | Citas |
| `/api/citas/{id}/anular` | PATCH | Citas, MisCitasPaciente |
| `/api/citas/paciente/{id}` | GET | MisCitasPaciente |
| `/api/citas/medico/{id}` | GET | Citas (vista médico) |

> Tickets y Boletas usan `localStorage` (datos locales) hasta integración con BD.

---

## Notas de diseño

- **Sin frameworks de UI:** Todo el CSS es personalizado (~900 líneas en `App.css`)
- **Modales:** Clase `.modal-overlay` + `.modal-box` con animación `slideUp`
- **Sidebar dinámico:** Los ítems del menú cambian según el rol activo
- **Responsive básico:** Diseñado para desktop (1280px+)
- **Persistencia de sesión:** Usuario guardado en `localStorage` clave `clinica_user`

---

*IDAT — 5to Ciclo — Desarrollo de Servicios Web — 2024*
