#!/bin/sh
# Session environment for KDE Plasma. startplasma sources every *.sh in this
# directory before the session starts.
#
# Hyprland gets the same variables from ~/.config/hypr/config/env.lua; keep
# the two in step. Left out on purpose: everything GPU- or toolkit-specific
# that Plasma decides for itself (AQ_DRM_DEVICES is aquamarine-only and KWin
# follows the boot GPU, i.e. the MUX; QT_QPA_PLATFORMTHEME, XDG_SESSION_TYPE
# and LIBVA_DRIVER_NAME are set or auto-detected by Plasma/libva).

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

export EDITOR=nvim
export TERMINAL=ghostty
export BROWSER=helium-browser
export SCRIPTS="$HOME/.local/bin"

# XDG base directories and the tools taught to respect them
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"

export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export MYSQL_HISTFILE="$XDG_DATA_HOME/mysql/history"
export CARGO_HOME="$XDG_DATA_HOME/rust-cargo"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/cuda"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export KEEPER_STORAGE_DIR="$XDG_STATE_HOME/keeper_storage"
export GOPATH="$XDG_DATA_HOME/go"

# Games / NVIDIA, independent of the desktop
export VKD3D_FILTER_DEVICE_NAME=NVIDIA
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_PATH="$HOME/.cache/nv"
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
