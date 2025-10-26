#!/usr/bin/bash

if [[ -z $HOME ]]; then
  echo "\$HOME not set! exiting..." >&2
  exit 1
fi

update_count_file="${XDG_STATE_HOME:-$HOME/.local/state}/waybar/updates"

if ! [[ -f $update_count_file ]]; then
  echo "Failed to open stored update count" >&2
  echo "$update_count_file: No such file or directory" >&2
  exit 1
fi

count=$(<"$update_count_file") 

if [[ $count -eq 0 ]]; then
  echo
  exit 0
fi

plural=''
if [[ $count -gt 1 ]]; then
  plural='s'
fi

printf '{"text": "%u", "tooltip": "%u available update%s"}\n' "$count" "$count" "$plural"
