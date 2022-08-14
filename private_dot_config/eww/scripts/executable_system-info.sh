#!/usr/bin/env bash

case "$1" in 
"brightness")
    brightnessctl -m | awk -F, '{print substr($4, 0, length($4) - 1)}' 
    while (inotifywait -e modify /sys/class/backlight/?**/brightness -qq); do 
        brightnessctl -m | awk -F, '{print substr($4, 0, length($4) - 1)}' 
    done
;;
"mic")
    while [[ ! -p $XDG_RUNTIME_DIR/eww.pipe ]]; do 
        sleep 0.1 
    done;
    tail -f "$XDG_RUNTIME_DIR/eww.pipe"
;;
"music-position")
    if float="$(playerctl position)"; then
        position=$(printf "%.0f" "$float")
        printf "%0d:%02d" $((position%3600/60)) $((position%60))
    fi
;;
esac