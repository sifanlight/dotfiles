# hypr-noctalia

The live Hyprland setup: Hyprland's Lua config plus the pieces that make the
[Noctalia](https://github.com/noctalia-dev/noctalia-shell) shell and this
laptop's two-GPU hardware work. `~/.config/hypr` is a symlink to this
directory (`switch-to-noctalia` sets it; `switch-to-classic` points it back
at the older waybar setup in `../hypr`).

## Layout

| path | what |
|---|---|
| `hyprland.lua` | entry point, requires everything under `config/` |
| `config/*.lua` | one file per topic (monitors, env, binds, options, rules, ...) |
| `config/gpu.lua` | symlink to `gpu-hybrid.lua` or `gpu-nvidia.lua`, managed by `gfx` |
| `config/colors/` | hand-written palettes, `init.lua` picks dark/light |
| `noctalia/settings.toml` | snapshot of `~/.local/state/noctalia/settings.toml` (bar layout, widgets, theme templates). Copy it there on a fresh install; refresh the snapshot by hand when the bar config changes |
| `hypridle.conf`, `hyprlock.conf` | idle and lock |

Generated at runtime and gitignored: `noctalia.lua` and `hyprtoolkit.conf`
are rendered by Noctalia's theme templates on every palette change.
`hyprland.lua` tolerates `noctalia.lua` being absent, so the config loads on
a fresh install before Noctalia has run.

## GPU modes (ASUS Q540VJ: Iris Xe + RTX 3050 behind a MUX)

`gfx status | hybrid | nvidia` (`~/.local/bin/gfx`) switches the MUX through
`supergfxctl`, repoints `config/gpu.lua`, and reboots. `env.lua` also reads
the MUX register at startup and follows the hardware if the symlink is stale,
with a notification.

- **hybrid**: panel on Intel, RTX runtime-suspends. Games: Steam launch
  option `prime-run %command%`. External ports are on the RTX, so a plugged
  monitor keeps it awake and costs a PCIe copy per frame.
- **nvidia** (`AsusMuxDgpu`): panel on the RTX, no copies, no `prime-run`.
  The mode for gaming and for the desk.

`nvidia-powerd` (Dynamic Boost, 35 W -> 65 W) is started by supergfxd the
instant the driver loads and negotiates a bogus ~25 W cap if the GPU is
asleep or too early. `etc/systemd/system/nvidia-powerd-restart.timer`
restarts it a minute after boot while holding the GPU awake. Install on a
new machine:

```sh
sudo install -m755 ~/dotfiles/usr/local/lib/nvidia-powerd-restart.sh /usr/local/lib/
sudo install -m644 ~/dotfiles/etc/systemd/system/nvidia-powerd-restart.{service,timer} /etc/systemd/system/
sudo systemctl daemon-reload && sudo systemctl enable nvidia-powerd-restart.timer
```

Check under load: `nvidia-smi --query-gpu=pstate,power.draw,clocks.mem --format=csv`.
Memory at 810 MHz means the cap is back; `sudo systemctl restart nvidia-powerd`
with the GPU awake clears it.

## Fresh install checklist

1. `bootstrap.sh` links this directory to `~/.config/hypr-noctalia` and the
   scripts into `~/.local/bin`.
2. `switch-to-noctalia` to point `~/.config/hypr` here.
3. `mkdir -p ~/.local/state/noctalia && cp noctalia/settings.toml ~/.local/state/noctalia/`
4. Install the systemd units above.
5. `gfx status`; if the MUX and the config disagree, run the matching `gfx <mode>`.
