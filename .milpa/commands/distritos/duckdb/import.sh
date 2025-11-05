#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>

repo="$(dirname "$MILPA_COMMAND_REPO")"
cache="$(cd "$repo/cache" && pwd)"

db="$repo/distritos.duckdb"
secciones="$cache/secciones.shp"

if [[ "$MILPA_OPT_OVERWRITE" ]]; then
  rm "$db" "$secciones"
else
  if [[ -f "$db" ]]; then
    @milpa.fail "A database already exists at $db, use --overwrite to replace"
  fi
fi

if [[ ! -f cache/secciones.shp ]]; then
  milpa itself project "cache/SECCION.shp" "cache/secciones.shp"
fi

@milpa.log info "Importing secciones to $db"
SECCIONES="$secciones" duckdb "$db" -c 'INSTALL spatial;
LOAD spatial;

CREATE TABLE
  seccion
AS
  SELECT
    SECCION id,
    ENTIDAD entidad,
    DISTRITO_F distrito_federal,
    DISTRITO_L distrito_local,
    TIPO tipo,
    ID ine_id,
    geom
  FROM
    ST_Read(getenv("secciones"));

CREATE INDEX geom_idx ON seccion USING RTREE (geom);'
