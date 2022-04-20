#!/usr/bin/env bash

FILE="$(xdg-user-dir VIDEOS)/Recording/$(date '+%d-%m-%Y %H:%M:%S').mp4"
AUDIO="$(pamixer --get-default-sink | awk ' NR==2 {print $2}' | sed 's/"//g').monitor"
SLURP_CMD="slurp -b 00000064 -c 81a1c1 -s 00000000 -B d8dee926 -w 2"

notify() {
    TITLE=${1:-"Recording"}
	MESSAGE=${2:-"OK"}
    notify-send -i /usr/share/icons/Papirus-Dark/64x64/apps/cs-screen.svg -t 3000 -a wf-recorder -u low "$TITLE" "$MESSAGE"
}

startRecording() {
    CAPTURE=$1
    notify "Recording Started" "$(basename "$FILE")"
    wf-recorder --audio="$AUDIO" -f "$FILE" --codec=h264_vaapi --device=/dev/dri/renderD128 --bframes=0 --force-yuv "$CAPTURE" > /dev/null 2>&1 &
    pkill -RTMIN+8 waybar
}

stopRecording() {
    notify "Recording Complete" "$(basename "$FILE")"
    pkill --signal SIGINT wf-recorder
    pkill -RTMIN+8 waybar
}

case "$1" in
    "--stop")
        if [ -n "$(pgrep wf-recorder)" ]; then
            stopRecording
        fi
        exit 0
        ;;
esac

dir="$HOME/.config/rofi/themes/"
ROFI_COMMAND="rofi -theme $dir/five.rasi"

SCREEN=""
AREA=""
WINDOW=""
STATUS="-u 0"
STATE=""

if [[ -z "$(pgrep wf-recorder)" ]]; then
    STATUS="-a 0"
    STATE=""
fi

OPTIONS="$STATE\n$SCREEN\n$AREA\n$WINDOW"
CHOSEN="$(echo -e $OPTIONS | $ROFI_COMMAND $STATUS -dmenu -l 4 -selected-row 1)"

if [[ -z "$(pgrep wf-recorder)" ]]; then
    case "$CHOSEN" in
        "$SCREEN")
            OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused)' | jq -r '.name')
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