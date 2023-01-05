#!/bin/bash

if ! nm-online -q -t 0; then
    echo "Network not available, exiting..."
    exit
fi

file="$HOME/.local/state/waybar/updates"

if ! updates_arch=$(checkupdates | wc -l); then
    updates_arch=0
fi

if ! updates_aur=$(paru -Qua | wc -l); then
    updates_aur=0
fi

num=$((updates_arch + updates_aur))
if [[ ! num -eq 0 ]]; then
    tooltip="$num Updates"
    echo -e "$num\n$tooltip" > "$file"
else
    echo > "$file"
fi

pkill -SIGRTMIN+6 waybar