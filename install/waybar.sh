# Install waybar config files
source $(dirname "$0")/__base.sh

_script "Installing waybar config files..."

# Previous waybar config file exists
if [[ -e "$DEST/.config/waybar" ]]; then
    _info "Previous waybar config found, backing up..."

    ensure_backup_dir

    mkdir -p "$BACKUP_DIR"/.config
    mv "$DEST/.config/waybar" "$BACKUP_DIR"/.config
fi

mkdir -p "$DEST/.config/waybar"
cp -r "$SRC/.config/waybar" "$DEST/.config/"

# If there is powerprofilesctl installed, replace waybar start module with power-profiles module
if which powerprofilesctl >/dev/null 2>&1; then
    _info "Replacing 'custom/start' module with power-profiles-daemon ..."
    
    # Upstream pointed at layouts/with_music.jsonc and layouts/with_window.jsonc,
    # which do not exist in this repo, so the swap silently never happened.
    # The module lives in config.jsonc / modules.jsonc.
    WAYBAR_FILES=(
        "$DEST/.config/waybar/config.jsonc"
        "$DEST/.config/waybar/modules.jsonc"
    )

    for FILE in "${WAYBAR_FILES[@]}"; do
        [[ -f "$FILE" ]] && sed -i 's|custom/start|power-profiles-daemon|g' "$FILE"
    done
else
    _warning "powerprofilesctl is not installed, 'custom/start' module will be used instead"
fi

# NOTE: the clock module deliberately has no "timezone" key, so waybar uses
# the system local time. Nothing to patch here - a hardcoded timezone only
# went stale whenever modules.jsonc was copied over the installed one.

_done "Waybar config was successfully installed!"
