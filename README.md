# Distritos Electorales México

Este repositorio contiene código para descargar y procesar el [Marco Geográfico Seccional](https://cartografia.ine.mx/sige8/productosCartograficos/bases) del INE, convertirlo a GeoJSON e importar polígonos simples a SQLite para poder hacer queries point-in-polygon.

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

# crea una base de datos sqlite para hacer consultas point-in-polygon
milpa distritos import

# hace una búsqueda de distritos correspondientes a coordenadas WGS84
milpa distritos find -- 19.430160 -99.117937
# output de id, entidad, localidad y tipo
# 11|9|federal|6
# 10|9|local|0
```

### Desde el browser

https://unrob.github.io/distritos-electorales-mx: Un playground simple para probar la DB que generé en 2025-10-29. Obtiene la ubicación geográfica del dispositivo, carga la DB de 18Mb al browser, y usa SQLite compilado para WASM para buscar los distritos locales y federales correspondientes. Este playground usa SQLite compilado a WASM desde el navegador, y no guarda ni transmite la ubicación del dispositivo. Requiere un navegador que soporte [WASM](https://caniuse.com/wasm) y [GeoLocation API](https://caniuse.com/mdn-api_geolocation).

## Limitantes

La interfaz [geopoly](https://sqlite.org/geopoly.html) en SQLite trabaja únicamente con objetos de tipo [Polygon](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.6). El MGS contiene objetos de tipo `MultiPolygon` así como `Polygon` con "hoyos" (por ejemplo, el distrito federal 4to de Quintana Roo). Para poder asegurar compatibilidad con la interfaz de `geopoly`, he convertido los multipolygons en polígonos simples, para los cuales existirá *más de una fila por distrito*. En el caso de polígonos complejos, es decir, aquellos con "hoyos", la geometría es simplificada ignorando estos "hoyos".

