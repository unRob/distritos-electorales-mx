#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>

repo="$(dirname "$MILPA_COMMAND_REPO")"
root="$(cd "$repo/cache" && pwd)"
mkdir -p "$root"

archive="$root/mgs.7z"
if [[ ! -f "$archive" ]]; then
  @milpa.log info "Downloading Marco Geográfico Seccional"
  curl --fail --show-error 'https://storage.googleapis.com/mapoteca/MGS_CCL/SHAPEFILE.7z' \
    -H 'Accept-Encoding: gzip, deflate, br' \
    -o "$archive"  || @milpa.fail "Could not download MGS"
fi


if [[ ! -f "$root/DISTRITO_FEDERAL.shp" ]] || [[ ! -f "$root/DISTRITO_LOCAL.shp" ]]; then
  @milpa.log info "Extracting 7z archive"
  7za x -o"$root" "$archive" DISTRITO_FEDERAL.shp DISTRITO_LOCAL.shp
fi

function docker_ogr() {
  docker run --entrypoint ogr2ogr \
    --rm -it \
    -v "$root":/data ghcr.io/osgeo/gdal:alpine-small-latest \
    -t_srs crs:84 \
    "$@"
}

@milpa.log info "Converting shapefiles into wgs84 web mercator-projected geojson"

docker_ogr /data/federales.geojson /data/DISTRITO_FEDERAL.shp || @milpa.fail "Could not parse DISTRITO_FEDERAL.shp into geojson"
docker_ogr /data/locales.geojson /data/DISTRITO_LOCAL.shp || @milpa.fail "Could not parse DISTRITO_LOCAL.shp into geojson"

@milpa.log complete "Cache populated with wgs84 web mercator-projected geojson"
