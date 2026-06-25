USE ClinicaDB;
GO
SET NOCOUNT ON;
PRINT '=== CLINICA IDAT - CARGA DE DATOS DE PRUEBA v2 ===';
GO

-- ============================================================
-- LIMPIEZA — desactivar FK, vaciar tablas, resetear IDs
-- ============================================================
ALTER TABLE CancelacionCita  NOCHECK CONSTRAINT ALL;
ALTER TABLE Pago              NOCHECK CONSTRAINT ALL;
ALTER TABLE Comprobante       NOCHECK CONSTRAINT ALL;
ALTER TABLE ItemReceta        NOCHECK CONSTRAINT ALL;
ALTER TABLE Receta            NOCHECK CONSTRAINT ALL;
ALTER TABLE HistorialClinico  NOCHECK CONSTRAINT ALL;
ALTER TABLE Triaje            NOCHECK CONSTRAINT ALL;
ALTER TABLE Seguro            NOCHECK CONSTRAINT ALL;
ALTER TABLE Cita              NOCHECK CONSTRAINT ALL;
ALTER TABLE HorarioMedico     NOCHECK CONSTRAINT ALL;
ALTER TABLE Tarifa            NOCHECK CONSTRAINT ALL;
ALTER TABLE Paciente          NOCHECK CONSTRAINT ALL;
ALTER TABLE Medico            NOCHECK CONSTRAINT ALL;
ALTER TABLE Contacto          NOCHECK CONSTRAINT ALL;
ALTER TABLE Usuario           NOCHECK CONSTRAINT ALL;

DELETE FROM CancelacionCita;
DELETE FROM Pago;
DELETE FROM Comprobante;
DELETE FROM ItemReceta;
DELETE FROM Receta;
DELETE FROM HistorialClinico;
DELETE FROM Triaje;
DELETE FROM Seguro;
DELETE FROM Cita;
DELETE FROM HorarioMedico;
DELETE FROM Tarifa;
DELETE FROM Paciente;
DELETE FROM Medico;
DELETE FROM Contacto;
DELETE FROM Usuario;
DELETE FROM Consultorio;
DELETE FROM TipoConsulta;
DELETE FROM EstadoCita;
DELETE FROM MetodoPago;
DELETE FROM Medicamento;
DELETE FROM Especialidad;
DELETE FROM TipoAsegurado;
DELETE FROM Empresa;
DELETE FROM Rol;

DBCC CHECKIDENT ('Rol',              RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Usuario',          RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Contacto',         RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Empresa',          RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('TipoAsegurado',    RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Especialidad',     RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Medico',           RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Tarifa',           RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Paciente',         RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('EstadoCita',       RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Cita',             RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Medicamento',      RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Receta',           RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('ItemReceta',       RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Comprobante',      RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('MetodoPago',       RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Pago',             RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('HorarioMedico',    RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Triaje',           RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('HistorialClinico', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Seguro',           RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('CancelacionCita',  RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('Consultorio',      RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('TipoConsulta',     RESEED, 0) WITH NO_INFOMSGS;
PRINT '=== Limpieza completada ===';
GO

-- ============================================================
-- SECCIÓN 1: CATÁLOGOS
-- ============================================================
INSERT INTO Rol (NombreRol, Descripcion) VALUES
('Admin',    'Administrador con acceso total al sistema'),
('Medico',   'Medico registrado del sistema'),
('Paciente', 'Paciente registrado del sistema');

INSERT INTO TipoAsegurado (Nombre) VALUES
('Particular'),('Corporativo'),('EsSalud'),('SIS');

INSERT INTO Especialidad (Nombre, Descripcion) VALUES
('Medicina General',         'Atencion integral y preventiva'),
('Pediatria',                'Atencion de ninos y adolescentes'),
('Ginecologia y Obstetricia','Salud femenina y obstetricia'),
('Traumatologia',            'Lesiones musculo-esqueleticas'),
('Neurologia',               'Enfermedades del sistema nervioso'),
('Cardiologia',              'Enfermedades del corazon'),
('Dermatologia',             'Enfermedades de la piel'),
('Oftalmologia',             'Enfermedades y cirugia ocular'),
('Psiquiatria',              'Trastornos mentales'),
('Oncologia',                'Diagnostico y tratamiento del cancer'),
('Endocrinologia',           'Trastornos hormonales y metabolicos'),
('Gastroenterologia',        'Enfermedades del sistema digestivo'),
('Neumologia',               'Enfermedades del sistema respiratorio'),
('Urologia',                 'Enfermedades del sistema urinario'),
('Geriatria',                'Atencion integral del adulto mayor');

-- 1=Pendiente 2=Confirmada 3=Cancelada 4=Completada 5=Anulada
INSERT INTO EstadoCita (Nombre) VALUES
('Pendiente'),('Confirmada'),('Cancelada'),('Completada'),('Anulada');

INSERT INTO MetodoPago (Nombre) VALUES
('Efectivo'),('Tarjeta de Credito'),('Transferencia Bancaria'),('Seguro Medico'),('Yape/Plin');

INSERT INTO TipoConsulta (Nombre, Descripcion, TarifaExtra) VALUES
('Primera Vez', 'Consulta inicial',        0.00),
('Seguimiento', 'Control de tratamiento',  0.00),
('Urgencia',    'Atencion de emergencia', 50.00);

INSERT INTO Consultorio (Nombre, Numero, Piso, Capacidad, Activo) VALUES
('Consultorio 101','101','1',1,1),('Consultorio 102','102','1',1,1),
('Consultorio 201','201','2',1,1),('Consultorio 202','202','2',1,1),('Consultorio 203','203','2',1,1),
('Consultorio 301','301','3',1,1),('Consultorio 302','302','3',1,1),
('Sala de Urgencias','URG','1',4,1),('Sala de Procedimientos','PROC','2',2,1),
('Consultorio VIP','VIP','3',1,1);

INSERT INTO Empresa (RazonSocial, RUC, Direccion, Telefono, Email) VALUES
('Corporacion IDAT S.A.C.',        '20100001001','Av. Petit Thouars 2120, Lince',         '014221000','convenios@idat.edu.pe'),
('TechCorp Peru S.A.',             '20100002002','Av. El Derby 254, Santiago de Surco',    '012718000','salud@techcorp.pe'),
('Minera Los Andes S.A.A.',        '20100003003','Av. Javier Prado Este 4200, La Molina', '016002000','salud@losandes.com.pe'),
('Industrias Pacific S.A.C.',      '20100004004','Av. Argentina 2750, Carmen de la Legua','015373000','rrhh@pacific.pe'),
('Constructora Lima Norte S.R.L.', '20100005005','Av. Tupac Amaru 1815, Independencia',   '015318000','bienestar@limanorte.pe'),
('BancoPrima S.A.',                '20100006006','Jr. de la Union 645, Lima Centro',       '013111000','empleados@bancoprima.pe'),
('Aerolineas del Peru S.A.',       '20100007007','Av. Elmer Faucett s/n, Callao',          '015173000','salud@aerolineas.pe'),
('Supermercados del Norte S.A.C.', '20100008008','Av. Universitaria 8001, Los Olivos',     '015353000','convenio@supernorte.pe'),
('Farmaceutica Andina S.A.',       '20100009009','Av. La Marina 2000, San Miguel',         '015786000','salud@farmandina.pe'),
('Telecomunicaciones Sur S.A.C.',  '20100010010','Av. Paseo de la Republica 3505, SJM',   '017082000','salud@telecom-sur.pe');

INSERT INTO Medicamento (Nombre, Presentacion, Concentracion, Laboratorio, Precio, Stock) VALUES
('Paracetamol',      'Tabletas',  '500 mg',   'Laboratorio Chile',  5.00, 500),
('Ibuprofeno',       'Tabletas',  '400 mg',   'Pharma Plus',        8.50, 300),
('Amoxicilina',      'Capsulas',  '500 mg',   'MedPharma',         12.00, 200),
('Omeprazol',        'Capsulas',  '20 mg',    'GastroLab',         15.00, 250),
('Metformina',       'Tabletas',  '850 mg',   'DiabetPharm',       18.00, 150),
('Losartan',         'Tabletas',  '50 mg',    'CardioMed',         22.00, 180),
('Atorvastatina',    'Tabletas',  '20 mg',    'LipoControl',       35.00, 120),
('Levotiroxina',     'Tabletas',  '50 mcg',   'ThyroLab',          28.00, 100),
('Salbutamol',       'Inhalador', '100 mcg',  'RespiraMed',        45.00,  80),
('Ciprofloxacino',   'Tabletas',  '500 mg',   'AntibioLab',        20.00, 200),
('Diclofenaco',      'Gel',       '1%',       'PharmaTop',         18.00, 150),
('Loratadina',       'Tabletas',  '10 mg',    'AllerFree',         10.00, 300),
('Metoclopramida',   'Tabletas',  '10 mg',    'GastroLab',          8.00, 200),
('Budesonida',       'Inhalador', '200 mcg',  'RespiraMed',        65.00,  60),
('Sulfato Ferroso',  'Tabletas',  '300 mg',   'HematoLab',         12.00, 250),
('Azitromicina',     'Capsulas',  '500 mg',   'MedPharma',         35.00, 120),
('Clonazepam',       'Tabletas',  '0.5 mg',   'NeuroPharm',        25.00,  80),
('Ranitidina',       'Tabletas',  '150 mg',   'GastroLab',         10.00, 180),
('Insulina Glargina','Inyectable','100 UI/ml', 'DiabetPharm',      120.00,  50),
('Prednisona',       'Tabletas',  '20 mg',    'ImmunoLab',         30.00, 100);

PRINT '=== Catalogos insertados ===';
GO

-- ============================================================
-- SECCIÓN 2: USUARIOS (100)
-- ============================================================
INSERT INTO Usuario (IdRol, Nombres, Apellidos, TipoDocumento, NumeroDocumento,
                     FechaNacimiento, Genero, Direccion, Username, PasswordHash)
VALUES
(1,'Jesus',          'Reymundo Roman',    'DNI','74521836','1998-03-15','M','Av. Universitaria 1801, Los Olivos',      'jesus_admin',      'Admin@2024'),
(1,'Leomarc',        'Reyes Zarate',      'DNI','73845219','1997-07-22','M','Jr. Carabaya 450, Lima Centro',           'leomarc_admin',    'Admin@2024');
GO
INSERT INTO Usuario (IdRol, Nombres, Apellidos, TipoDocumento, NumeroDocumento,
                     FechaNacimiento, Genero, Direccion, Username, PasswordHash)
VALUES
(2,'Aldair',         'Santos Cahuana',    'DNI','72963145','1995-11-08','M','Av. Brasil 2455, Pueblo Libre',           'aldair_santos',    'Doctor@2024'),
(2,'Ivan',           'Zarate Soncco',     'DNI','76541823','1994-05-19','M','Av. San Martin 321, Barranco',            'ivan_zarate',      'Doctor@2024'),
(2,'Crhistian',      'Meza Cardenas',     'DNI','71852963','1996-09-03','M','Jr. Moquegua 175, Jesus Maria',           'crhistian_meza',   'Doctor@2024'),
(2,'Alexandee',      'Morillo Campos',    'DNI','73692148','1995-02-14','M','Av. La Marina 3200, San Miguel',          'alex_morillo',     'Doctor@2024'),
(2,'Pedro Augusto',  'Vega Castillo',     'DNI','43000001','1972-06-10','M','Av. Arequipa 2456, Miraflores',          'pedro_vega',       'Medico@2024'),
(2,'Ramon Luis',     'Huanca Quispe',     'DNI','43000002','1968-03-25','M','Jr. Huallaga 320, Lima Centro',           'ramon_huanca',     'Medico@2024'),
(2,'Rosa Elena',     'Mamani Condori',    'DNI','43000003','1975-08-17','F','Av. Aviacion 3420, San Borja',            'rosa_mamani',      'Medico@2024'),
(2,'Jorge Antonio',  'Pizarro Navarro',   'DNI','43000004','1970-11-30','M','Calle Las Begonias 450, San Isidro',     'jorge_pizarro',    'Medico@2024'),
(2,'Cecilia Belen',  'Fuentes Alarcon',   'DNI','43000005','1978-04-22','F','Av. Salaverry 2135, Jesus Maria',        'cecilia_fuentes',  'Medico@2024'),
(2,'Arturo Miguel',  'Navarro Pena',      'DNI','43000006','1965-09-07','M','Av. La Paz 1245, Miraflores',            'arturo_navarro',   'Medico@2024'),
(2,'Liliana Isabel', 'Contreras Silva',   'DNI','43000007','1980-01-15','F','Jr. Zepita 345, Brena',                  'liliana_contreras','Medico@2024'),
(2,'Oswaldo Rene',   'Moreno Delgado',    'DNI','43000008','1973-07-28','M','Av. Venezuela 3456, Lima Centro',        'oswaldo_moreno',   'Medico@2024'),
(2,'Gloria E.',      'Delgado Cortez',    'DNI','43000009','1977-12-05','F','Av. Colonial 1200, Cercado de Lima',     'gloria_delgado',   'Medico@2024'),
(2,'Ruben Enrique',  'Castillo Bermejo',  'DNI','43000010','1969-08-19','M','Av. Benavides 4851, Santiago de Surco', 'ruben_castillo',   'Medico@2024'),
(2,'Martha Susana',  'Bermejo Garcia',    'DNI','43000011','1974-03-11','F','Jr. Ica 432, Lima Centro',               'martha_bermejo',   'Medico@2024'),
(2,'Ernesto Jose',   'Acosta Bravo',      'DNI','43000012','1967-10-23','M','Av. Javier Prado Este 1245, Ate',        'ernesto_acosta',   'Medico@2024'),
(2,'Angela Patricia','Bravo Mendez',      'DNI','43000013','1982-06-30','F','Av. San Luis 1785, San Luis',            'angela_bravo',     'Medico@2024'),
(2,'Martin H.',      'Mendez Salvador',   'DNI','43000014','1971-09-14','M','Jr. Andahuaylas 678, La Victoria',       'martin_mendez',    'Medico@2024'),
(2,'Hugo Valentin',  'Salvador Castro',   'DNI','43000015','1963-04-02','M','Av. Canada 1025, La Victoria',           'hugo_salvador',    'Medico@2024'),
(2,'Leopoldo B.',    'Castro Ramos',      'DNI','43000016','1966-11-17','M','Av. Brasil 1560, Pueblo Libre',          'leopoldo_castro',  'Medico@2024'),
(2,'Elena N.',       'Ramos Solis',       'DNI','43000017','1979-07-08','F','Calle Monte Rosa 240, Surco',            'elena_ramos',      'Medico@2024'),
(2,'Cesar Augusto',  'Solis Rios',        'DNI','43000018','1976-02-27','M','Av. Larco 1150, Miraflores',             'cesar_solis',      'Medico@2024'),
(2,'Nora Gabriela',  'Rios Campos',       'DNI','43000019','1983-05-16','F','Jr. Tacna 890, Cercado de Lima',         'nora_rios',        'Medico@2024'),
(2,'Aurelio Marcos', 'Campos Guzman',     'DNI','43000020','1960-01-29','M','Av. Angamos Este 2340, Surquillo',       'aurelio_campos',   'Medico@2024'),
(2,'Teresa Dolores', 'Guzman Lara',       'DNI','43000021','1981-08-13','F','Av. Tupac Amaru 2100, Independencia',    'teresa_guzman',    'Medico@2024'),
(2,'Humberto F.',    'Lara Mejia',        'DNI','43000022','1964-06-04','M','Jr. Cusco 345, Lima Centro',             'humberto_lara',    'Medico@2024'),
(2,'Laura Celeste',  'Mejia Fuentes',     'DNI','43000023','1985-10-20','F','Av. Reducto 1278, Miraflores',           'laura_mejia',      'Medico@2024'),
(2,'Dario Eduardo',  'Fuentes Montes',    'DNI','43000024','1970-03-09','M','Av. Ejercito 1100, Miraflores',          'dario_fuentes',    'Medico@2024');
GO
INSERT INTO Usuario (IdRol, Nombres, Apellidos, TipoDocumento, NumeroDocumento,
                     FechaNacimiento, Genero, Direccion, Username, PasswordHash)
VALUES
(3,'Carlos',         'Garcia Mendoza',    'DNI','52000001','1990-04-12','M','Jr. Los Pinos 234, SJL',                 'carlos_garcia',    'Paciente123'),
(3,'Ana Lucia',      'Torres Lopez',      'DNI','52000002','1988-07-25','F','Av. Proceres 1560, SJL',                 'ana_torres',       'Paciente123'),
(3,'Miguel Angel',   'Flores Ramirez',    'DNI','52000003','1992-01-30','M','Av. Lima 456, Comas',                    'miguel_flores',    'Paciente123'),
(3,'Maria Elena',    'Sanchez Garcia',    'DNI','52000004','1985-09-18','F','Jr. Loreto 789, Ate',                    'maria_sanchez',    'Paciente123'),
(3,'Jose Luis',      'Herrera Torres',    'DNI','52000005','1978-11-05','M','Av. Central 1230, El Agustino',          'jose_herrera',     'Paciente123'),
(3,'Carmen Rosa',    'Ramirez Cruz',      'DNI','52000006','1983-03-22','F','Jr. San Martin 345, Brena',              'carmen_ramirez',   'Paciente123'),
(3,'Ricardo A.',     'Cruz Lima',         'DNI','52000007','1995-06-14','M','Av. Grau 890, La Victoria',              'ricardo_cruz',     'Paciente123'),
(3,'Patricia I.',    'Morales Herrera',   'DNI','52000008','1987-12-08','F','Calle Los Rosales 120, Surco',           'patricia_morales', 'Paciente123'),
(3,'Fernando A.',    'Diaz Ramos',        'DNI','52000009','1970-08-27','M','Av. Universitaria 3456, SMP',            'fernando_diaz',    'Paciente123'),
(3,'Diana Sofia',    'Herrera Vasquez',   'DNI','52000010','1993-02-15','F','Jr. Cahuide 678, Santa Anita',           'diana_herrera',    'Paciente123'),
(3,'Roberto C.',     'Morales Flores',    'DNI','52000011','1975-05-03','M','Av. Lima 2100, Carabayllo',              'roberto_morales',  'Paciente123'),
(3,'Monica A.',      'Flores Quispe',     'DNI','52000012','1989-10-19','F','Jr. Pachacutec 456, Villa El Salvador',  'monica_flores',    'Paciente123'),
(3,'Daniel E.',      'Vasquez Reyes',     'DNI','52000013','1996-07-11','M','Av. Separadora Industrial 890, Ate',     'daniel_vasquez',   'Paciente123'),
(3,'Claudia V.',     'Reyes Morales',     'DNI','52000014','1984-04-28','F','Calle Los Olivos 230, Los Olivos',       'claudia_reyes',    'Paciente123'),
(3,'Eduardo M.',     'Ramos Castro',      'DNI','52000015','1972-09-16','M','Av. Naranjal 1234, Independencia',       'eduardo_ramos',    'Paciente123'),
(3,'Sandra Beatriz', 'Castro Soto',       'DNI','52000016','1991-01-07','F','Jr. Bolognesi 567, Chorrillos',          'sandra_castro',    'Paciente123'),
(3,'Guillermo E.',   'Torres Gutierrez',  'DNI','52000017','1968-06-24','M','Av. Defensores del Morro 890, Chorrillos','guillermo_torres','Paciente123'),
(3,'Valeria S.',     'Gutierrez Pizarro', 'DNI','52000018','1997-03-31','F','Calle Los Cipreses 45, San Borja',       'valeria_gutierrez','Paciente123'),
(3,'Victor Hugo',    'Soto Pizarro',      'DNI','52000019','1980-11-14','M','Av. Encalada 1560, Santiago de Surco',  'victor_soto',      'Paciente123'),
(3,'Lucia F.',       'Pizarro Romero',    'DNI','52000020','1994-08-02','F','Jr. Dean Valdivia 234, San Isidro',      'lucia_pizarro',    'Paciente123'),
(3,'Pablo Andre',    'Romero Medina',     'DNI','52000021','1986-05-20','M','Av. Caminos del Inca 789, Surco',        'pablo_romero',     'Paciente123'),
(3,'Paola Andrea',   'Medina Espinoza',   'DNI','52000022','1990-12-09','F','Jr. Cangallo 345, Lima Centro',          'paola_medina',     'Paciente123'),
(3,'Sergio Ivan',    'Espinoza Ponce',    'DNI','52000023','1977-04-17','M','Av. Evitamiento 2340, SJL',              'sergio_espinoza',  'Paciente123'),
(3,'Daniela C.',     'Ponce Rojas',       'DNI','52000024','1993-09-26','F','Calle Monte Bello 120, San Borja',       'daniela_ponce',    'Paciente123'),
(3,'Andres Felipe',  'Rojas Villanueva',  'DNI','52000025','1982-07-08','M','Av. Huaylas 456, Chorrillos',            'andres_rojas',     'Paciente123'),
(3,'Sofia I.',       'Rojas Torres',      'DNI','52000026','1998-02-23','F','Jr. Los Incas 789, Rimac',               'sofia_rojas',      'Paciente123'),
(3,'Diego Armando',  'Chavez Vera',       'DNI','52000027','1974-10-31','M','Av. Proceres de la Independencia 1230, SJL','diego_chavez', 'Paciente123'),
(3,'Gabriela N.',    'Vera Chavez',       'DNI','52000028','1987-06-05','F','Calle Las Acacias 56, Surco',            'gabriela_vera',    'Paciente123'),
(3,'Antonio Raul',   'Palomino Salinas',  'DNI','52000029','1969-03-18','M','Av. Naranjal 890, Los Olivos',           'antonio_palomino', 'Paciente123'),
(3,'Camila A.',      'Palomino Cruz',     'DNI','52000030','1995-11-27','F','Jr. Huancavelica 234, La Victoria',      'camila_palomino',  'Paciente123'),
(3,'Francisco J.',   'Vargas Paredes',    'DNI','52000031','1971-08-13','M','Av. Tupac Amaru 3456, Comas',            'francisco_vargas', 'Paciente123'),
(3,'Andrea M.',      'Paredes Vargas',    'DNI','52000032','1989-05-02','F','Calle Las Palmeras 67, San Isidro',      'andrea_paredes',   'Paciente123'),
(3,'Hector Miguel',  'Mendoza Castro',    'DNI','52000033','1984-12-20','M','Av. Separadora 1200, Ate',               'hector_mendoza',   'Paciente123'),
(3,'Fernanda V.',    'Mendoza Ponce',     'DNI','52000034','1992-09-07','F','Jr. Junin 456, Lima Centro',             'fernanda_mendoza', 'Paciente123'),
(3,'Oscar Daniel',   'Ponce Chavez',      'DNI','52000035','1976-06-15','M','Av. Lima 3456, Puente Piedra',           'oscar_ponce',      'Paciente123'),
(3,'Alejandra C.',   'Alarcon Fuentes',   'DNI','52000036','1991-01-24','F','Calle Las Violetas 89, La Molina',       'alejandra_alarcon','Paciente123'),
(3,'Alberto Jesus',  'Vera Palomino',     'DNI','52000037','1973-10-09','M','Av. El Sol 1560, Villa El Salvador',     'alberto_vera',     'Paciente123'),
(3,'Isabella M.',    'Fuentes Navarro',   'DNI','52000038','1996-07-28','F','Jr. Ica 678, Lima Centro',               'isabella_fuentes', 'Paciente123'),
(3,'Raul Ernesto',   'Salinas Vargas',    'DNI','52000039','1980-04-16','M','Av. Colonial 2340, Cercado de Lima',     'raul_salinas',     'Paciente123'),
(3,'Natalia Pilar',  'Navarro Rios',      'DNI','52000040','1988-11-03','F','Calle Los Fresnos 23, San Borja',        'natalia_navarro',  'Paciente123'),
(3,'Julio Cesar',    'Alarcon Fuentes',   'DNI','52000041','1967-08-21','M','Av. Tupac Amaru 890, Independencia',     'julio_alarcon',    'Paciente123'),
(3,'Giuliana R.',    'Rios Campos',       'DNI','52000042','1994-05-10','F','Jr. Cusco 123, Cercado de Lima',         'giuliana_rios',    'Paciente123'),
(3,'Marco Antonio',  'Navarro Pena',      'DNI','52000043','1978-02-26','M','Av. Angamos 1234, Miraflores',           'marco_navarro',    'Paciente123'),
(3,'Katia M.',       'Campos Quispe',     'DNI','52000044','1990-09-14','F','Calle Monte Rey 45, Santiago de Surco',  'katia_campos',     'Paciente123'),
(3,'Luis Enrique',   'Rios Campos',       'DNI','52000045','1983-06-01','M','Av. La Fontana 890, La Molina',          'luis_rios',        'Paciente123'),
(3,'Vanessa C.',     'Guzman Lara',       'DNI','52000046','1997-12-19','F','Jr. Arequipa 456, Miraflores',           'vanessa_guzman',   'Paciente123'),
(3,'Alfredo M.',     'Campos Guzman',     'DNI','52000047','1965-03-07','M','Av. Benavides 2100, Miraflores',         'alfredo_campos',   'Paciente123'),
(3,'Stephanie A.',   'Lara Mejia',        'DNI','52000048','1993-10-25','F','Calle Los Pinos 78, Surco',              'stephanie_lara',   'Paciente123'),
(3,'Emilio Jose',    'Guzman Solis',      'DNI','52000049','1979-07-13','M','Av. Primavera 1560, Santiago de Surco',  'emilio_guzman',    'Paciente123'),
(3,'Ximena A.',      'Mejia Fuentes',     'DNI','52000050','1986-04-22','F','Jr. Moquegua 234, Jesus Maria',          'ximena_mejia',     'Paciente123'),
(3,'Arturo F.',      'Lara Mejia',        'DNI','52000051','1972-01-30','M','Av. Universitaria 4567, Comas',          'arturo_lara',      'Paciente123'),
(3,'Priscila M.',    'Fuentes Montes',    'DNI','52000052','1991-08-18','F','Calle Las Camelias 90, San Isidro',      'priscila_fuentes', 'Paciente123'),
(3,'Gonzalo R.',     'Mejia Castro',      'DNI','52000053','1976-05-06','M','Av. Javier Prado Oeste 890, San Isidro', 'gonzalo_mejia',    'Paciente123'),
(3,'Karla Lucia',    'Montes Garcia',     'DNI','52000054','1989-12-24','F','Jr. Huallaga 567, Lima Centro',          'karla_montes',     'Paciente123'),
(3,'Patricio A.',    'Fuentes Montes',    'DNI','52000055','1984-09-11','M','Av. Mexico 1234, La Victoria',           'patricio_fuentes', 'Paciente123'),
(3,'Silvia P.',      'Garcia Flores',     'DNI','52000056','1992-06-29','F','Calle Los Tulipanes 12, Surco',          'silvia_garcia',    'Paciente123'),
(3,'Sebastian D.',   'Montes Garcia',     'DNI','52000057','1974-03-17','M','Av. Lima 5678, Puente Piedra',           'sebastian_montes', 'Paciente123'),
(3,'Milagros E.',    'Flores Garcia',     'DNI','52000058','1987-10-04','F','Jr. Lampa 890, Lima Centro',             'milagros_flores',  'Paciente123'),
(3,'Ignacio E.',     'Torres Rios',       'DNI','52000059','1981-07-22','M','Av. Proceres 2340, SJL',                 'ignacio_torres',   'Paciente123'),
(3,'Beatriz A.',     'Garcia Mendoza',    'DNI','52000060','1995-04-10','F','Calle Las Magnolias 34, La Molina',      'beatriz_garcia',   'Paciente123'),
(3,'Nicolas A.',     'Rios Silva',        'DNI','52000061','1969-01-28','M','Av. Lima 7890, Villa El Salvador',       'nicolas_rios',     'Paciente123'),
(3,'Renata V.',      'Mendoza Torres',    'DNI','52000062','1993-08-16','F','Jr. Ica 345, Lima Centro',               'renata_mendoza',   'Paciente123'),
(3,'German O.',      'Silva Moreno',      'DNI','52000063','1977-05-05','M','Av. Universitaria 2345, Los Olivos',     'german_silva',     'Paciente123'),
(3,'Marisol E.',     'Torres Ramirez',    'DNI','52000064','1988-12-23','F','Calle Los Aromos 56, Surco',             'marisol_torres',   'Paciente123'),
(3,'Augusto G.',     'Moreno Castro',     'DNI','52000065','1964-09-10','M','Av. Paseo de la Republica 1560, SJM',   'augusto_moreno',   'Paciente123'),
(3,'Yolanda C.',     'Ramirez Cruz',      'DNI','52000066','1990-06-28','F','Jr. Cusco 678, Cercado de Lima',         'yolanda_ramirez',  'Paciente123'),
(3,'Salvador E.',    'Castro Delgado',    'DNI','52000067','1973-03-16','M','Av. Tupac Amaru 4567, Independencia',    'salvador_castro',  'Paciente123'),
(3,'Elena Rocio',    'Cruz Lima',         'DNI','52000068','1986-10-04','F','Calle Las Orquideas 78, San Borja',      'elena_cruz',       'Paciente123'),
(3,'Mauricio E.',    'Delgado Cortez',    'DNI','52000069','1980-07-22','M','Av. La Marina 4567, San Miguel',         'mauricio_delgado', 'Paciente123'),
(3,'Cynthia R.',     'Lima Garcia',       'DNI','52000070','1994-04-09','F','Jr. Washington 234, Lima Centro',        'cynthia_lima',     'Paciente123');

PRINT '=== 100 usuarios insertados ===';
GO

-- ============================================================
-- SECCIÓN 3: CONTACTOS (SET-based, usa IdUsuario real)
-- ============================================================
INSERT INTO Contacto (IdUsuario, TipoContacto, Valor, EsPrincipal)
SELECT IdUsuario, 'Telefono',
       '9' + RIGHT('00000000' + CAST(10000000 + IdUsuario * 7 + 13 AS VARCHAR(9)), 8), 1
FROM Usuario
UNION ALL
SELECT IdUsuario, 'Email', Username + '@clinicaidat.pe', 0
FROM Usuario;
PRINT '=== Contactos insertados ===';
GO

-- ============================================================
-- SECCIÓN 4: MÉDICOS (28) + TARIFAS
-- ============================================================
INSERT INTO Medico (IdUsuario, ColegioMedico, Activo)
SELECT IdUsuario,
       'CMP-' + RIGHT('000000' + CAST(ROW_NUMBER() OVER (ORDER BY IdUsuario) + 98999 AS VARCHAR(6)), 6),
       1
FROM Usuario WHERE IdRol = 2;

INSERT INTO Tarifa (IdMedico, IdEspecialidad, Monto, Descripcion, Activo)
SELECT
    m.IdMedico,
    ((m.IdMedico - 1) % 15) + 1,
    CASE ((m.IdMedico - 1) % 15) + 1
        WHEN 1  THEN  80.00 WHEN 2  THEN  90.00 WHEN 3  THEN 120.00
        WHEN 4  THEN 130.00 WHEN 5  THEN 150.00 WHEN 6  THEN 160.00
        WHEN 7  THEN 110.00 WHEN 8  THEN 100.00 WHEN 9  THEN 140.00
        WHEN 10 THEN 200.00 WHEN 11 THEN 130.00 WHEN 12 THEN 120.00
        WHEN 13 THEN 120.00 WHEN 14 THEN 130.00 ELSE    100.00
    END,
    'Consulta ' + e.Nombre,
    1
FROM Medico m
JOIN Especialidad e ON e.IdEspecialidad = ((m.IdMedico - 1) % 15) + 1;

PRINT '=== Medicos y Tarifas insertados ===';
GO

-- ============================================================
-- SECCIÓN 5: HORARIOS (SET-based, cross join con dias 1-5)
-- ============================================================
INSERT INTO HorarioMedico (IdMedico, DiaSemana, HoraInicio, HoraFin, IdConsultorio)
SELECT
    m.IdMedico,
    d.dia,
    CASE m.IdMedico % 3 WHEN 0 THEN '07:00' WHEN 1 THEN '08:00' ELSE '14:00' END,
    CASE m.IdMedico % 3 WHEN 0 THEN '13:00' WHEN 1 THEN '14:00' ELSE '20:00' END,
    ((m.IdMedico + d.dia) % 10) + 1
FROM Medico m
CROSS JOIN (VALUES (1),(2),(3),(4),(5)) AS d(dia);
PRINT '=== Horarios insertados ===';
GO

-- ============================================================
-- SECCIÓN 6: PACIENTES (SET-based)
-- ============================================================
INSERT INTO Paciente (IdUsuario, IdTipoAsegurado, IdEmpresa, NumeroSeguro, GrupoSanguineo)
SELECT
    u.IdUsuario,
    CASE
        WHEN u.IdUsuario <= 30 THEN 1
        WHEN u.IdUsuario <= 50 THEN 3
        WHEN u.IdUsuario <= 75 THEN 2
        ELSE 4
    END,
    CASE WHEN u.IdUsuario BETWEEN 51 AND 75 THEN ((u.IdUsuario - 51) % 10) + 1 ELSE NULL END,
    CASE
        WHEN u.IdUsuario BETWEEN 31 AND 50 THEN 'ES-'   + RIGHT('000000' + CAST(u.IdUsuario AS VARCHAR), 6)
        WHEN u.IdUsuario BETWEEN 51 AND 75 THEN 'CORP-' + RIGHT('000000' + CAST(u.IdUsuario AS VARCHAR), 6)
        WHEN u.IdUsuario > 75              THEN 'SIS-'  + RIGHT('000000' + CAST(u.IdUsuario AS VARCHAR), 6)
        ELSE NULL
    END,
    CHOOSE((u.IdUsuario % 8) + 1, 'O+','A+','B+','AB+','O-','A-','B-','AB-')
FROM Usuario u;
PRINT '=== Pacientes insertados ===';
GO

-- ============================================================
-- SECCIÓN 7: SEGUROS (SET-based)
-- ============================================================
INSERT INTO Seguro (IdPaciente, NombreSeguro, NumeroPoliza, FechaVigencia, FechaVencimiento, CoberturaMax, Activo)
SELECT
    p.IdPaciente,
    CHOOSE((p.IdPaciente % 5) + 1, 'EsSalud','Rimac Seguros','Pacifico Salud','La Positiva','Mapfre Salud'),
    'POL-' + RIGHT('0000000' + CAST(p.IdPaciente * 1234 AS VARCHAR(8)), 7),
    DATEADD(YEAR, 1, GETDATE()),
    DATEADD(YEAR, 2, GETDATE()),
    CAST(((p.IdPaciente % 5) + 1) * 5000 AS DECIMAL(10,2)),
    1
FROM Paciente p
WHERE p.IdPaciente BETWEEN 31 AND 90;
PRINT '=== Seguros insertados ===';
GO

-- ============================================================
-- SECCIÓN 8: CITAS
-- ============================================================
DECLARE @p    INT;
DECLARE @i    INT;
DECLARE @docId INT;
DECLARE @espId INT;
DECLARE @tarifaId INT;
DECLARE @fechaCita DATETIME;
DECLARE @mot  VARCHAR(300);
DECLARE @motivos TABLE (n INT IDENTITY(1,1), m VARCHAR(300));
INSERT INTO @motivos VALUES
('Consulta de control rutinario'),('Dolor de cabeza persistente'),
('Fiebre y malestar general'),('Revision anual preventiva'),
('Dolor articular y muscular'),('Problemas respiratorios'),
('Evaluacion dermatologica'),('Control de presion arterial'),
('Revision oftalmologica'),('Dolor abdominal agudo'),
('Infeccion respiratoria alta'),('Control de enfermedad cronica'),
('Molestias cardiacas'),('Evaluacion neurologica'),('Consulta de seguimiento');

-- 6 citas COMPLETADAS por cada paciente
SET @p = 1;
WHILE @p <= 100
BEGIN
    SET @i = 1;
    WHILE @i <= 6
    BEGIN
        SET @docId    = ((@p * 7 + @i * 3) % 28) + 1;
        SET @espId    = ((@docId - 1) % 15) + 1; -- fallback
        SET @tarifaId = NULL;
        SELECT TOP 1 @espId = IdEspecialidad, @tarifaId = IdTarifa
        FROM Tarifa WHERE IdMedico = @docId AND Activo = 1;
        SET @fechaCita = DATEADD(HOUR, 8 + (@i % 9),
            DATEADD(DAY, -((@p - 1) * 6 + @i * 14 + 30), CAST(GETDATE() AS DATE)));
        SELECT @mot = m FROM @motivos WHERE n = (@i % 15) + 1;
        INSERT INTO Cita (IdPaciente, IdMedico, IdEspecialidad, IdTarifa, IdEstadoCita,
                          FechaHora, Motivo, FechaCreacion)
        VALUES (@p, @docId, @espId, @tarifaId, 4, @fechaCita, @mot, DATEADD(DAY,-7,@fechaCita));
        SET @i = @i + 1;
    END
    SET @p = @p + 1;
END

-- 50 citas PENDIENTES
SET @p = 1;
WHILE @p <= 50
BEGIN
    SET @docId    = ((@p * 3 + 5) % 28) + 1;
    SET @espId    = ((@docId - 1) % 15) + 1;
    SET @tarifaId = NULL;
    SELECT TOP 1 @espId = IdEspecialidad, @tarifaId = IdTarifa
    FROM Tarifa WHERE IdMedico = @docId AND Activo = 1;
    SET @fechaCita = DATEADD(HOUR, 9 + (@p % 8), DATEADD(DAY, 7 + @p, CAST(GETDATE() AS DATE)));
    SELECT @mot = m FROM @motivos WHERE n = (@p % 15) + 1;
    INSERT INTO Cita (IdPaciente, IdMedico, IdEspecialidad, IdTarifa, IdEstadoCita,
                      FechaHora, Motivo, FechaCreacion)
    VALUES (@p, @docId, @espId, @tarifaId, 1, @fechaCita, @mot, DATEADD(DAY,-2,GETDATE()));
    SET @p = @p + 1;
END

-- 30 citas CONFIRMADAS
SET @p = 1;
WHILE @p <= 30
BEGIN
    SET @docId    = ((@p * 5 + 2) % 28) + 1;
    SET @espId    = ((@docId - 1) % 15) + 1;
    SET @tarifaId = NULL;
    SELECT TOP 1 @espId = IdEspecialidad, @tarifaId = IdTarifa
    FROM Tarifa WHERE IdMedico = @docId AND Activo = 1;
    SET @fechaCita = DATEADD(HOUR, 10 + (@p % 7), DATEADD(DAY, 3 + @p * 2, CAST(GETDATE() AS DATE)));
    SELECT @mot = m FROM @motivos WHERE n = ((@p + 3) % 15) + 1;
    INSERT INTO Cita (IdPaciente, IdMedico, IdEspecialidad, IdTarifa, IdEstadoCita,
                      FechaHora, Motivo, FechaCreacion)
    VALUES (@p, @docId, @espId, @tarifaId, 2, @fechaCita, @mot, DATEADD(DAY,-5,GETDATE()));
    SET @p = @p + 1;
END

-- 20 citas CANCELADAS
SET @p = 51;
WHILE @p <= 70
BEGIN
    SET @docId    = ((@p * 2 + 1) % 28) + 1;
    SET @espId    = ((@docId - 1) % 15) + 1;
    SET @tarifaId = NULL;
    SELECT TOP 1 @espId = IdEspecialidad, @tarifaId = IdTarifa
    FROM Tarifa WHERE IdMedico = @docId AND Activo = 1;
    SET @fechaCita = DATEADD(HOUR, 11, DATEADD(DAY, -(@p - 40), CAST(GETDATE() AS DATE)));
    SELECT @mot = m FROM @motivos WHERE n = ((@p + 7) % 15) + 1;
    INSERT INTO Cita (IdPaciente, IdMedico, IdEspecialidad, IdTarifa, IdEstadoCita,
                      FechaHora, Motivo, FechaCreacion)
    VALUES (@p, @docId, @espId, @tarifaId, 3, @fechaCita, @mot, DATEADD(DAY,-10,@fechaCita));
    SET @p = @p + 1;
END

-- 15 citas ANULADAS
SET @p = 71;
WHILE @p <= 85
BEGIN
    SET @docId    = ((@p * 4 + 3) % 28) + 1;
    SET @espId    = ((@docId - 1) % 15) + 1;
    SET @tarifaId = NULL;
    SELECT TOP 1 @espId = IdEspecialidad, @tarifaId = IdTarifa
    FROM Tarifa WHERE IdMedico = @docId AND Activo = 1;
    SET @fechaCita = DATEADD(HOUR, 14, DATEADD(DAY, -(@p - 60), CAST(GETDATE() AS DATE)));
    SELECT @mot = m FROM @motivos WHERE n = ((@p + 9) % 15) + 1;
    INSERT INTO Cita (IdPaciente, IdMedico, IdEspecialidad, IdTarifa, IdEstadoCita,
                      FechaHora, Motivo, FechaCreacion)
    VALUES (@p, @docId, @espId, @tarifaId, 5, @fechaCita, @mot, DATEADD(DAY,-8,@fechaCita));
    SET @p = @p + 1;
END

PRINT '=== Citas insertadas ===';
GO

-- ============================================================
-- SECCIÓN 9: CANCELACIONES
-- ============================================================
INSERT INTO CancelacionCita (IdCita, Motivo, CanceladoPor)
SELECT c.IdCita,
    CASE c.IdEstadoCita
        WHEN 3 THEN CHOOSE((c.IdCita % 5)+1,
            'Medico no disponible','Consultorio en mantenimiento',
            'Paciente no se presento','Emergencia en clinica','Reprogramacion medica')
        WHEN 5 THEN CHOOSE((c.IdCita % 4)+1,
            'Paciente cancelo por motivos personales','Viaje imprevisto',
            'Paciente se siente mejor','Conflicto de horario')
    END,
    CASE c.IdEstadoCita WHEN 3 THEN 'Medico' ELSE 'Paciente' END
FROM Cita c
WHERE c.IdEstadoCita IN (3, 5);
PRINT '=== Cancelaciones insertadas ===';
GO

-- ============================================================
-- SECCIÓN 10: TRIAJE
-- ============================================================
INSERT INTO Triaje (IdCita, Peso, Talla, PresionSistolica, PresionDiastolica,
                    FrecuenciaCardiaca, Temperatura, Saturacion, FechaRegistro)
SELECT
    IdCita,
    CAST(60 + (IdCita % 50) AS DECIMAL(5,2)),
    CAST(155 + (IdCita % 30) AS DECIMAL(5,2)),
    100 + (IdCita % 40),
    60  + (IdCita % 25),
    60  + (IdCita % 40),
    CAST(36.0 + (IdCita % 15) * 0.1 AS DECIMAL(4,1)),
    CAST(95.0 + (IdCita % 5)  * 0.5 AS DECIMAL(4,1)),
    FechaHora
FROM Cita
WHERE IdEstadoCita = 4;
PRINT '=== Triaje insertado ===';
GO

-- ============================================================
-- SECCIÓN 11: HISTORIAL CLÍNICO
-- ============================================================
DECLARE @diag TABLE (n INT IDENTITY(1,1), d VARCHAR(500), t VARCHAR(500), e VARCHAR(500));
INSERT INTO @diag VALUES
('Hipertension arterial grado I','Losartan 50mg/dia. Dieta hiposodica. Control en 30 dias','Paciente evoluciona bien, PA dentro de rangos normales'),
('Gastritis cronica superficial','Omeprazol 20mg en ayunas 4 semanas. Dieta blanda','Sintomas en remision parcial. Se mantiene tratamiento'),
('Diabetes mellitus tipo 2','Metformina 850mg c/12h. Dieta diabetica. Control glucemico','Glucemia en descenso progresivo. Buen cumplimiento'),
('Lumbalgia mecanica aguda','Diclofenaco topico. Reposo 3 dias. Fisioterapia 10 sesiones','Mejora del dolor. Continua fisioterapia'),
('Faringitis aguda bacteriana','Amoxicilina 500mg c/8h 7 dias. Paracetamol PRN','Resolucion completa al 7mo dia'),
('Infeccion del tracto urinario','Ciprofloxacino 500mg c/12h 7 dias. Hidratacion','Paciente sin sintomas. Urocultivo negativo'),
('Dermatitis atopica moderada','Hidrocortisona 1% bid. Loratadina 10mg/noche','Lesiones en regresion. Prurito disminuido'),
('Anemia ferropenica leve','Sulfato ferroso 300mg/dia con Vit C. Dieta rica en hierro','Hemoglobina en aumento progresivo'),
('Hipotiroidismo subclinico','Levotiroxina 50mcg en ayunas. Control TSH 3 meses','TSH en normalizacion. Paciente asintomatico'),
('Asma bronquial leve','Salbutamol PRN. Budesonida 200mcg bid preventivo','Frecuencia de crisis reducida'),
('Conjuntivitis viral aguda','Reposo ocular. Compresas frias. Higiene ocular','Resolucion completa en 7 dias'),
('Cefalea tensional','Ibuprofeno 400mg PRN. Tecnicas de relajacion','Frecuencia de episodios reducida'),
('Sindrome de intestino irritable','Dieta FODMAP. Metoclopramida antes de comidas','Mejora con adherencia a la dieta'),
('Rinitis alergica perenne','Loratadina 10mg/dia. Lavados nasales con suero','Sintomas controlados. Buena calidad de vida'),
('Artritis gotosa aguda','Ibuprofeno 600mg c/8h 5 dias. Dieta hipouremica','Resolucion del episodio en 5 dias');

INSERT INTO HistorialClinico (IdPaciente, IdCita, Diagnostico, Tratamiento, Evolucion, FechaRegistro)
SELECT c.IdPaciente, c.IdCita, d.d, d.t, d.e, c.FechaHora
FROM Cita c
CROSS APPLY (SELECT TOP 1 d, t, e FROM @diag WHERE n = ((c.IdCita % 15) + 1)) d
WHERE c.IdEstadoCita = 4;
PRINT '=== Historial clinico insertado ===';
GO

-- ============================================================
-- SECCIÓN 12: RECETAS
-- ============================================================
INSERT INTO Receta (IdCita, Diagnostico, Indicaciones, FechaEmision)
SELECT IdCita,
    CHOOSE((IdCita % 10)+1,'Hipertension','Gastritis','Diabetes tipo 2',
        'Dolor agudo','Infeccion bacteriana','Infeccion urinaria',
        'Dermatitis','Anemia','Hipotiroidismo','Asma bronquial'),
    'Tomar segun indicaciones. No automedicarse. Consulte ante efectos adversos.',
    FechaHora
FROM Cita
WHERE IdEstadoCita = 4 AND IdCita % 2 = 0;

INSERT INTO ItemReceta (IdReceta, IdMedicamento, Dosis, Frecuencia, Duracion, Cantidad)
SELECT r.IdReceta, ((r.IdReceta % 20) + 1),
    CHOOSE((r.IdReceta%5)+1,'1 tableta','2 tabletas','1/2 tableta','1 capsula','1 aplicacion'),
    CHOOSE((r.IdReceta%4)+1,'Cada 8 horas','Cada 12 horas','Una vez al dia','Dos veces al dia'),
    CHOOSE((r.IdReceta%4)+1,'7 dias','14 dias','30 dias','Continuo'),
    (r.IdReceta % 3) + 1
FROM Receta r;

INSERT INTO ItemReceta (IdReceta, IdMedicamento, Dosis, Frecuencia, Duracion, Cantidad)
SELECT r.IdReceta, (((r.IdReceta+7) % 20) + 1),
    CHOOSE(((r.IdReceta+2)%5)+1,'1 tableta','2 tabletas','1/2 tableta','1 capsula','1 inhalacion'),
    CHOOSE(((r.IdReceta+1)%4)+1,'Cada 8 horas','Cada 12 horas','Una vez al dia','Segun necesidad'),
    CHOOSE(((r.IdReceta+2)%4)+1,'5 dias','10 dias','21 dias','Continuo'),
    (r.IdReceta % 2) + 1
FROM Receta r;
PRINT '=== Recetas y detalles insertados ===';
GO

-- ============================================================
-- SECCIÓN 13: COMPROBANTES
-- ============================================================
INSERT INTO Comprobante (IdCita, TipoComprobante, Serie, Numero, Subtotal, IGV, Total, EstadoPago, FechaEmision)
SELECT
    c.IdCita,
    CASE p.IdTipoAsegurado WHEN 2 THEN 'Factura' ELSE 'Boleta' END,
    CASE p.IdTipoAsegurado WHEN 2 THEN 'F002'    ELSE 'B001'   END,
    CASE p.IdTipoAsegurado WHEN 2 THEN 'F002' ELSE 'B001' END
        + '-' + RIGHT('0000000' + CAST(c.IdCita AS VARCHAR(8)), 7),
    ISNULL(t.Monto, 100.00),
    ROUND(ISNULL(t.Monto, 100.00) * 0.18, 2),
    ROUND(ISNULL(t.Monto, 100.00) * 1.18, 2),
    CASE WHEN c.IdCita % 10 = 0 THEN 'Pendiente' ELSE 'Pagado' END,
    c.FechaHora
FROM Cita c
JOIN  Paciente p ON c.IdPaciente = p.IdPaciente
LEFT JOIN Tarifa t   ON c.IdTarifa   = t.IdTarifa
WHERE c.IdEstadoCita = 4;
PRINT '=== Comprobantes insertados ===';
GO

-- ============================================================
-- SECCIÓN 14: PAGOS
-- ============================================================
INSERT INTO Pago (IdComprobante, IdMetodoPago, Monto, NroOperacion, FechaPago)
SELECT
    co.IdComprobante,
    (co.IdComprobante % 5) + 1,
    co.Total,
    CASE (co.IdComprobante % 5) + 1
        WHEN 3 THEN 'TRF-' + RIGHT('000000' + CAST(co.IdComprobante * 7919 AS VARCHAR(8)), 6)
        WHEN 5 THEN 'YPE-' + RIGHT('000000' + CAST(co.IdComprobante * 1327 AS VARCHAR(8)), 6)
        ELSE NULL
    END,
    DATEADD(HOUR, 1, co.FechaEmision)
FROM Comprobante co
WHERE co.EstadoPago = 'Pagado';
PRINT '=== Pagos insertados ===';
GO

-- ============================================================
-- REACTIVAR CONSTRAINTS
-- ============================================================
ALTER TABLE Contacto         WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Medico           WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Tarifa           WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE HorarioMedico    WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Paciente         WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Seguro           WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Cita             WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE CancelacionCita  WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Triaje           WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE HistorialClinico WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Receta           WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE ItemReceta       WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Comprobante      WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Pago             WITH CHECK CHECK CONSTRAINT ALL;
ALTER TABLE Usuario          WITH CHECK CHECK CONSTRAINT ALL;
PRINT '=== Constraints reactivados ===';
GO

-- ============================================================
-- RESUMEN FINAL
-- ============================================================
PRINT '';
PRINT '============================================================';
PRINT '  ROL       USUARIO            PASSWORD      NOMBRE';
PRINT '============================================================';
PRINT '  Admin     jesus_admin        Admin@2024    Jesus Reymundo';
PRINT '  Admin     leomarc_admin      Admin@2024    Leomarc Reyes';
PRINT '  Medico    aldair_santos      Doctor@2024   Aldair Santos';
PRINT '  Medico    ivan_zarate        Doctor@2024   Ivan Zarate';
PRINT '  Paciente  paola_medina       Paciente123   Paola Medina';
PRINT '============================================================';

SELECT r.NombreRol AS Rol, u.Username, u.PasswordHash AS Pass,
       CONCAT(u.Nombres,' ',u.Apellidos) AS Nombre,
       u.TipoDocumento, u.NumeroDocumento,
       ISNULL(e.Nombre,'—') AS Especialidad
FROM Usuario u
JOIN Rol r ON u.IdRol = r.IdRol
LEFT JOIN Medico m  ON m.IdUsuario = u.IdUsuario
LEFT JOIN Tarifa tf ON tf.IdMedico = m.IdMedico AND tf.Activo = 1
LEFT JOIN Especialidad e ON e.IdEspecialidad = tf.IdEspecialidad
ORDER BY u.IdRol, u.IdUsuario;

SELECT 'Usuario'      AS Tabla, COUNT(*) AS Total FROM Usuario         UNION ALL
SELECT 'Medico',               COUNT(*) FROM Medico                    UNION ALL
SELECT 'Tarifa',               COUNT(*) FROM Tarifa                    UNION ALL
SELECT 'Paciente',             COUNT(*) FROM Paciente                  UNION ALL
SELECT 'Cita Total',           COUNT(*) FROM Cita                      UNION ALL
SELECT 'Cita Completada',      COUNT(*) FROM Cita WHERE IdEstadoCita=4 UNION ALL
SELECT 'Cita Pendiente',       COUNT(*) FROM Cita WHERE IdEstadoCita=1 UNION ALL
SELECT 'Cita Confirmada',      COUNT(*) FROM Cita WHERE IdEstadoCita=2 UNION ALL
SELECT 'Cita Cancelada',       COUNT(*) FROM Cita WHERE IdEstadoCita=3 UNION ALL
SELECT 'Cita Anulada',         COUNT(*) FROM Cita WHERE IdEstadoCita=5 UNION ALL
SELECT 'Historial',            COUNT(*) FROM HistorialClinico          UNION ALL
SELECT 'Receta',               COUNT(*) FROM Receta                    UNION ALL
SELECT 'Comprobante',          COUNT(*) FROM Comprobante               UNION ALL
SELECT 'Pago',                 COUNT(*) FROM Pago                      UNION ALL
SELECT 'Seguro',               COUNT(*) FROM Seguro;

PRINT '=== CARGA COMPLETADA EXITOSAMENTE ===';
GO
