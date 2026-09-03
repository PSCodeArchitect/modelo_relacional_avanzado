# S7 — Modelo Relacional Avanzado: Congreso ConectaTech

 Desarrollado para analizar la narrativa de ConectaTech, construir un modelo ER avanzado, transformarlo a PostgreSQL 18.6 y demostrar integridad mediante datos y pruebas invalidas.

## Requisitos

- Docker y Docker Compose.
- Git.
- PostgreSQL 18.6 mediante la imagen oficial `postgres:18.6`.
- No se usa ORM ni generacion automatica del esquema.

## Estructura

```text
s7-modelo-relacional-avanzado/
├── README.md
├── narrativa-y-reglas.md
├── diccionario-datos.md
├── compose.yaml
├── .env.example
├── .gitignore
├── modelo-conceptual.mmd
├── modelo-logico.mmd
└── sql/
    ├── 01_schema.sql
    ├── 02_seed.sql
    ├── 03_queries.sql
    └── 04_invalid_tests.sql
```

## 1. Preparar variables

Copiar `.env.example` como `.env`.

```bash
cp .env.example .env
```

No subir `.env` a Git.

## 2. Levantar PostgreSQL desde una base vacia

```bash
docker compose down -v
docker compose up -d
docker compose ps
```

El `-v` elimina el volumen para garantizar una base realmente vacia.

## 3. Crear el esquema

```bash
docker compose exec -T postgres psql -U conectatech -d conectatech < sql/01_schema.sql
```

## 4. Cargar los datos

```bash
docker compose exec -T postgres psql -U conectatech -d conectatech < sql/02_seed.sql
```

## 5. Ejecutar consultas

```bash
docker compose exec -T postgres psql -U conectatech -d conectatech < sql/03_queries.sql
```

## 6. Ejecutar pruebas inválidas

```bash
docker compose exec -T postgres psql -U conectatech -d conectatech < sql/04_invalid_tests.sql
```

Las pruebas invalidas están encerradas en bloques `DO` para que cada operación esperada falle, sea capturada y el script continue. La salida muestra la restriccion esperada.

## 7. Reiniciar completamente

```bash
docker compose down -v
docker compose up -d
docker compose exec -T postgres psql -U conectatech -d conectatech < sql/01_schema.sql
docker compose exec -T postgres psql -U conectatech -d conectatech < sql/02_seed.sql
```

## Decisiones principales

- `participacion` representa la pertenencia de una persona a una edición. Los subtipos `asistente` y `ponente` dependen de ella, permitiendo que una misma persona tenga ambos roles en una edicion.
- `sesion` usa una jerarquía disjunta y total mediante `tipo_sesion` más tablas `charla` y `taller`; un trigger comprueba que exista exactamente el subtipo indicado.
- `edicion` usa una jerarquía disjunta y total de modalidad (`presencial`, `virtual`, `hibrida`) con una columna discriminadora. Esta es una estrategia de tabla única para la jerarquía.
- `transmision.sesion_id` es simultáneamente PK y FK, garantizando máximo una transmisión por sesión.
- `inscripcion`, `asignacion_ponente`, `acuerdo_patrocinio` y `prerequisito` transforman relaciones N:M.
- La superposición de sesiones en una misma sala se evita con `EXCLUDE USING gist` y rangos `tsrange`.

