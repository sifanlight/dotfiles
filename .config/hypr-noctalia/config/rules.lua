-- ▄▄▌ ▐ ▄▌▪   ▐ ▄ ·▄▄▄▄  ▄▄▌ ▐ ▄▌    ▄▄▄  ▄• ▄▌▄▄▌  ▄▄▄ ..▄▄ · 
-- ██· █▌▐███ •█▌▐███▪ ██ ██· █▌▐█    ▀▄ █·█▪██▌██•  ▀▄.▀·▐█ ▀. 
-- ██▪▐█▐▐▌▐█·▐█▐▐▌▐█· ▐█▌██▪▐█▐▐▌    ▐▀▀▄ █▌▐█▌██▪  ▐▀▀▪▄▄▀▀▀█▄
-- ▐█▌██▐█▌▐█▌██▐█▌██. ██ ▐█▌██▐█▌    ▐█•█▌▐█▄█▌▐█▌▐▌▐█▄▄▌▐█▄▪▐█
--  ▀▀▀▀ ▀▪▀▀▀▀▀ █▪▀▀▀▀▀•  ▀▀▀▀ ▀▪    .▀  ▀ ▀▀▀ .▀▀▀  ▀▀▀  ▀▀▀▀ 
--
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Workspace rules
hl.workspace_rule({ workspace = "special:magic", layout = "dwindle"})

-- The persistent rules for the 5 workspaces from binds.lua live in
-- monitors.lua, not here. They carry a `monitor` as well as `persistent`,
-- and which monitor that is depends on what is plugged in and which
-- profile is active - so they have to be rebuilt on every hotplug, next to
-- the code that already tracks all of that. See WORKSPACE_COUNT there.

-- Layer rules
hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})

hl.window_rule({
    name = "Noctalia Settings",
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size = { 1080, 920 },
})


hl.window_rule({ float = true, match = { class = "org.telegram.desktop", title = "^(Media viewer)" }})
hl.window_rule({ float = true, match = { class = "zenity", title = "^(Winetricks -)(.*)|winetricks" }})

hl.window_rule({ stay_focused = true, match = { class = "xfce-polkit" }})
hl.window_rule({ stay_focused = true, match = { title = "^(Rename device)$", class = "blueman-manager" }})


-- Tags, toggled per window from binds.lua (SUPER + backslash and
-- SUPER + SHIFT + backslash). Tag rules re-evaluate on toggle, so these take
-- effect and undo immediately on the focused window.
hl.window_rule({
    name = "Tag: borderless",
    match = { tag = "borderless" },
    -- Borders are on by default (general.border_size in options.lua), so
    -- the toggle takes one away. Colors come from general.col.*_border,
    -- which noctalia.lua overrides with the wallpaper palette when the
    -- Noctalia "hyprland" template is on.
    border_size = 2,
})

hl.window_rule({
    name = "Tag: opaque",
    match = { tag = "opaque" },
    -- `opaque`, not `opacity = 1`: opacity is a multiplier on the window's
    -- own alpha, so it did nothing for Ghostty/Spotify. `opaque` forces the
    -- surface fully solid regardless of what the app or another rule set.
    opaque = true,
})


hl.window_rule({
    name = "Float by title",
    match = { 
        title = "Font Manager|Volume Control|Qalculate!|Library|Add bookmark"
    },

    float = true,
    center = true,
    persistent_size = true,
})

hl.window_rule({
    name = "Float by class",
    match = { 
        class = "blueman-manager|blueman-services|nwg-look|rog-control-center|org.qbittorrent.qBittorrent|kvantummanager|\
                 org.gnome.seahorse.Application|xfce-polkit|org.polymc.PolyMC|engrampa|nm-connection-editor|system-config-printer|hyprland-share-picker|\
                 org.bleachbit.BleachBit|vlc|exo-desktop-item-edit|xdg-desktop-portal-gtk|org.gnome.eog|qt6ct|xfce-polkit"
    },

    float = true,
    center = true,
    persistent_size = true,
})

hl.window_rule({
    name = "Thunar dialogs",
    match = {
        class = "thunar|Thunar",
        title = 'Rename "*.*"|File Operation Progress|Confirm to replace files|Attention'
    },

    float = true,
    persistent_size = true,
})

hl.window_rule({
    name = "Thunar stayfocused",
    match = {
        class = "thunar|Thunar",
        title = 'Attention|Rename "*.*"|Create Document from .*|New .* ...|Create New Folder'
    },

    stay_focused = true
})

hl.window_rule({
    name = "Thunar move right bottom",
    match = {
        title = "^(File Operation Progress)$",
        class = "(thunar|Thunar)",
    },
    
    focus_on_activate = false,
    move = "1460 970"
})

hl.window_rule({
    name = "Thunar menu force center",
    match = {
        title = "^(Confirm to replace files)$",
        class = "(thunar|Thunar)"
    },

    center = true
})

hl.window_rule({
    name = "Small window size",
    match = {
        class = "org.gnome.seahorse.Application|org.polymc.PolyMC|nwg-look",
    },

    size = "900 600",
    center = true,
})

hl.window_rule({
    name = "Scrolling almost full width",
    match = {
        class = "codium|vesktop|helium-browser|Helium-browser",
    },
    
    scrolling_width = 0.95
})

hl.window_rule({
    name = "Ghostty opacity",
    match = {
        class = "com.mitchellh.ghostty|ghostty|peaclock"
    },

    -- 1 is a multiplier on the window's own alpha, not a force-opaque:
    -- Ghostty's background-opacity (0.7, matching the Noctalia bar) still
    -- shows through, and Hyprland's blur fills in behind it. Two values are
    -- active and inactive; the second mirrors decoration.inactive_opacity
    -- in options.lua, because a rule's `opacity` replaces both globals.
    opacity = "1 0.92",
})

hl.window_rule({
    name = "PdfCraft touchpad scroll",
    match = { class = "ai\\.storyteller\\.pdfcraft" },

    -- input.touchpad.scroll_factor (options.lua) is 0.5, tuned for browsers
    -- that already scroll fast. PdfCraft is egui, which uses the raw deltas,
    -- so at a low factor it barely moves. This replaces the factor for this window.
    scroll_touchpad = 1.0,
})

hl.window_rule({
    name = "Browser Picture in Picture",
    match = {
        title = "(?i)^picture[- ]in[- ]picture$",
    },

    size = "367 206",
    move = "1544 866",
    pin = true,
    float = true,
    no_initial_focus = true,
    focus_on_activate = true,
    keep_aspect_ratio = true,
})

hl.window_rule({
    -- TODO fullscreens all wine apps
    name = "Games in fullscreen",
    match = {
        -- steam_app_<id> is what Proton/Wine games get. Native Linux Source
        -- games use their binary name instead (Dota 2 = dota2, CS2 = cs2).
        class = "^(steam_app_\\d+|dota2|cs2)$",
    },

    fullscreen = true,

    -- Let the game tear: its frames go to the screen the moment they are
    -- ready instead of waiting for vblank, which cuts input latency. Only
    -- takes effect with general.allow_tearing on (options.lua) and while
    -- the game is fullscreen with nothing else visible on that monitor.
    immediate = true,
})

hl.window_rule({
    name = "Spotify pseudotile", -- Extra gaps for Spotify
    match = {
       class = "spotify|Spotify" 
    },

    pseudo = true,
    size = "1850 1000",
    scrolling_width = 1,

    -- Glass look. Unlike Ghostty, Spotify (CEF) cannot paint its own
    -- background translucent - making it `transparent` in spicetify CSS just
    -- shows an opaque #121212 - so the alpha has to come from the compositor.
    -- This dims album art and text along with the background, which is why it
    -- sits higher than Ghostty's 0.7. Hyprland blurs behind it on its own.
    -- Second value is unfocused: 0.8 stepped down by the same 0.92 as
    -- decoration.inactive_opacity in options.lua.
    opacity = "0.8 0.74",
})

hl.window_rule({
    name = "peaclock terminal",
    match = {
        class = "peaclock",
    },

    float = true,
    pin = true,
    size = "500 260",
    move = "711 60",
})

hl.window_rule({
    name = "Dev-tools",
    match = {
        title = "^(DevToolsApp)$"
    },

    float = true,
    move = "50% 15%",
    size = "900 600"
})

hl.window_rule({
    name = "Flameshot",
    match = {
        class = "flameshot"
    },
    float = true,
    fullscreen = true,
})

hl.window_rule({
    name = "Uzerburg",
    match = {
        class = "ueberzugpp(.*)",
    },
    
    float = true,
    no_initial_focus = true
})

hl.window_rule({
    name = "Tag: opaque, unfocused too",
    match = { tag = "opaque" },
    -- `opaque` above only drops the app's own alpha; the inactive_opacity
    -- multiplier and the Ghostty/Spotify `opacity` rules still fade the
    -- window when it loses focus. This rule sits last so it beats them.
    opacity = "1 override 1 override",
})
