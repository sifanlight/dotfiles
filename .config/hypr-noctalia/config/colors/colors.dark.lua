-- Derived from the KDE "Edna" global theme (~/.config/kdeglobals).
--   Window background   38,50,56    #263238
--   Button background   44,58,65    #2c3a41
--   DecorationFocus     146,110,228 #926ee4  (accent)
--   Selection bg        113,92,176  #715cb0
--   ForegroundNormal    237,240,242 #edf0f2
--   ForegroundInactive  172,180,196 #acb4c4
return {
    border = {
        active   = "rgb(926ee4)",   -- KDE DecorationFocus / accent
        inactive = "rgba(263238db)", -- KDE window background, translucent
    },

    group = {
        active   = "0x00000000",
        inactive = "0x00000000",
        text     = "rgb(edf0f2)",   -- KDE ForegroundNormal
    },

    groupbar = {
        active   = "0xE6263238",    -- KDE window bg, ~90% opaque
        inactive = "0xB32c3a41",    -- KDE button bg, ~70% opaque
    }
}
