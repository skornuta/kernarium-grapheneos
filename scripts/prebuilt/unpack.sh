#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
. "$(dirname "$0")/env.sh"

need_root
if [ ! -f "$BASE/release-manifest.json" ]; then
    log "extracting $BASE_NAME"
    mkdir -p "$WORK/base"
    tar -xzf "$DL/$BASE_NAME.tar.gz" -C "$WORK/base"
fi

python3 "$KGOS/tools/split-disk.py" "$BASE/guest/partition-layout.json" "$BASE/guest/system.img" "$PARTS"

for p in $REBUILD_PARTITIONS; do
    rm -rf "${TREE:?}/$p"
    mkdir -p "$TREE/$p"
    log "extracting $p"
    "$EROFS/fsck.erofs" --extract="$TREE/$p" --xattrs --preserve --force "$PARTS/$p.img" >/dev/null
done

mkdir -p "$WORK/ref"
for f in framework/framework-res.apk framework/org.lineageos.platform-res.apk framework/services.jar; do
    "$EROFS/dump.erofs" --path="/system/$f" --cat "$PARTS/system.img" > "$WORK/ref/$(basename "$f")"
done
log "unpack ok"
