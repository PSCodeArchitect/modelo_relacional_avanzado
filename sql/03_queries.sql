-- 1. Programa completo atravesando EDICION -> SESION -> SALA -> SEDE
SELECT
    e.nombre AS edicion,
    e.anio,
    s.titulo AS sesion,
    s.fecha,
    s.hora_inicio,
    s.hora_fin,
    se.nombre AS sede,
    sa.nombre AS sala,
    s.tipo_sesion
FROM edicion e
JOIN sesion s ON s.edicion_id = e.edicion_id
LEFT JOIN sala sa ON sa.sala_id = s.sala_id
LEFT JOIN sede se ON se.sede_id = sa.sede_id
ORDER BY e.anio, s.fecha, s.hora_inicio;

-- 2. participantes y roles por edicion
SELECT
    e.nombre AS edicion,
    p.nombre AS persona,
    CASE
        WHEN a.participacion_id IS NOT NULL AND po.participacion_id IS NOT NULL
            THEN 'ASISTENTE + PONENTE'
        WHEN a.participacion_id IS NOT NULL
            THEN 'ASISTENTE'
        WHEN po.participacion_id IS NOT NULL
            THEN 'PONENTE'
        ELSE 'SIN ROL'
    END AS roles
FROM participacion pa
JOIN persona p ON p.persona_id = pa.persona_id
JOIN edicion e ON e.edicion_id = pa.edicion_id
LEFT JOIN asistente a ON a.participacion_id = pa.participacion_id
LEFT JOIN ponente po ON po.participacion_id = pa.participacion_id
ORDER BY e.anio, p.nombre;

-- 3. Cupos y participacion por sesion
SELECT
    s.titulo,
    s.tipo_sesion,
    CASE WHEN t.sesion_id IS NOT NULL THEN t.cupo_practico ELSE NULL END AS cupo_practico,
    COUNT(i.participacion_id) AS inscritos,
    COUNT(i.participacion_id) FILTER (WHERE i.asistio IS TRUE) AS asistieron
FROM sesion s
LEFT JOIN taller t ON t.sesion_id = s.sesion_id
LEFT JOIN inscripcion i ON i.sesion_id = s.sesion_id
GROUP BY s.sesion_id, s.titulo, s.tipo_sesion, t.cupo_practico
ORDER BY s.sesion_id;

-- 4. Ponentes y orden del programa
SELECT
    s.titulo,
    ap.orden_programa,
    ap.rol,
    p.nombre AS ponente
FROM asignacion_ponente ap
JOIN ponente po ON po.participacion_id = ap.participacion_id
JOIN participacion pa ON pa.participacion_id = po.participacion_id
JOIN persona p ON p.persona_id = pa.persona_id
JOIN sesion s ON s.sesion_id = ap.sesion_id
ORDER BY s.sesion_id, ap.orden_programa;

-- 5. Prerrequisitos
SELECT
    objetivo.titulo AS sesion,
    previa.titulo AS prerrequisito
FROM prerrequisito pr
JOIN sesion objetivo ON objetivo.sesion_id = pr.sesion_id
JOIN sesion previa ON previa.sesion_id = pr.sesion_previa_id
ORDER BY objetivo.sesion_id;

-- 6. Patrocinadores por edicion
SELECT
    e.nombre AS edicion,
    em.nombre AS empresa,
    ap.categoria,
    ap.monto,
    ap.fecha_confirmacion
FROM acuerdo_patrocinio ap
JOIN empresa em ON em.empresa_id = ap.empresa_id
JOIN edicion e ON e.edicion_id = ap.edicion_id
ORDER BY e.anio, ap.monto DESC;
