#!/bin/bash

if [ -n "$(pgrep rofi)" ]; then
    pkill rofi
fi
    swaymsg unbindsym '$mod+d'
    rofi -show drun -theme ~/.config/rofi/themes/launcher.rasi -kb-cancel 'Super_L+d' -kb-cancel 'Escape'
    swaymsg bindsym '$mod+d' exec '$bin/launcher.sh'
