--  ▄▄ • ▄▄▄ ..▄▄ · ▄▄▄▄▄▄• ▄▌▄▄▄  ▄▄▄ ..▄▄ · 
-- ▐█ ▀ ▪▀▄.▀·▐█ ▀. •██  █▪██▌▀▄ █·▀▄.▀·▐█ ▀. 
-- ▄█ ▀█▄▐▀▀▪▄▄▀▀▀█▄ ▐█.▪█▌▐█▌▐▀▀▄ ▐▀▀▪▄▄▀▀▀█▄
-- ▐█▄▪▐█▐█▄▄▌▐█▄▪▐█ ▐█▌·▐█▄█▌▐█•█▌▐█▄▄▌▐█▄▪▐█
-- ·▀▀▀▀  ▀▀▀  ▀▀▀▀  ▀▀▀  ▀▀▀ .▀  ▀ ▀▀▀  ▀▀▀▀ 
--
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/

hl.gesture({
    fingers = 3,
    direction = "vertical",
    action = "workspace"
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "scroll_move",
    scale = 0.9,
})

-- Fullscreen on at pinchin gesture with 4 fingers 
hl.gesture({ fingers = 4, direction = "pinchout", action = function ()
    hl.dispatch(hl.dsp.window.fullscreen({ action="set" })) 
end})

-- Fullscreen off at pinchin gesture with 4 fingers 
hl.gesture({ fingers = 4, direction = "pinchin", action = function ()
    hl.dispatch(hl.dsp.window.fullscreen({ action="unset" })) 
end})

-- Move the active window to the next/previous workspace and follow it on a
-- 4-finger vertical swipe. Fires once the swipe completes; the 3-finger
-- swipe stays the live, follow-the-finger workspace switch.
hl.gesture({ fingers = 4, direction = "up", action = function ()
    hl.dispatch(hl.dsp.window.move({ workspace = "r+1" }))
end})

hl.gesture({ fingers = 4, direction = "down", action = function ()
    hl.dispatch(hl.dsp.window.move({ workspace = "r-1" }))
end})
