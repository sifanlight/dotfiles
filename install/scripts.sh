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

# NOTE: upstream did "mv ~/.local/bin -> backup", which wipes out anything
# else living there (pipx/npm/cargo shims, the `claude` symlink, ...).
# Back it up as a COPY and merge the dotfiles scripts on top instead, so
# pre-existing entries survive.
if [ -e "$DEST/.local/bin" ]; then
    ensure_backup_dir

    _info "Backing up existing $DEST/.local/bin (kept in place, not removed)..."
    mkdir -p "$BACKUP_DIR/.local"
    cp -a "$DEST/.local/bin" "$BACKUP_DIR/.local/bin"
fi

mkdir -p "$DEST/.local/bin"
cp -a "$SRC/.local/bin/." "$DEST/.local/bin/"
 
_done "Scripts were installed!"
