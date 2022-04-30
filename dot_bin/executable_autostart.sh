#!/bin/bash
## Autostart Programs

/usr/lib/geoclue-2.0/demos/agent > /dev/null 2>&1 & 
gammastep &
nm-applet --indicator &
dunst &
playerctld &
blueman-applet &
autotiling &
flashfocus &
xsettingsd &
eww daemon > /dev/null 2>&1 &
spotify &





#discord --start-minimized ; for_window [class="discord"] move container to scratchpad
#keepassxc