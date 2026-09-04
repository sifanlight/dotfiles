# Install swaync config files
source $(dirname "$0")/__base.sh

_script "Installing swaync configuration files..."

link_file_or_dir "$SRC/.config/swaync" "$DEST/.config/swaync"

_done "Swaync config was successfully installed!"

