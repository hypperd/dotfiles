#!/bin/bash

# Requirements:
#   - xdg-user-dirs.
#   - wf-recorder
#   - jq

set -eo pipefail

lock_file="/tmp/waybar-rec.lock"
file_path="$(xdg-user-dir VIDEOS)/Recording"

function notify() {
    notify-send -t 3000 -a wf-recorder "$@"
}

function notify_ok() {
    title=${1:-"Recording"}
	message=${2:-"OK"}
    notify -i cs-screen -u low "$title" "$message"
}

function notify_error() {
    title=${1:-"Recording Error"}
	message=${2:-"Error"}
	notify -u critical "$title" "$message"
}

function waybar_icon() {
    if [[ ! -f $lock_file ]]; then
        jq --null-input --arg filename "${file##*/}" \
          '.filename = $filename' > "$lock_file"
    else
        rm $lock_file
    fi
    pkill -RTMIN+8 waybar
}

function start_recording() {
    capture=$1
    file="$file_path/$(date '+%d-%m-%Y %H%M%S').mp4"

    params=(--codec=h264_vaapi --device=/dev/dri/renderD128 -f "$file")
    params+=("$capture")

    [[ ! $audio_rec == true ]] && \
        params+=(--audio="$(pactl get-default-sink).monitor")
    
    wf-recorder "${params[@]}" || \
        notify_error "Error on capturing screen" "Error in wf-recorder" &
    notify_ok "Recording Started" "${file##*/}"
    waybar_icon
}

function stop_recording() {
    pkill -SIGINT wf-recorder || notify_error "Unable to stop wf-recorder" \
        "Error on capturing screen"
    
    notify_ok "Recording Complete" "$(jq -r '.filename' "$lock_file")"
    waybar_icon
}

function slurp_cmd() {
    slurp -b 00000064 -c 81a1c1 -s 00000000 -B d8dee926 -w 2
}

screen=""
area=""
window=""

declare -A audio_opt=([on]="" [off]="")
declare -A state_opt=([on]="" [off]="")

pid=$(pidof wf-recorder) || true

if [[ -n $pid ]]; then
    echo -en "\0theme\x1fprompt { background-color: @urgent;}\n"
    state="${state_opt[on]}"
    info="$(ps --pid="$pid" -o args --no-headers)"
else
    echo -en "\0theme\x1fprompt {background-color: @active;}\n"
    state="${state_opt[off]}"
fi

if [[ $ROFI_DATA == "false" ]] || [[ $info = *"audio"* ]]; then
    echo -en "\0active\x1f3\n"
    echo -en "\0data\x1ftrue\n"
    audio="${audio_opt[on]}"
    audio_rec=true
else
    echo -en "\0urgent\x1f3\n"
    echo -en "\0data\x1ffalse\n"
    audio="${audio_opt[off]}"
    audio_rec=false
fi

echo -en "\0theme\x1flistview {lines: 4;}\n"
echo -en "\0prompt\x1f$state\n"
echo -en "\0keep-selection\x1ftrue\n"
options="$screen\n$area\n$window\n$audio\n"

if [[ -z $pid ]]; then
    case "$1" in
        "$screen")
            start() {
                output=$(swaymsg -t get_outputs | jq -r \
                    '.[] | select(.focused).name')
                start_recording --output="$output"
            }

            # stop rofi listen to script
            start > /dev/null &
        ;;
        "$area")
            start() {
                geom=$(slurp_cmd)

                [[ -z "$geom" ]] && exit 0

                start_recording --geometry="$geom"
            }

            start > /dev/null &
        ;;
        "$window")
            start() {

                geom=$(swaymsg -t get_tree | jq -r \
                    '.. | select(.pid? and .visible?) | .rect | 
                    "\(.x),\(.y) \(.width)x\(.height)"' | slurp_cmd)

                [[ -z "$geom" ]] && exit 0

                start_recording --geometry="$geom"
            }

            start > /dev/null &
        ;;
        *)
            echo -en "$options"
        ;;
    esac
else
    if [[ -z "$1" ]]; then
        echo -en "$options"
    else 
        stop_recording
    fi
fi
