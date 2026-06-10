#!/usr/bin/env bash

# ==============================================================================
# CONFIGURACIÓN
# ==============================================================================
WALLPAPER_DIR="$HOME/Hyprland-Dots/wallpapers"  # Cambia esto a tu carpeta de wallpapers
CACHE_DIR="$HOME/.cache/wallpaper-selector"
THUMBNAIL_WIDTH="250"  # Tamaño de miniaturas en px (16:9)
THUMBNAIL_HEIGHT="141"

# Crear directorio de caché si no existe
mkdir -p "$CACHE_DIR"

_wwp_has() { command -v "$1" &>/dev/null; }

# Función para aplicar el fondo usando tu lógica original + la limpieza de memoria
set_wallpaper() {
    [[ -z "$1" ]] && return 1

    echo "Aplicando: $1..."

    if _wwp_has swaybg; then
        pkill -x swaybg 2>/dev/null || true
        swaybg --image "$1" --mode fill &
    elif _wwp_has swaymsg; then
        swaymsg output "*" bg "$1" fill
    else
        # Tu script personalizado para Hyprland
        /home/blackgaze/Scripts/hyprWallpaper.sh "$1" &
    fi

    # Si usas hyprpaper dentro de tu script personalizado, esto descargará
    # de la memoria RAM los wallpapers anteriores que ya no se usen.
    if _wwp_has hyprctl; then
        (sleep 1 && hyprctl hyprpaper unload unused) &
    fi
}

# Función para generar miniaturas
generate_thumbnail() {
    local input="$1"
    local output="$2"
    magick "$input" -thumbnail "${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT}^" -gravity center -extent "${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT}" "$output"
}

# Crear miniatura del icono "Shuffle" sobre la marcha
SHUFFLE_ICON="$CACHE_DIR/shuffle_thumbnail.png"
if [ -f "$HOME/Repos/wallpaper-selector/assets/shuffle.png" ]; then
    magick -size "${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT}" xc:#1e1e2e \
        \( "$HOME/Repos/wallpaper-selector/assets/shuffle.png" -resize "80x80" \) \
        -gravity center -composite "$SHUFFLE_ICON"
else
    # Fallback por si no encuentra el recurso en Repos, crea un fondo plano con texto
    magick -size "${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT}" xc:#1e1e2e -gravity center -fill white -pointsize 18 -draw "text 0,0 '🎲 RANDOM'" "$SHUFFLE_ICON"
fi

# Generar el menú optimizado para Wofi dmenu
generate_menu() {
    # Opción aleatoria: Guardamos la palabra clave "RANDOM_WP" en el texto visible de wofi
    echo -e "img:$SHUFFLE_ICON:text:🎲 Aleatorio (Random)"

    # Añadir todos los wallpapers de la carpeta
    for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp}; do
        # Saltar si no hay coincidencias
        [[ -f "$img" ]] || continue

        # Nombre base para la caché
        filename=$(basename "$img")
        thumbnail="$CACHE_DIR/${filename%.*}.png"

        # Generar miniatura si no existe o si el original es más nuevo
        if [[ ! -f "$thumbnail" ]] || [[ "$img" -nt "$thumbnail" ]]; then
            generate_thumbnail "$img" "$thumbnail"
        fi

        # El formato plano "img:ruta:text:nombre_visible" es el más estable en Wofi
        echo "img:$thumbnail:text:$filename"
    done
}

# Lanzar Wofi en modo dmenu
# Nota: Wofi dmenu devuelve exactamente la línea de texto seleccionada.
selection=$(generate_menu | wofi --show dmenu \
    --cache-file /dev/null \
    --define "image-size=${THUMBNAIL_WIDTH}x${THUMBNAIL_HEIGHT}" \
    --columns 3 \
    --allow-images \
    --insensitive \
    --sort-order=default \
    --prompt "Select Wallpaper" \
    --conf ~/.config/wofi/wallpaper.conf)

# Si el usuario canceló o cerró Wofi
[[ -z "$selection" ]] && exit 0

# Procesar la selección
if [[ "$selection" == *"🎲 Aleatorio"* ]]; then
    # Elegir un archivo al azar que sea imagen
    original_path=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)
else
    # Extraer el nombre del archivo de texto eliminando el prefijo "img:...:text:"
    selected_filename=$(echo "$selection" | sed -E 's/^img:.*:text://')
    original_path="$WALLPAPER_DIR/$selected_filename"
fi

# Validar y aplicar
if [[ -f "$original_path" ]]; then
    set_wallpaper "$original_path"

    # Guardar persistencia
    echo "$original_path" > "$HOME/.cache/current_wallpaper"

    # Notificación visual del sistema
    _wwp_has notify-send && notify-send "Wallpaper" "Fondo de pantalla actualizado con éxito" -i "$original_path"
else
    _wwp_has notify-send && notify-send "Wallpaper Error" "No se pudo encontrar el archivo original."
fi