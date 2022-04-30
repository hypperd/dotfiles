#!/bin/bash

config="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
xsettingsd="${XDG_CONFIG_HOME:-$HOME/.config}/xsettingsd/xsettingsd.conf"

if [[ ! -f "$config" ]] && [[ ! -f "$xsettingsd" ]]; then exit 1; fi

replace() {
   file="$1"
   var="$2"
   new_value="$3"
   tmpfile=$(mktemp)
   awk -v var="$var" -v new_val="$new_value" 'BEGIN {FPAT = "([^ ]+)|(\"[^\"]+\")"} match($1, "^" var "\\s*") {$2=new_val}1' "$file" > "$tmpfile"
   cat "$tmpfile" > "$file"
   rm -f "$tmpfile"
}

quotes() {
   echo "\"$1\""
}

cutValueConfig() {
   key=$1
   grep "$key" "$config" | cut -f2 -d=
}

icon_theme="$(cutValueConfig 'gtk-icon-theme')"
gtk_theme="$(cutValueConfig 'gtk-theme-name')"
cursor_theme="$(cutValueConfig 'gtk-cursor-theme-name')"

replace "$xsettingsd" "Net/ThemeName" "$(quotes "$gtk_theme")"
replace "$xsettingsd" "Net/IconThemeName" "$(quotes "$icon_theme")"
replace "$xsettingsd" "Gtk/CursorThemeName" "$(quotes "$cursor_theme")"

killall -SIGHUP xsettingsd

font_name="$(cutValueConfig 'gtk-font-name')"

gnome_schema="org.gnome.desktop.interface"
gsettings set "$gnome_schema" gtk-theme "$gtk_theme"
gsettings set "$gnome_schema" icon-theme "$icon_theme"
gsettings set "$gnome_schema" cursor-theme "$cursor_theme"
gsettings set "$gnome_schema" font-name "$font_name"
gsettings set "$gnome_schema" cursor-size 16
gsettings set "$gnome_schema" font-antialiasing "rgba"