# Distritos Electorales México

Este repositorio contiene código para descargar y procesar el [Marco Geográfico Seccional](https://cartografia.ine.mx/sige8/productosCartograficos/bases) del INE, procesarlo e importar tablas de distritos y secciones a SQLite o DuckDB para poder hacer queries point-in-polygon.

## Uso


```sh
curl -L https://milpa.dev/install.sh | bash -
git clone https://git.rob.mx/roberto/distritos-electorales-mx.git
cd distritos-electorales-mx

# instala dependencias usando homebrew
brew bundle --file=./Brewfile

# descarga los distritos federales y locales
# extrae shapefiles comprimidos y los convierte a geojson
milpa distritos download
```

### SQLite

[SQLite](https://sqlite.org/) es una de las bases de datos más instaladas y usadas del mundo. Usamos la extensión [geopoly](https://www.sqlite.org/geopoly.html) y convertimos las geometrías de los **distritos locales y federales** del INE en polígonos simples para poder realizar consultas point-in-polygon:

```sql
SELECT
  -- int: federales del 1-40, locales del 1-45
  id,
  -- int: 1-32
  entidad,
  -- string: 'federal' o 'local'
  localidad,
  -- int: ni idea todavía, 6-14 para federales, 0 para locales
  tipo,
  -- resulta en un string con las coordenadas de un {type: Polygon}: [[lat,lng]...]
  -- geopoly_json(_shape) as geometry
FROM
  distrito
WHERE
  geopoly_contains_point(_shape, $LONGITUDE, $LATITUDE);
```

La extensión [geopoly](https://sqlite.org/geopoly.html) en SQLite trabaja únicamente con objetos de tipo [Polygon](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.6). El MGS contiene objetos de tipo `MultiPolygon` así como `Polygon` con "hoyos" (por ejemplo, el distrito federal 4to de Quintana Roo). Para poder asegurar compatibilidad con la interfaz de `geopoly`, he convertido los multipolygons en polígonos simples, para los cuales existirá *más de una fila por distrito*. En el caso de polígonos complejos, es decir, aquellos con "hoyos", la geometría es simplificada ignorando estos "hoyos".


```sh
# crea una base de datos sqlite para hacer consultas point-in-polygon
milpa distritos sqlite import

# hace una búsqueda de distritos correspondientes a coordenadas WGS84
milpa distritos sqlite lookup -- 19.430160 -99.117937
# [
#   {
#     "id": 11,
#     "entidad": 9,
#     "localidad": "federal",
#     "tipo": "6"
#   },
#   {
#     "id": 10,
#     "entidad": 9,
#     "localidad": "local",
#     "tipo": "0"
#   }
# ]
```


### DuckDB

[DuckDB](https://duckdb.org) es un DBMS más moderno que SQLite. Usamos la extensión [spatial](https://duckdb.org/docs/stable/core_extensions/spatial/overview) e ingestamos las geometrías de las **secciones electorales** del INE (convertidas a WGS84) para realizar consultas point-in-polygon.

```sql
INSTALL spatial;
LOAD spatial;

SELECT
  -- int: 1-7024
  id,
  -- int: 1-32
  entidad,
  -- int: 1-40
  distrito_federal,
  -- int: 1-45
  distrito_local,
  -- int: 2-4
  tipo,
  -- string: {type: (Polygon|MultiPolygon), coordinates: [[lat,lng]...]}
  -- ST_AsGeoJSON(geom) geom
FROM
  seccion
WHERE
  ST_Contains(geom, ST_Point($LONGITUDE, $LATITUDE));
```

```sh
# crea una base de datos DuckDB para hacer consultas point-in-polygon
milpa distritos duckdb import

# hace una búsqueda de secciones correspondientes a coordenadas WGS84
milpa distritos duckdb lookup -- 19.430160 -99.117937
# [
#   {
#     "id": 5342,
#     "entidad": 9,
#     "distrito_federal": 11,
#     "distrito_local": 10,
#     "tipo": 2
#   }
# ]
```

### Desde el browser

[https://unrob.github.io/distritos-electorales-mx](https://unrob.github.io/distritos-electorales-mx): Una demostración técnica que usa DBs que generé en 2025-11-04. Requiere un navegador que soporte [WASM](https://caniuse.com/wasm) y [GeoLocation API](https://caniuse.com/mdn-api_geolocation).

Funciona obtieniendo la ubicación geográfica del dispositivo, y consultando localmente la DB de (18Mb sqlite, 183Mb duckdb). Usa SQLite o DuckDB compilados para WASM y el [WMS del INEGI](https://gaia.inegi.org.mx/geoserver/web/?0) para mostrar en un mapa distritos locales, federales, y/o secciones correspondientes. Esta demostración técnica usa motores de bases de datos compilados a WASM y no guarda ni transmite la ubicación del dispositivo.
