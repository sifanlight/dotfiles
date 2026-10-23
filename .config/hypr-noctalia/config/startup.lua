-- .▄▄ · ▄▄▄▄▄ ▄▄▄· ▄▄▄  ▄▄▄▄▄▄• ▄▌ ▄▄▄·
-- ▐█ ▀. •██  ▐█ ▀█ ▀▄ █·•██  █▪██▌▐█ ▄█
-- ▄▀▀▀█▄ ▐█.▪▄█▀▀█ ▐▀▀▄  ▐█.▪█▌▐█▌ ██▀·
-- ▐█▄▪▐█ ▐█▌·▐█ ▪▐▌▐█•█▌ ▐█▌·▐█▄█▌▐█▪·•
--  ▀▀▀▀  ▀▀▀  ▀  ▀ .▀  ▀ ▀▀▀  ▀▀▀ .▀
-- 
-- https://wiki.hypr.land/Configuring/Basics/Autostart/   

local startup = {
    -- Push session variables into the systemd user manager and D-Bus. Apps
    -- started by D-Bus activation (Ghostty via `ghostty +new-window`, and
    -- everything launched from inside it) inherit *this* environment, not
    -- Hyprland's, so anything they must see has to be listed here.
    -- XDG_SESSION_TYPE: obsidian.nvim picks wl-paste vs xclip from it.
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE",
    -- Starts kwalletd6 (which provides org.freedesktop.secrets) and unlocks the
    -- wallet with the login password handed over by pam_kwallet5 in SDDM.
    -- Nothing D-Bus-activates the Secret Service otherwise, so apps using
    -- libsecret (spotifast, secret-tool, ...) fail with "not activatable".
    "/usr/lib/pam_kwallet_init",
    "gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Ice", -- Set cursor theme in gsettings 
    "hyprctl setcursor Bibata-Modern-Ice 24", -- Set cursor theme for hyprland 
    "wl-clip-persist --clipboard regular", -- Enables clipboard persistence
    -- No cliphist: Noctalia keeps its own clipboard history and SUPER+V opens it.
    "/usr/lib/polkit-kde-authentication-agent-1", -- Policy manager (prompts for sudo access if app requests)
    -- No hypridle: the dim/lock/screen-off/suspend chain moved to Noctalia's
    -- idle service, see [idle] in ~/.local/state/noctalia/settings.toml.
    "noctalia", -- Noctalia all-in-one desktop shell
    "~/.local/bin/at_startup" -- Misc user defined custom shell scripts
}

hl.on("hyprland.start", function()
    for i = 1, #startup do
        hl.exec_cmd(startup[i])
    end
end)

