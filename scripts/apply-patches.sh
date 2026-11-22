#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
. "$(dirname "$0")/env.sh"

skip=$(grep -v '^#' "$KGOS/patches/skip.txt" | awk '{print $1}')
report="$LOGS/patch-report.tsv"
printf 'route\tpath\tstatus\tdetail\n' > "$report"
failed=0

while IFS=$'\t' read -r route path series_dir; do
    if grep -qx "$route" <<<"$skip"; then
        printf '%s\t%s\tskipped\t\n' "$route" "$path" >> "$report"; continue
    fi
    repo_dir="$SRC/$path"
    if [ ! -d "$repo_dir/.git" ] && [ ! -f "$repo_dir/.git" ]; then
        printf '%s\t%s\tmissing\tproject not in GrapheneOS manifest\n' "$route" "$path" >> "$report"
        failed=$((failed + 1)); continue
    fi
    dir="$KGOS/patches/$route"
    [ -d "$dir" ] || dir="$L24/$series_dir"

    g() { git -C "$repo_dir" "$@"; }
    g rev-parse -q --verify refs/kgos/base >/dev/null || g update-ref refs/kgos/base HEAD
    g am --abort >/dev/null 2>&1 || true
    g reset -q --hard refs/kgos/base
    g clean -qfd

    status=applied detail=$(basename "$dir")
    while IFS=$'\t' read -r kind file; do
        [ "$kind" = patch ] || continue
        if ! g am -q --3way --keep-cr "$dir/$file" >/dev/null 2>&1; then
            g am --abort >/dev/null 2>&1 || true
            g reset -q --hard refs/kgos/base
            status=failed detail=$file
            failed=$((failed + 1))
            break
        fi
    done < <(grep -v '^#' "$dir/series.tsv")
    printf '%s\t%s\t%s\t%s\n' "$route" "$path" "$status" "$detail" >> "$report"
    log "$route $path: $status"
done < <(awk -F '\t' '$1 ~ /^[0-9]+$/ {print $2 "\t" $5 "\t" $10}' "$L24/patches/projects.tsv")

column -t -s $'\t' "$report"
[ "$failed" -eq 0 ] || { [ "${ALLOW_FAIL:-0}" = 1 ] && log "$failed routes need work" || die "$failed routes failed (see $report)"; }
