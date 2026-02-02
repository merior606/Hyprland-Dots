#!/usr/bin/env bash

# Archivo de estado
STATE_FILE="$HOME/.cache/kb_layout_state"

# Inicializar estado si no existe
if [ ! -f "$STATE_FILE" ]; then
    hyprctl keyword input:kb_layout us
    echo "us" > "$STATE_FILE"
fi

CURRENT=$(cat "$STATE_FILE")

# hyprctl keyword input:kb_layout us
# hyprctl keyword input:kb_variant intl
# 

toggle_layout() {
    if [ "$CURRENT" = "us" ]; then
        hyprctl keyword input:kb_variant ""
        hyprctl keyword input:kb_layout es
        echo "es" > "$STATE_FILE"
    else
        hyprctl keyword input:kb_layout us
        hyprctl keyword input:kb_variant intl
        echo "us" > "$STATE_FILE"
    fi
}

print_layout() {
    echo "$CURRENT"
}

case "$1" in
    --toggle)
        toggle_layout
        ;;
    --print)
        print_layout
        ;;
    *)
        echo "Usage: $0 [--toggle|--print]"
        ;;
esac
