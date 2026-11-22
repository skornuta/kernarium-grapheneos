if [ "$(cmd settings get global kgos_ui_defaults 2>/dev/null)" != 1 ]; then
    kgos_tries=0
    until cmd settings get global animator_duration_scale >/dev/null 2>&1 || [ "$kgos_tries" -ge 30 ]; do
        kgos_tries=$((kgos_tries + 1))
        sleep 2
    done
    for kgos_key in window_animation_scale transition_animation_scale animator_duration_scale; do
        cmd settings put global "$kgos_key" 0 >/dev/null 2>&1
    done
    cmd settings put global kgos_ui_defaults 1 >/dev/null 2>&1 && log -t kgos_ui_defaults -p i "animation scales set to 0"
fi

