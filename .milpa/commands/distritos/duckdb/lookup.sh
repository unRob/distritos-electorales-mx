#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>

repo="$(dirname "$MILPA_COMMAND_REPO")"

duckdb -json "$repo/distritos.duckdb" -c "INSTALL spatial;
LOAD spatial;

SELECT
  id,
  entidad,
  distrito_federal,
  distrito_local,
  tipo,
FROM
  seccion
WHERE
  ST_Contains(geom, ST_Point($MILPA_ARG_LONG, $MILPA_ARG_LAT));" | jq . || @milpa.fail "could not find districts for latitude $MILPA_ARG_LAT, longitude $MILPA_ARG_LONG"

