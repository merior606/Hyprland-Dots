#!/bin/bash

BAT="/sys/class/power_supply/BAT0/capacity"
STATUS="/sys/class/power_supply/BAT0/status"

LEVEL=$(cat "$BAT")
STATE=$(cat "$STATUS")

FLAG="$HOME/.cache/battery_notified"

if [ "$STATE" = "Discharging" ] && [ "$LEVEL" -le 5 ]; then
    if [ ! -f "$FLAG" ]; then
        notify-send -u critical -i battery-caution \
        "⚠ Low battery" \
        "${LEVEL}% remaining"
        touch "$FLAG"
    fi
else
    rm -f "$FLAG"
fi
