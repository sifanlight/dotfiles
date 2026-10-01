#!/bin/bash
# KDE Plasma settings that make Plasma coexist with the Hyprland setup.
#
# These live in KConfig files that Plasma rewrites itself, so they are applied
# with kwriteconfig6 instead of being symlinked into the repo. Idempotent.

source $(dirname "$0")/__base.sh

_script "Applying KDE Plasma settings..."

if ! command -v kwriteconfig6 >/dev/null 2>&1; then
    _warning "kwriteconfig6 not found (Plasma not installed?), skipping."
    exit 0
fi

# Same keyboard layouts as Hyprland (options.lua: kb_layout = "us,ir").
kwriteconfig6 --file kxkbrc --group Layout --key Use true
kwriteconfig6 --file kxkbrc --group Layout --key LayoutList "us,ir"

# NumLock on at login, as in Hyprland (numlock_by_default = true). 0 = on.
kwriteconfig6 --file kcminputrc --group Keyboard --key NumLock 0

# Stop Plasma's "GNOME/GTK Settings Synchronization" service. It rewrites
# ~/.config/gtk-3.0, gtk-4.0 and xsettingsd, which are tracked here and
# rendered by Noctalia's theme templates under Hyprland; left on, every Plasma
# session dirties the repo and changes the GTK look back in Hyprland.
kwriteconfig6 --file kded6rc --group Module-gtkconfig --key autoload false

_done "KDE Plasma settings applied (take effect at the next Plasma login)."
