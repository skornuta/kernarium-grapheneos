# SPDX-License-Identifier: GPL-2.0-or-later
# shellcheck shell=bash disable=SC2034

KGOS=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
set -a
. "$KGOS/prebuilt/config.env"
set +a

WORK=${WORK:-$KGOS/.work}
DL=$WORK/dl
BASE=$WORK/base/$BASE_NAME
PARTS=$WORK/parts
TREE=$WORK/tree
IMAGES=$WORK/images
OUT=${OUT:-$WORK/out}
KERNARIUM=$WORK/kernarium
EROFS=${EROFS:-$WORK/erofs/bin}
L24_TOOLS=$KERNARIUM/android/lineage-24/tools

mkdir -p "$DL" "$PARTS" "$TREE" "$IMAGES" "$OUT"

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
log() { printf '==> %s\n' "$*"; }
need_root() { [ "$(id -u)" = 0 ] || die "run as root (sudo -E)"; }
sha_ok() { [ "$(sha256sum "$1" | cut -d' ' -f1)" = "$2" ] || die "sha256 mismatch: $1"; }
