-- Las seis pruebas se capturan para que el script completo continue.
-- Cada prueba debe producir un NOTICE con el rechazo esperado.

-- 1. DUPLICADO: correo unico.
DO $$
BEGIN
    INSERT INTO persona (nombre, correo, pais)
    VALUES ('Duplicado', 'ana.lopez@example.com', 'Guatemala');
    RAISE EXCEPTION 'PRUEBA FALLIDA: el duplicado fue aceptado';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'OK 1 - Duplicado rechazado por UNIQUE: %', SQLERRM;
END $$;
-- 2. FK INEXISTENTE.
DO $$
BEGIN
    INSERT INTO sala (sede_id, nombre, capacidad)
    VALUES (999999, 'Sala Fantasma', 50);
    RAISE EXCEPTION 'PRUEBA FALLIDA: FK inexistente fue aceptada';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'OK 2 - FK inexistente rechazada: %', SQLERRM;
END $$;
-- 3. VALOR FUERA DE DOMINIO: capacidad negativa.
DO $$
BEGIN
    INSERT INTO sala (sede_id, nombre, capacidad)
    VALUES (1, 'Sala Invalida', -10);
    RAISE EXCEPTION 'PRUEBA FALLIDA: capacidad negativa fue aceptada';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'OK 3 - Valor fuera de dominio rechazado por CHECK: %', SQLERRM;
END $$;

-- 4. DATO OBLIGATORIO AUSENTE.
DO $$
BEGIN
    INSERT INTO persona (nombre, correo, pais)
    VALUES (NULL, 'sin.nombre@example.com', 'Guatemala');
    RAISE EXCEPTION 'PRUEBA FALLIDA: NULL obligatorio fue aceptado';
EXCEPTION
    WHEN not_null_violation THEN
        RAISE NOTICE 'OK 4 - Dato obligatorio rechazado por NOT NULL: %', SQLERRM;
END $$;

-- 5. AUTORRELACIoN INVALIDA.
DO $$
BEGIN
    INSERT INTO prerrequisito (sesion_id, sesion_previa_id)
    VALUES (1, 1);
    RAISE EXCEPTION 'PRUEBA FALLIDA: autorrelacion fue aceptada';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'OK 5 - Autorrelacion rechazada por CHECK: %', SQLERRM;
END $$;

-- 6. VIOLACIÓN ADICIONAL: horario superpuesto en la misma sala.
DO $$
BEGIN
    INSERT INTO sesion
    (edicion_id, sala_id, titulo, resumen, fecha, hora_inicio, hora_fin, tipo_sesion)
    VALUES
    (1, 1, 'Sesión superpuesta', 'Debe ser rechazada.', '2026-10-15',
     '09:30', '10:30', 'CHARLA');

    RAISE EXCEPTION 'PRUEBA FALLIDA: horario superpuesto fue aceptado';
EXCEPTION
    WHEN exclusion_violation THEN
        RAISE NOTICE 'OK 6 - Horario superpuesto rechazado por EXCLUDE: %', SQLERRM;
END $$;



-- 7. VIOLACIoN ADICIONAL: inscripcion de una sesion de otra edicion.
DO $$
BEGIN
    INSERT INTO inscripcion
    (participacion_id, sesion_id, estado)
    VALUES (1, 5, 'CONFIRMADA');

    RAISE EXCEPTION 'PRUEBA FALLIDA: inscripcion cruzada fue aceptada';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'OK 7 - Inscripcion entre ediciones distintas rechazada: %', SQLERRM;
END $$;
