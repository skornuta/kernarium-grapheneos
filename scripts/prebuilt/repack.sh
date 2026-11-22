#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
. "$(dirname "$0")/env.sh"
need_root

hints=$KGOS/device/kernarium/graphene/config/erofs_compress_hints.txt
rm -f "$IMAGES"/*.img
for img in "$PARTS"/*.img; do
    name=$(basename "$img" .img)
    if [[ " $REBUILD_PARTITIONS " == *" $name "* ]]; then
        uuid=$("$EROFS/dump.erofs" -s "$img" | awk '/UUID/ {print $3}')
        log "mkfs.erofs $name"
        "$EROFS/mkfs.erofs" -z zstd,level=15 -C16384 --compress-hints="$hints" \
            -T 1230768000 -U "$uuid" --mount-point="/$name" \
            "$IMAGES/$name.img" "$TREE/$name" >/dev/null 2>"$WORK/mkfs-$name.log"
        "$EROFS/fsck.erofs" "$IMAGES/$name.img" >/dev/null
    else
        ln "$img" "$IMAGES/$name.img"
    fi
done

disk=$WORK/disk
rm -rf "$disk"
python3 -B "$L24_TOOLS/ubd-disk.py" assemble --policy "$KGOS/support/image/disk-policy.json" \
    --images-dir "$IMAGES" --output-dir "$disk"
python3 -B "$L24_TOOLS/ubd-disk.py" verify --layout "$disk/partition-layout.json" --disk "$disk/system.img" --hash \
    --policy "$KGOS/support/image/disk-policy.json"

rel=$OUT/$DIRECTORY_NAME
rm -rf "$rel"
cp -a "$BASE" "$rel"
cp "$disk/system.img" "$disk/partition-layout.json" "$rel/guest/"
python3 "$KGOS/tools/manifest.py" "$rel"

log "packing $DIRECTORY_NAME.tar.gz"
tar -C "$OUT" --owner=0 --group=0 -czf "$OUT/$DIRECTORY_NAME.tar.gz" "$DIRECTORY_NAME"
(cd "$OUT" && sha256sum "$DIRECTORY_NAME.tar.gz" > "$DIRECTORY_NAME.tar.gz.sha256")
cat "$OUT/$DIRECTORY_NAME.tar.gz.sha256"
log "repack ok"
