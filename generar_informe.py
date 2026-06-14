from docx import Document
from docx.shared import Pt, RGBColor, Inches, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

doc = Document()

# Margenes
for section in doc.sections:
    section.top_margin = Cm(2.5)
    section.bottom_margin = Cm(2.5)
    section.left_margin = Cm(3)
    section.right_margin = Cm(2.5)

PURPLE = RGBColor(0x6B, 0x21, 0xA8)
BLACK = RGBColor(0, 0, 0)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)

def set_cell_bg(cell, color_hex):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), color_hex)
    tcPr.append(shd)

def heading1(text):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    run = p.add_run(text)
    run.bold = True
    run.font.size = Pt(16)
    run.font.color.rgb = PURPLE
    p.paragraph_format.space_before = Pt(14)
    p.paragraph_format.space_after = Pt(6)
    return p

def heading2(text):
    p = doc.add_paragraph()
    run = p.add_run(text)
    run.bold = True
    run.font.size = Pt(12)
    run.font.color.rgb = PURPLE
    p.paragraph_format.space_before = Pt(10)
    p.paragraph_format.space_after = Pt(4)
    return p

def body(text):
    p = doc.add_paragraph(text)
    p.runs[0].font.size = Pt(11)
    p.paragraph_format.space_after = Pt(4)
    return p

def bullet(text):
    p = doc.add_paragraph(style='List Bullet')
    run = p.add_run(text)
    run.font.size = Pt(11)
    return p

def code_block(text):
    p = doc.add_paragraph()
    run = p.add_run(text)
    run.font.name = 'Courier New'
    run.font.size = Pt(9)
    run.font.color.rgb = RGBColor(0x1F, 0x2D, 0x3D)
    p.paragraph_format.left_indent = Cm(1)
    p.paragraph_format.space_after = Pt(2)
    return p

# ─── PORTADA ───────────────────────────────────────────────
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run("INFORME TÉCNICO")
run.bold = True
run.font.size = Pt(26)
run.font.color.rgb = PURPLE

p2 = doc.add_paragraph()
p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
r2 = p2.add_run("Sistema de Gestión de Citas Médicas")
r2.bold = True
r2.font.size = Pt(18)
r2.font.color.rgb = BLACK

doc.add_paragraph()

info = [
    ("Institución", "IDAT — Escuela de Tecnología"),
    ("Unidad didáctica", "Desarrollo de Servicios Web"),
    ("Ciclo", "5to Ciclo"),
    ("Proyecto", "ClinicaAPI — Evaluación Parcial"),
]
for label, value in info:
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(f"{label}: ")
    r.bold = True
    r.font.size = Pt(12)
    p.add_run(value).font.size = Pt(12)

doc.add_page_break()

# ─── 1. DESCRIPCIÓN ────────────────────────────────────────
heading1("1. DESCRIPCIÓN DEL PROYECTO")

heading2("1.1 Contexto")
body("Una clínica privada necesita gestionar las citas médicas que los pacientes solicitan a diario. "
     "Actualmente, las citas se anotan manualmente en agendas físicas o se confirman por llamadas "
     "telefónicas sin un control unificado, generando confusión, pérdida de información y sobrecarga "
     "para el personal administrativo.")

heading2("1.2 Solución")
body("Se desarrolló una API RESTful con C# y .NET 8 que permite registrar, consultar, actualizar y "
     "cancelar citas médicas de manera eficiente y ordenada. La aplicación simula el almacenamiento "
     "de datos en memoria usando colecciones List<T>, sin requerir conexión a base de datos.")

heading2("1.3 Tecnologías utilizadas")
bullet("Lenguaje: C# con .NET 8")
bullet("Framework: ASP.NET Core Web API")
bullet("Documentación: Swagger / OpenAPI")
bullet("Pruebas: Postman")
bullet("Repositorio: GitHub")

# ─── 2. ESTRUCTURA ─────────────────────────────────────────
heading1("2. ESTRUCTURA DEL PROYECTO")

body("El proyecto sigue una arquitectura de capas bien definida que separa responsabilidades:")

code_block("ClinicaAPI/")
code_block("├── Controllers/      → Exponen los endpoints REST")
code_block("│   ├── CitasController.cs")
code_block("│   ├── MedicosController.cs")
code_block("│   └── PacientesController.cs")
code_block("├── Services/         → Contienen la lógica de negocio")
code_block("│   ├── Interfaces/   → Contratos de servicio")
code_block("│   ├── CitaService.cs")
code_block("│   ├── MedicoService.cs")
code_block("│   └── PacienteService.cs")
code_block("├── Models/           → Entidades del dominio")
code_block("│   ├── Cita.cs  |  Medico.cs  |  Paciente.cs")
code_block("├── DTOs/             → Validaciones de entrada/salida")
code_block("│   ├── CitaDto.cs  |  MedicoDto.cs  |  PacienteDto.cs")
code_block("├── Exceptions/       → Manejo centralizado de errores")
code_block("│   ├── AppExceptions.cs  |  GlobalExceptionHandler.cs")
code_block("└── Program.cs        → Configuración e inyección de dependencias")

heading2("Descripción de cada capa")
layers = [
    ("Controllers:", "Reciben peticiones HTTP, validan el modelo y delegan al servicio. Devuelven respuestas con códigos HTTP correctos (200, 201, 400, 404)."),
    ("Services:", "Lógica de negocio completa. Implementan interfaces para inyección de dependencias. Gestionan datos en memoria con List<T>."),
    ("Models:", "Entidades: Paciente, Medico y Cita. Incluyen el enum EstadoCita (Pendiente, Confirmada, Cancelada, Completada)."),
    ("DTOs:", "Separan la representación interna de lo que se expone al cliente. Validaciones con [Required], [StringLength], [EmailAddress], [RegularExpression]."),
    ("Exceptions:", "GlobalExceptionHandler captura excepciones no controladas y devuelve respuestas estructuradas. Excepciones: NotFoundException (404) y BusinessException (400)."),
]
for title, desc in layers:
    p = doc.add_paragraph()
    r = p.add_run(title + " ")
    r.bold = True
    r.font.size = Pt(11)
    p.add_run(desc).font.size = Pt(11)
    p.paragraph_format.space_after = Pt(3)

# ─── 3. ENDPOINTS ──────────────────────────────────────────
heading1("3. ENDPOINTS DE LA API")

def add_endpoint_table(title, rows):
    heading2(title)
    headers = ["Método", "Ruta", "Descripción", "Código HTTP"]
    table = doc.add_table(rows=1 + len(rows), cols=4)
    table.style = 'Table Grid'
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    hdr = table.rows[0].cells
    for i, h in enumerate(headers):
        hdr[i].text = h
        hdr[i].paragraphs[0].runs[0].bold = True
        hdr[i].paragraphs[0].runs[0].font.color.rgb = WHITE
        hdr[i].paragraphs[0].runs[0].font.size = Pt(10)
        set_cell_bg(hdr[i], "6B21A8")
    for r_idx, row_data in enumerate(rows):
        row = table.rows[r_idx + 1].cells
        for c_idx, cell_text in enumerate(row_data):
            row[c_idx].text = cell_text
            row[c_idx].paragraphs[0].runs[0].font.size = Pt(10)
        if r_idx % 2 == 0:
            for c in row:
                set_cell_bg(c, "F3E8FF")
    doc.add_paragraph()

add_endpoint_table("3.1 Pacientes (/api/Pacientes)", [
    ["GET", "/api/Pacientes", "Listar todos los pacientes", "200 OK"],
    ["GET", "/api/Pacientes/{id}", "Buscar paciente por ID", "200 / 404"],
    ["POST", "/api/Pacientes", "Registrar nuevo paciente", "201 Created"],
    ["PUT", "/api/Pacientes/{id}", "Actualizar paciente", "200 / 404"],
    ["DELETE", "/api/Pacientes/{id}", "Eliminar paciente", "200 / 404"],
])

add_endpoint_table("3.2 Médicos (/api/Medicos)", [
    ["GET", "/api/Medicos", "Listar todos los médicos", "200 OK"],
    ["GET", "/api/Medicos/{id}", "Buscar médico por ID", "200 / 404"],
    ["POST", "/api/Medicos", "Registrar nuevo médico", "201 Created"],
    ["PUT", "/api/Medicos/{id}", "Actualizar médico", "200 / 404"],
    ["DELETE", "/api/Medicos/{id}", "Eliminar médico", "200 / 404"],
])

add_endpoint_table("3.3 Citas (/api/Citas)", [
    ["GET", "/api/Citas", "Listar todas las citas", "200 OK"],
    ["GET", "/api/Citas/{id}", "Buscar cita por ID", "200 / 404"],
    ["GET", "/api/Citas/paciente/{id}", "Citas de un paciente", "200 / 404"],
    ["GET", "/api/Citas/medico/{id}", "Citas de un médico", "200 / 404"],
    ["GET", "/api/Citas/estado/{estado}", "Filtrar por estado", "200 / 400"],
    ["POST", "/api/Citas", "Registrar nueva cita", "201 Created"],
    ["PUT", "/api/Citas/{id}", "Actualizar cita", "200 / 404"],
    ["PATCH", "/api/Citas/{id}/cancelar", "Cancelar cita", "200 / 400"],
    ["DELETE", "/api/Citas/{id}", "Eliminar cita", "200 / 404"],
])

# ─── 4. PRUEBAS POSTMAN ────────────────────────────────────
heading1("4. PRUEBAS FUNCIONALES CON POSTMAN")

body("A continuación se muestran las capturas de las pruebas realizadas con Postman, "
     "verificando el correcto funcionamiento de todos los endpoints CRUD de la API.")

p_note = doc.add_paragraph()
r_note = p_note.add_run("Insertar aquí las capturas de pantalla de cada prueba realizada en Postman.")
r_note.italic = True
r_note.font.color.rgb = RGBColor(0x6B, 0x7B, 0x8D)
r_note.font.size = Pt(11)

pruebas = [
    ("POST /api/Pacientes", "Crear Paciente", "201 Created"),
    ("GET /api/Pacientes", "Listar Pacientes", "200 OK"),
    ("GET /api/Pacientes/{id}", "Buscar Paciente por ID", "200 OK"),
    ("DELETE /api/Pacientes/{id}", "Eliminar Paciente", "200 OK"),
    ("POST /api/Medicos", "Crear Médico", "201 Created"),
    ("GET /api/Medicos", "Listar Médicos", "200 OK"),
    ("POST /api/Citas", "Crear Cita", "201 Created"),
    ("GET /api/Citas", "Listar Citas", "200 OK"),
    ("GET /api/Citas/{id}", "Buscar Cita por ID", "200 OK"),
    ("PUT /api/Citas/{id}", "Actualizar Cita", "200 OK"),
    ("PATCH /api/Citas/{id}/cancelar", "Cancelar Cita", "200 OK"),
]

table2 = doc.add_table(rows=1 + len(pruebas), cols=3)
table2.style = 'Table Grid'
h2 = table2.rows[0].cells
for i, txt in enumerate(["Endpoint", "Descripción", "Resultado"]):
    h2[i].text = txt
    h2[i].paragraphs[0].runs[0].bold = True
    h2[i].paragraphs[0].runs[0].font.color.rgb = WHITE
    h2[i].paragraphs[0].runs[0].font.size = Pt(10)
    set_cell_bg(h2[i], "6B21A8")
for i, (ep, desc, res) in enumerate(pruebas):
    row = table2.rows[i + 1].cells
    row[0].text = ep
    row[1].text = desc
    row[2].text = "✅ " + res
    for c in row:
        c.paragraphs[0].runs[0].font.size = Pt(10)
    if i % 2 == 0:
        for c in row:
            set_cell_bg(c, "F3E8FF")

doc.add_paragraph()

# ─── 5. REPOSITORIO ────────────────────────────────────────
heading1("5. REPOSITORIO EN GITHUB")
body("El código fuente del proyecto está disponible en el siguiente repositorio público:")

p_repo = doc.add_paragraph()
r_repo = p_repo.add_run("https://github.com/JesusReymundo/ClinicaAPI")
r_repo.bold = True
r_repo.font.size = Pt(12)
r_repo.font.color.rgb = PURPLE

heading2("Instrucciones de instalación y ejecución")
code_block("# 1. Clonar el repositorio")
code_block("git clone https://github.com/JesusReymundo/ClinicaAPI.git")
code_block("")
code_block("# 2. Ingresar a la carpeta")
code_block("cd ClinicaAPI")
code_block("")
code_block("# 3. Restaurar dependencias")
code_block("dotnet restore")
code_block("")
code_block("# 4. Ejecutar la aplicación")
code_block("dotnet run")
code_block("")
code_block("# 5. Abrir en el navegador")
code_block("http://localhost:5024   → Swagger UI (documentación interactiva)")

# ─── 6. ROLES DEL EQUIPO ───────────────────────────────────
heading1("6. ROLES DEL EQUIPO")

team = [
    ["Jesus Reymundo Román", "Líder técnico / Backend", "Arquitectura general, Módulo Citas, configuración del proyecto"],
    ["Aldair Santos Cahuana", "Backend", "Módulo Pacientes, validaciones en DTOs"],
    ["Reyes Zarate Leomarc", "Backend", "Módulo Médicos, modelos de dominio"],
    ["Ivan Zarate Soncco", "Backend", "Validaciones, DTOs de entrada y salida"],
    ["Crhistian Meza Cardenas", "Backend", "Manejo centralizado de excepciones"],
    ["Alexandee Morillo Campos", "Documentación", "Swagger, pruebas Postman, README"],
]

table3 = doc.add_table(rows=1 + len(team), cols=3)
table3.style = 'Table Grid'
h3 = table3.rows[0].cells
for i, txt in enumerate(["Integrante", "Rol", "Responsabilidad"]):
    h3[i].text = txt
    h3[i].paragraphs[0].runs[0].bold = True
    h3[i].paragraphs[0].runs[0].font.color.rgb = WHITE
    h3[i].paragraphs[0].runs[0].font.size = Pt(10)
    set_cell_bg(h3[i], "6B21A8")
for i, row_data in enumerate(team):
    row = table3.rows[i + 1].cells
    for j, val in enumerate(row_data):
        row[j].text = val
        row[j].paragraphs[0].runs[0].font.size = Pt(10)
    if i % 2 == 0:
        for c in row:
            set_cell_bg(c, "F3E8FF")

doc.add_paragraph()

out = r"d:\IDAT\5TO CICLO\Desarrollo de Servicios Web\ClinicaAPI\Informe_Tecnico_ClinicaAPI.docx"
doc.save(out)
print(f"Documento generado: {out}")
