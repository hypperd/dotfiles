#!/bin/bash

LOCK_FILE="/tmp/waybar-rec.lock"

if [[ ! -f $LOCK_FILE ]]; then
        touch $LOCK_FILE
else
        rm $LOCK_FILE
fi
pkill -RTMIN+8 waybar
