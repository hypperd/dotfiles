#!/usr/bin/env bash

LOCK_FILE="/tmp/waybar-rec.lock"

if [[ ! -f $LOCK_FILE ]]; then
    echo
else
    echo ''
fi