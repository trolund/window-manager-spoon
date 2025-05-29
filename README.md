# 🪟 Window manager for HammerSpoon 🔨🥄

A simple window manager for Hammerspoon.

## 🔑 Hotkey Mappings

These are the window management keybindings provided by this configuration. All shortcuts use the **`ctrl + alt`** modifier combination (a.k.a. the `hyper` key in this script).

| Key Combination       | Action                                                                                            |
| --------------------- | ------------------------------------------------------------------------------------------------- |
| `ctrl + alt + ←`      | Resize and move window to the **left** side. Cycles through predefined size fractions.            |
| `ctrl + alt + →`      | Resize and move window to the **right** side. Cycles through predefined size fractions.           |
| `ctrl + alt + ↑`      | Resize and move window to the **top** of the screen. Cycles through predefined size fractions.    |
| `ctrl + alt + ↓`      | Resize and move window to the **bottom** of the screen. Cycles through predefined size fractions. |
| `ctrl + alt + Return` | **Maximize** the focused window.                                                                  |

### ↺ Cycling Behavior

Each directional key cycles through a list of sizes (e.g., 1/2, 1/3, 2/3 of screen width or height), making it easy to snap windows into different fractional layouts.

## 🚀 Setup

```lua
hs.loadSpoon("WindowManager")
spoon.WindowManager:bindHotkeys({})
```
