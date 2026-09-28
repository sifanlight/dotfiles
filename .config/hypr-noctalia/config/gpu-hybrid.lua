-- GPU environment for supergfxctl **Hybrid** mode (config/gpu.lua -> here).
--
-- The internal panel is wired to the Intel iGPU (0000:00:02.0); HDMI-A-1 and
-- the USB-C DP ports stay on the NVIDIA RTX 3050 (0000:01:00.0). Intel is
-- named FIRST in AQ_DRM_DEVICES so aquamarine makes it the primary
-- render/scanout device and the RTX can runtime-suspend; the RTX stays in the
-- list (second) so the external ports work, at the cost of a PCIe frame copy
-- while one is in use. Games go to the RTX with `prime-run %command%`.
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
    local intel  = card_for_pci("0000:00:02.0")
    local nvidia = card_for_pci("0000:01:00.0")
    if intel and nvidia then return intel .. ":" .. nvidia end
    return intel or nvidia
end)

-- If resolution fails for any reason, leave the variable unset and let
-- Hyprland auto-detect rather than handing it a broken device list.
if ok and devices then
    hl.env("AQ_DRM_DEVICES", devices)
end

-- Hardware video decoding on the iGPU (intel-media-driver), so browsers
-- decode video without waking the RTX.
hl.env("LIBVA_DRIVER_NAME", "iHD")
