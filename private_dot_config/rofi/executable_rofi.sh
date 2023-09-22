#!/usr/bin/bash

scripts="${XDG_CONFIG_HOME:-$HOME/.config}"/rofi/scripts

pidof -q rofi && pkill rofi

case "$1" in
  "powermenu")
    exec rofi -show powermenu -theme menu -modes powermenu \
      -theme-str 'inputbar {enabled: false;}' 
  ;;
  "launcher")
    exec rofi -show drun -theme launcher
  ;;
  "window")
    exec rofi -show window -theme launcher
  ;;
  "recorder")
    exec rofi -show recorder -theme menu
  ;;
  "wallpaper")
    exec "$scripts"/wallpaper.py
  ;;
  "actions")
    exec rofi -show actions -theme menu -modes actions \
      -theme-str 'listview {lines: 4; }' \
      -theme-str 'inputbar {enabled: false;}' \
      -theme-str 'element-text {
          font: "Symbols Nerd Font Mono 12"; 
          padding: 12px 16px;
      }'
  ;;
  *)
    echo -e "\033[0;31mError:\033[0m '$1' not found" 1>&2
  ;;
esac
