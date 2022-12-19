#!/bin/bash

scripts="${XDG_CONFIG_HOME:-$HOME/.config}"/rofi/scripts

pidof -q rofi && pkill rofi

case "$1" in
  "powermenu")
    exec rofi -show powermenu -theme menu \
      -theme-str 'inputbar {enabled: false;}' -selected-row 2 
  ;;
  "launcher")
    exec rofi -show drun -theme launcher
  ;;
  "recorder")
    exec rofi -show recorder -theme menu -selected-row 1
  ;;
  "wallpaper")
    exec "$scripts"/wallpaper-picker.sh
  ;;
  *)
    echo -e "\033[0;31mError:\033[0m '$1' not found" 1>&2
  ;;
esac
