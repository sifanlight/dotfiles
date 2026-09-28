-- ▄▄▄ . ▐ ▄  ▌ ▐·
-- ▀▄.▀·•█▌▐█▪█·█▌
-- ▐▀▀▪▄▐█▐▐▌▐█▐█•
-- ▐█▄▄▌██▐█▌ ███ 
--  ▀▀▀ ▀▀ █▪. ▀  
--
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

local HOME = os.getenv("HOME")

hl.env("EDITOR", "nvim")
hl.env("TERMINAL", "ghostty")
hl.env("BROWSER", "helium-browser")
hl.env("SCRIPTS", HOME .. "/.local/bin")

-- GPU used for hyprland.
--
-- This laptop has a MUX. The GPU-specific environment (AQ_DRM_DEVICES order,
-- VA-API driver) lives in one of two files:
--   config/gpu-hybrid.lua  <- supergfxctl Hybrid      (panel on Intel)
--   config/gpu-nvidia.lua  <- supergfxctl AsusMuxDgpu (panel on the RTX)
-- config/gpu.lua is a symlink to the one `gfx hybrid` / `gfx nvidia`
-- (~/.local/bin/gfx) last chose; that script also asks supergfxd to flip the
-- MUX and reboots, since the MUX only changes at boot.
--
-- Safety net: the symlink is a promise, the MUX register is the truth. If the
-- two disagree at startup (BIOS change, supergfxctl run by hand, forgotten
-- reboot), naming the wrong card first makes every frame get rendered on one
-- GPU and copied to the other for the panel. So the register wins when it is
-- readable, and a notification says which file was loaded and how to
-- realign. When the register is unreadable (driver change, other laptop) the
-- symlink is used as-is.
local GPU_FILES = { hybrid = "config.gpu-hybrid", nvidia = "config.gpu-nvidia" }

local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local data = f:read("*a")
    f:close()
    return data
end

-- asus-wmi exposes the MUX itself: 0 = dGPU wired to the panel (AsusMuxDgpu),
-- 1 = iGPU wired to the panel (Hybrid, or Integrated with the dGPU off).
local function mux_mode()
    local v = read_file("/sys/devices/platform/asus-nb-wmi/gpu_mux_mode")
    if not v then return nil end
    if v:match("^%s*0%s*$") then return "nvidia" end
    if v:match("^%s*1%s*$") then return "hybrid" end
end

-- What config/gpu.lua currently points at, from the symlink target's name.
local function linked_mode()
    local here = HOME .. "/.config/hypr/config"
    local ok, src = pcall(function() return debug.getinfo(1, "S").source end)
    if ok and type(src) == "string" then
        here = src:match("^@(.*)/[^/]*$") or here
    end
    local ok2, target = pcall(function()
        local p = io.popen("readlink -- '" .. here .. "/gpu.lua' 2>/dev/null")
        if not p then return nil end
        local out = p:read("*l")
        p:close()
        return out
    end)
    if ok2 and type(target) == "string" then
        return target:match("gpu%-(%w+)%.lua$")
    end
end

local linked   = linked_mode()
local detected = mux_mode()
local chosen   = detected or linked or "hybrid"

require(GPU_FILES[chosen])

if detected and linked and detected ~= linked then
    hl.on("hyprland.start", function()
        hl.exec_cmd(string.format(
            "notify-send -u critical -a Hyprland 'GPU config out of sync' " ..
            "'The MUX is in %s mode but config/gpu.lua points at %s. " ..
            "Loaded gpu-%s.lua for this session. Run: gfx %s'",
            detected, linked, detected, detected))
    end)
end

-- Disable mgpu buffer sync?? no clue what it does. 
-- hl.env("AQ_MGPU_NO_EXPLICIT", "1")

-- Disables realtime priority setting by Hyprland. I Allready have ananicy
hl.env("HYPRLAND_NO_RT", "1")

-- Wayland realted variables
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("DESKTOP_SESSION", "Hyprland")
hl.env("XCURSOR_THEME", "WhiteSur-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Vulkan and nvidia related things
hl.env("VKD3D_FILTER_DEVICE_NAME", "NVIDIA") -- Force nvidia for VKD3D
-- Left disabled: with Intel driving the panel, GL/Vulkan apps land on the
-- iGPU by default, which is what we want for the desktop. Run games and
-- other heavy apps on the dGPU with `prime-run <cmd>` (package nvidia-prime),
-- or in Steam: `prime-run %command%`. Hard-coding the ICD list here would
-- push *everything* onto the RTX and keep it awake.
-- hl.env("VK_ICD_FILENAMES", "/usr/share/vulkan/icd.d/nvidia_icd.json")

-- User queue suppor for amd mesa dirvers.
-- https://www.phoronix.com/news/Mesa-25.0-AMDGPU-User-Queue
-- Disabled: no AMD GPU in this machine.
-- hl.env("AMD_USERQ", "1")

-- GTK4 apps use discrete gpu, this fixes it
-- I've put the same into /etc/environment 
hl.env("GSK_RENDERER", "opengl")

-- Hardware video decoding (LIBVA_DRIVER_NAME etc.) is set in config/gpu-*.lua.

-- Nvidia cache related variables
hl.env("__GL_SHADER_DISK_CACHE", "1")                        -- Force caching. It might not cache shaders sometimes
hl.env("__GL_SHADER_DISK_CACHE_PATH", HOME .. "/.cache/nv")  -- Store shaders cache here
hl.env("__GL_SHADER_DISK_CACHE_SKIP_CLEANUP", "1")           -- Do not cleanup nvidia shaders cache

-- Qt related environment variables
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_QPA_PLATFORMTHEME", "kde") -- follow KDE kdeglobals (Edna theme)
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- What the hell is this?
-- Basically helps apps to figure out where to store:
local XDG_STATE_HOME  = HOME .. "/.local/state" -- App related state files
local XDG_DATA_HOME   = HOME .. "/.local/share" -- App related data 
local XDG_CONFIG_HOME = HOME .. "/.config"      -- App related configuration files
local XDG_CACHE_HOME  = HOME .. "/.cache"       -- App related cache files

-- Using these, your $HOME will have less weird directories and files
-- For more info see https://wiki.archlinux.org/title/XDG_Base_Directory
--                   https://wiki.archlinux.org/title/XDG_user_directories

-- Global XDG environment variables 
hl.env("XDG_STATE_HOME",  XDG_STATE_HOME)
hl.env("XDG_DATA_HOME",   XDG_DATA_HOME)
hl.env("XDG_CONFIG_HOME", XDG_CONFIG_HOME)
hl.env("XDG_CACHE_HOME",  XDG_CACHE_HOME)

-- XDG *user* directories are NOT redefined here. They are read back out of
-- ~/.config/user-dirs.dirs and exported unchanged, so scripts that reference
-- $XDG_PICTURES_DIR / $XDG_VIDEOS_DIR (screenshot, screenrec, ...) work while
-- user-dirs.dirs remains the single source of truth for where things live.
local function export_user_dirs()
    local f = io.open(XDG_CONFIG_HOME .. "/user-dirs.dirs", "r")

    if not f then
        return
    end

    for line in f:lines() do
        local key, value = line:match('^%s*(XDG_[%u_]+_DIR)%s*=%s*"(.-)"%s*$')

        if key and value then
            hl.env(key, (value:gsub("%$HOME", HOME)))
        end
    end

    f:close()
end

export_user_dirs()

-- Force misc apps use XDG base directories
hl.env("GNUPGHOME",             XDG_DATA_HOME   .. "/gnupg")
hl.env("MYSQL_HISTFILE",        XDG_DATA_HOME   .. "/mysql/history")
hl.env("CARGO_HOME",            XDG_DATA_HOME   .. "/rust-cargo")
hl.env("CUDA_CACHE_PATH",       XDG_CACHE_HOME  .. "/cuda")
hl.env("NPM_CONFIG_USERCONFIG", XDG_CONFIG_HOME .. "/npm/npmrc")
hl.env("WGETRC",                XDG_CONFIG_HOME .. "/wgetrc")
hl.env("DOCKER_CONFIG",         XDG_CONFIG_HOME .. "/docker")
hl.env("KEEPER_STORAGE_DIR",    XDG_STATE_HOME  .. "/keeper_storage")
hl.env("GOPATH",                XDG_DATA_HOME   .. "/go")
hl.env("GOMODCACHE",            XDG_CACHE_HOME  .. "/go/mod")
hl.env("PYTHON_HISTORY",        XDG_STATE_HOME  .. "/python_history")

hl.env("_JAVA_OPTIONS", "-Djava.util.prefs.userRoot="..XDG_CONFIG_HOME.."/java")
hl.env("GTK2_RC_FILES", string.format("%s/gtk-2.0/gtkrc:%s/gtk-2.0/gtkrc.mine", 
                                       XDG_CONFIG_HOME, XDG_CONFIG_HOME))

