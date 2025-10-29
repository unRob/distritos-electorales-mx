-- SPDX-License-Identifier: Apache-2.0
-- Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>

CREATE VIRTUAL TABLE
  distrito
USING geopoly(
  id INTEGER NOT NULL, -- locales del 1-679, federales del 1-300
  entidad INTEGER NOT NULL, -- 1 al 32
  localidad TEXT NOT NULL, -- `local` o `federal` (porque npi de dónde salen los judiciales)
  tipo INTEGER, -- tbd qué significa esto, sé que van en los federales del 6 al 14, y los locales siempre son 0?
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
  ine_id INTEGER -- corresponde al id del shapefile convertido a geojson
);
