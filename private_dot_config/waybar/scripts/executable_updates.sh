#!/bin/bash

if ! nm-online -q -t 0; then
    echo "Network not available, exiting..."
    exit 1
fi

file="$HOME/.local/state/waybar/updates"

# if [[ ! -f $file ]]; then
#   touch "$file"
# fi
#
# if ! updates_arch=$(checkupdates | wc -l); then
#     updates_arch=0
# fi
#
# if ! updates_aur=$(paru -Qua | wc -l); then
#     updates_aur=0
# fi

num=$($HOME/.local/bin/updates)
if [[ ! num -eq 0 ]]; then
    tooltip="$num Updates"
    jq -c --arg text "$num" --arg tooltip "$tooltip" \
      --null-input '{"text": $text, "tooltip": $tooltip}' > "$file"
else
    echo > "$file"
fi

pkill -SIGRTMIN+6 waybar
