#!/usr/bin/env bash

##
## Modified from https://github.com/adi1090x/rofi
##

dir="$HOME/.config/rofi/themes/"
rofi_command="rofi -theme $dir/five.rasi"

# Options
shutdown=""
reboot=""
lock=""
suspend=""
logout=""

# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

pkill rofi
chosen="$(echo -e "$options" | $rofi_command -dmenu -selected-row 2)"

case $chosen in
    $shutdown)
		systemctl poweroff
        ;;
    $reboot)
		systemctl reboot
        ;;
    $lock)
		loginctl lock-session
        ;;
    $suspend)
		systemctl suspend
        ;;
    $logout)
		swaymsg exit
        ;;
esac
