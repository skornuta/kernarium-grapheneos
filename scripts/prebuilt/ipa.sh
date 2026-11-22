#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
. "$(dirname "$0")/env.sh"

ipa=${1:-$DL/$IPA_NAME}
rel=$OUT/$DIRECTORY_NAME
[ -f "$ipa" ] || die "missing $ipa"
[ -f "$rel/guest/system.img" ] || die "run repack.sh first"

stage=$WORK/ipa
rm -rf "$stage"
mkdir -p "$stage"
unzip -q "$ipa" -d "$stage"
sys=$(find "$stage/Payload" -maxdepth 2 -type d -name andarium-system | head -1)
[ -n "$sys" ] || die "no andarium-system in $ipa"
for f in release-manifest.json boot/kernel-command-line.txt guest/partition-layout.json guest/system.img; do
    [ -f "$sys/$f" ] || die "IPA lacks andarium-system/$f"
    cp "$rel/$f" "$sys/$f"
done
out=$OUT/${IPA_NAME%.ipa}-kgos$KGOS_REV.ipa
rm -f "$out"
(cd "$stage" && zip -qr -X -y "$out" Payload)
rm -rf "$stage"
ls -l "$out"
log "ipa ok (re-sign when sideloading)"
