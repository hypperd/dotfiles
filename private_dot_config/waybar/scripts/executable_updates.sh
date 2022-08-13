#!/bin/bash

while pgrep checkupdates > /dev/null; do
    sleep 0.5
done

num=$(checkupdates | wc -l)
# num=2 # mock
tooltip="$num Updates"
echo -e "$num\n$tooltip"
