#!/bin/bash

if pidof -q gammastep; then
    pkill gammastep
    eww update night_light=false
else
    eww update night_light=true
    swaymsg exec gammastep 
fi