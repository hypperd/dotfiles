#!/bin/sh

## Grimshot: a helper for screenshots within sway
## Requirements:
##  - `grim`: screenshot utility for wayland
##  - `slurp`: to select an area
##  - `swaymsg`: to read properties of current window
##  - `wl-copy`: clipboard utility
##  - `jq`: json utility to parse swaymsg output
##  - `notify-send`: to show notifications
## Those are needed to be installed, if unsure, run `grimshot check`
##
## See `man 1 grimshot` or `grimshot usage` for further details.

getTargetDirectory() {
  test -f ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs && \
    . ${XDG_CONFIG_HOME:-~/.config}/user-dirs.dirs

  echo ${XDG_SCREENSHOTS_DIR:-${XDG_PICTURES_DIR:-$HOME}}
}

if [ "$1" = "--notify" ]; then
  NOTIFY=yes
  shift 1
else
  NOTIFY=no
fi

ACTION=${1:-usage}
SUBJECT=${2:-screen}
FILE=${3:-$(getTargetDirectory)/$(date +'%d-%m-%Y %H:%M:%S').png}

if [ "$ACTION" != "save" ] && [ "$ACTION" != "copy" ] && [ "$ACTION" != "copy-save" ]; then
  echo "Usage:"
  echo "  grimshot [--notify] (copy|save) [active|screen|output|area|window] [FILE|-]"
  echo "  grimshot usage"
  echo ""
  echo "Commands:"
  echo "  copy: Copy the screenshot data into the clipboard."
  echo "  save: Save the screenshot to a regular file or '-' to pipe to STDOUT."
  echo "  usage: Show this message and exit."
  echo ""
  echo "Targets:"
  echo "  active: Currently active window."
  echo "  screen: All visible outputs."
  echo "  output: Currently active output."
  echo "  area: Manually select a region."
  echo "  window: Manually select a window."
  exit
fi

notify() {
  notify-send -i /usr/share/icons/Papirus-Dark/64x64/devices/camera.svg -t 3000 -a grimshot "$@"
}
notifyOk() {
  [ "$NOTIFY" = "no" ] && return

  TITLE=${2:-"Screenshot"}
  MESSAGE=${1:-"OK"}
  notify -u low "$TITLE" "$MESSAGE"
}
notifyError() {
  if [ $NOTIFY = "yes" ]; then
    TITLE=${2:-"Screenshot"}
    MESSAGE=${1:-"Error taking screenshot with grim"}
    notify -u critical "$TITLE" "$MESSAGE"
  else
    echo $1
  fi
}

die() {
  MSG=${1:-Bye}
  notifyError "Error: $MSG"
  exit 2
}

takeScreenshot() {
  FILE=$1
  GEOM=$2
  OUTPUT=$3
  if [ ! -z "$OUTPUT" ]; then
    grim -o "$OUTPUT" "$FILE" || die "Unable to invoke grim"
  elif [ -z "$GEOM" ]; then
    grim "$FILE" || die "Unable to invoke grim"
  else
    grim -g "$GEOM" "$FILE" || die "Unable to invoke grim"
  fi
}

if [ "$SUBJECT" = "area" ] ; then
  GEOM=$(slurp -d -b 00000064 -c 3b4252)
  # Check if user exited slurp without selecting the area
  if [ -z "$GEOM" ]; then
    exit 1
  fi
  WHAT="Area"
elif [ "$SUBJECT" = "active" ] ; then
  FOCUSED=$(swaymsg -t get_tree | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.focused)')
  GEOM=$(echo "$FOCUSED" | jq -r '.rect | "\(.x),\(.y) \(.width)x\(.height)"')
  APP_ID=$(echo "$FOCUSED" | jq -r '.app_id')
  WHAT="$APP_ID window"
elif [ "$SUBJECT" = "screen" ] ; then
  GEOM=""
  WHAT="Screen"
elif [ "$SUBJECT" = "output" ] ; then
  GEOM=""
  OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused)' | jq -r '.name')
  WHAT="$OUTPUT"
elif [ "$SUBJECT" = "window" ] ; then
  GEOM=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp)
  # Check if user exited slurp without selecting the area
  if [ -z "$GEOM" ]; then
   exit 1
  fi
  WHAT="Window"
else
  die "Unknown subject to take a screen shot from" "$SUBJECT"
fi

if [ "$ACTION" = "copy" ] ; then
  takeScreenshot - "$GEOM" "$OUTPUT" | wl-copy --type image/png || die "Clipboard error"
  notifyOk "$WHAT copied to buffer"
elif [ "$ACTION" = "copy-save" ] ; then
  if takeScreenshot "$FILE" "$GEOM" "$OUTPUT"; then
    TITLE="Screenshot of $SUBJECT"
    MESSAGE=$(basename "$FILE")
    notifyOk "$MESSAGE" "$TITLE"
    echo $FILE
    wl-copy --type image/png < $FILE || die "Clipboard error"
  else
    notifyError "Error taking screenshot with grim"
  fi
else
  if takeScreenshot "$FILE" "$GEOM" "$OUTPUT"; then
    TITLE="Screenshot of $SUBJECT"
    MESSAGE=$(basename "$FILE")
    notifyOk "$MESSAGE" "$TITLE"
    echo $FILE
  else
    notifyError "Error taking screenshot with grim"
  fi
fi
