#!/bin/bash

# Comprobar si hay baterías (si no, cerrar para sobremesas)
if [ ! -d /sys/class/power_supply/BAT0 ] && [ ! -d /sys/class/power_supply/BAT1 ]; then
    exit 0
fi

AVISO_WARN=15
AVISO_CRIT=5
NOTIFICADO_WARN=false
NOTIFICADO_CRIT=false

while true; do
    ENERGIA_ACTUAL=0
    ENERGIA_MAXIMA=0
    ESTADO="Unknown"

    for bat in /sys/class/power_supply/BAT*; do
        # 1. Detectar si el sistema usa Energy (Wh) o Charge (Ah)
        if [ -f "$bat/energy_now" ]; then
            ACTUAL=$(cat "$bat/energy_now")
            MAXIMA=$(cat "$bat/energy_full")
        elif [ -f "$bat/charge_now" ]; then
            ACTUAL=$(cat "$bat/charge_now")
            MAXIMA=$(cat "$bat/charge_full")
        else
            continue
        fi

        # 2. Ir sumando los valores absolutos (así el tamaño y desgaste no importan)
        ENERGIA_ACTUAL=$((ENERGIA_ACTUAL + ACTUAL))
        ENERGIA_MAXIMA=$((ENERGIA_MAXIMA + MAXIMA))

        # 3. Saber si alguna batería se está descargando
        BAT_STATUS=$(cat "$bat/status")
        if [ "$BAT_STATUS" = "Discharging" ]; then
            ESTADO="Discharging"
        fi
    done

    # 4. Calcular el porcentaje real idéntico al de Waybar
    if [ "$ENERGIA_MAXIMA" -gt 0 ]; then
        # Multiplicamos por 100 antes de dividir para mantener precisión entera
        PORCENTAJE=$(( (ENERGIA_ACTUAL * 100) / ENERGIA_MAXIMA ))
    else
        exit 0
    fi

    # Lógica de alertas
    if [ "$ESTADO" = "Discharging" ]; then
        if [ "$PORCENTAJE" -le "$AVISO_CRIT" ] && [ "$NOTIFICADO_CRIT" = false ]; then
            notify-send -u critical "($PORCENTAJE%)."
            NOTIFICADO_CRIT=true
            NOTIFICADO_WARN=true
        elif [ "$PORCENTAJE" -le "$AVISO_WARN" ] && [ "$PORCENTAJE" -gt "$AVISO_CRIT" ] && [ "$NOTIFICADO_WARN" = false ]; then
            notify-send -u normal "Low battery" "$PORCENTAJE% remaining"
            NOTIFICADO_WARN=true
        fi
    else
        # Si está cargando o Full, reseteamos avisos
        NOTIFICADO_WARN=false
        NOTIFICADO_CRIT=false
    fi

    sleep 60
done