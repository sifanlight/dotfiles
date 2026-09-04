# Ghostty config

Cross-platform Ghostty setup, ported from the iTerm2 profile **"Modern"**.
Ghostty reads `~/.config/ghostty/` on **both macOS and Linux**, so this whole
directory copies over as-is.

## Install on a new machine

```sh
git clone <this repo> ~/.config/ghostty     # or just copy the directory
cd ~/.config/ghostty && ./install.sh
```

`install.sh` links `platform/current.conf` to the right fragment for the OS
and validates the result. Re-run it any time; it only touches that symlink.

## Layout

| Path | Purpose |
|---|---|
| `config` | Cross-platform settings — colors, font, window, keybinds |
| `platform/darwin.conf` | macOS-only |
| `platform/linux.conf` | Linux / KDE-only |
| `platform/current.conf` | Symlink created by `install.sh` (gitignored) |
| `themes/iterm2-modern-{light,dark}` | Color palettes |

Included files load **after** the file that includes them, so anything in
`platform/current.conf` overrides `config`.

## Linux / KDE notes

### 1. Install the font

The config asks for `JetBrainsMono Nerd Font Mono`, falling back to
`JetBrains Mono`, then `monospace`. To get the real thing:

```sh
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip && rm JetBrainsMono.zip
fc-cache -f
```

Confirm Ghostty sees it, and that the `SemiBold`/`ExtraBold` styles the config
references are present:

```sh
ghostty +list-fonts | grep -A20 'JetBrainsMono Nerd Font Mono'
```

### 2. Light/dark switching

`theme = light:…,dark:…` follows the desktop color scheme through the
`org.freedesktop.appearance` portal. On Plasma that needs
**`xdg-desktop-portal-kde`** installed. Without it Ghostty falls back to the
light entry — which is still a dark palette here, so it degrades harmlessly.

### 3. Global hotkey (the old iTerm2 hotkey window)

`keybind = global:ctrl+alt+space=toggle_quick_terminal` needs the
**GlobalShortcuts** desktop portal, which means `xdg-desktop-portal-kde` on
**Plasma 6 under Wayland**. On X11, or with the portal missing, the binding
silently fails to register — check `ghostty +validate-config` output and the
Ghostty log. The quick terminal itself also wants Wayland layer-shell; on X11
it degrades to an ordinary window.

### 4. Keys that differ from macOS on purpose

- Copy/paste stay at Ghostty's Linux defaults, **Ctrl+Shift+C / Ctrl+Shift+V**,
  which is also what Konsole uses. macOS keeps Cmd+C / Cmd+V.
- `super+ctrl+t` = new window mirrors the macOS Cmd+Ctrl+T. KDE may already
  own that chord — check System Settings → Shortcuts if it doesn't fire.

### 5. Optional transparency

The commented `background-opacity` / `background-blur` lines in `config` need
the **Blur** effect enabled under System Settings → Desktop Effects.

## Provenance

Generated 2026-08-19 from the iTerm2 profile "Modern"
(guid `A4592203-DEDD-43AD-A938-ED1B1C38BE8A`) in
`~/Library/Preferences/com.googlecode.iterm2.plist`.

Deliberately **not** ported: iTerm2's 1000-line scrollback (Ghostty's 10MB
default is better) and `AllowClipboardAccess` (Ghostty asks before letting a
program read the clipboard, which is the safer default).
