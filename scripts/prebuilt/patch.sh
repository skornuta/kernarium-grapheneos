#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
. "$(dirname "$0")/env.sh"
need_root

P=$KGOS/prebuilt
CTX=u:object_r:system_file:s0

install_file() {
    install -D -m 0644 -o 0 -g 0 "$1" "$2"
    setfattr -n security.selinux -v "$CTX" "$2"
}
label_dirs() {
    find "$1" -type d -exec chown 0:0 {} + -exec chmod 0755 {} + -exec setfattr -n security.selinux -v "$CTX" {} +
}

log "props (JIT $KGOS_JIT)"
props=$TREE/product/etc/build.prop
sed -i '/^# kgos-begin$/,/^# kgos-end$/d' "$props"
{
    echo '# kgos-begin'
    cat "$P/props/aot.prop" "$P/props/ui.prop"
    [ "$KGOS_JIT" = on ] || cat "$P/props/nojit.prop"
    echo '# kgos-end'
} >> "$props"

log "animation defaults"
python3 - "$TREE/system_ext/bin/kernarium_keyboard_default.sh" "$P/ui-defaults.sh" <<'PY'
import sys
path, snippet = sys.argv[1], open(sys.argv[2]).read()
s = open(path).read()
anchor = '[ "$(getprop $marker)" = 1 ] && exit 0\n'
if 'kgos_ui_defaults' not in s:
    assert s.count(anchor) == 1, 'anchor not found'
    s = s.replace(anchor, snippet + anchor)
    with open(path, 'r+') as f:
        f.seek(0); f.write(s); f.truncate()
PY

log "debloat"
while read -r rel; do
    case $rel in ''|'#'*) continue ;; esac
    rm -rf "${TREE:?}/$rel"
    echo "  removed $rel"
done < "$P/debloat.txt"

log "microG"
gms=$TREE/product/priv-app/GmsCore
vending=$TREE/product/priv-app/Phonesky
rm -rf "$gms" "$vending"
install_file "$DL/$MICROG_GMS" "$gms/GmsCore.apk"
install_file "$DL/$MICROG_VENDING" "$vending/Phonesky.apk"
tmp=$(mktemp -d)
unzip -q -o "$DL/$MICROG_GMS" 'lib/arm64-v8a/*' 'lib/armeabi-v7a/*' -d "$tmp"
for pair in arm64-v8a:arm64 armeabi-v7a:arm; do
    for so in "$tmp/lib/${pair%%:*}"/*.so; do
        install_file "$so" "$gms/lib/${pair##*:}/$(basename "$so")"
    done
done
rm -rf "$tmp"
label_dirs "$gms"
label_dirs "$vending"
python3 "$KGOS/tools/microg.py" --ref "$WORK/ref" --cert-sha256 "$MICROG_CERT_SHA256" \
    --privapp-xml "$WORK/privapp-permissions-microg.xml" "$gms/GmsCore.apk" "$vending/Phonesky.apk"
install_file "$WORK/privapp-permissions-microg.xml" "$TREE/product/etc/permissions/privapp-permissions-microg.xml"
install_file "$P/microg/sysconfig-microg.xml" "$TREE/product/etc/sysconfig/microg.xml"
log "patch ok"
