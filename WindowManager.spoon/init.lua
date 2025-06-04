local obj = {}
obj.__index = obj
obj.name = "WindowManager"
obj.version = "0.2"
obj.author = "Troels Lund <trolund@gmail.com>"
obj.license = "MIT"

local Direction = {
    LEFT = "left",
    RIGHT = "right",
    UP = "up",
    DOWN = "down"
}

local highlightWatcher = nil

local function screenFrame(win)
    return win:screen():frame()
end

local function snapWindow(win, relX, relY, relW, relH)
    local sf = screenFrame(win)
    win:setFrame({
        x = sf.x + sf.w * relX,
        y = sf.y + sf.h * relY,
        w = sf.w * relW,
        h = sf.h * relH
    })
end

local snapZones = {
    leftHalf = function(win) snapWindow(win, 0, 0, 0.5, 1) end,
    rightHalf = function(win) snapWindow(win, 0.5, 0, 0.5, 1) end,
    topHalf = function(win) snapWindow(win, 0, 0, 1, 0.5) end,
    bottomHalf = function(win) snapWindow(win, 0, 0.5, 1, 0.5) end,
    topLeftQuarter = function(win) snapWindow(win, 0, 0, 0.5, 0.5) end,
    topRightQuarter = function(win) snapWindow(win, 0.5, 0, 0.5, 0.5) end,
    bottomLeftQuarter = function(win) snapWindow(win, 0, 0.5, 0.5, 0.5) end,
    bottomRightQuarter = function(win) snapWindow(win, 0.5, 0.5, 0.5, 0.5) end,
    leftThird = function(win) snapWindow(win, 0, 0, 1/3, 1) end,
    middleThird = function(win) snapWindow(win, 1/3, 0, 1/3, 1) end,
    rightThird = function(win) snapWindow(win, 2/3, 0, 1/3, 1) end,
    full = function(win) win:maximize() end
}

obj.lastDirection = nil
obj.lastSnapIndex = {
    left = 1,
    right = 1,
    up = 1,
    down = 1
}

local zoneSequences = {
    left = {
        snapZones.leftHalf,
        snapZones.leftThird,
        snapZones.topLeftQuarter,
        snapZones.bottomLeftQuarter,
    },
    right = {
        snapZones.rightHalf,
        snapZones.rightThird,
        snapZones.topRightQuarter,
        snapZones.bottomRightQuarter,
    },
    up = {
        snapZones.topHalf,
        snapZones.full,
    },
    down = {
        snapZones.bottomHalf,
        snapZones.full,
    }
}

local function snapCycle(win, direction)
    if obj.lastDirection ~= direction then
        obj.lastSnapIndex[direction] = 1
        obj.lastDirection = direction
    end
    local index = obj.lastSnapIndex[direction]
    local zones = zoneSequences[direction]
    zones[index](win)
    obj.lastSnapIndex[direction] = (index % #zones) + 1
end

local function moveWindowToScreen(win, direction)
    local currentScreen = win:screen()
    local nextScreen = nil
    if direction == Direction.LEFT then
        nextScreen = currentScreen:toWest()
    elseif direction == Direction.RIGHT then
        nextScreen = currentScreen:toEast()
    elseif direction == Direction.UP then
        nextScreen = currentScreen:toNorth()
    elseif direction == Direction.DOWN then
        nextScreen = currentScreen:toSouth()
    end
    if nextScreen then
        local frame = win:frame()
        local currentFrame = currentScreen:frame()
        local nextFrame = nextScreen:frame()

        local relX = (frame.x - currentFrame.x) / currentFrame.w
        local relY = (frame.y - currentFrame.y) / currentFrame.h
        local relW = frame.w / currentFrame.w
        local relH = frame.h / currentFrame.h

        local newX = nextFrame.x + relX * nextFrame.w
        local newY = nextFrame.y + relY * nextFrame.h
        local newW = relW * nextFrame.w
        local newH = relH * nextFrame.h

        win:moveToScreen(nextScreen)
        win:setFrame({x = newX, y = newY, w = newW, h = newH})
    end
end

function obj:bindHotkeys()
    local snapModifiers = {"ctrl", "alt"}
    local moveModifiers = {"ctrl", "alt", "cmd"}
    local focusModifiers = {"shift", "ctrl"}

    local windowFilter = hs.window.filter.defaultCurrentSpace

    -- New hotkey bindings to change focus
    hs.hotkey.bind(focusModifiers, "Left", function()
        local win = hs.window.focusedWindow()
        if win then
            windowFilter:focusWindowWest(win)
        end
    end)

    hs.hotkey.bind(focusModifiers, "Right", function()
        local win = hs.window.focusedWindow()
        if win then
            windowFilter:focusWindowEast(win)
        end
    end)

    hs.hotkey.bind(focusModifiers, "Up", function()
        local win = hs.window.focusedWindow()
        if win then
            windowFilter:focusWindowNorth(win)
        end
    end)

    hs.hotkey.bind(focusModifiers, "Down", function()
        local win = hs.window.focusedWindow()
        if win then
            windowFilter:focusWindowSouth(win)
        end
    end)

    -- New hotkey binding to maximize the focused window
    hs.hotkey.bind(snapModifiers, "return", function()
        local win = hs.window.focusedWindow()
        if win then
            win:maximize()
        end
    end)

    hs.hotkey.bind(snapModifiers, "Left", function()
        local win = hs.window.focusedWindow()
        if win then snapCycle(win, Direction.LEFT) end
    end)
    hs.hotkey.bind(snapModifiers, "Right", function()
        local win = hs.window.focusedWindow()
        if win then snapCycle(win, Direction.RIGHT) end
    end)
    hs.hotkey.bind(snapModifiers, "Up", function()
        local win = hs.window.focusedWindow()
        if win then snapCycle(win, Direction.UP) end
    end)
    hs.hotkey.bind(snapModifiers, "Down", function()
        local win = hs.window.focusedWindow()
        if win then snapCycle(win, Direction.DOWN) end
    end)

    hs.hotkey.bind(moveModifiers, "Left", function()
        local win = hs.window.focusedWindow()
        if win then moveWindowToScreen(win, Direction.LEFT) end
    end)
    hs.hotkey.bind(moveModifiers, "Right", function()
        local win = hs.window.focusedWindow()
        if win then moveWindowToScreen(win, Direction.RIGHT) end
    end)
    hs.hotkey.bind(moveModifiers, "Up", function()
        local win = hs.window.focusedWindow()
        if win then moveWindowToScreen(win, Direction.UP) end
    end)
    hs.hotkey.bind(moveModifiers, "Down", function()
        local win = hs.window.focusedWindow()
        if win then moveWindowToScreen(win, Direction.DOWN) end
    end)
end

return obj
