local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.enable_wayland = false

return config
