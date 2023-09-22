#!/usr/bin/bash

set -eo pipefail

screen=""
area=""
window=""

lock_file="/tmp/waybar-rec.lock"
declare -A audio_opt=([on]="" [off]="")
declare -A state_opt=([on]="" [off]="")
bool_audio=${ROFI_DATA:-true}

function notify() {
  notify-send -t 3000 -a "wf-recorder" "$@"
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
      true > "$lock_file"
    else
      rm $lock_file
    fi
    pkill -RTMIN+8 waybar
}

function start_recording() {
  file_path="$(xdg-user-dir VIDEOS)/Recording"
  file="$file_path/$(date '+%d-%m-%Y_%H%M%S').mp4"
  params=(--codec=h264_vaapi --device=/dev/dri/renderD128 -f "$file")

  if [[ ! $bool_audio == true ]]; then
    params+=(--audio="$(pactl get-default-sink).monitor")
  fi

  params+=("$@")
  notify_ok "Recording Started" "${file##*/}"

  waybar_icon
  if wf-recorder "${params[@]}" ; then
    notify_ok "Recording Complete" "${file##*/}"
  else
    notify_error "Error on capturing screen" "Error in wf-recorder"
  fi
  waybar_icon
}

function stop_recording() {
  pkill -SIGINT wf-recorder || notify_error "Unable to stop wf-recorder" \
      "Error on capturing screen"
}

function slurp_cmd() {
  slurp -b 00000064 -c 81a1c1 -s 00000000 -B d8dee926 -w 2 0<&-
}

if pid=$(pidof wf-recorder); then
  info="$(ps --pid="$pid" -o args --no-headers)"
  if [[ ! $info = *"audio"* ]]; then
    bool_audio=false
  fi
fi

if [[ -z "$1" ]] || [[ $1 =~ (${audio_opt[on]}|${audio_opt[off]}) ]]; then
  # General Options
  echo -en "\0theme\x1flistview {lines: 4;}\n"
  echo -en "\0keep-selection\x1ftrue\n"

  if [[ -n $pid ]]; then
      echo -en "\0theme\x1fprompt { background-color: @urgent;}\n"
      state="${state_opt[on]}"
  else
      echo -en "\0theme\x1fprompt {background-color: @active;}\n"
      state="${state_opt[off]}"
  fi

  echo -en "\0prompt\x1f$state\n"

  if [[ $bool_audio == false ]]; then
    echo -en "\0urgent\x1f3\n"
    echo -en "\0data\x1ftrue\n"
    audio="${audio_opt[off]}"
  else
    echo -en "\0active\x1f3\n"
    echo -en "\0data\x1ffalse\n"
    audio="${audio_opt[on]}"
  fi

  options="$screen\n$area\n$window\n$audio\n"
  echo -en "$options"
else
  # stop rofi listen to script
  exec > /dev/null

  if [[ -n $pid ]]; then
    stop_recording
    exit 0
  fi

  case "$1" in
    "$screen")
      output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused).name')
      start_recording --output="$output"
    ;;
    "$area") 
      geom=$(slurp_cmd)

      [[ -z "$geom" ]] && exit 0

      start_recording --geometry="$geom"
    ;;
    "$window")
      geom=$(swaymsg -t get_tree | jq -r \
          '.. | select(.pid? and .visible?) | .rect | 
          "\(.x),\(.y) \(.width)x\(.height)"' | slurp_cmd)

      [[ -z "$geom" ]] && exit 0

      start_recording --geometry="$geom"
    ;;
  esac
fi

