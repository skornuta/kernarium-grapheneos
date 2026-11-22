#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
. "$(dirname "$0")/env.sh"

get() {
    local url=$1 dest=$2 sha=${3:-}
    if [ ! -f "$dest" ]; then
        log "downloading $(basename "$dest")"
        curl -fsSL --retry 3 -o "$dest.part" "$url"
        mv "$dest.part" "$dest"
    fi
    [ -z "$sha" ] || sha_ok "$dest" "$sha"
}

get "$BASE_URL/$BASE_NAME.tar.gz" "$DL/$BASE_NAME.tar.gz" "$BASE_SHA256"
get "$MICROG_URL/$MICROG_GMS" "$DL/$MICROG_GMS" "$MICROG_GMS_SHA256"
get "$MICROG_URL/$MICROG_VENDING" "$DL/$MICROG_VENDING" "$MICROG_VENDING_SHA256"
[ "${WITH_IPA:-0}" != 1 ] || get "$BASE_URL/$IPA_NAME" "$DL/$IPA_NAME"
log "fetch ok"
