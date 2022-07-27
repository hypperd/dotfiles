#!/usr/bin/env bash

dir="$HOME/.config/rofi/themes/"
rofi_command="rofi -theme $dir/menu.rasi"

# options
shutdown=""
reboot=""
lock=""
suspend=""
logout=""

# variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

pgrep rofi > /dev/null && pkill rofi

chosen="$(echo -e $options | $rofi_command -dmenu -selected-row 2)"

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
