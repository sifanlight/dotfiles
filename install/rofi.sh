# Install waybar config files
source $(dirname "$0")/__base.sh

_script "Installing rofi configuration files..."

link_file_or_dir "$SRC/.config/rofi" "$DEST/.config/rofi"


if rofi -h | grep -qE 'drun-(games|utils|network|media|text)'; then
    _info "Patched rofi detected, adding special modes buttons"

    mkdir -p "$DEST/.config/rofi/bin"
    cat > "$DEST/.config/rofi/bin/drun" <<'EOF'
rofi -theme ~/.config/rofi/themes/launcher.rasi \
     -show drun \
     -modi "drun,drun-utils,drun-games,drun-network,drun-media" \
     -drun-exclude-categories "Game" \
     -display-drun "" \
     -display-drun-games "󰊴" \
     -display-drun-utils "" \
     -display-drun-network "󰭹" \
     -display-drun-media "󰲍" \
EOF

fi

_done "Rofi config was successfully installed!"
