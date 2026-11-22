#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
. "$(dirname "$0")/env.sh"

mkdir -p "$SRC"
cd "$SRC"

log "repo init GrapheneOS $GRAPHENE_REF"
repo init -u "$GRAPHENE_MANIFEST" -b "$GRAPHENE_REF" \
    --git-lfs --partial-clone --clone-filter=blob:none --no-clone-bundle

log "repo sync (-j$JOBS)"
for attempt in 1 2 3; do
    repo sync -c -j"$JOBS" --force-sync --no-tags && break
    [ "$attempt" = 3 ] && die "repo sync failed 3 times"
    log "retrying sync ($attempt)"
done
repo forall -j"$JOBS" -c '[ ! -f .lfsconfig ] || { git lfs install --local >/dev/null && git lfs checkout >/dev/null; }'
repo manifest -r -o "$LOGS/resolved-manifest.xml"

. "$L24/third_party/mesa-venus/metadata.env"
mesa="$SRC/$MESA_VENUS_DESTINATION"
if [ ! -d "$mesa/.git" ]; then
    log "materializing Mesa Venus $MESA_VENUS_UPSTREAM_RELEASE"
    stage=$(mktemp -d "$(dirname "$mesa")/.mesa.XXXXXX")
    git -C "$stage" init -q
    git -C "$stage" remote add origin "$MESA_VENUS_UPSTREAM_REPOSITORY"
    git -C "$stage" fetch -q --no-tags --depth=1 origin "$MESA_VENUS_UPSTREAM_COMMIT"
    git -C "$stage" switch -q --create "$MESA_VENUS_PATCH_BRANCH" "$MESA_VENUS_UPSTREAM_COMMIT"
    [ "$(git -C "$stage" rev-parse 'HEAD^{tree}')" = "$MESA_VENUS_UPSTREAM_TREE" ] || die "mesa upstream tree mismatch"
    python3 -B "$PATCH_SERIES" apply --repo "$stage" \
        --series-dir "$KERNARIUM/$MESA_VENUS_GUEST_SERIES" --expect-tree "$MESA_VENUS_GUEST_TREE" >/dev/null
    python3 -B "$PATCH_SERIES" apply --repo "$stage" \
        --series-dir "$L24/third_party/mesa-venus/series" --expect-tree "$MESA_VENUS_FINAL_TREE" >/dev/null
    mv "$stage" "$mesa"
fi

"$KGOS/scripts/link-device.sh"
log "sync done: $(du -sh "$SRC" 2>/dev/null | cut -f1)"
