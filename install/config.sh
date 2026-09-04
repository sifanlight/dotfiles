# Installs/symlinks configuration files from .config and .local
source $(dirname "$0")/__base.sh

_script "Installing config files"
_info "Linking configuration files from $SRC/.config to $DEST/.config ..."

ensure_backup_dir
mkdir -p "$DEST/.config"

# Link all configs from .config
for CONFIG_PATH in "$SRC"/.config/*; do
    NAME=$(basename "$CONFIG_PATH")
    
    _info "Linking: $NAME"
    link_file_or_dir "$CONFIG_PATH" "$DEST/.config/$NAME"
done

# Link root shell & git configuration files
_info "Linking root config files (.zshrc, .bashrc, .gitconfig) ..."
[[ -f "$SRC/.zshrc" ]] && link_file_or_dir "$SRC/.zshrc" "$DEST/.zshrc"
[[ -f "$SRC/.bashrc" ]] && link_file_or_dir "$SRC/.bashrc" "$DEST/.bashrc"
[[ -f "$SRC/.gitconfig" ]] && link_file_or_dir "$SRC/.gitconfig" "$DEST/.gitconfig"

# Ensure ~/.tmux.conf points to ~/.config/tmux/tmux.conf
if [[ -f "$DEST/.config/tmux/tmux.conf" ]]; then
    _info "Linking ~/.tmux.conf -> ~/.config/tmux/tmux.conf"
    link_file_or_dir "$DEST/.config/tmux/tmux.conf" "$DEST/.tmux.conf"
fi

# Ensure TPM is cloned and plugins are installed for tmux
if [[ ! -d "$DEST/.tmux/plugins/tpm" ]]; then
    _info "Cloning Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$DEST/.tmux/plugins/tpm" 2>/dev/null || true
fi

# Link ~/.tmux/plugins <-> ~/.config/tmux/plugins to keep both paths consistent
mkdir -p "$DEST/.config/tmux/plugins"
if [[ -x "$DEST/.tmux/plugins/tpm/bin/install_plugins" ]]; then
    _info "Installing tmux plugins (Catppuccin, sensible, navigator, etc.)..."
    "$DEST/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 || true
    # Sync to ~/.config/tmux/plugins for configs referencing that path
    cp -a "$DEST/.tmux/plugins/." "$DEST/.config/tmux/plugins/" 2>/dev/null || true
fi


# Install/merge .local/share applications and templates
_info "Setting up $SRC/.local/share ..."
for SHARE_DIR in applications templates; do
    if [[ -d "$SRC/.local/share/$SHARE_DIR" ]]; then
        mkdir -p "$DEST/.local/share/$SHARE_DIR"
        cp -a "$SRC/.local/share/$SHARE_DIR/." "$DEST/.local/share/$SHARE_DIR/"
    fi
done

for LOCAL_SHARE_PATH in "$SRC"/.local/share/*; do
    NAME=$(basename "$LOCAL_SHARE_PATH")
    if [[ "$NAME" == "applications" || "$NAME" == "templates" ]]; then
        continue
    fi
    _info "Installing $NAME ..."
    link_file_or_dir "$LOCAL_SHARE_PATH" "$DEST/.local/share/$NAME"
done

# Reload systemd user daemon if user services are present
if which systemctl >/dev/null 2>&1; then
    _info "Reloading systemd user daemon..."
    systemctl --user daemon-reload 2>/dev/null || true
    if [[ -f "$DEST/.config/systemd/user/hyprshell.service" ]]; then
        systemctl --user enable hyprshell.service 2>/dev/null || true
    fi
fi

_done "Config and setting files were installed and linked!"