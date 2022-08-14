#!/usr/bin/env bash

trap exit 0 SIGINT SIGTERM

loop() {
    while true; do
        systemd-inhibit sleep 1h || break
    done
}

#echo ${BASH_SOURCE[0]}
echo $$

script_name=${BASH_SOURCE[0]}

case $1 in
"toggle")
    if pgrep -f $script_name | grep -v "$$" > /dev/null; then
        echo 'stop inhibiting'
        eww update idle_inhibitor=false

        for pid in $(pgrep -f $script_name); do
            if [ $pid != $$ ]; then
                #echo $pid
                pkill -P "$pid"
            fi 
        done
        
        exit 0
    else 
        eww update idle_inhibitor=true
        echo 'inhibiting'
        loop &
    fi
;;
esac