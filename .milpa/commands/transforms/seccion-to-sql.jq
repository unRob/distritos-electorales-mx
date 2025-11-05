# SPDX-License-Identifier: Apache-2.0
# Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>

.features |
  reduce .[] as $f ([];
    if $f.geometry.type == "Polygon" then
      . + [($f.properties + {_shape: (
        # districts like cancun's federal 4th have holes in them
        # get rid of them cause sqlite geopoly doesn't like them
        if ($f.geometry.coordinates | length) == 1 then
          $f.geometry.coordinates
        else
          $f.geometry.coordinates | first
        end
      )})]
    else
      # create multiple polygons from multipolygons
      . + (
        $f.geometry.coordinates | map($f.properties + {
          _shape: [(
            # districts like cancun's federal 4th have holes in them
            # get rid of them cause sqlite geopoly doesn't like them
            if ($f.geometry.coordinates | length) == 1 then
              .
            else
              . | first
            end
          )]
        })
      )
    end
  ) |
  map(
    "INSERT INTO
  seccion(id,entidad,distrito_federal,distrito_local,tipo,ine_id,_shape)
VALUES(
  \(.SECCION | round),
  \(.ENTIDAD | round),
  '\(.DISTRITO_F | round)',
  '\(.DISTRITO_L | round)',
  '\(.TIPO // 0)',
  '\(.ID | round)',
  '\(._shape | if length == 1 then (first | if length == 1 then first else . end) else . end)'
);")[]
