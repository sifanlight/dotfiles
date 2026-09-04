#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Setup & Bootstrap Script
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

BACKUP_DIR="${HOME}/.local/old/dotfiles-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
export BACKUP_DIR

export SRC="$DIR"
export DEST="$HOME"

COLOR_BLUE='\033[0;34m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

_info()    { printf "${COLOR_GREEN}[INFO]${COLOR_RESET} %s\n" "$*"; }
_warn()    { printf "${COLOR_YELLOW}[WARN]${COLOR_RESET} %s\n" "$*"; }
_err()     { printf "${COLOR_RED}[ERROR]${COLOR_RESET} %s\n" "$*"; }
_heading() { printf "\n${COLOR_BLUE}=== %s ===${COLOR_RESET}\n" "$*"; }

show_banner() {
    printf "${COLOR_BLUE}"
    cat << 'BANNER'
   ___         __   _____ __          
  / _ \___  __/ /_ / _(_) /__ ___     
 / // / _ \/ _  // _// / / -_|_-<     
/____/\___/\__/_/_/ /_/_/\__/___/     
        Bootstrap & Sync Setup
BANNER
    printf "${COLOR_RESET}\n"
}

show_banner

LINK_ONLY=0
for arg in "$@"; do
    case "$arg" in
        --link-only) LINK_ONLY=1 ;;
        --help|-h)
            echo "Usage: ./bootstrap.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --link-only   Only link dotfiles without installing packages"
            echo "  --help, -h    Show this help message"
            exit 0
            ;;
    esac
done

# Step 1: Package Installation (if not skipped)
if [ "$LINK_ONLY" -eq 0 ]; then
    _heading "Package Verification & Installation"
    if command -v pacman >/dev/null 2>&1; then
        read -r -p "Do you want to verify and install missing system packages? [y/N] " install_pkgs
        if [[ "$install_pkgs" =~ ^[Yy]$ ]]; then
            # Official packages
            if [ -f "$DIR/packages.txt" ]; then
                _info "Checking official repository packages..."
                MISSING=()
                while IFS= read -r line || [[ -n "$line" ]]; do
                    pkg=$(echo "$line" | sed 's/#.*//' | tr -d '[:space:]')
                    [[ -z "$pkg" ]] && continue
                    if ! pacman -Q "$pkg" >/dev/null 2>&1; then
                        MISSING+=("$pkg")
                    fi
                done < "$DIR/packages.txt"

                if [ ${#MISSING[@]} -gt 0 ]; then
                    _info "Installing missing official packages: ${MISSING[*]}"
                    sudo pacman -Sy --needed "${MISSING[@]}"
                else
                    _info "All official packages are already installed."
                fi
            fi

            # AUR packages
            AUR_HELPER=""
            if command -v yay >/dev/null 2>&1; then
                AUR_HELPER="yay"
            elif command -v paru >/dev/null 2>&1; then
                AUR_HELPER="paru"
            fi

            if [ -n "$AUR_HELPER" ] && [ -f "$DIR/packages.aur.txt" ]; then
                _info "Checking AUR packages via $AUR_HELPER..."
                MISSING_AUR=()
                while IFS= read -r line || [[ -n "$line" ]]; do
                    pkg=$(echo "$line" | sed 's/#.*//' | tr -d '[:space:]')
                    [[ -z "$pkg" ]] && continue
                    if ! pacman -Q "$pkg" >/dev/null 2>&1; then
                        MISSING_AUR+=("$pkg")
                    fi
                done < "$DIR/packages.aur.txt"

                if [ ${#MISSING_AUR[@]} -gt 0 ]; then
                    _info "Installing missing AUR packages: ${MISSING_AUR[*]}"
                    "$AUR_HELPER" -S --needed "${MISSING_AUR[@]}"
                else
                    _info "All AUR packages are already installed."
                fi
            fi
        fi
    else
        _warn "Pacman not found (non-Arch system). Skipping automatic package installation."
    fi
fi

# Step 2: Link Configurations (.config, .zshrc, .bashrc, .gitconfig, .tmux.conf)
_heading "Linking Dotfiles Configurations"
"$DIR/install/config.sh"

# Step 3: Link Scripts (~/.local/bin)
_heading "Linking Scripts into ~/.local/bin"
"$DIR/install/scripts.sh"

# Step 4: Shell Setup (Zsh & Oh-My-Zsh plugins)
_heading "Shell Configuration"
"$DIR/install/zsh.sh"

# Step 5: Update font cache
if command -v fc-cache >/dev/null 2>&1; then
    _info "Refreshing font cache..."
    fc-cache -f >/dev/null 2>&1 || true
fi

_heading "Setup Complete!"
_info "All dotfiles and scripts have been linked directly to $DIR."
_info "Any changes you make in ~/.config/ or ~/.local/bin/ will immediately be reflected in git."
if [ -d "$BACKUP_DIR" ]; then
    _info "Pre-existing files were safely backed up to: $BACKUP_DIR"
fi
echo ""
echo "Next steps:"
echo "  - Reload Hyprland: hyprctl reload"
echo "  - In tmux, press 'prefix + I' (Ctrl+A then Shift+I) to fetch TPM plugins"
echo "  - Push to your git remote when ready: git push -u origin main"
echo ""
