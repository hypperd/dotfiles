#!/bin/bash

# Multi monitor fix
while pgrep -f checkupdates > /dev/null; do
    sleep 0.5
done


if ! updates_arch=$(checkupdates | wc -l); then
    updates_arch=0
fi

if ! updates_aur=$(yay --aur -Qum --devel | wc -l); then
    updates_aur=0
fi

num=$((updates_arch + updates_aur))

if [[ ! num -eq 0 ]]; then
    tooltip="$num Updates"
    echo -e "$num\n$tooltip"
else
    echo
fi
