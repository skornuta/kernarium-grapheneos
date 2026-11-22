# SPDX-License-Identifier: GPL-2.0-or-later
# shellcheck shell=bash disable=SC2034

WORK=${WORK:-/work}
KGOS=${KGOS:-$WORK/kernarium-grapheneos}
KERNARIUM=${KERNARIUM:-$WORK/Kernarium}
SRC=${SRC:-$WORK/grapheneos}

KERNARIUM_URL=${KERNARIUM_URL:-https://github.com/imxieyi/Kernarium.git}
KERNARIUM_TAG=${KERNARIUM_TAG:-1.0b15-release}
GRAPHENE_MANIFEST=${GRAPHENE_MANIFEST:-https://github.com/GrapheneOS/platform_manifest.git}
GRAPHENE_REF=${GRAPHENE_REF:-17}

PRODUCT=${PRODUCT:-graphene_andarium}
RELEASE=${RELEASE:-cur}
VARIANT=${VARIANT:-userdebug}
JOBS=${JOBS:-$(nproc)}

L24=$KERNARIUM/android/lineage-24
PATCH_SERIES=$KERNARIUM/scripts/patch_series.py
LOGS=$WORK/logs

export GIT_AUTHOR_NAME=${GIT_AUTHOR_NAME:-kgos-builder}
export GIT_AUTHOR_EMAIL=${GIT_AUTHOR_EMAIL:-builder@localhost}
export GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME
export GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL

mkdir -p "$LOGS"

die() { printf 'error: %s\n' "$*" >&2; exit 1; }
log() { printf '==> %s\n' "$*"; }
