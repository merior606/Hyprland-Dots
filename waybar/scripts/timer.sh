#!/bin/bash

# Rutas para archivos temporales que guardan el estado
STATUS_FILE="/tmp/waybar_timer_status"
START_FILE="/tmp/waybar_timer_start"

# Si el archivo de estado no existe, asumimos que está detenido
if [ ! -f "$STATUS_FILE" ]; then
    echo "stopped" > "$STATUS_FILE"
fi

STATUS=$(cat "$STATUS_FILE")

if [ "$1" == "toggle" ]; then
    if [ "$STATUS" == "stopped" ]; then
        # Iniciar temporizador
        echo "running" > "$STATUS_FILE"
        date +%s > "$START_FILE"
        # Forzar actualización de Waybar
        pkill -RTMIN+10 waybar
    else
        # Detener y resetear temporizador
        echo "stopped" > "$STATUS_FILE"
        rm -f "$START_FILE"
        pkill -RTMIN+10 waybar
    fi
    exit 0
fi

# Lógica para mostrar el texto en Waybar
if [ "$STATUS" == "running" ] && [ -f "$START_FILE" ]; then
    START_TIME=$(cat "$START_FILE")
    NOW=$(date +%s)
    ELAPSED=$((NOW - START_TIME))
    
    # Formatear el tiempo en MM:SS
    MINUTES=$((ELAPSED / 60))
    SECONDS=$((ELAPSED % 60))
    printf "⏱%02d:%02d \n" $MINUTES $SECONDS
else
    # Si está detenido, no muestra nada (deja espacio al reloj)
    echo ""
fi