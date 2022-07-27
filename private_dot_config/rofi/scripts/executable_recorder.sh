#!/usr/bin/env bash

LOCK_FILE="/tmp/waybar-rec.lock"
FILE="$(xdg-user-dir VIDEOS)/Recording/$(date '+%d-%m-%Y %H:%M:%S').mp4"
AUDIO="$(pactl get-default-sink).monitor"
SLURP_CMD="slurp -b 00000064 -c 81a1c1 -s 00000000 -B d8dee926 -w 2"

notify() {
    notify-send -t 3000 -a wf-recorder "$@"
}

notifyOk() {
    TITLE=${1:-"Recording"}
	MESSAGE=${2:-"OK"}
    notify -i cs-screen -u low "$TITLE" "$MESSAGE"
}

notifyError() {
    TITLE=${1:-"Recording Error"}
	MESSAGE=${2:-"Error"}
	notify -u critical "$TITLE" "$MESSAGE"
}

waybar-icon() {
    if [[ ! -f $LOCK_FILE ]]; then
        touch $LOCK_FILE
    else
        rm $LOCK_FILE
    fi
    pkill -RTMIN+8 waybar
}

startRecording() {
    CAPTURE=$1
    wf-recorder --audio="$AUDIO" -f "$FILE" --codec=h264_vaapi --device=/dev/dri/renderD128 "$CAPTURE" > /dev/null 2>&1 &
    notifyOk "Recording Started" "$(basename "$FILE")"
    waybar-icon
}

stopRecording() {
    pkill -SIGINT wf-recorder || notifyError "Unable to stop wf-recorder" "Error on capturing screen"
    notifyOk "Recording Complete" "$(basename "$FILE")"
    waybar-icon
}

DIR="$HOME/.config/rofi/themes/"
ROFI_COMMAND="rofi -theme $DIR/menu.rasi"

SCREEN=""
AREA=""
WINDOW=""
STATUS="-u 0"
STATE=""

if ! pgrep wf-recorder > /dev/null; then
    STATUS="-a 0"
    STATE=""
fi

OPTIONS="$STATE\n$SCREEN\n$AREA\n$WINDOW"

pgrep rofi > /dev/null && pkill rofi

CHOSEN="$(echo -e $OPTIONS | $ROFI_COMMAND $STATUS -dmenu -l 4 -selected-row 1)"

if ! pgrep wf-recorder > /dev/null; then
    case "$CHOSEN" in
        "$SCREEN")
            OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused).name')
            startRecording --output="$OUTPUT"
        ;;
        "$AREA")
            GEOM=$($SLURP_CMD)
	        
	        if [ -z "$GEOM" ]; then
		        exit 0
	        fi

            startRecording --geometry="$GEOM"
        ;;
        "$WINDOW")
            GEOM=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | $SLURP_CMD)
	        
            if [ -z "$GEOM" ]; then
		        exit 0
	        fi

            startRecording --geometry="$GEOM"
        ;;
    esac
else
    if [[ -n "$CHOSEN" ]] && [[ "$CHOSEN" != "$STATE" ]]; then
        stopRecording
    fi
fi
