#!/bin/bash

if pgrep gammastep > /dev/null; then

    pkill gammastep
    eww update night_light=false

else
    eww update night_light=true
    swaymsg exec gammastep 

fi
