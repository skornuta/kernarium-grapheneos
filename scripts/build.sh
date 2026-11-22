#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -eo pipefail
. "$(dirname "$0")/env.sh"

"$KGOS/scripts/link-device.sh"
cd "$SRC"
export USE_CCACHE=1 CCACHE_EXEC=/usr/bin/ccache
set +u
. build/envsetup.sh
lunch "$PRODUCT-$RELEASE-$VARIANT"
set -u

targets=${TARGETS:-target-files-package}
log "m $targets (-j$JOBS)"
m -j"$JOBS" $targets 2>&1 | tee "$LOGS/build-$(date +%Y%m%d-%H%M%S).log"
ls -lh "$OUT"/*.img 2>/dev/null || true
