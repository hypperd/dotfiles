#!/bin/bash

pgrep rofi > /dev/null && pkill rofi
rofi -show drun -theme ~/.config/rofi/themes/launcher.rasi
