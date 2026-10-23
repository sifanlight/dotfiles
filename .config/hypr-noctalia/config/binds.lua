-- ▄▄▄▄· ▪   ▐ ▄ ·▄▄▄▄  .▄▄ · 
-- ▐█ ▀█▪██ •█▌▐███▪ ██ ▐█ ▀. 
-- ▐█▀▀█▄▐█·▐█▐▐▌▐█· ▐█▌▄▀▀▀█▄
-- ██▄▪▐█▐█▌██▐█▌██. ██ ▐█▄▪▐█
-- ·▀▀▀▀ ▀▀▀▀▀ █▪▀▀▀▀▀•  ▀▀▀▀ 
--
-- https://wiki.hypr.land/Configuring/Basics/Binds/

local scripts      = "~/.local/bin/"
local rofi_scripts = "~/.config/rofi/bin/"

local terminal     = "ghostty +new-window"
local file_manager = "dolphin"
local code         = "vscodium"
local browser      = "helium-browser"

-- Amount of workspaces used, no more than 10
local workspaces   = 5

-- Writing hl.ds.exec_cmd() all the time is too long, here is a shortcut
local function run(cmd, window_rules)
    return hl.dsp.exec_cmd(cmd, window_rules)
end

-- Runs script with given name
local function run_script(script_name)
    return hl.dsp.exec_cmd(scripts .. script_name)        
end

-- toggle_rofi is a script that adds toggle behavior to rofi
-- If menu is already shown, script will close it
local function toggle_rofi(cmd)
    return hl.dsp.exec_cmd(scripts .. "toggle_rofi "  .. cmd)
end

local function toggle_rofi_script(script_name)
    return toggle_rofi(rofi_scripts .. script_name)
end

-- Generates layout specific binds to avoid hyprland warnings
local function layout_bind(bind_table)
    return function ()
        local workspace = hl.get_active_special_workspace() or
                          hl.get_active_workspace()

        if not workspace then
            return
        end

        local layout = workspace.tiled_layout
                
        if bind_table[layout] then
            hl.dispatch(bind_table[layout])
        end
    end
end

-- Launch terminal
hl.bind("SUPER + SEMICOLON",         run(terminal))
hl.bind("SUPER + SHIFT + SEMICOLON", run(terminal, {float = true}))

-- Launch some apps
hl.bind("SUPER + B", run(file_manager))
hl.bind("SUPER + N", run(browser))
hl.bind("SUPER + M", run(code))

-- Cycle current workspace layout 
hl.bind("SUPER + tab",         run_script("cycle_layout"))
hl.bind("SUPER + SHIFT + tab", run_script("cycle_layout --prev"))

-- Reload hyprland config, I have misc.disable_autoreload = true
hl.bind("SUPER + CTRL + R",    run("hyprctl reload"))

-- Window actions
hl.bind("SUPER + Q",           hl.dsp.window.close())  -- Close window
hl.bind("SUPER + SHIFT + Q",   hl.dsp.window.kill())   -- Kill window
hl.bind("SUPER + W",           hl.dsp.window.center()) -- Centers window if it is floating
hl.bind("SUPER + U",           hl.dsp.window.pin())    -- Pins floating window
hl.bind("SUPER + Z",           hl.dsp.window.resize({x = -80, y = -75, relative = true})) -- Make window x-80 y-75 smaller 
hl.bind("SUPER + C",           hl.dsp.window.resize({x =  80, y =  75, relative = true})) -- Make window x+80 y+75 bigger
hl.bind("SUPER + SHIFT + F",   hl.dsp.window.fullscreen({ action = "toggle" }))

hl.bind("SUPER + F", function ()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.center())
end) -- Toggle window floating state and center it.

hl.bind("SUPER + P", function ()
    hl.dispatch(hl.dsp.window.float({ action = "off" }))
    hl.dispatch(hl.dsp.window.pseudo())
end) -- Pseudotiles window, ensure it's tiled


-- Current workspace layout based bindings 
hl.bind("SUPER + W", layout_bind({ 
    scrolling = hl.dsp.layout("colresize +conf"),   -- Scrolling:, set next column width from config
    dwindle   = hl.dsp.layout("movetoroot active"), -- Dwindle: make active window the root window
}))

hl.bind("SUPER + SHIFT + W", layout_bind({
    scrolling = hl.dsp.layout("colresize -conf"),  -- Scrolling: set previous column width from config
}))

hl.bind("SUPER + A", layout_bind({
    scrolling = hl.dsp.layout("swapcol l"),  -- Scrolling: swap column with left one
    dwindle   = hl.dsp.layout("swapsplit"),  -- Dwindle: swap window split 
    monocle   = hl.dsp.layout("cycleprev"),  -- Monocle and master: cycle prev window
    master    = hl.dsp.layout("cycleprev"),
}))

-- Show Desktop (dummy workspace): pressing SUPER + D switches to an empty
-- dummy workspace on the current monitor; pressing it again returns to the
-- previous workspace. Kept out of Noctalia's workspace list.
local desktop_previous_workspace = {}

local function toggle_show_desktop()
    local ws = hl.get_active_workspace()
    if not ws then return end

    local mon_name = (ws.monitor and ws.monitor.name) or "default"
    local dummy_name = "dummy_" .. mon_name
    local dummy_target = "name:" .. dummy_name

    if ws.name == dummy_name then
        local prev = desktop_previous_workspace[mon_name]
        if prev then
            if type(prev) == "string" and not prev:match("^name:") and tonumber(prev) == nil then
                hl.dispatch(hl.dsp.focus({ workspace = "name:" .. prev }))
            else
                hl.dispatch(hl.dsp.focus({ workspace = prev }))
            end
        else
            hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
        end
    else
        local special = hl.get_active_special_workspace()
        if special then
            local spec_name = special.name:gsub("^special:", "")
            hl.dispatch(hl.dsp.workspace.toggle_special(spec_name))
        end

        desktop_previous_workspace[mon_name] = (ws.id and ws.id > 0) and ws.id or ws.name
        hl.dispatch(hl.dsp.focus({ workspace = dummy_target }))
    end
end

hl.bind("SUPER + D", toggle_show_desktop)


-- Minimize active window, Press SUPER + X one more time to show it.
-- https://wiki.hypr.land/0.54.0/Configuring/Uncommon-tips--tricks/#minimize-windows-using-special-workspaces
hl.bind("SUPER + X", function ()
    hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
    hl.dispatch(hl.dsp.window.move({workspace = "+0"}))
    hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
    hl.dispatch(hl.dsp.window.move({workspace = "special:minimize"}))
    hl.dispatch(hl.dsp.workspace.toggle_special("minimize"))
end)

-- Group binds
hl.bind("SUPER + O",            hl.dsp.group.toggle()) -- Create windows group
hl.bind("SUPER + bracketleft",  hl.dsp.group.prev())   -- Show previous window in group
hl.bind("SUPER + bracketright", hl.dsp.group.next())   -- Show next window in group
hl.bind("SUPER + SHIFT + O", hl.dsp.window.move({ out_of_group = true})) -- Move window out of group

-- Noctalia IPC controls
local noctalia_msg = "noctalia msg "
hl.bind("SUPER + SPACE",         run(noctalia_msg .. "panel-toggle launcher"))       -- Application launcher
hl.bind("SUPER + R",             run(noctalia_msg .. "panel-toggle launcher"))       -- Application launcher alias
-- Control center is on SUPER + T only. SUPER + S belongs to the special
-- workspace further down; binding both fired the two at once.
hl.bind("SUPER + T",             run(noctalia_msg .. "panel-toggle control-center")) -- Control center & notifications
hl.bind("SUPER + comma",         run(noctalia_msg .. "settings-toggle"))             -- Noctalia settings GUI
hl.bind("ALT + tab",             run(noctalia_msg .. "window-switcher"))             -- Window switcher overlay
hl.bind("SUPER + ESCAPE",        run(noctalia_msg .. "session lock"))                -- Session lock / power
hl.bind("SUPER + V",             run(noctalia_msg .. "panel-toggle clipboard"))      -- Clipboard history
hl.bind("SUPER + E",             run(noctalia_msg .. "panel-toggle session"))        -- Session menu (lock/suspend/reboot/shutdown)
hl.bind("SUPER + ALT + K",       run(noctalia_msg .. "panel-toggle wallpaper"))      -- Wallpaper picker
hl.bind("SUPER + G",             run(noctalia_msg .. "caffeine-toggle"))             -- Keep the machine awake
hl.bind("SUPER + ALT + H",       run(noctalia_msg .. "nightlight-force-toggle"))     -- Force night light on/off
hl.bind("SUPER + ALT + J",       run(noctalia_msg .. "notification-dnd-toggle"))     -- Do not disturb

-- Wallpapers are Noctalia's now, cycling included; auto_walls no longer runs.
hl.bind("SUPER + Y",             run(noctalia_msg .. "wallpaper-random"))            -- Random wallpaper
hl.bind("SUPER + CTRL + Y",      run(noctalia_msg .. "wallpaper-next"))              -- Next wallpaper
hl.bind("SUPER + CTRL + SHIFT + Y", run(noctalia_msg .. "wallpaper-previous"))       -- Previous wallpaper

-- Misc bindings 
hl.bind("SUPER + ALT + SPACE",    run(noctalia_msg .. "keyboard-layout-cycle"))       -- English <-> Persian
hl.bind("SUPER + ALT + M",        run_script("monitors"))                             -- Monitor profile picker (rofi)
hl.bind("SUPER + CTRL + M",       run_script("monitors next"))                        -- Cycle monitor layout
hl.bind("SUPER + CTRL + SHIFT + M", run_script("monitors rescue"))                    -- Rescue: laptop panel only
hl.bind("SUPER + ALT + P",        run_script("monitors portrait"))                    -- Toggle Surface panel portrait (reading)

-- Flex Keyboard detached / attached. The on-screen keyboard only comes on
-- when it is detached and no external monitor is connected, so plugging or
-- unplugging a monitor has to re-check too.
local tablet_switch = "Microsoft Surface POS Tablet Mode Switch"
hl.bind("switch:on:"  .. tablet_switch, run_script("tablet-mode on"),  { locked = true })
hl.bind("switch:off:" .. tablet_switch, run_script("tablet-mode off"), { locked = true })
hl.on("monitor.added",   function() hl.exec_cmd(scripts .. "tablet-mode refresh") end)
hl.on("monitor.removed", function() hl.exec_cmd(scripts .. "tablet-mode refresh") end)
hl.bind("SUPER + SHIFT + Y",      run(noctalia_msg .. "theme-mode-toggle"))           -- Switch between dark/light mode
hl.bind("SUPER + MINUS",          run(noctalia_msg .. "volume-down 2"), {repeating = true}) -- Decrease volume
hl.bind("SUPER + EQUAL",          run(noctalia_msg .. "volume-up 2"), {repeating = true})   -- Increase volume


-- Media, moved off SUPER + comma/period/slash: SUPER + comma is Noctalia's
-- settings toggle, and both binds used to fire together. Routed through
-- Noctalia rather than playerctl so the media OSD shows, matching the
-- XF86 media keys further down.
hl.bind("SUPER + SHIFT + comma",  run(noctalia_msg .. "media previous"))         -- Play previous song
hl.bind("SUPER + SHIFT + period", run(noctalia_msg .. "media next"))             -- Play next song
hl.bind("SUPER + SHIFT + slash",  run(noctalia_msg .. "media toggle"))           -- Play or pause song

hl.bind("Print",                  run(noctalia_msg .. "screenshot-fullscreen"))  -- Screenshot
hl.bind("SHIFT + Print",          run(noctalia_msg .. "screenshot-region"))      -- Screenshot selected area
hl.bind("CTRL + Print",           run_script("screenrec"))                       -- Screen record
hl.bind("CTRL + SHIFT + Print",   run_script("screenrec --select"))              -- Screen record selected area

-- Same four actions on SUPER + I, because this keyboard has no PrtSc key.
-- The Print binds above are kept for keyboards that do have one.
hl.bind("SUPER + I",                 run(noctalia_msg .. "screenshot-fullscreen")) -- Screenshot
hl.bind("SUPER + SHIFT + I",         run(noctalia_msg .. "screenshot-region"))     -- Screenshot selected area
hl.bind("SUPER + CTRL + I",          run_script("screenrec"))                    -- Screen record
hl.bind("SUPER + CTRL + SHIFT + I",  run_script("screenrec --select"))           -- Screen record selected area


-- Move focus:   SUPER + H/J/K/L (vim keys)
-- Move windows: SUPER + CTRL + H/J/K/L
-- Swap windows: SUPER + SHIFT + H/J/K/L
for key, dir in pairs({ H = "left", J = "down", K = "up", L = "right" }) do
    hl.bind("SUPER + " .. key,          hl.dsp.focus({ direction = dir }))
    hl.bind("SUPER + CTRL + " .. key,   hl.dsp.window.move({ direction = dir }))
    hl.bind("SUPER + SHIFT + " .. key,  hl.dsp.window.swap({ direction = dir }))
end

-- Resize active window: SUPER + CTRL + SHIFT + H/J/K/L
hl.bind("SUPER + CTRL + SHIFT + H", hl.dsp.window.resize({ x = -70, y = 0,   relative = true }))
hl.bind("SUPER + CTRL + SHIFT + L", hl.dsp.window.resize({ x =  70, y = 0,   relative = true }))
hl.bind("SUPER + CTRL + SHIFT + K", hl.dsp.window.resize({ x = 0,   y = -70, relative = true }))
hl.bind("SUPER + CTRL + SHIFT + J", hl.dsp.window.resize({ x = 0,   y =  70, relative = true }))

-- Switch workspaces: SUPER + [1-workspaces]
-- Move active window to workspace: SUPER + SHIFT [1-workspaces]
-- Move active window to workspace and follow: SUPER + CTRL [1-workspaces]
for i = 1, workspaces do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + " .. key,         hl.dsp.focus({ workspace = i}))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false}))
    hl.bind("SUPER + CTRL + " .. key,  hl.dsp.window.move({ workspace = i }))
end

-- Toggle a tag on the active window. A bare name toggles; "+name" / "-name"
-- would set / unset. What each tag does is defined by the matching
-- `match = { tag = ... }` rules in rules.lua.
hl.bind("SUPER + backslash",         hl.dsp.window.tag({ tag = "borderless" }))
hl.bind("SUPER + SHIFT + backslash", hl.dsp.window.tag({ tag = "opaque" }))

-- Special workspace
hl.bind("SUPER + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic", follow = false }))
hl.bind("SUPER + CTRL + S",  hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with SUPER + scroll
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Laptop specific function key binds
hl.bind("XF86AudioNext",        run("noctalia msg media next"),                   { locked = true })
hl.bind("code:172",             run("noctalia msg media toggle"),                 { locked = true }) -- XF86AudioPlayPause
hl.bind("XF86AudioPause",       run("noctalia msg media pause"),                  { locked = true })
hl.bind("XF86AudioPlay",        run("noctalia msg media play"),                   { locked = true })
hl.bind("XF86KbdBrightnessUp",  run("noctalia msg keyboard-backlight-up"),        { locked = true })
hl.bind("XF86KbdBrightnessDown",run("noctalia msg keyboard-backlight-down"),      { locked = true })
hl.bind("Pause",                run("noctalia msg media pause"),                  { locked = true })
hl.bind("XF86AudioMute",        run("noctalia msg volume-mute"),                  { locked = true })
hl.bind("XF86AudioPrev",        run("noctalia msg media previous"),               { locked = true })
hl.bind("XF86AudioMicMute",     run("noctalia msg mic-mute"),                     { locked = true })
hl.bind("XF86AudioRaiseVolume", run("noctalia msg volume-up 5"),                  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", run("noctalia msg volume-down 5"),                { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  run("noctalia msg brightness-up 5"),              { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",run("noctalia msg brightness-down 5"),            { locked = true, repeating = true })

hl.bind("XF86Launch1",          run("noctalia msg power-cycle"))
hl.bind("XF86Calculator",       run("qalculate-gtk"))
hl.bind("XF86Launch4",          run("rog-control-center"))
-- XF86PowerOff left unbound: logind suspends on the power key (50-power-keys.conf)

-- Move/resize windows with SUPER + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- SUPER + mouse side buttons step focus through the windows on the workspace
-- (back = right, forward = left). A mouse-triggered focus change doesn't warp
-- the cursor, so follow_mouse would hand focus straight back to the window
-- under it; put the cursor in the middle of the new window instead.
local function focus_and_warp(dir)
    return function ()
        local before = hl.get_active_window()
        hl.dispatch(hl.dsp.focus({ direction = dir }))
        local w = hl.get_active_window()
        if not w or (before and before.address == w.address) then return end
        hl.dispatch(hl.dsp.cursor.move({
            x = w.at.x + w.size.x // 2,
            y = w.at.y + w.size.y // 2,
        }))
    end
end

hl.bind("SUPER + mouse:275", focus_and_warp("right"))
hl.bind("SUPER + mouse:276", focus_and_warp("left"))



hl.bind("SUPER + F1", function ()
    local game_mode = (hl.get_config("animations.enabled") == false)

    if game_mode then
        hl.exec_cmd("hyprctl reload")
        return
    end
    
    hl.config({
        general = {
            gaps_in = 0, gaps_out = 0, -- Disable gaps  
            border_size = 0,
        },

        animations = {
            enabled = false, -- Disable animations
        },
        
        -- Disable blur, shadow and window rounding
        decoration = {
            shadow = { enabled = false },
            blur = { enabled = false },
            rounding = 0,
        }
    })
end)
