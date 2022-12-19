#!/bin/bash

wallpapers_path="$(xdg-user-dir PICTURES)/Wallpapers"

width=$(swaymsg -t get_outputs | jq -r \
  '.[] | select(.focused).current_mode.height')
lines=$(((width * 80) / 15000))

function rofi_cmd() {
  rofi -theme icon -dmenu -show-icons -l "$lines"
}

function thumbs() {
  python3 "${XDG_CONFIG_HOME:-$HOME/.config}"/rofi/util/thumbnail.py \
    "$wallpapers_path"
}

choose="$(thumbs | rofi_cmd)"

if [[ -n $choose ]]; then 
  wallpaper set "$choose"
fi
