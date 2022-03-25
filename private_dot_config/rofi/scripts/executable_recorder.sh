#!/usr/bin/env bash

fileName=$(date +'%d-%m-%Y %H:%M:%S.mkv')
filePath=$(xdg-user-dir VIDEOS)/Recordings/$fileName
sink="$(pamixer --get-default-sink | awk ' NR==2 {print $2}' | sed 's/"//g').monitor"

startRecording() {
    capture=$1
    value=$2
    wf-recorder -f "$filePath" -c h264_vaapi -d /dev/dri/renderD128 --bframes 0 --force-yuv --audio=$sink $capture "$value" > /dev/null 2>&1 &
    pkill -RTMIN+8 waybar
}

notify() {
  notify-send -i /usr/share/icons/Papirus-Dark/64x64/apps/cs-screen.svg -t 3000 -a grimshot -u low "$@"
}

die() {
    notify "Recording Complete" "$fileName"
    pkill --signal SIGINT wf-recorder
    pkill -RTMIN+8 waybar
}

case "$1" in
    "--stop")
        if [ ! -z $(pgrep wf-recorder) ]; then
            die
        fi
        exit 0
        ;;
esac

dir="$HOME/.config/rofi/themes/"
rofi_command="rofi -theme $dir/five.rasi"

# Options
state=""
screen=""
area=""
window=""

# recording
status=""

if [ -z $(pgrep wf-recorder) ]; then
    status="-a 0"
    state=""
else
    status="-u 0"
    state=""
fi

options="$state\n$screen\n$area\n$window"

chosen="$(echo -e "$options" | $rofi_command $status -dmenu -l 4 -selected-row 1)"

case $chosen in
    $screen)
		if [ -z $(pgrep wf-recorder) ]; then
            notify "Recording Started" "Recording output"
            output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused)' | jq -r '.name')
            startRecording --output "$output"
        else
            die
        fi
        ;;
    $area)
        if [ -z $(pgrep wf-recorder) ]; then
		    geom="$(slurp -b 00000064 -c 81a1c1)"
            if [ -z "$geom" ]; then
                exit 0
            fi
            notify "Recording Started" "Recording area"
            startRecording --geometry "$geom"
        else 
            die
        fi
        ;;
    $window)
        if [ -z $(pgrep wf-recorder) ]; then
		    geom="$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp -b 00000064 -c 81a1c1 -B 3b425264)"
            if [ -z "$geom" ]; then
                exit 0
            fi
            notify "Recording Started" "Recording window"
            startRecording --geometry "$geom"
        else 
            die
        fi
        ;;
esac