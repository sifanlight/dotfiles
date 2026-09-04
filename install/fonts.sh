source $(dirname "$0")/__base.sh

_script "Installing fonts and fontconfig..."

if which pacman >/dev/null 2>&1; then
    if ! pacman -Q noto-fonts noto-fonts-emoji ttf-cascadia-code ttf-cascadia-code-nerd >/dev/null 2>&1; then
        echo_and_exec sudo pacman -S noto-fonts noto-fonts-emoji ttf-cascadia-code ttf-cascadia-code-nerd --noconfirm
    else
        _info "Fonts are allready installed."
    fi
else
    _error "Not an arch based distro. Please install fonts manually:"
    echo "         - noto-fonts"
    echo "         - noto-fonts-emoji"
    echo "         - ttf-cascadia-code"
    echo "         - ttf-cascadia-code-nerd"
    read -r -p "Press ENTER to continue..."
    exit
fi

link_file_or_dir "$SRC/.config/fontconfig" "$DEST/.config/fontconfig"


# A *user* fontconfig does not need root; running fc-cache as root only
# rebuilds root's cache and needlessly prompts for a password.
_info "Updating fonts cache..."
echo_and_exec fc-cache -f