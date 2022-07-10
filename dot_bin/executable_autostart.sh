#!/bin/bash

# -- Applets --
nm-applet --indicator &
blueman-applet &

# -- Daemons --
/usr/lib/geoclue-2.0/demos/agent > /dev/null 2>&1 & 
gammastep &
dunst &
xsettingsd &
playerctld &
eww daemon > /dev/null 2>&1 &
thunar --daemon &

# -- Sway --
autotiling &
#flashfocus &

# -- Apps --
#discord --start-minimized 
#keepassxc
#spotify &
