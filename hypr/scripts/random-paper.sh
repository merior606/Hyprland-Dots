#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/wallpapers"

WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | shuf -n 1)

hyprctl hyprpaper reload ,"$WALLPAPER"