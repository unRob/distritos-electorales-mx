#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>

@milpa.log info "Converting $MILPA_ARG_INPUT to $MILPA_ARG_OUTPUT"

ogr2ogr \
  -t_srs crs:84 \
  "$MILPA_ARG_OUTPUT" "$MILPA_ARG_INPUT" || @milpa.fail "Could not convert $MILPA_ARG_INPUT"

@milpa.log complete "WGS84 web mercator-projected file stored at $MILPA_ARG_OUTPUT"
