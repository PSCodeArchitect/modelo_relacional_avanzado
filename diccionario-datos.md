# Diccionario de datos

| Tabla | Columna | Tipo | Nulo | Clave / dominio | Descripción |
|---|---|---|---|---|---|
| persona | persona_id | INTEGER | No | PK, identity | Identificador |
| persona | nombre | VARCHAR(120) | No | — | Nombre completo |
| persona | correo | VARCHAR(180) | No | UK | Correo |
| persona | pais | VARCHAR(80) | No | — | País |
| edicion | edicion_id | INTEGER | No | PK, identity | Identificador |
| edicion | nombre | VARCHAR(160) | No | — | Nombre |
| edicion | anio | SMALLINT | No | CHECK > 0 | Año |
| edicion | fecha_inicio | DATE | No | — | Inicio |
| edicion | fecha_fin | DATE | No | CHECK >= inicio | Fin |
| edicion | estado | estado_edicion | No | dominio | Estado |
| edicion | modalidad | modalidad_edicion | No | dominio | Modalidad |
| sede | sede_id | INTEGER | No | PK, identity | Identificador |
| sede | nombre | VARCHAR(140) | No | — | Nombre |
| sede | ciudad | VARCHAR(100) | No | — | Ciudad |
| sala | sala_id | INTEGER | No | PK, identity | Identificador |
| sala | sede_id | INTEGER | No | FK | Sede |
| sala | nombre | VARCHAR(100) | No | UK compuesta | Nombre |
| sala | capacidad | INTEGER | No | CHECK > 0 | Capacidad |
| participacion | participacion_id | INTEGER | No | PK, identity | Identificador |
| participacion | persona_id | INTEGER | No | FK, UK compuesta | Persona |
| participacion | edicion_id | INTEGER | No | FK, UK compuesta | Edición |
| asistente | participacion_id | INTEGER | No | PK/FK | Subtipo |
| asistente | tipo_acreditacion | tipo_acreditacion | No | dominio | Acreditación |
| ponente | participacion_id | INTEGER | No | PK/FK | Subtipo |
| ponente | biografia | TEXT | No | — | Biografía |
| sesion | sesion_id | INTEGER | No | PK, identity | Identificador |
| sesion | edicion_id | INTEGER | No | FK | Edición |
| sesion | sala_id | INTEGER | Sí | FK | Sala opcional |
| sesion | titulo | VARCHAR(200) | No | — | Título |
| sesion | resumen | TEXT | No | — | Resumen |
| sesion | fecha | DATE | No | — | Fecha |
| sesion | hora_inicio | TIME | No | — | Inicio |
| sesion | hora_fin | TIME | No | CHECK > inicio | Fin |
| sesion | tipo_sesion | tipo_sesion | No | discriminador | Charla/Taller |
| charla | sesion_id | INTEGER | No | PK/FK | Subtipo |
| charla | minutos_preguntas | INTEGER | No | CHECK >= 0 | Minutos |
| taller | sesion_id | INTEGER | No | PK/FK | Subtipo |
| taller | cupo_practico | INTEGER | No | CHECK > 0 | Cupo |
| taller | requisitos_materiales | TEXT | No | — | Materiales |
| transmision | sesion_id | INTEGER | No | PK/FK | Sesión |
| transmision | plataforma | VARCHAR(80) | No | — | Plataforma |
| transmision | url | VARCHAR(500) | No | — | URL |
| transmision | codigo_acceso | VARCHAR(120) | Sí | — | Código |
| inscripcion | participacion_id | INTEGER | No | PK/FK compuesta | Participación |
| inscripcion | sesion_id | INTEGER | No | PK/FK compuesta | Sesión |
| inscripcion | fecha_inscripcion | DATE | No | DEFAULT | Fecha |
| inscripcion | estado | estado_inscripcion | No | dominio | Estado |
| inscripcion | asistio | BOOLEAN | Sí | — | Asistencia |
| asignacion_ponente | participacion_id | INTEGER | No | PK/FK compuesta | Ponente |
| asignacion_ponente | sesion_id | INTEGER | No | PK/FK compuesta | Sesión |
| asignacion_ponente | rol | rol_ponente | No | dominio | Rol |
| asignacion_ponente | orden_programa | INTEGER | No | UK por sesión | Orden |
| empresa | empresa_id | INTEGER | No | PK, identity | Identificador |
| empresa | nombre | VARCHAR(160) | No | UK | Empresa |
| acuerdo_patrocinio | empresa_id | INTEGER | No | PK/FK compuesta | Empresa |
| acuerdo_patrocinio | edicion_id | INTEGER | No | PK/FK compuesta | Edición |
| acuerdo_patrocinio | categoria | categoria_patrocinio | No | dominio | Categoría |
| acuerdo_patrocinio | monto | NUMERIC(12,2) | No | CHECK > 0 | Monto |
| acuerdo_patrocinio | fecha_confirmacion | DATE | No | — | Confirmación |
| prerrequisito | sesion_id | INTEGER | No | PK/FK compuesta | Sesión objetivo |
| prerrequisito | sesion_previa_id | INTEGER | No | PK/FK compuesta | Sesión previa |

## Claves candidatas

- `persona.correo`
- `empresa.nombre`
- `(sala.sede_id, sala.nombre)`
- `(participacion.persona_id, participacion.edicion_id)`
- `(inscripcion.participacion_id, inscripcion.sesion_id)`
- `(asignacion_ponente.participacion_id, asignacion_ponente.sesion_id)`
- `(asignacion_ponente.sesion_id, asignacion_ponente.orden_programa)`
- `(acuerdo_patrocinio.empresa_id, acuerdo_patrocinio.edicion_id)`
- `(prerrequisito.sesion_id, prerrequisito.sesion_previa_id)`
