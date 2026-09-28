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

-- Hyprshell workspace overview on 4-finger swipe up
hl.gesture({ fingers = 4, direction = "up", action = function ()
    hl.exec_cmd("hyprshell socat '\"OpenOverview\"'")
end})

-- Close hyprshell workspace overview on 4-finger swipe down
hl.gesture({ fingers = 4, direction = "down", action = function ()
    hl.exec_cmd('sh -c "hyprctl layers | grep -q hyprshell_overview && hyprshell socat \\"\\"OpenOverview\\"\\""')
end})
