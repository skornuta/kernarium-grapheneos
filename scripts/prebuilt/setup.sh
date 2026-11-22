#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
. "$(dirname "$0")/env.sh"

if [ "${SKIP_APT:-0}" != 1 ]; then
    SUDO=; [ "$(id -u)" = 0 ] || SUDO=sudo
    $SUDO apt-get update -qq
    $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        autoconf automake libtool pkg-config build-essential uuid-dev zlib1g-dev \
        liblz4-dev libzstd-dev attr libcap2-bin python3-venv unzip zip curl git
fi
[ -x "$PY" ] || python3 -m venv "$WORK/venv"
"$PY" -c 'import androguard' 2>/dev/null || "$PY" -m pip install -q --disable-pip-version-check androguard==4.1.2

if [ ! -x "$EROFS/mkfs.erofs" ]; then
    log "building erofs-utils $EROFS_UTILS_TAG"
    src=$WORK/erofs-utils
    [ -d "$src" ] || git clone -q --depth 1 --branch "$EROFS_UTILS_TAG" https://github.com/erofs/erofs-utils.git "$src"
    git -C "$src" apply "$KGOS/prebuilt/patches/erofs-utils-fsck-xattrs-after-chown.patch"
    (cd "$src" && ./autogen.sh >/dev/null && ./configure -q --enable-lz4 --with-libzstd --prefix="$WORK/erofs" >/dev/null \
        && make -s -j"$(nproc)" >/dev/null && make -s install >/dev/null)
fi
"$EROFS/mkfs.erofs" --help 2>&1 | grep -q zstd || die "mkfs.erofs lacks zstd"

if [ ! -f "$L24_TOOLS/ubd-disk.py" ]; then
    log "fetching Kernarium $KERNARIUM_TAG tools"
    git clone -q --depth 1 --branch "$KERNARIUM_TAG" --filter=blob:none --sparse \
        https://github.com/imxieyi/Kernarium.git "$KERNARIUM"
    git -C "$KERNARIUM" sparse-checkout set android/lineage-24/tools android/lineage-24/support
fi
log "setup ok"
