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
wl-paste -t text --watch clipman store --no-persist & # clipboard
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 # polkit
# -- Apps --
#discord-canary --enable-features=UseOzonePlatform \ 
#  --ozone-platform=wayland --start-minimized 
#keepassxc
#spotify &
