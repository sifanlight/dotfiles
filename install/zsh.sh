source $(dirname "$0")/__base.sh

_script "Installing zsh configuration and plugins..."

# Install oh-my-zsh if missing
if [[ ! -d "$DEST/.oh-my-zsh" ]]; then
    _info "Installing oh-my-zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null || true
fi

# Ensure custom plugins are installed
ZSH_CUSTOM="${ZSH_CUSTOM:-$DEST/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    _info "Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    _info "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true
fi

_info "Linking .zshrc ..."
link_file_or_dir "$SRC/.zshrc" "$DEST/.zshrc"

_done "zsh configuration and plugins installed!"

