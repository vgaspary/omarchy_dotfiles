-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

-- Switch workspaces with ALT + 1..9, 0; disable SUPER + 1..9, 0 and SUPER + SHIFT + 1..9, 0.
local move_to_slot = {}
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  hl.unbind("SUPER + " .. key)
  hl.unbind("SUPER + SHIFT + " .. key)
  o.bind("ALT + " .. key, "Switch to workspace " .. workspace, o.workspaces.focus(workspace))
  move_to_slot[workspace] = o.workspaces.move_window(workspace)
end

-- Focus windows with SUPER + H/J/K/L instead of SUPER + arrow keys.
-- Replaces: SUPER+J (Toggle window split), SUPER+K (Keybindings), SUPER+L (Cycle workspace layout).
hl.unbind("SUPER + LEFT")
hl.unbind("SUPER + RIGHT")
hl.unbind("SUPER + UP")
hl.unbind("SUPER + DOWN")
o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.rebind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.rebind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.rebind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))

-- Swap windows in the grid with SUPER + CTRL + H/J/K/L instead of SUPER + SHIFT + arrow keys.
-- Replaces: SUPER+CTRL+H (Hardware menu), SUPER+CTRL+K (Herdr keybindings), SUPER+CTRL+L (Lock system).
hl.unbind("SUPER + SHIFT + LEFT")
hl.unbind("SUPER + SHIFT + RIGHT")
hl.unbind("SUPER + SHIFT + UP")
hl.unbind("SUPER + SHIFT + DOWN")
o.rebind("SUPER + CTRL + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + CTRL + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.rebind("SUPER + CTRL + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.rebind("SUPER + CTRL + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))

-- Move active window to the left or right workspace on the current monitor with SUPER + SHIFT + H/L.
local function move_window_adjacent_workspace(delta)
  return function()
    local workspace = hl.get_active_workspace()
    if not workspace or workspace.special or workspace.id < 1 then
      return
    end
    local slots = o.workspaces.slots or 10
    local slot = ((workspace.id - 1) % slots) + 1
    local target = slot + delta
    if target >= 1 and target <= slots then
      move_to_slot[target]()
    end
  end
end

o.bind("SUPER + SHIFT + H", "Move window to left workspace", move_window_adjacent_workspace(-1))
o.bind("SUPER + SHIFT + L", "Move window to right workspace", move_window_adjacent_workspace(1))

-- Open the Omarchy launcher with ALT + SPACE instead of SUPER + SPACE.
-- Replaces: ALT+SPACE (Toggle dictation).
hl.unbind("SUPER + SPACE")
if o.dictation_installed and o.dictation_installed() then
  o.rebind("ALT + SPACE", "Omarchy menu", { menu = "root" })
else
  o.bind("ALT + SPACE", "Omarchy menu", { menu = "root" })
end

-- Open Apps with SUPER + SPACE instead of SUPER + ALT + SPACE.
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + SPACE", "Apps", "omarchy-shell omarchy.dock apps")

-- Remove default app, agent, activity, and screenshot launcher bindings
-- (preinstalled app/webapp bindings are disabled via omarchy_preinstalled_bindings = false in hyprland.lua).
hl.unbind("SUPER + RETURN")
hl.unbind("SUPER + SHIFT + RETURN")
hl.unbind("SUPER + SHIFT + F")
hl.unbind("SUPER + ALT + SHIFT + F")
hl.unbind("SUPER + SHIFT + B")
hl.unbind("SUPER + SHIFT + ALT + B")
hl.unbind("SUPER + SHIFT + N")
hl.unbind("SUPER + SHIFT + CTRL + A")
hl.unbind("SUPER + SHIFT + T")
hl.unbind("PRINT")
hl.unbind("SUPER + CTRL + ALT + C")

-- Launcher mappings (CTRL + ALT + <letter>).
o.bind("CTRL + ALT + T", "Terminal", { launch = 'xdg-terminal-exec --dir="$HOME"' })
o.bind("CTRL + ALT + B", "Browser", { omarchy = "browser" })
o.bind("CTRL + ALT + A", "Agent", "omarchy-agent --pick")
o.bind("CTRL + ALT + M", "Google Maps", { webapp = "https://maps.google.com/", focus = true })
o.bind("CTRL + ALT + S", "Screenshot (region)", "omarchy-capture-screenshot region")

-- Lock system with CTRL + ESCAPE (since SUPER + CTRL + L is used for swapping windows).
o.bind("CTRL + ESCAPE", "Lock system", "omarchy-system-lock")
