#!/usr/bin/env bash

function rofi_cmd() {
  inputbar=false rofi -theme menu -dmenu -selected-row 2 -l 5 
}

shutdown=""
reboot=""
lock=""
suspend=""
logout=""

options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"
chosen="$(echo -e $options | rofi_cmd)"

case "$chosen" in
  "$shutdown")
    systemctl poweroff
    ;;
  "$reboot")
    systemctl reboot
    ;;
  "$lock")
    loginctl lock-session
    ;;
  "$suspend")
    systemctl suspend
    ;;
  "$logout")
    swaymsg exit
    ;;
esac