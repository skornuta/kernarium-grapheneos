#!/system/bin/sh
# SPDX-License-Identifier: Apache-2.0
# Sets the three animation scales to 0 once per data partition.

marker=persist.sys.kernarium.ui_defaults
[ "$(getprop $marker)" = 1 ] && exit 0

tries=0
until cmd settings get global animator_duration_scale >/dev/null 2>&1; do
    tries=$((tries + 1))
    [ "$tries" -ge 30 ] && exit 1
    sleep 2
done

for key in window_animation_scale transition_animation_scale animator_duration_scale; do
    cmd settings put global "$key" 0 >/dev/null 2>&1 || exit 1
done
setprop "$marker" 1
log -t kernarium_ui_defaults -p i "animation scales set to 0"
