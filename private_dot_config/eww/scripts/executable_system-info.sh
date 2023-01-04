#!/usr/bin/env bash
set -eo pipefail

case "$1" in 
"brightness")
    brightnessctl -m | awk -F, '{print substr($4, 0, length($4) - 1)}'
    while (inotifywait -e modify /sys/class/backlight/?**/brightness -qq); do 
        brightnessctl -m | awk -F, '{print substr($4, 0, length($4) - 1)}'
    done
;;
"music-position")
    if float="$(playerctl position)"; then
        position=$(printf "%.0f" "$float")
        printf "%0d:%02d" $((position%3600/60)) $((position%60))
    fi
;;
"night-light")
    if pidof -q gammastep; then 
        echo true
    else
        echo false
    fi
;;
"")
  if pidof '/jellyfin/jellyfin'; then
    echo true
  else
    echo false
  fi
;;
esac
