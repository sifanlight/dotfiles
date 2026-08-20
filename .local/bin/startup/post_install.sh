#!/bin/bash
# Runs once on the first Hyprland login, then deletes itself.

SCRIPTS="${SCRIPTS:-$HOME/.local/bin}"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
DEFAULT_WALLPAPER="$WALLPAPER_DIR/rain_road_tree_foggy_bush_flowers_girl_umbrela_grey_outside_mountain.jpg"

if ! command -v awww >/dev/null 2>&1; then
    notify-send 'Error: awww is not installed!' "Please install it with your package manager" \
        --icon="dialog-error" --app-name="post_install"
    exit 1
fi

if [[ -f "$DEFAULT_WALLPAPER" ]]; then
    awww img "$DEFAULT_WALLPAPER"
else
    # Fall back to whatever is in the wallpapers dir
    FALLBACK=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f | head -n 1)
    [[ -n "$FALLBACK" ]] && awww img "$FALLBACK"
fi

notify-send "Generating thumbnails for wallpapers" "Please wait..." \
    --icon="preferences-desktop-wallpaper" --app-name="post_install"

python3 "$SCRIPTS/auto_walls" rofi --gen-thumbnails

notify-send "Thumbnails were generated!" \
    --icon="preferences-desktop-wallpaper" --app-name="post_install"

# Self destroy (upstream pointed at $SCRIPTS/hook/startup/, which does not exist)
rm -f "$SCRIPTS/startup/post_install.sh"
