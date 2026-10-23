-- Touchscreen gestures for the Surface panel, via the hyprgrass plugin.
-- https://github.com/horriblename/hyprgrass
--
-- Hyprland's own hl.gesture only listens to the touchpad, so finger-count
-- swipes on the screen need a plugin. Built from ~/.local/src/hyprgrass at
-- the commit hyprpm.toml pins to the running Hyprland, without hyprpm.
--
-- After every Hyprland update run `hyprgrass-rebuild`, then log out and
-- back in. Until then the old build refuses to load and this file quietly
-- does nothing: no touch gestures, everything else unaffected.

local PLUGIN = os.getenv("HOME") .. "/.local/lib/hyprland/libhyprgrass.so"

local function plugin_loaded()
    local ok, plugins = pcall(hl.get_loaded_plugins)
    if not ok or not plugins then return false end
    for _, p in ipairs(plugins) do
        if p.name == "hyprgrass" then return true end
    end
    return false
end

-- Not loaded yet: wait for startup to finish, load it from outside, then
-- reload so this file runs again with the plugin present. Loading it during
-- the very first parse segfaults Hyprland 0.56.2 before it is up (tested in
-- a nested session, 2026-10-23), so hl.plugin.load is not used here.
-- hyprland.start fires once per session, so a build that refuses to load
-- cannot turn this into a reload loop.
if not plugin_loaded() then
    hl.on("hyprland.start", function()
        local f = io.open(PLUGIN, "rb")
        if not f then return end
        f:close()
        hl.exec_cmd("hyprctl plugin load '" .. PLUGIN .. "' && hyprctl reload")
    end)
    return
end

local ok, hyprgrass = pcall(function() return hl.plugin.hyprgrass end)
if not ok or not hyprgrass then return end

pcall(function()
    hl.config({
        plugin = {
            hyprgrass = {
                -- The default 1.0 is meant for small screens; the hyprgrass
                -- docs suggest 4.0 for tablets.
                sensitivity = 4.0,
            },
        },
    })

    -- 3 fingers up/down: change workspace, following the fingers like the
    -- 3-finger touchpad swipe in gestures.lua.
    hyprgrass.gesture({
        pattern = { kind = "swipe", fingers = 3, direction = "vertical" },
        action  = "workspace",
    })

    -- 3 fingers left/right: focus the next window on the same workspace.
    -- Fires once the fingers lift.
    hyprgrass.bind({
        pattern = { kind = "swipe", fingers = 3, direction = "left" },
        action  = hl.dsp.focus({ direction = "right" }),
    })
    hyprgrass.bind({
        pattern = { kind = "swipe", fingers = 3, direction = "right" },
        action  = hl.dsp.focus({ direction = "left" }),
    })
end)
