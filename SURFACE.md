# surface branch

`main` as it runs on a Surface Pro 9 (Intel only, linux-surface kernel,
Hyprland 0.56 Lua config + Noctalia). Copy files by hand; the install and
bootstrap scripts target the ASUS laptop and do not work here.

`.config/hypr-noctalia/` is installed as `~/.config/hypr/`, and
`.config/hypr-noctalia/noctalia/settings.toml` as
`~/.local/state/noctalia/settings.toml`.

## Differences from main

- **Monitors** (`config/monitors.lua`): internal panel at scale 1.5 and
  `highrr` (the panel reports 60 Hz as preferred but does 120). Portrait
  toggle for reading: SUPER+ALT+P, the rotate button on the Noctalia bar, or
  `monitors portrait`. Touch and pen are pinned to eDP-1 and rotate with it.
- **No GPU/MUX or OLED config**: `gpu*.lua` and `oled.lua` are gone, and
  `env.lua` has no GPU block.
- **Touchscreen gestures** (`config/touch.lua`): the hyprgrass plugin.
  3 fingers up/down changes workspace, left/right moves focus between the
  windows on a workspace.
- **Tablet mode** (`binds.lua`, `.local/bin/tablet-mode`): detaching the Flex
  Keyboard turns on squeekboard, but only while no external monitor is
  connected.
- **Palm rejection** (`etc/iptsd.d/90-palm.conf`): touch is ignored while the
  pen is near the screen.
- Smaller ones: vim keys (H/J/K/L) for moving/swapping/resizing windows,
  touchpad `disable_while_typing = true`, kwallet started from
  `startup.lua`, and tmux following Noctalia's palette (`tmux-noctalia.*`
  units, `noctalia-catppuccin.conf`).

## After a fresh install

```sh
sudo pacman -S --needed squeekboard iptsd meson ninja glm
sudo cp etc/iptsd.d/90-palm.conf /etc/iptsd.d/
systemctl --user enable --now tmux-noctalia.path
hyprgrass-rebuild    # builds the plugin into ~/.local/lib/hyprland
```

Run `hyprgrass-rebuild` again after every Hyprland update, then log out and
back in. Until then the old plugin won't load and touch gestures are off;
nothing else is affected.

To restart iptsd, don't use `systemctl restart`: the unit stops itself when
nothing needs it. Use
`sudo udevadm trigger --action=add /sys/class/hidraw/hidrawN` instead
(find N with `systemctl list-units 'iptsd*'`).
