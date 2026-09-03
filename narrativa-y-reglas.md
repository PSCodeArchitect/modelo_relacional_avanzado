# Narrativa, analisis y reglas de negocio

## 1. Hechos explilitos de la narrativa

La narrativa establece que:

- ConectaTech organiza congresos presenciales, virtuales e hibridos.
- Cada edicion tiene nombre, año, fechas y estado.
- Una edicion presencial o hibrida utiliza una sede con varias salas.
- Una sesin virtual puede no tener sala y necesita transmision.
- Una sala tiene nombre y capacidad.
- Una sala no puede alojar dos sesiones con horarios superpuestos.
- Las personas tienen nombre, correo y pais.
- En una edicin una persona puede ser asistente, ponente o ambos.
- El asistente tiene tipo de acreditacion.
- El ponente tiene biografia profesional.
- Toda persona inscrita en una edicion tiene al menos uno de esos roles.
- Las sesiones tienen titulo, resumen, fecha y horas.
- Toda sesion es exactamente charla o taller.
- Las charlas tienen minutos para preguntas.
- Los talleres tienen cupo practico y requisitos de materiales.
- Las sesiones pueden tener prerrequisitos.
- Una sesion no puede ser prerrequisito de si misma.
- Las inscripciones guardan fecha, estado y asistencia.
- Una inscripcion no puede repetirse para la misma persona/sesion.
- Una sesion puede tener varios ponentes.
- Una asignacion de ponente guarda rol y orden.
- Las empresas patrocinan ediciones mediante acuerdos.
- Un acuerdo guarda categoria, monto y fecha de confirmacion.
- Una empresa puede aparecer en varias ediciones, pero solo una vez por edicion.

## 2. Entidades

### Persona
Identifica a individuos que pueden participar en una o varias ediciones.

### Edicion
Representa una realizacion concreta del congreso en un año y periodo determinados.

### Sede
Lugar fisico que contiene salas.

### Sala
Espacio fisico dentro de una sede.

### Participacion
Entidad asociativa entre Persona y Edicion. Es necesaria porque los roles de asistente y ponente dependen de una edicion.

### Asistente
Subtipo de Participacion. Contiene el tipo de acreditacion.

### Ponente
Subtipo de Participación. Contiene la biografía profesional.

### Sesión
Actividad del programa de una edición.

### Charla
Subtipo de Sesión con minutos reservados para preguntas.

### Taller
Subtipo de Sesión con cupo práctico y requisitos de materiales.

### Transmisión
Información virtual asociada como máximo a una sesión.

### Inscripción
Asociativa entre Participación y Sesión.

### Asignación de ponente
Asociativa entre Participación de tipo ponente y Sesión.

### Empresa
Entidad patrocinadora.

### Acuerdo de patrocinio
Asociativa entre Empresa y Edición.

### Prerrequisito
Asociativa recursiva entre dos sesiones.

## 3. Dominios

- `estado_edicion`: PLANIFICADA, ABIERTA, EN_CURSO, FINALIZADA, CANCELADA.
- `modalidad_edicion`: PRESENCIAL, VIRTUAL, HIBRIDA.
- `tipo_sesion`: CHARLA, TALLER.
- `estado_inscripcion`: PREINSCRITA, CONFIRMADA, CANCELADA.
- `tipo_acreditacion`: GENERAL, ESTUDIANTE, PROFESIONAL, VIP.
- `categoria_patrocinio`: ORO, PLATA, BRONCE, INSTITUCIONAL.
- `rol_ponente`: PRINCIPAL, CO_PONENTE, MODERADOR.

## 4. Cardinalidades y opcionalidad

- Persona 1:N Participación. Una persona puede no haber participado todavía.
- Edición 1:N Participación. Una edición puede iniciar sin participantes.
- Participación 1:0..1 Asistente.
- Participación 1:0..1 Ponente.
- Por regla de negocio, Participación debe tener al menos uno de esos dos subtipos.
- Sede 1:N Sala.
- Edición 1:N Sesión.
- Sala 1:N Sesión, pero una sesión puede no tener sala.
- Sesión 1:0..1 Transmisión.
- Participación 1:N Inscripción y Sesión 1:N Inscripción.
- Participación 1:N AsignaciónPonente y Sesión 1:N AsignaciónPonente.
- Empresa 1:N Acuerdo y Edición 1:N Acuerdo.
- Sesión N:M Sesión mediante Prerrequisito.

## 5. Jerarquías

### Jerarquía solapada: Participación → Asistente/Ponente

Es **solapada** porque una misma participación puede ser ambos roles.

Es **parcial** en el sentido del supertipo: una participación puede existir inicialmente sin subtipo, aunque la regla de negocio de una inscripción completa exige al menos un rol. En la implementación se protege que no se cree una participación sin roles mediante un trigger diferido.

### Jerarquía disjunta: Sesión → Charla/Taller

Es **disjunta y total**: toda sesión debe ser exactamente una charla o un taller.

Se implementa con `tipo_sesion` como discriminador y tablas de subtipo, con trigger diferido que comprueba correspondencia exacta.

### Jerarquía adicional: Edición → Presencial/Virtual/Híbrida

Es **disjunta y total**: cada edición tiene exactamente una modalidad.

Se implementa con una columna discriminadora `modalidad`.

## 6. Supuestos y decisiones propias

1. El correo se trata como identificador alternativo único.
2. La capacidad de una sala debe ser positiva.
3. Las fechas y horas se almacenan sin zona horaria porque el congreso se modela en horario local de su sede.
4. Una sesión sin sala representa una sesión virtual.
5. Una sesión con sala puede además tener transmisión en una edición híbrida.
6. Una edición virtual no utiliza salas.
7. Una edición presencial no utiliza transmisiones.
8. En una edición híbrida se permite sala, transmisión o ambas.
9. El estado `asistio` puede ser NULL antes del evento.
10. Los prerrequisitos pertenecen a sesiones de la misma edición.
11. El orden de un ponente es único dentro de una sesión.
12. Un acuerdo de patrocinio es único por empresa y edición.
13. El monto de patrocinio debe ser positivo.
14. Una sesión no puede ser prerrequisito de sí misma.
15. Se evita la superposición de sesiones en una sala mediante una restricción de exclusión de PostgreSQL.

## 7. Reglas de negocio implementadas

1. Correo de persona único.
2. Nombre de empresa único.
3. Nombre de sala único dentro de una sede.
4. Año positivo.
5. Fecha final de edición no anterior a fecha inicial.
6. Capacidad de sala mayor que cero.
7. Hora final de sesión posterior a hora inicial.
8. Toda sesión tiene tipo válido.
9. Toda sesión tiene exactamente un subtipo.
10. Minutos de preguntas no negativos.
11. Cupo práctico positivo.
12. Toda participación tiene al menos un rol.
13. No se repite la participación Persona-Edición.
14. No se repite la inscripción Participación-Sesión.
15. No se repite la asignación Participación-Sesión.
16. No se repite el orden de ponentes en una sesión.
17. No se repite acuerdo Empresa-Edición.
18. Monto de patrocinio positivo.
19. Una sesión no puede prerrequisitarse a sí misma.
20. Una misma sala no puede tener sesiones superpuestas.
21. En sesiones virtuales sin sala debe existir transmisión.
22. Una edición virtual no puede usar una sala.
23. Una edición presencial no puede tener transmisión.
24. Los prerrequisitos deben pertenecer a la misma edición.
