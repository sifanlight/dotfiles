# Installs scripts.
source $(dirname "$0")/__base.sh

_script "Installing scripts from $SRC/.local/bin ..."

# Initialize/update submodules (auto_walls)
# NOTE: "git submodule init" alone only registers the submodule; without
# "update" the directory stays EMPTY and ~/.local/bin/auto_walls installs
# as a dangling symlink, silently breaking the wallpaper cycler.
_info "Initializing submodules..."
git -C "$SRC" submodule update --init --recursive
check_status $? "Could not fetch the auto_walls submodule."

if [[ ! -f "$SRC/.local/bin/autowalls/auto_walls.py" ]]; then
    _error "auto_walls submodule is still empty; wallpaper cycling would not work."
    read -r -p "Press ENTER to continue..."
fi

mkdir -p "$DEST/.local/bin"

for SCRIPT_PATH in "$SRC"/.local/bin/*; do
    NAME=$(basename "$SCRIPT_PATH")
    [[ "$NAME" == "autowalls" ]] && continue
    [[ "$NAME" == "README.md" ]] && continue

    if [[ -f "$SCRIPT_PATH" ]]; then
        chmod +x "$SCRIPT_PATH"
        link_file_or_dir "$SCRIPT_PATH" "$DEST/.local/bin/$NAME"
    elif [[ -d "$SCRIPT_PATH" ]]; then
        link_file_or_dir "$SCRIPT_PATH" "$DEST/.local/bin/$NAME"
    elif [[ -L "$SCRIPT_PATH" ]]; then
        link_file_or_dir "$SCRIPT_PATH" "$DEST/.local/bin/$NAME"
    fi
done

# Submodule autowalls directory link
if [[ -d "$SRC/.local/bin/autowalls" ]]; then
    link_file_or_dir "$SRC/.local/bin/autowalls" "$DEST/.local/bin/autowalls"
fi

_done "Scripts were linked and installed!"
