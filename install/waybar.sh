# Install waybar config files
source $(dirname "$0")/__base.sh

_script "Installing waybar config files..."

link_file_or_dir "$SRC/.config/waybar" "$DEST/.config/waybar"

_done "Waybar config was successfully installed!"

