require("config.monitors")
require("config.env")
require("config.startup")
require("config.binds")
require("config.options")
require("config.gestures")
require("config.rules")
require("config.animations")
require("config.oled")

-- For Noctalia Color templates. noctalia.lua is rendered by Noctalia's
-- "hyprland" template (it is gitignored), so on a fresh install it does not
-- exist until Noctalia has run once: don't let that take the whole config down.
local ok, noctalia = pcall(function() return require("noctalia") end)
if ok then noctalia.apply_theme() end

