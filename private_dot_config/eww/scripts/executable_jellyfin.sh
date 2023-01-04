#!/bin/bash

start() {
    echo 'Starting server!'
    if pkexec ufw allow Jellyfin; then
        podman start jellyfin-server
        eww update server=true
    fi
}

stop() {
    echo 'Stoping server'
    if pkexec ufw deny Jellyfin; then
        podman stop jellyfin-server
        eww update server=false
    fi
}

case "$1" in 
    "start")
        start
    ;;
    "stop")
        stop
    ;;
    "toggle")
        if pidof '/jellyfin/jellyfin'; then
            stop
        else
            start
        fi
    ;;
esac
