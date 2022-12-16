#!/bin/bash

[[ ! -f /tmp/rofipid ]] && echo 1 > /tmp/rofipid

if [[ $(pidof rofi) -eq $(awk '{print $1}' < /tmp/rofipid) ]] && [[ $(awk '{print $2}' < /tmp/rofipid) = "launcher" ]]; then
    pkill rofi
else
    pidof -q rofi && pkill rofi
    rofi -show drun -theme ~/.config/rofi/themes/launcher.rasi &
    printf '%s %s' "$(pidof rofi)" "launcher" > /tmp/rofipid
fi
