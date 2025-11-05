#!/usr/bin/env bash

repo="$(dirname "$MILPA_COMMAND_REPO")"
cd "$repo" || @milpa.fail "Could not cd into $repo"

milpa itself project cache/federales.geojson cache/DISTRITO_FEDERAL.shp || @milpa.fail "Could not convert DISTRITO_FEDERAL.shp into geojson"
milpa itself project cache/locales.geojson cache/DISTRITO_LOCAL.shp || @milpa.fail "Could not convert DISTRITO_LOCAL.shp into geojson"
# docker_ogr /data/secciones.shp /data/SECCION.shp || @milpa.fail "Could not parse SECCION.shp into geojson"

cache="$(cd "$repo/cache" && pwd)"

sql="$cache/import.sql"
db="$repo/distritos.db"

if [[ "$MILPA_OPT_OVERWRITE" ]]; then
  rm "$sql" "$db"
fi

if [[ ! -f "$sql" ]]; then
  @milpa.log info "Converting geojson to sql"
  jq -r \
    --from-file "$MILPA_COMMAND_REPO/transforms/distrito-to-sql.jq" \
    "$cache/federales.geojson" \
    "$cache/locales.geojson" > "$sql" || @milpa.fail "Could not generate sql import"
fi

if [[ -f "$db" ]]; then
  @milpa.fail "sqlite file already present at $db, won't overwrite"
fi

"$(brew --prefix)/opt/sqlite/bin/sqlite3" "$db" <"$MILPA_COMMAND_REPO/schema/sqlite.sql" || @milpa.fail "could not create db at $db"

"$(brew --prefix)/opt/sqlite/bin/sqlite3" "$db" <"$sql" || @milpa.fail "could not import districts to db at $db"

