local obj = {}
obj.__index = obj
obj.name = "WindowManager"
obj.version = "0.1"
obj.author = "Troels Lund <trolund@gmail.com>"
obj.license = "MIT"

local sizes = {0.5, 2 / 3, 1 / 3}

obj.lastDirection = ""
obj.lastSizeIndex = {
    left = 1,
    right = 1,
    up = 1,
    down = 1
}

local Direction = {
    LEFT = "left",
    RIGHT = "right",
    UP = "up",
    DOWN = "down"
}

local function moveWindowToFraction(win, direction, fraction)
    local screen = win:screen()
    local max = screen:frame()
    local frame = win:frame()

    if direction == Direction.LEFT then
        win:setFrame({
            x = max.x,
            y = max.y,
            w = max.w * fraction,
            h = max.h
        })
    elseif direction == Direction.RIGHT then
        win:setFrame({
            x = max.x + max.w * (1 - fraction),
            y = max.y,
            w = max.w * fraction,
            h = max.h
        })
    elseif direction == Direction.UP then
        win:setFrame({
            x = max.x,
            y = max.y,
            w = max.w,
            h = max.h * fraction
        })
    elseif direction == Direction.DOWN then
        win:setFrame({
            x = max.x,
            y = max.y + max.h * (1 - fraction),
            w = max.w,
            h = max.h * fraction
        })
    end
end

function obj:bindHotkeys()
    local hyper = {"ctrl", "alt"}

    local function handleDirection(direction)
        local win = hs.window.focusedWindow()
        if not win then
            return
        end

        if self.lastDirection ~= direction then
            self.lastSizeIndex[direction] = 1
            self.lastDirection = direction
        end

        local i = self.lastSizeIndex[direction]
        moveWindowToFraction(win, direction, sizes[i])
        self.lastSizeIndex[direction] = (i % #sizes) + 1
    end

    hs.hotkey.bind(hyper, "Left", function()
        handleDirection(Direction.LEFT)
    end)
    hs.hotkey.bind(hyper, "Right", function()
        handleDirection(Direction.RIGHT)
    end)
    hs.hotkey.bind(hyper, "Up", function()
        handleDirection(Direction.UP)
    end)
    hs.hotkey.bind(hyper, "Down", function()
        handleDirection(Direction.DOWN)
    end)

    hs.hotkey.bind(hyper, "Return", function()
        local win = hs.window.focusedWindow()
        if win then
            win:maximize()
        end
    end)
end

return obj
