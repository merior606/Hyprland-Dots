#!/usr/bin/env bash

# ==============================================================================
# CONFIGURACIÓN: Cambia esto por la ruta de tu carpeta de wallpapers
# ==============================================================================
WALLPAPER_DIR="$HOME/Hyprland-Dots/wallpapers"
# ==============================================================================

# Verificar si fzf está instalado
if ! command -v fzf &> /dev/null; then
    echo "Error: 'fzf' no está instalado. Instálalo para usar esta TUI."
    exit 1
fi

# Verificar si hyprpaper se está ejecutando
if ! pgrep -x "hyprpaper" &> /dev/null; then
    echo "Error: 'hyprpaper' no se está ejecutando. Inícialo primero."
    exit 1
fi

# Entrar a la carpeta de wallpapers
cd "$WALLPAPER_DIR" || { echo "Error: No se pudo acceder a $WALLPAPER_DIR"; exit 1; }

# TUI con FZF: Lista imágenes, muestra una vista previa en la terminal (si usas kitty/ghostty/wezterm)
# y permite seleccionar una.
SELECTION=$(find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sed 's|^\./||' | fzf \
    --ansi \
    --prompt="Selecciona Wallpaper: " \
    --border=rounded \
    --margin=5% \
    --layout=reverse \
    --height=80%)

# Si el usuario cancela (Presiona ESC)
if [ -z "$SELECTION" ]; then
    echo "Selección cancelada."
    exit 0
fi

# Ruta absoluta del archivo seleccionado
FULL_PATH="$WALLPAPER_DIR/$SELECTION"

echo "Aplicando: $SELECTION..."

# Conseguir la lista de monitores activos en Hyprland
MONITORS=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

# 1. Precargar el nuevo wallpaper en hyprpaper
hyprctl hyprpaper preload "$FULL_PATH"

# 2. Aplicarlo a cada monitor activo
while read -r monitor; do
    if [ ! -z "$monitor" ]; then
        hyprctl hyprpaper wallpaper "$monitor,$FULL_PATH"
    fi
done <<< "$MONITORS"

# 3. Descargar wallpapers anteriores para no saturar la memoria RAM
hyprctl hyprpaper unload unused

echo "¡Listo! Fondo actualizado."