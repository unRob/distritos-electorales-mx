#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>

repo="$(dirname "$MILPA_COMMAND_REPO")"
cache="$(cd "$repo/cache" && pwd)"

sql="$cache/import.sql"
db="$repo/distritos.db"

if [[ "$MILPA_OPT_OVERWRITE" ]]; then
  rm "$sql" "$db"
fi

if [[ ! -f "$sql" ]]; then
  @milpa.log info "Converting geojson to sql"
  jq -r \
    --from-file geojson-to-csv.jq \
    "$cache/federales.geojson" \
    "$cache/locales.geojson" > "$sql" || @milpa.fail "Could not generate sql import"
fi

if [[ -f "$db" ]]; then
  @milpa.fail "sqlite file already present at $db, won't overwrite"
fi

"$(brew --prefix)/opt/sqlite/bin/sqlite3" "$db" <"$repo/schema.sql" || @milpa.fail "could not create db at $db"

"$(brew --prefix)/opt/sqlite/bin/sqlite3" "$db" <"$sql" || @milpa.fail "could not import districts to db at $db"

