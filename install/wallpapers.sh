# Move wallpapers.
source $(dirname "$0")/__base.sh

_script "Installing wallpapers ..."
_info "Copying wallpapers to $DEST/Pictures/wallpapers ..."

mkdir -p "$DEST"/Pictures/
cp -r "$SRC"/wallpapers "$DEST"/Pictures/

_done "Wallpapers were installed!"
