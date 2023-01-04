#!/bin/bash

# Applets
nm-applet --indicator &
blueman-applet &

# Daemons
/usr/lib/geoclue-2.0/demos/agent > /dev/null 2>&1 & 
gammastep &
dunst &
xsettingsd &
playerctld &
eww daemon > /dev/null 2>&1 &
thunar --daemon &

# Sway 
autotiling > /dev/null &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 & 
xrdb -merge ~/.config/X11/xresources

# Apps
spotify-launcher &
keepassxc &
