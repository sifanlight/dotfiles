-- GPU environment for supergfxctl **AsusMuxDgpu** mode (config/gpu.lua -> here).
--
-- The MUX wires the internal panel (and HDMI-A-1) straight to the NVIDIA RTX
-- 3050 (0000:01:00.0). NVIDIA is named FIRST in AQ_DRM_DEVICES so it is the
-- primary render/scanout device: games render and display on the same GPU
-- with no copy, which is why this mode is the one for gaming. The Intel iGPU
-- (0000:00:02.0) has only disconnected DP outputs here and is kept second
-- only so nothing breaks if a port turns out to be routed to it. `prime-run`
-- is unnecessary in this mode.
--
-- AQ_DRM_DEVICES is a COLON-separated list, and PCI paths under
-- /dev/dri/by-path/ themselves contain colons (pci-0000:01:00.0-card), so
-- those cannot be used here: aquamarine splits them into garbage and exits
-- with "Found no gpus to use". Resolve the stable PCI address to its
-- (colon-free) /dev/dri/cardN at startup instead, since cardN numbering is
-- not guaranteed to be stable across boots.
local function card_for_pci(pci)
    for i = 0, 15 do
        local f = io.open("/sys/class/drm/card" .. i .. "/device/uevent", "r")
        if f then
            local uevent = f:read("*a")
            f:close()
            if uevent:find("PCI_SLOT_NAME=" .. pci, 1, true) then
                return "/dev/dri/card" .. i
            end
        end
    end
end

local ok, devices = pcall(function()
    local nvidia = card_for_pci("0000:01:00.0")
    local intel  = card_for_pci("0000:00:02.0")
    if nvidia and intel then return nvidia .. ":" .. intel end
    return nvidia or intel
end)

-- If resolution fails for any reason, leave the variable unset and let
-- Hyprland auto-detect rather than handing it a broken device list.
if ok and devices then
    hl.env("AQ_DRM_DEVICES", devices)
end

-- Hardware video decoding on the RTX: libva-nvidia-driver, with
-- NVD_BACKEND=direct so it uses NVDEC directly instead of going through
-- VDPAU. Without these, browsers fall back to CPU decoding.
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
