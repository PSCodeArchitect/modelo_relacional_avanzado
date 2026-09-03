BEGIN;

CREATE EXTENSION IF NOT EXISTS btree_gist;

DROP TABLE IF EXISTS prerrequisito CASCADE;
DROP TABLE IF EXISTS acuerdo_patrocinio CASCADE;
DROP TABLE IF EXISTS empresa CASCADE;
DROP TABLE IF EXISTS asignacion_ponente CASCADE;
DROP TABLE IF EXISTS inscripcion CASCADE;
DROP TABLE IF EXISTS transmision CASCADE;
DROP TABLE IF EXISTS taller CASCADE;
DROP TABLE IF EXISTS charla CASCADE;
DROP TABLE IF EXISTS sesion CASCADE;
DROP TABLE IF EXISTS ponente CASCADE;
DROP TABLE IF EXISTS asistente CASCADE;
DROP TABLE IF EXISTS participacion CASCADE;
DROP TABLE IF EXISTS sala CASCADE;
DROP TABLE IF EXISTS sede CASCADE;
DROP TABLE IF EXISTS edicion CASCADE;
DROP TABLE IF EXISTS persona CASCADE;

DROP TYPE IF EXISTS estado_edicion CASCADE;
DROP TYPE IF EXISTS modalidad_edicion CASCADE;
DROP TYPE IF EXISTS tipo_sesion CASCADE;
DROP TYPE IF EXISTS tipo_acreditacion CASCADE;
DROP TYPE IF EXISTS estado_inscripcion CASCADE;
DROP TYPE IF EXISTS rol_ponente CASCADE;
DROP TYPE IF EXISTS categoria_patrocinio CASCADE;

CREATE TYPE estado_edicion AS ENUM
    ('PLANIFICADA', 'ABIERTA', 'EN_CURSO', 'FINALIZADA', 'CANCELADA');

CREATE TYPE modalidad_edicion AS ENUM
    ('PRESENCIAL', 'VIRTUAL', 'HIBRIDA');

CREATE TYPE tipo_sesion AS ENUM
    ('CHARLA', 'TALLER');

CREATE TYPE tipo_acreditacion AS ENUM
    ('GENERAL', 'ESTUDIANTE', 'PROFESIONAL', 'VIP');

CREATE TYPE estado_inscripcion AS ENUM
    ('PREINSCRITA', 'CONFIRMADA', 'CANCELADA');

CREATE TYPE rol_ponente AS ENUM
    ('PRINCIPAL', 'CO_PONENTE', 'MODERADOR');

CREATE TYPE categoria_patrocinio AS ENUM
    ('ORO', 'PLATA', 'BRONCE', 'INSTITUCIONAL');

CREATE TABLE persona (
    persona_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(180) NOT NULL,
    pais VARCHAR(80) NOT NULL,
    CONSTRAINT uq_persona_correo UNIQUE (correo),
    CONSTRAINT ck_persona_correo_no_vacio CHECK (length(trim(correo)) > 3),
    CONSTRAINT ck_persona_nombre_no_vacio CHECK (length(trim(nombre)) > 0)
);

CREATE TABLE edicion (
    edicion_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(160) NOT NULL,
    anio SMALLINT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado estado_edicion NOT NULL DEFAULT 'PLANIFICADA',
    modalidad modalidad_edicion NOT NULL,
    CONSTRAINT ck_edicion_anio CHECK (anio > 0),
    CONSTRAINT ck_edicion_fechas CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT uq_edicion_nombre_anio UNIQUE (nombre, anio)
);

CREATE TABLE sede (
    sede_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(140) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    CONSTRAINT uq_sede_nombre_ciudad UNIQUE (nombre, ciudad)
);

CREATE TABLE sala (
    sala_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sede_id INTEGER NOT NULL REFERENCES sede(sede_id),
    nombre VARCHAR(100) NOT NULL,
    capacidad INTEGER NOT NULL,
    CONSTRAINT uq_sala_sede_nombre UNIQUE (sede_id, nombre),
    CONSTRAINT ck_sala_capacidad CHECK (capacidad > 0)
);

CREATE TABLE participacion (
    participacion_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    persona_id INTEGER NOT NULL REFERENCES persona(persona_id),
    edicion_id INTEGER NOT NULL REFERENCES edicion(edicion_id),
    CONSTRAINT uq_participacion_persona_edicion UNIQUE (persona_id, edicion_id)
);

CREATE TABLE asistente (
    participacion_id INTEGER PRIMARY KEY
        REFERENCES participacion(participacion_id) ON DELETE CASCADE,
    tipo_acreditacion tipo_acreditacion NOT NULL
);

CREATE TABLE ponente (
    participacion_id INTEGER PRIMARY KEY
        REFERENCES participacion(participacion_id) ON DELETE CASCADE,
    biografia TEXT NOT NULL,
    CONSTRAINT ck_ponente_biografia_no_vacia CHECK (length(trim(biografia)) > 0)
);

CREATE TABLE sesion (
    sesion_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    edicion_id INTEGER NOT NULL REFERENCES edicion(edicion_id),
    sala_id INTEGER REFERENCES sala(sala_id),
    titulo VARCHAR(200) NOT NULL,
    resumen TEXT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    tipo_sesion tipo_sesion NOT NULL,
    horario tsrange GENERATED ALWAYS AS (
        tsrange(
            fecha::timestamp + hora_inicio,
            fecha::timestamp + hora_fin,
            '[)'
        )
    ) STORED,
    CONSTRAINT ck_sesion_horas CHECK (hora_fin > hora_inicio),
    CONSTRAINT ck_sesion_titulo_no_vacio CHECK (length(trim(titulo)) > 0)
);

ALTER TABLE sesion
    ADD CONSTRAINT ex_sala_horario_sin_superposicion
    EXCLUDE USING gist (
        sala_id WITH =,
        horario WITH &&
    );

CREATE TABLE charla (
    sesion_id INTEGER PRIMARY KEY
        REFERENCES sesion(sesion_id) ON DELETE CASCADE,
    minutos_preguntas INTEGER NOT NULL,
    CONSTRAINT ck_charla_minutos CHECK (minutos_preguntas >= 0)
);

CREATE TABLE taller (
    sesion_id INTEGER PRIMARY KEY
        REFERENCES sesion(sesion_id) ON DELETE CASCADE,
    cupo_practico INTEGER NOT NULL,
    requisitos_materiales TEXT NOT NULL,
    CONSTRAINT ck_taller_cupo CHECK (cupo_practico > 0),
    CONSTRAINT ck_taller_materiales CHECK (length(trim(requisitos_materiales)) > 0)
);

CREATE TABLE transmision (
    sesion_id INTEGER PRIMARY KEY
        REFERENCES sesion(sesion_id) ON DELETE CASCADE,
    plataforma VARCHAR(80) NOT NULL,
    url VARCHAR(500) NOT NULL,
    codigo_acceso VARCHAR(120),
    CONSTRAINT ck_transmision_url CHECK (length(trim(url)) > 0)
);

CREATE TABLE inscripcion (
    participacion_id INTEGER NOT NULL
        REFERENCES participacion(participacion_id) ON DELETE CASCADE,
    sesion_id INTEGER NOT NULL
        REFERENCES sesion(sesion_id) ON DELETE CASCADE,
    fecha_inscripcion DATE NOT NULL DEFAULT CURRENT_DATE,
    estado estado_inscripcion NOT NULL DEFAULT 'PREINSCRITA',
    asistio BOOLEAN,
    PRIMARY KEY (participacion_id, sesion_id)
);

CREATE TABLE asignacion_ponente (
    participacion_id INTEGER NOT NULL
        REFERENCES ponente(participacion_id) ON DELETE CASCADE,
    sesion_id INTEGER NOT NULL
        REFERENCES sesion(sesion_id) ON DELETE CASCADE,
    rol rol_ponente NOT NULL,
    orden_programa INTEGER NOT NULL,
    PRIMARY KEY (participacion_id, sesion_id),
    CONSTRAINT uq_asignacion_orden UNIQUE (sesion_id, orden_programa),
    CONSTRAINT ck_asignacion_orden CHECK (orden_programa > 0)
);

CREATE TABLE empresa (
    empresa_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(160) NOT NULL,
    CONSTRAINT uq_empresa_nombre UNIQUE (nombre)
);

CREATE TABLE acuerdo_patrocinio (
    empresa_id INTEGER NOT NULL REFERENCES empresa(empresa_id),
    edicion_id INTEGER NOT NULL REFERENCES edicion(edicion_id),
    categoria categoria_patrocinio NOT NULL,
    monto NUMERIC(12,2) NOT NULL,
    fecha_confirmacion DATE NOT NULL,
    PRIMARY KEY (empresa_id, edicion_id),
    CONSTRAINT ck_acuerdo_monto CHECK (monto > 0)
);

CREATE TABLE prerrequisito (
    sesion_id INTEGER NOT NULL REFERENCES sesion(sesion_id) ON DELETE CASCADE,
    sesion_previa_id INTEGER NOT NULL REFERENCES sesion(sesion_id) ON DELETE CASCADE,
    PRIMARY KEY (sesion_id, sesion_previa_id),
    CONSTRAINT ck_prerrequisito_no_autoreferencia
        CHECK (sesion_id <> sesion_previa_id)
);

-- Validaciones transversales de jerarquías y reglas que requieren consultar otras tablas.

CREATE OR REPLACE FUNCTION fn_validar_participacion_roles()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
BEGIN
    v_id := COALESCE(NEW.participacion_id, OLD.participacion_id);
    IF NOT EXISTS (SELECT 1 FROM asistente WHERE participacion_id = v_id)
       AND NOT EXISTS (SELECT 1 FROM ponente WHERE participacion_id = v_id) THEN
        RAISE EXCEPTION USING
            ERRCODE = '23514',
            MESSAGE = format('La participación %s debe tener al menos un rol', v_id),
            CONSTRAINT = 'ck_participacion_al_menos_un_rol';
    END IF;
    RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER ct_participacion_al_menos_un_rol_asistente
AFTER INSERT OR UPDATE OR DELETE ON asistente
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION fn_validar_participacion_roles();

CREATE CONSTRAINT TRIGGER ct_participacion_al_menos_un_rol_ponente
AFTER INSERT OR UPDATE OR DELETE ON ponente
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION fn_validar_participacion_roles();

CREATE OR REPLACE FUNCTION fn_validar_subtipo_sesion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_tipo tipo_sesion;
    v_es_charla BOOLEAN;
    v_es_taller BOOLEAN;
BEGIN
    v_id := COALESCE(NEW.sesion_id, OLD.sesion_id);
    SELECT tipo_sesion INTO v_tipo FROM sesion WHERE sesion_id = v_id;

    SELECT EXISTS (SELECT 1 FROM charla WHERE sesion_id = v_id) INTO v_es_charla;
    SELECT EXISTS (SELECT 1 FROM taller WHERE sesion_id = v_id) INTO v_es_taller;

    IF v_tipo = 'CHARLA' AND (NOT v_es_charla OR v_es_taller) THEN
        RAISE EXCEPTION USING ERRCODE = '23514',
            MESSAGE = format('La sesión %s debe ser exactamente una CHARLA', v_id),
            CONSTRAINT = 'ck_sesion_subtipo_total_disjunto';
    ELSIF v_tipo = 'TALLER' AND (NOT v_es_taller OR v_es_charla) THEN
        RAISE EXCEPTION USING ERRCODE = '23514',
            MESSAGE = format('La sesión %s debe ser exactamente un TALLER', v_id),
            CONSTRAINT = 'ck_sesion_subtipo_total_disjunto';
    END IF;
    RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER ct_sesion_subtipo_charla
AFTER INSERT OR UPDATE OR DELETE ON charla
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION fn_validar_subtipo_sesion();

CREATE CONSTRAINT TRIGGER ct_sesion_subtipo_taller
AFTER INSERT OR UPDATE OR DELETE ON taller
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION fn_validar_subtipo_sesion();

CREATE OR REPLACE FUNCTION fn_validar_sesion_contexto()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_modalidad modalidad_edicion;
    v_tiene_sala BOOLEAN;
    v_tiene_transmision BOOLEAN;
BEGIN
    SELECT modalidad INTO v_modalidad
    FROM edicion
    WHERE edicion_id = NEW.edicion_id;

    v_tiene_sala := NEW.sala_id IS NOT NULL;
    SELECT EXISTS (
        SELECT 1 FROM transmision WHERE sesion_id = NEW.sesion_id
    ) INTO v_tiene_transmision;

    IF v_modalidad = 'VIRTUAL' AND v_tiene_sala THEN
        RAISE EXCEPTION USING ERRCODE = '23514',
            MESSAGE = 'Una sesión de una edición VIRTUAL no puede tener sala',
            CONSTRAINT = 'ck_modalidad_virtual_sin_sala';
    END IF;

    IF v_modalidad = 'PRESENCIAL' AND v_tiene_transmision THEN
        RAISE EXCEPTION USING ERRCODE = '23514',
            MESSAGE = 'Una sesión de una edición PRESENCIAL no puede tener transmisión',
            CONSTRAINT = 'ck_modalidad_presencial_sin_transmision';
    END IF;

    IF NOT v_tiene_sala AND NOT v_tiene_transmision THEN
        RAISE EXCEPTION USING ERRCODE = '23514',
            MESSAGE = 'Una sesión sin sala necesita transmisión',
            CONSTRAINT = 'ck_sesion_virtual_con_transmision';
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION fn_validar_sesion_contexto_transmision()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_modalidad modalidad_edicion;
    v_sala INTEGER;
BEGIN
    SELECT e.modalidad, s.sala_id
      INTO v_modalidad, v_sala
      FROM sesion s
      JOIN edicion e ON e.edicion_id = s.edicion_id
     WHERE s.sesion_id = NEW.sesion_id;

    IF v_modalidad = 'PRESENCIAL' THEN
        RAISE EXCEPTION USING ERRCODE = '23514',
            MESSAGE = 'Una edición PRESENCIAL no admite transmisión',
            CONSTRAINT = 'ck_modalidad_presencial_sin_transmision';
    END IF;

    RETURN NEW;
END;
$$;

CREATE CONSTRAINT TRIGGER ct_sesion_contexto
AFTER INSERT OR UPDATE ON sesion
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION fn_validar_sesion_contexto();

CREATE CONSTRAINT TRIGGER ct_transmision_contexto
AFTER INSERT OR UPDATE ON transmision
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION fn_validar_sesion_contexto_transmision();

CREATE OR REPLACE FUNCTION fn_validar_inscripcion_misma_edicion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    p_edicion INTEGER;
    s_edicion INTEGER;
BEGIN
    SELECT edicion_id INTO p_edicion
    FROM participacion WHERE participacion_id = NEW.participacion_id;

    SELECT edicion_id INTO s_edicion
    FROM sesion WHERE sesion_id = NEW.sesion_id;

    IF p_edicion <> s_edicion THEN
        RAISE EXCEPTION USING ERRCODE = '23514',
            MESSAGE = 'La inscripción debe unir una participación y una sesión de la misma edición',
            CONSTRAINT = 'ck_inscripcion_misma_edicion';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER tr_inscripcion_misma_edicion
BEFORE INSERT OR UPDATE ON inscripcion
FOR EACH ROW EXECUTE FUNCTION fn_validar_inscripcion_misma_edicion();

CREATE OR REPLACE FUNCTION fn_validar_asignacion_ponente()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    p_edicion INTEGER;
    s_edicion INTEGER;
BEGIN
    SELECT p.edicion_id INTO p_edicion
    FROM participacion p
    WHERE p.participacion_id = NEW.participacion_id;

    SELECT s.edicion_id INTO s_edicion
    FROM sesion s
    WHERE s.sesion_id = NEW.sesion_id;

    IF p_edicion <> s_edicion THEN
        RAISE EXCEPTION USING ERRCODE = '23514',
            MESSAGE = 'La asignación de ponente debe corresponder a la misma edición',
            CONSTRAINT = 'ck_asignacion_misma_edicion';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER tr_asignacion_ponente_misma_edicion
BEFORE INSERT OR UPDATE ON asignacion_ponente
FOR EACH ROW EXECUTE FUNCTION fn_validar_asignacion_ponente();

CREATE OR REPLACE FUNCTION fn_validar_prerrequisito_misma_edicion()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    e1 INTEGER;
    e2 INTEGER;
BEGIN
    SELECT edicion_id INTO e1 FROM sesion WHERE sesion_id = NEW.sesion_id;
    SELECT edicion_id INTO e2 FROM sesion WHERE sesion_id = NEW.sesion_previa_id;

    IF e1 <> e2 THEN
        RAISE EXCEPTION USING ERRCODE = '23514',
            MESSAGE = 'Un prerrequisito debe pertenecer a la misma edición',
            CONSTRAINT = 'ck_prerrequisito_misma_edicion';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER tr_prerrequisito_misma_edicion
BEFORE INSERT OR UPDATE ON prerrequisito
FOR EACH ROW EXECUTE FUNCTION fn_validar_prerrequisito_misma_edicion();

COMMIT;
