-- .▄▄ · ▄▄▄▄▄ ▄▄▄· ▄▄▄  ▄▄▄▄▄▄• ▄▌ ▄▄▄·
-- ▐█ ▀. •██  ▐█ ▀█ ▀▄ █·•██  █▪██▌▐█ ▄█
-- ▄▀▀▀█▄ ▐█.▪▄█▀▀█ ▐▀▀▄  ▐█.▪█▌▐█▌ ██▀·
-- ▐█▄▪▐█ ▐█▌·▐█ ▪▐▌▐█•█▌ ▐█▌·▐█▄█▌▐█▪·•
--  ▀▀▀▀  ▀▀▀  ▀  ▀ .▀  ▀ ▀▀▀  ▀▀▀ .▀
-- 
-- https://wiki.hypr.land/Configuring/Basics/Autostart/   

local startup = {
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",  -- Update some dbus variables
    "gsettings set org.gnome.desktop.interface cursor-theme WhiteSur-cursors", -- Set cursor theme in gsettings 
    "hyprctl setcursor WhiteSur-cursors 24", -- Set cursor theme for hyprland 
    "wl-clip-persist --clipboard regular", -- Enables clipboard persistence
    "wl-paste --type text --watch cliphist -max-items=35 store", -- Enable clipboard for text
    "wl-paste --type image --watch cliphist -max-items=10 store", -- Enable clipboard for images
    "awww-daemon", -- Wallpapers daemon
    "~/.local/bin/waybar-auto --watch", -- waybar (external monitor if connected, else eDP-1)
    "swaync", -- swaync
    "/usr/lib/polkit-kde-authentication-agent-1", -- Policy manager (prompts for sudo access if app requests)
    "hypridle", -- "Idle daemon"
    "hyprshell run", -- Workspace & window switcher / overview
    "~/.local/bin/dock", -- dock
    "~/.local/bin/at_startup" -- Misc user defined custom shell scripts
}

hl.on("hyprland.start", function()
    for i = 1, #startup do
        hl.exec_cmd(startup[i])
    end
end)
