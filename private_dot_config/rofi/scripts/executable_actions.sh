#!/usr/bin/bash

declare -A inhibitor_opt=([on]="󰅶" [off]="󰾪")
declare -A dunst_opt=([on]="󰂞" [off]="󰂛")
declare -A gammastep_opt=([on]="󰌵" [off]="󰹏")

start_jellyfin() {
    if pkexec ufw allow Jellyfin && systemctl --user start jellyfin; then
      notify-send "Jellyfin started" \
        -i jellyfin -u low -a jellyfin
    else
      notify-send "Jellyfin start failed" \
        -i jellyfin -u critical -a jellyfin
    fi
}

stop_jellyfin() {
    if pkexec ufw deny Jellyfin && systemctl --user stop jellyfin; then
      notify-send "Jellyfin stoped" \
        -i jellyfin -u low -a jellyfin
    else
      notify-send "Jellyfin start failed" \
        -i jellyfin -u critical -a jellyfin
    fi
}

idle_inhibitor() {
  systemd-inhibit sleep infinity
}

jellyfin=false
jellyfin_icon="󰚺"
dunst_icon=${dunst_opt[off]}
gammastep=false
gammastep_icon=${gammastep_opt[off]}
inhibitor=false
inhibitor_icon=${inhibitor_opt[off]}

if [[ $(dunstctl is-paused) = false ]]; then
  dunst_icon=${dunst_opt[on]}
  echo -en "\0active\x1f0\n"
fi

if pidof -q '/jellyfin/jellyfin'; then
  jellyfin=true
  echo -en "\0active\x1f1\n"
fi

if pidof -q gammastep; then
  gammastep_icon=${gammastep_opt[on]}
  gammastep=true
  echo -en "\0active\x1f2\n"
fi

if pidof -q systemd-inhibit; then
  inhibitor_icon=${inhibitor_opt[on]}
  inhibitor=true
  echo -en "\0active\x1f3\n"
fi

if [[ -z "$1" ]]; then
  echo -en "$dunst_icon\n$jellyfin_icon\n$gammastep_icon\n$inhibitor_icon\n"
else
  # stop rofi listen to script
  exec > /dev/null

  case "$1" in
    "$dunst_icon") 
      dunstctl set-paused toggle
    ;;
    "$jellyfin_icon") 
      if [[ "$jellyfin" = true ]];then
        stop_jellyfin
      else
        start_jellyfin
      fi
    ;;
    "$gammastep_icon") 
      if [[ "$gammastep" = true ]];then
        pkill gammastep
      else
        exec gammastep &
      fi
    ;;
    "$inhibitor_icon")
      if [[ "$inhibitor" = true ]]; then
        pkill systemd-inhibit
      else
        idle_inhibitor &
      fi
    ;;
  esac
fi
