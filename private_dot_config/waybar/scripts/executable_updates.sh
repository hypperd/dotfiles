#!/bin/bash

while pgrep checkupdates > /dev/null; do
    sleep 0.5
done

num=$(checkupdates | wc -l)
echo "$num"
