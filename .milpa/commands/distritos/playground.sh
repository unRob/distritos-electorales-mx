#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright © 2025 Roberto Hidalgo <distritos@un.rob.mx>

repo="$(dirname "$MILPA_COMMAND_REPO")"


@milpa.log info "Listening for requests at http://localhost:8000, press CTRL-C to stop"
cd "$repo/docs"
exec python -m http.server
