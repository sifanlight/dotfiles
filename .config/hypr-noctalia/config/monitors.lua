-- • ▌ ▄ ·.        ▐ ▄  ▪  ▄▄▄▄▄      ▄▄▄  .▄▄ · 
-- ·██ ▐███▪▪     •█▌▐█ ██ •██  ▪     ▀▄ █·▐█ ▀. 
-- ▐█ ▌▐▌▐█· ▄█▀▄ ▐█▐▐▌ ▐█· ▐█.▪ ▄█▀▄ ▐▀▀▄ ▄▀▀▀█▄
-- ██ ██▌▐█▌▐█▌.▐▌██▐█▌ ▐█▌ ▐█▌·▐█▌.▐▌▐█•█▌▐█▄▪▐█
-- ▀▀  █▪▀▀▀ ▀█▄▀▪▀▀ █▪ ▀▀▀ ▀▀▀  ▀█▄▀▪.▀  ▀ ▀▀▀▀ 
--
-- https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Four profiles, switched at runtime - no editing this file to dock or
-- undock. The chosen profile is remembered in a state file and re-applied
-- on startup, on `hyprctl reload`, and whenever a monitor is plugged or
-- unplugged.
--
--   extended  internal panel + externals, side by side
--   external  externals only, internal panel off
--   internal  internal panel only, externals off
--   mirror    externals mirror the internal panel
--
-- Switch with `monitors <profile>`, `monitors next`, or SUPER+SHIFT+M.
--
-- The profile is an *intention*, not a promise: a profile that would leave
-- you with no lit screen is downgraded to `internal` for as long as that is
-- true. Save `external`, boot with nothing plugged in, and you come up on
-- the laptop panel; plug the monitor in later and `external` takes effect
-- on its own. That is the whole point of this file - a blank screen here
-- costs a trip to another TTY.

local INTERNAL = "eDP-1"

-- Which side of the internal panel the row of externals lands on.
-- "auto-left" is the layout this config already had; "auto-right" flips it.
-- Only those two mean anything here: the row is laid out by layout() below,
-- and this string is sent to Hyprland verbatim only when a panel's mode
-- cannot be read from /sys.
local EXTERNAL_PLACEMENT = "auto-left"

-- The externals, in the order they physically sit on the desk, left to
-- right. Anything not listed here still works - it just lands on the far
-- left, unrotated, the way every external used to.
--
-- Panels are matched on a string lifted out of their EDID rather than on a
-- connector name, because the connector is a property of the port, not the
-- monitor: the Lenovo is DP-5 through this USB-C port and DP-6 through the
-- other one, but "LEN LT2223pwC" is stamped into the hardware. Read the
-- available strings with `strings /sys/class/drm/card*-<output>/edid`.
--
-- transform is Hyprland's output rotation: 0 none, 1 = 90 degrees,
-- 2 = 180, 3 = 270. An odd transform swaps the panel's logical width and
-- height, which is the whole reason the positions below are computed here
-- instead of being left to Hyprland's `auto-left` - auto placement lays
-- monitors out in the order it happens to see them and has no idea that a
-- rotated 1920x1080 panel is 1080 wide.
--
-- workspaces is the slice of the persistent workspaces that lives on this
-- panel. A panel that claims none still works; it just gets whatever
-- scratch workspace Hyprland parks there.
--
-- position = "up" or "down" takes the panel out of the left-to-right row
-- and centres it above or below the internal panel's slot instead. Leave it
-- out for a panel that belongs in the row. One panel per side: two "up"
-- panels would be stacked on the same spot.
--
-- Two of these are the same model, so the model string alone is ambiguous:
-- both panels would match the first entry, tie on rank, and land in
-- whatever order the sort happened to leave them. The serial is the only
-- string in the EDID that tells them apart.
local DESK = {
    { edid = "F4FJGS2", transform = 0, workspaces = { 1, 2, 3 } },  -- Dell SE2719H (HDMI-A-1), left
    { edid = "25FJGS2", transform = 0, workspaces = { 4, 5 } },     -- Dell SE2719H (DP-5), right
    { edid = "HNAY802838", transform = 0, workspaces = { 1, 2 }, position = "up" },  -- Samsung Odyssey G5 (HDMI-A-1), above
}

-- Internal panel is 2880x1620 native; scale 1.5 gives exactly 1920x1080 logical pixels.
local INTERNAL_SCALE = "1.5"

-- When every real output is disabled, Hyprland conjures this headless
-- placeholder so it does not die. It keeps the compositor alive but shows
-- you nothing, so it must never be counted as a monitor.
local FALLBACK = "FALLBACK"

local STATE_DIR  = os.getenv("HOME") .. "/.local/state/hypr"
local STATE_FILE = STATE_DIR .. "/monitor-profile"
local DEFAULT    = "extended"

local PROFILES = { "extended", "external", "internal", "mirror" }

--------------------------------------------------------------------------
-- state file
--------------------------------------------------------------------------

local function is_profile(name)
    for _, p in ipairs(PROFILES) do
        if p == name then return true end
    end
    return false
end

local function read_profile()
    local f = io.open(STATE_FILE, "r")
    if not f then return DEFAULT end
    local value = (f:read("l") or ""):match("^%s*(%S*)")
    f:close()
    return is_profile(value) and value or DEFAULT
end

local function write_profile(name)
    os.execute("mkdir -p '" .. STATE_DIR .. "'")
    local f = io.open(STATE_FILE, "w")
    if not f then return end
    f:write(name .. "\n")
    f:close()
end

--------------------------------------------------------------------------
-- what is actually plugged in
--------------------------------------------------------------------------

-- /sys is the only source that also sees outputs Hyprland has disabled, and
-- unlike hl.get_monitors() it answers during config parse, before any
-- output exists. DRM names them cardN-<connector>, and <connector> is
-- exactly what Hyprland calls them.
local function connected_outputs()
    local seen, order = {}, {}

    local function add(name)
        if name and name ~= "" and name ~= FALLBACK and not seen[name] then
            seen[name] = true
            order[#order + 1] = name
        end
    end

    local ls = io.popen("ls -1 /sys/class/drm 2>/dev/null")
    if ls then
        for entry in ls:lines() do
            local name = entry:match("^card%d+%-(.+)$")
            if name then
                local status = io.open("/sys/class/drm/" .. entry .. "/status", "r")
                if status then
                    local state = status:read("l")
                    status:close()
                    if state == "connected" then add(name) end
                end
            end
        end
        ls:close()
    end

    -- Belt and braces: anything Hyprland is already driving is plugged in by
    -- definition, whatever /sys had to say about it.
    local ok, monitors = pcall(hl.get_monitors)
    if ok and monitors then
        for _, m in ipairs(monitors) do add(m.name) end
    end

    local externals = {}
    for _, name in ipairs(order) do
        if name ~= INTERNAL then externals[#externals + 1] = name end
    end

    return externals, seen[INTERNAL] == true
end

-- Connector name -> its /sys/class/drm directory. Successful lookups are
-- cached; a miss always rescans, so a newly plugged output is still found.
-- The whole cache dies with the Lua state on every reload anyway.
local drm_dirs = {}

local function drm_path(name)
    if drm_dirs[name] then return drm_dirs[name] end

    local ls = io.popen("ls -1 /sys/class/drm 2>/dev/null")
    if not ls then return nil end

    local dir
    for entry in ls:lines() do
        if entry:match("^card%d+%-(.+)$") == name then
            dir = "/sys/class/drm/" .. entry
            break
        end
    end
    ls:close()

    if dir then drm_dirs[name] = dir end
    return dir
end

-- Native resolution of the output's preferred mode. The first line of DRM's
-- `modes` is the preferred one, in WxH form. Like `status`, this answers
-- during config parse and for outputs Hyprland has disabled, which
-- hl.get_monitors() does not.
local function native_size(name)
    local dir = drm_path(name)
    if not dir then return nil end

    local f = io.open(dir .. "/modes", "r")
    if not f then return nil end
    local line = f:read("l")
    f:close()

    local w, h = (line or ""):match("^(%d+)x(%d+)")
    if not w then return nil end
    return tonumber(w), tonumber(h)
end

-- Where a panel sits on the desk, matched against its raw EDID. Returns the
-- DESK entry and its rank, or nil for a monitor nobody has described.
local function desk_entry(name)
    local dir = drm_path(name)
    if not dir then return nil end

    local f = io.open(dir .. "/edid", "rb")
    if not f then return nil end
    local edid = f:read("a")
    f:close()
    if not edid or edid == "" then return nil end

    for rank, entry in ipairs(DESK) do
        if edid:find(entry.edid, 1, true) then return entry, rank end
    end
    return nil
end

local function transform_of(name)
    local entry = desk_entry(name)
    return (entry and entry.transform) or 0
end

-- Logical size of the internal panel, i.e. after its scale. 2880x1620 / 1.5.
local function internal_size()
    local w, h = native_size(INTERNAL)
    local scale = tonumber(INTERNAL_SCALE) or 1
    if not w or scale <= 0 then return 1920, 1080 end
    return math.floor(w / scale + 0.5), math.floor(h / scale + 0.5)
end

-- Explicit placement for the externals. Panels in the row are laid out in
-- DESK order and packed flush against each other so there is no dead gap
-- for the pointer to fall into. A panel with position = "up" or "down" is
-- centred above or below the internal panel's slot instead. The internal
-- panel owns 0x0 whether or not it is lit, which is what keeps `extended`
-- and `external` showing the externals in the same place.
--
-- Returns a map of output name -> "XxY", or nil if any panel's mode could
-- not be read - in which case the caller falls back to Hyprland's auto
-- placement, which is wrong about rotation but never leaves a screen dark.
local function layout(externals, internal_lit)
    local items = {}
    local pos = {}
    local iw, ih = internal_size()

    for i, name in ipairs(externals) do
        local nw, nh = native_size(name)
        if not nw then return nil end

        local entry, rank = desk_entry(name)
        local transform = (entry and entry.transform) or 0

        local w, h = nw, nh
        if transform % 2 == 1 then w, h = nh, nw end

        local side = entry and entry.position
        if side == "up" or side == "down" then
            local x = math.floor(iw / 2 - w / 2)
            local y = (side == "up") and -h or ih
            pos[name] = x .. "x" .. y
        else
            items[#items + 1] = {
                name  = name,
                width = w,
                -- Listed panels sort above every unlisted one, so a monitor
                -- nobody has described lands on the far left rather than
                -- shouldering into the middle of the desk.
                rank  = entry and (1000 + rank) or i,
            }
        end
    end

    table.sort(items, function(a, b) return a.rank < b.rank end)

    if EXTERNAL_PLACEMENT == "auto-right" then
        local x = internal_lit and iw or 0
        for _, item in ipairs(items) do
            pos[item.name] = x .. "x0"
            x = x + item.width
        end
    else
        local x = 0
        for i = #items, 1, -1 do
            x = x - items[i].width
            pos[items[i].name] = x .. "x0"
        end
    end

    return pos
end

local function enabled_outputs()
    local live = {}
    local ok, monitors = pcall(hl.get_monitors)
    if ok and monitors then
        for _, m in ipairs(monitors) do
            if m.name ~= FALLBACK then live[m.name] = true end
        end
    end
    return live
end

--------------------------------------------------------------------------
-- profile -> monitor specs
--------------------------------------------------------------------------

-- The profile you asked for, narrowed to one that can actually light a screen.
local function resolve(requested, externals, has_internal)
    if #externals == 0 then
        return "internal"
    end
    if not has_internal and (requested == "internal" or requested == "mirror") then
        return "external"
    end
    return requested
end

local function plan(profile, externals, has_internal)
    local specs = {}

    if has_internal then
        specs[#specs + 1] = {
            output   = INTERNAL,
            mode     = "preferred",
            position = "0x0",
            scale    = INTERNAL_SCALE,
            -- Must be `false`, not `0`: in Lua 0 is truthy, so `vrr = 0`
            -- reads as "enable" and turns VRR on - the opposite of the
            -- intent. misc.vrr in options.lua is the other half of this.
            vrr      = false,
            disabled = (profile == "external"),
        }
    end

    -- nil when a mode was unreadable; every spec then falls back to
    -- EXTERNAL_PLACEMENT, exactly as this file behaved before DESK existed.
    local placement = layout(externals, has_internal and profile ~= "external")

    for _, name in ipairs(externals) do
        if profile == "internal" then
            specs[#specs + 1] = { output = name, disabled = true }
        elseif profile == "mirror" then
            specs[#specs + 1] = {
                output    = name,
                mode      = "preferred",
                position  = "0x0",
                scale     = "1",
                -- A physically rotated panel is rotated while it mirrors
                -- too, otherwise the copy arrives on its side.
                transform = transform_of(name),
                mirror    = INTERNAL,
                disabled  = false,
            }
        else -- extended, external
            specs[#specs + 1] = {
                output    = name,
                mode      = "preferred",
                position  = (placement and placement[name]) or EXTERNAL_PLACEMENT,
                scale     = "1",
                transform = transform_of(name),
                -- Mirroring is sticky: a monitor spec that simply omits
                -- `mirror` leaves any previous binding in place, so leaving
                -- the mirror profile has to say "none" out loud. Without
                -- this, mirror -> extended re-sent the position and changed
                -- nothing on screen. "none" is the sentinel Hyprland itself
                -- reports in `mirrorOf` for an unmirrored output.
                mirror    = "none",
                disabled  = false,
            }
        end
    end

    return specs
end

-- resolve() should already guarantee this. It is repeated here because the
-- cost of being wrong is a black screen, and the cost of the check is nil.
local function ensure_lit(specs)
    for _, s in ipairs(specs) do
        if not s.disabled then return specs end
    end

    for _, s in ipairs(specs) do
        if s.output == INTERNAL then
            s.disabled, s.mode, s.position, s.scale = false, "preferred", "0x0", INTERNAL_SCALE
            return specs
        end
    end

    if specs[1] then
        specs[1].disabled, specs[1].mode, specs[1].position, specs[1].scale =
            false, "preferred", "auto", "1"
    end
    return specs
end

--------------------------------------------------------------------------
-- workspaces
--------------------------------------------------------------------------

-- binds.lua binds SUPER+1..WORKSPACE_COUNT, and those workspaces are
-- persistent so Noctalia's widget shows all of them even while empty. Keep
-- this in step with `workspaces` in binds.lua.
local WORKSPACE_COUNT = 5

-- Workspaces the internal panel claims for itself. Empty on purpose: DESK
-- already hands all five to the externals, so with the laptop docked and
-- the lid open there is nothing left to give it. It still picks up every
-- workspace whose panel is dark, which is what covers being undocked.
local INTERNAL_WORKSPACES = {}

-- Where each persistent workspace should live, given what is actually lit.
-- Returns a map of workspace number -> output name, or nil when nothing is
-- lit at all and there is nowhere to put anything.
--
-- Every workspace whose panel is off falls back to a lit one rather than
-- being left homeless: Hyprland will not keep a workspace on a disabled
-- monitor, and a monitor left holding none immediately invents a fresh one.
local function assign(profile, externals, has_internal)
    local internal_lit  = has_internal and profile ~= "external"
    -- A mirrored panel is a copy of the internal one, not an independent
    -- screen, so it holds no workspaces of its own.
    local externals_lit = profile ~= "internal" and profile ~= "mirror"

    local claim, first_external = {}, nil

    if externals_lit then
        local ranked = {}
        for i, name in ipairs(externals) do
            local entry, rank = desk_entry(name)
            ranked[#ranked + 1] = {
                name  = name,
                entry = entry,
                rank  = entry and (1000 + rank) or i,
            }
        end
        table.sort(ranked, function(a, b) return a.rank < b.rank end)

        for _, item in ipairs(ranked) do
            first_external = first_external or item.name
            for _, ws in ipairs(item.entry and item.entry.workspaces or {}) do
                claim[ws] = item.name
            end
        end
    end

    if internal_lit then
        for _, ws in ipairs(INTERNAL_WORKSPACES) do claim[ws] = INTERNAL end
    end

    local fallback = internal_lit and INTERNAL or first_external
    if not fallback then return nil end

    for ws = 1, WORKSPACE_COUNT do
        claim[ws] = claim[ws] or fallback
    end

    return claim
end

-- One live rule per workspace. A rule cannot be re-pointed once made, so
-- moving a workspace to another panel means disabling the old rule and
-- adding a new one - without the disable they pile up and the stale
-- monitor wins.
local ws_rules = {}

local function apply_workspaces(profile, externals, has_internal)
    local claim = assign(profile, externals, has_internal)
    if not claim then return end

    for ws = 1, WORKSPACE_COUNT do
        local target = claim[ws]

        local old = ws_rules[ws]
        if old then pcall(function() old:set_enabled(false) end) end

        local ok, rule = pcall(hl.workspace_rule, {
            workspace  = tostring(ws),
            monitor    = target,
            persistent = true,
        })
        ws_rules[ws] = ok and rule or nil

        -- The rule only decides where a workspace is *created*. One that
        -- already exists has to be told to move.
        local got, live = pcall(hl.get_workspace, ws)
        if got and live and live.monitor and live.monitor.name ~= target then
            pcall(hl.dispatch, hl.dsp.workspace.move({ workspace = ws, monitor = target }))
        end
    end
end

--------------------------------------------------------------------------
-- applying
--------------------------------------------------------------------------

local function notify(text, icon)
    pcall(hl.notification.create, { text = text, timeout = 4000, icon = icon or 1 })
end

-- Hyprland throws the whole Lua state away on reload, so this starts nil
-- every time the config is parsed - which is what we want, since a reload
-- should re-assert the monitor layout rather than assume it still holds.
--
-- What is remembered is the whole intended layout, not just the profile
-- name. With only the name, a dock that brings its panels up one at a time
-- got the first one placed and the second one left wherever Hyprland's
-- catch-all rule dropped it: the profile was already "applied", so the
-- second arrival re-asserted the workspaces and nothing else, and the two
-- panels came up in the wrong order (seen 2026-09-27).
local applied = nil
local busy    = false

local function signature(profile, specs)
    local parts = { profile }
    for _, s in ipairs(specs) do
        parts[#parts + 1] = s.output .. "="
            .. (s.disabled and "off" or tostring(s.position or "auto"))
    end
    table.sort(parts, nil)
    return table.concat(parts, ";")
end

local function apply(requested, announce)
    if busy then return end
    busy = true

    local externals, has_internal = connected_outputs()
    local effective = resolve(requested, externals, has_internal)
    local specs = ensure_lit(plan(effective, externals, has_internal))

    -- Skip the no-op case. Re-applying identical specs would emit fresh
    -- monitor.added/removed events, which land right back here - this is
    -- what stops that from becoming a loop.
    local wanted    = signature(effective, specs)
    local unchanged = (wanted == applied)
    if unchanged then
        local live = enabled_outputs()
        for _, s in ipairs(specs) do
            if (live[s.output] == true) == (s.disabled == true) then
                unchanged = false
                break
            end
        end
    end

    if unchanged then
        -- Layout is already right, but the workspace split still has to be
        -- re-asserted: this is the path a reload takes, and the rules died
        -- with the old Lua state.
        apply_workspaces(effective, externals, has_internal)
        busy = false
        return effective
    end

    -- Screens ON before any go OFF, so the count never passes through zero.
    for _, s in ipairs(specs) do
        if not s.disabled then pcall(hl.monitor, s) end
    end
    for _, s in ipairs(specs) do
        if s.disabled then pcall(hl.monitor, s) end
    end

    -- After the specs, so a workspace is never sent to a monitor that is
    -- still dark.
    apply_workspaces(effective, externals, has_internal)

    applied = wanted
    busy    = false

    if announce and effective ~= requested then
        notify(string.format(
            "Monitors: '%s' needs an external display - holding '%s' until one is plugged in.",
            requested, effective), 0)
    end

    return effective
end

-- Base rules, so an output that appears before the handler runs still comes
-- up with something sane. The empty output is Hyprland's catch-all; it must
-- never be disabled, or an unrecognised monitor arrives dark.
hl.monitor({ output = INTERNAL, mode = "preferred", position = "0x0",
             scale = INTERNAL_SCALE, vrr = false })
hl.monitor({ output = "", mode = "preferred", position = EXTERNAL_PLACEMENT, scale = "1" })

--------------------------------------------------------------------------
-- public interface, reachable from a shell via `hyprctl eval`
--------------------------------------------------------------------------

MONITORS = {
    profiles = PROFILES,
}

function MONITORS.get()
    return read_profile()
end

-- Ask for a profile. Remembers it even when it cannot be honoured yet, so
-- plugging a monitor in later gets you what you actually asked for.
function MONITORS.set(name)
    if not is_profile(name) then
        notify("Monitors: no such profile '" .. tostring(name) .. "'", 3)
        return
    end
    write_profile(name)
    local effective = apply(name, true)
    if effective == name then
        notify("Monitors: " .. name, 5)
    end
end

function MONITORS.next()
    local current = read_profile()
    for i, p in ipairs(PROFILES) do
        if p == current then
            MONITORS.set(PROFILES[(i % #PROFILES) + 1])
            return
        end
    end
    MONITORS.set(DEFAULT)
end

function MONITORS.apply()
    apply(read_profile(), false)
end

-- Panic button. Keybinds still work when the screen is dark, so this is the
-- way back without switching TTY.
function MONITORS.rescue()
    applied = nil
    MONITORS.set("internal")
end

--------------------------------------------------------------------------
-- keep it in step with reality
--------------------------------------------------------------------------

local pending

local function schedule(delay)
    if pending then pcall(function() pending:cancel() end) end
    pending = hl.timer(function()
        pending = nil
        apply(read_profile(), true)
    end, { timeout = delay, type = "oneshot" })
end

-- Hotplug settles over a few frames; let it before reading /sys.
hl.on("monitor.added",   function() schedule(400) end)
hl.on("monitor.removed", function() schedule(400) end)
hl.on("hyprland.start",  function() schedule(500) end)
hl.on("config.reloaded", function() schedule(150) end)

-- Startup and reload both parse this file, and on reload the outputs
-- already exist, so settle the layout immediately rather than waiting.
apply(read_profile(), false)
