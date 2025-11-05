-- SPDX-License-Identifier: Apache-2.0
-- Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>

CREATE VIRTUAL TABLE IF NOT EXISTS
  distrito
USING geopoly(
  -- federales 1-40, locales 1-45
  id INTEGER NOT NULL,
  -- 1- 32
  entidad INTEGER NOT NULL,
  -- `local` o `federal` (porque npi de dónde salen los judiciales)
  localidad TEXT NOT NULL,
  -- tbd qué significa esto, sé que van en los federales del 6 al 14, y los locales siempre son 0?
  tipo INTEGER,
  -- stats:
  -- tipo count
  -- 6 20
  -- 7 47
  -- 8 88
  -- 9 21
  -- 10 44
  -- 11 22
  -- 12 35
  -- 13 14
  -- 14 9

  -- corresponde al id del shapefile convertido a geojson
  -- locales del 1-679, federales del 1-300
  ine_id INTEGER NOT NULL UNIQUE
);


CREATE VIRTUAL TABLE IF NOT EXISTS
  seccion
USING geopoly(
  id INTEGER NOT NULL,
  entidad INTEGER NOT NULL,
  distrito_federal INTEGER NOT NULL,
  distrito_local INTEGER NOT NULL,
  tipo INTEGER,
  ine_id INTEGER NOT NULL UNIQUE
);
