-- • ▌ ▄ ·.        ▐ ▄  ▪  ▄▄▄▄▄      ▄▄▄  .▄▄ · 
-- ·██ ▐███▪▪     •█▌▐█ ██ •██  ▪     ▀▄ █·▐█ ▀. 
-- ▐█ ▌▐▌▐█· ▄█▀▄ ▐█▐▐▌ ▐█· ▐█.▪ ▄█▀▄ ▐▀▀▄ ▄▀▀▀█▄
-- ██ ██▌▐█▌▐█▌.▐▌██▐█▌ ▐█▌ ▐█▌·▐█▌.▐▌▐█•█▌▐█▄▪▐█
-- ▀▀  █▪▀▀▀ ▀█▄▀▪▀▀ █▪ ▀▀▀ ▀▀▀  ▀█▄▀▪.▀  ▀ ▀▀▀▀ 
--
-- https://wiki.hypr.land/Configuring/Basics/Monitors/

-- Internal laptop panel. 2880x1620 native; scale 1.5 gives exactly
-- 1920x1080 logical pixels (Hyprland requires a scale that lands on
-- whole pixels, so 1.5 is clean where KDE's 1.4 would not be).
local default_monitor = "eDP-1"

-- vrr = false here is belt-and-braces only. It pins this panel's idle state,
-- but it does NOT stop misc.vrr from enabling Adaptive Sync when a window
-- goes fullscreen - that is why misc.vrr is 0 in options.lua. Keeping both.
--
-- NOTE: must be `false`, not `0`. In Lua 0 is truthy, so `vrr = 0` reads as
-- "enable" and turns VRR on - the opposite of what is intended here.
hl.monitor({
    output   = default_monitor,
    mode     = "preferred",
    position = "0x0",
    scale    = "1.5",
    vrr      = false,
})

-- Any other monitor that gets plugged in: use its preferred mode and
-- extend to the right of the internal panel.
-- (The upstream config mirrored everything onto the laptop panel, which
-- misbehaves here because HDMI-A-1 reports as connected.)
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "1",
})
