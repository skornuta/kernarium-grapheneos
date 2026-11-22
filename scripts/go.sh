#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0-or-later
set -euo pipefail
. "$(dirname "$0")/env.sh"

steps=${*:-sync patch build}
cmd="cd $KGOS && git pull -q --ff-only; export GRAPHENE_REF=$GRAPHENE_REF VARIANT=$VARIANT RELEASE=$RELEASE JOBS=$JOBS ALLOW_FAIL=${ALLOW_FAIL:-0};"
for s in $steps; do
    case $s in
        sync) cmd+=" scripts/sync.sh &&" ;;
        patch) cmd+=" scripts/apply-patches.sh &&" ;;
        build) cmd+=" scripts/build.sh &&" ;;
        *) die "unknown step: $s" ;;
    esac
done
cmd+=" echo KGOS-DONE"

tmux has-session -t build 2>/dev/null && die "tmux session 'build' already running: tmux attach -t build"
tmux new-session -d -s build "bash -lc '( $cmd ) 2>&1 | tee -a $LOGS/go.log; exec bash'"
log "started in tmux session 'build' — watch with: tmux attach -t build (detach: Ctrl-b d)"
