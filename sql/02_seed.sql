BEGIN;

INSERT INTO persona (nombre, correo, pais) VALUES
('Ana López', 'ana.lopez@example.com', 'Guatemala'),
('Carlos Méndez', 'carlos.mendez@example.com', 'México'),
('Sofía García', 'sofia.garcia@example.com', 'Guatemala'),
('Diego Ramírez', 'diego.ramirez@example.com', 'El Salvador'),
('Valeria Cruz', 'valeria.cruz@example.com', 'Honduras'),
('Mateo Herrera', 'mateo.herrera@example.com', 'Costa Rica');

INSERT INTO edicion (nombre, anio, fecha_inicio, fecha_fin, estado, modalidad) VALUES
('ConectaTech Centroamérica', 2026, '2026-10-15', '2026-10-17', 'ABIERTA', 'HIBRIDA'),
('ConectaTech Innovación', 2027, '2027-05-20', '2027-05-22', 'PLANIFICADA', 'VIRTUAL');

INSERT INTO sede (nombre, ciudad) VALUES
('Centro de Convenciones Huehuetenango', 'Huehuetenango'),
('Centro Empresarial GT', 'Guatemala');

INSERT INTO sala (sede_id, nombre, capacidad) VALUES
(1, 'Auditorio Quetzal', 300),
(1, 'Sala Innovación', 80),
(2, 'Sala Maya', 120),
(2, 'Laboratorio Digital', 40);

-- Participaciones: Ana y Carlos serán ambos roles en 2026.
INSERT INTO participacion (persona_id, edicion_id) VALUES
(1, 1), -- Ana
(2, 1), -- Carlos
(3, 1), -- Sofía
(4, 1), -- Diego
(5, 2), -- Valeria
(6, 2); -- Mateo

INSERT INTO asistente (participacion_id, tipo_acreditacion) VALUES
(1, 'PROFESIONAL'),
(2, 'VIP'),
(3, 'ESTUDIANTE'),
(4, 'GENERAL'),
(5, 'PROFESIONAL');

INSERT INTO ponente (participacion_id, biografia) VALUES
(1, 'Especialista en arquitectura de software y transformación digital.'),
(2, 'Consultor internacional en datos y plataformas empresariales.'),
(3, 'Investigadora en inteligencia artificial aplicada.'),
(5, 'Directora de innovación y estrategia tecnológica.');

INSERT INTO sesion
(edicion_id, sala_id, titulo, resumen, fecha, hora_inicio, hora_fin, tipo_sesion)
VALUES
(1, 1, 'Arquitecturas modernas', 'Patrones para sistemas distribuidos.', '2026-10-15', '09:00', '10:00', 'CHARLA'),
(1, 2, 'Taller de APIs', 'Construcción de una API REST.', '2026-10-15', '10:15', '11:45', 'TALLER'),
(1, NULL, 'IA responsable', 'Riesgos y buenas prácticas de IA.', '2026-10-16', '09:00', '10:00', 'CHARLA'),
(1, 1, 'Datos para decisiones', 'Diseño de indicadores y calidad de datos.', '2026-10-16', '11:00', '12:00', 'CHARLA'),
(2, NULL, 'Cloud y escalabilidad', 'Conceptos de nube y escalabilidad.', '2027-05-20', '09:00', '10:00', 'CHARLA'),
(2, NULL, 'Laboratorio de observabilidad', 'Práctica guiada de métricas y trazas.', '2027-05-20', '10:15', '11:45', 'TALLER');

INSERT INTO charla (sesion_id, minutos_preguntas) VALUES
(1, 10),
(3, 15),
(4, 10),
(5, 10);
INSERT INTO taller (sesion_id, cupo_practico, requisitos_materiales) VALUES
(2, 25, 'Computadora con navegador y editor de código.'),
(6, 20, 'Computadora con acceso a internet.');
INSERT INTO transmision (sesion_id, plataforma, url, codigo_acceso) VALUES
(1, 'Meet', 'https://meet.example.com/conectatech-1', 'CT26-1'),
(3, 'Zoom', 'https://zoom.example.com/conectatech-3', 'CT26-3'),
(5, 'Meet', 'https://meet.example.com/conectatech-5', 'CT27-5'),
(6, 'Teams', 'https://teams.example.com/conectatech-6', 'CT27-6');
INSERT INTO inscripcion
(participacion_id, sesion_id, fecha_inscripcion, estado, asistio)
VALUES
(1, 1, '2026-09-01', 'CONFIRMADA', TRUE),
(2, 1, '2026-09-02', 'CONFIRMADA', TRUE),
(3, 2, '2026-09-03', 'CONFIRMADA', TRUE),
(4, 3, '2026-09-04', 'CONFIRMADA', FALSE),
(1, 4, '2026-09-05', 'CONFIRMADA', TRUE),
(5, 5, '2027-04-01', 'CONFIRMADA', NULL),
(6, 5, '2027-04-02', 'CONFIRMADA', NULL),
(5, 6, '2027-04-03', 'PREINSCRITA', NULL);

INSERT INTO asignacion_ponente
(participacion_id, sesion_id, rol, orden_programa)
VALUES
(1, 1, 'PRINCIPAL', 1),
(2, 2, 'PRINCIPAL', 1),
(3, 3, 'PRINCIPAL', 1),
(2, 4, 'CO_PONENTE', 1);
INSERT INTO empresa (nombre) VALUES
('TecnoMaya'),
('DataCentro'),
('CloudLatam');
INSERT INTO acuerdo_patrocinio
(empresa_id, edicion_id, categoria, monto, fecha_confirmacion)
VALUES
(1, 1, 'ORO', 25000.00, '2026-08-15'),
(2, 1, 'PLATA', 12000.00, '2026-08-20'),
(3, 2, 'BRONCE', 8000.00, '2027-03-10');
INSERT INTO prerrequisito (sesion_id, sesion_previa_id) VALUES
(2, 1),
(4, 1),
(6, 5);

COMMIT;
