#!/usr/bin/env bash

## Modified from https://github.com/adi1090x/rofi

DIR="$HOME/.config/rofi/themes/"
ROFI_COMMAND="rofi -theme $DIR/five.rasi"

# Options
SHUTDOWN=""
REBOOT=""
LOCK=""
SUSPEND=""
LOGOUT=""

# Variable passed to rofi
OPTIONS="$SHUTDOWN\n$REBOOT\n$LOCK\n$SUSPEND\n$LOGOUT"

# SIGTERM rofi
pkill rofi

CHOSEN="$(echo -e $OPTIONS | $ROFI_COMMAND -dmenu -selected-row 2)"

case "$CHOSEN" in
"$SHUTDOWN")
	systemctl poweroff
	;;
"$REBOOT")
	systemctl reboot
	;;
"$LOCK")
	loginctl lock-session
	;;
"$SUSPEND")
	systemctl suspend
	;;
"$LOGOUT")
	swaymsg exit
	;;
esac