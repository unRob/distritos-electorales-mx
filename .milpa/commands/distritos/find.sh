#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>

repo="$(dirname "$MILPA_COMMAND_REPO")"
sqlite=$(command -v sqlite3)

if [[ -f /opt/homebrew/opt/sqlite/bin/sqlite3 ]]; then
  @milpa.log warning "using homebrew sqlite3, hoping it has geopoly enabled"
  sqlite="/opt/homebrew/opt/sqlite/bin/sqlite3"
fi

"$sqlite" "$repo/distritos.db" <<<"SELECT
  id,
  entidad,
  localidad,
  tipo
FROM
  distrito
WHERE
  geopoly_contains_point(_shape, $MILPA_ARG_LONG, $MILPA_ARG_LAT );" || @milpa.fail "could not find districts for latitude $MILPA_ARG_LAT, longitude $MILPA_ARG_LONG"
