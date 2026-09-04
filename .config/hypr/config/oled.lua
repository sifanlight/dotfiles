--  ▄▄▄ .▄▄▌  ▄▄▄ .·▄▄▄▄
--  ▀▄.▀·██•  ▀▄.▀·██▪ ██
--  ▐▀▀▪▄██▪  ▐▀▀▪▄▐█· ▐█▌
--  ▐█▄▄▌▐█▌▐▌▐█▄▄▌██. ██
--   ▀▀▀ .▀▀▀  ▀▀▀ ▀▀▀▀▀•
--
-- Burn-in mitigation for the internal OLED panel. Two halves:
--
--   * a checkerboard mask over the bar strip, applied by ~/.local/bin/oled-care
--     through hyproled - blanks every other physical pixel and flips which
--     ones on each pass, so no pixel under the bar stays lit
--   * a one-pixel nudge of the gaps here, which walks the window borders
--     across neighbouring pixels instead of letting them sit on the same
--     line for hours
--
-- Both are no-ops when the OLED is not the lit display.
--
-- Temporarily:  oled-care off   (sticky - survives reloads and reboots)
-- Permanently:  oled-care uninstall

local OLED             = "eDP-1"
local INTERVAL_MINUTES = 20
local NUDGE            = 0  -- logical px (set to 0 to disable gap jitter)
local SCRIPT           = os.getenv("HOME") .. "/.local/bin/oled-care"
local FLAG_DISABLED    = os.getenv("HOME") .. "/.local/state/hypr/oled-care/disabled"

-- `oled-care off` drops this file in place; while it is there nothing here
-- touches the layout or the shader.
local function disabled()
    local f = io.open(FLAG_DISABLED, "r")
    if not f then return false end
    f:close()
    return true
end

-- gaps_in/gaps_out can be numbers or CSS-gap tables; offset adds to each component.
local function offset_gap(gap, offset)
    if type(gap) == "table" then
        local res = {}
        for k, v in pairs(gap) do
            res[k] = (tonumber(v) or 0) + offset
        end
        return res
    end
    return (tonumber(gap) or 0) + offset
end

-- Read once per parse. This file is required *after* options.lua, so these
-- are your configured numbers - and because Hyprland rebuilds the Lua state
-- on every reload, they are re-read then too. The jitter is therefore always
-- base or base+NUDGE and can never accumulate.
local base_in  = hl.get_config("general.gaps_in")
local base_out = hl.get_config("general.gaps_out")

local phase = 0

local function oled_lit()
    local ok, monitors = pcall(hl.get_monitors)
    if not ok or not monitors then return false end
    for _, m in ipairs(monitors) do
        if m.name == OLED then return true end
    end
    return false
end

local function set_gaps(offset)
    hl.config({ general = {
        gaps_in  = offset_gap(base_in, offset),
        gaps_out = offset_gap(base_out, offset),
    } })
end

-- Put the layout back exactly as configured and drop the shader. Uses the
-- internal `clear`, not `off`, so this never sets the sticky flag itself.
local function stand_down()
    if phase ~= 0 then
        phase = 0
        set_gaps(0)
    end
    hl.exec_cmd(SCRIPT .. " clear")
end

-- One protection pass: move the borders, flip the checkerboard.
local function tick()
    if disabled() or not oled_lit() then
        stand_down()
        return
    end
    phase = 1 - phase
    set_gaps(phase * NUDGE)
    hl.exec_cmd(SCRIPT .. " apply")
end

-- Re-assert the right state without disturbing the layout, for when the set
-- of lit monitors changes underneath us.
local function sync()
    if not disabled() and oled_lit() then
        hl.exec_cmd(SCRIPT .. " apply")
    else
        stand_down()
    end
end

-- Reachable from a shell via `hyprctl eval`, for testing and for binding a
-- key to an immediate pass or an immediate stand-down.
OLED_CARE = { tick = tick, sync = sync, stand_down = stand_down }

hl.timer(tick, { timeout = INTERVAL_MINUTES * 60 * 1000, type = "repeat" })

-- Wait for waybar to map before the first pass, so its height can be
-- measured rather than guessed.
hl.timer(sync, { timeout = 8000, type = "oneshot" })

local pending
local function schedule()
    if pending then pcall(function() pending:cancel() end) end
    pending = hl.timer(function() pending = nil; sync() end,
                       { timeout = 1500, type = "oneshot" })
end

hl.on("monitor.added",   schedule)
hl.on("monitor.removed", schedule)
