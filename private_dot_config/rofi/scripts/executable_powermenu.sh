#!/bin/bash

shutdown=""
reboot=""
lock=""
suspend=""
logout=""

options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

if [[ -z $1 ]]; then
  echo -en $options
else
  case "$1" in
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
fi
