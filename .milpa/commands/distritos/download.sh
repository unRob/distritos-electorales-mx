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
  7za x -o"$root" "$archive" DISTRITO_FEDERAL.shp DISTRITO_LOCAL.shp SECCION.shp
fi

@milpa.log complete "Downloaded and extracted files"
