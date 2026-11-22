#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
. "$(dirname "$0")/env.sh"

mkdir -p "$SRC/device/kernarium/graphene"
rsync -a --delete --exclude .gitkeep "$KGOS/device/kernarium/graphene/" "$SRC/device/kernarium/graphene/"
log "device tree synced to $SRC/device/kernarium/graphene"
