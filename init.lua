-- -------------------------------
-- Watcher for changes of init.lua
-- -------------------------------
function reloadConfig(files)
  doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end

local myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert("Hammerspoon config reloaded")

-- ------------------
-- Modifier shortcuts
-- ------------------
local alt = {"⌥"}
local hyper = {"⌘", "⌥", "⌃", "⇧"}
local nudgekey = {"⌥", "⌃"}
local yankkey = {"⌥", "⌃","⇧"}
local pushkey = {"⌃", "⌘", "⌥"}
local shiftpushkey= {"⌃", "⌘", "⇧"}

-- ---------------------
-- F19 and Hyperkey Hack
-- ---------------------

-- Keys you want to use with hyper key go here:
hyperBindings = {
  -- Application
  'b', 'g', 'u', 'f', 'e', 'x', 'w', 'p', 's', 'c', 'd', 'm',
  -- Grid
  '\\', 'j', 'k', 'h', 'l', 'q', 'TAB'
}

k = hs.hotkey.modal.new({}, "F17")

for i,key in ipairs(hyperBindings) do
  k:bind({}, key, nil, function() hs.eventtap.keyStroke(hyper, key)
    k.triggered = true
  end)
end

pressedF19 = function()
 k.triggered = false
 k:enter()
end

releasedF19 = function()
 k:exit()
 if not k.triggered then
   hs.eventtap.keyStroke({}, 'F18')
 end
end

f18 = hs.hotkey.bind({}, 'F19', pressedF19, releasedF19)

-- -----------------
-- Window management
-- -----------------

-- None of this animation shit:
hs.window.animationDuration = 0

-- Get list of screens and refresh that list whenever screens are plugged or unplugged:
local screens = hs.screen.allScreens()
local screenwatcher = hs.screen.watcher.new(function()
 screens = hs.screen.allScreens()
end)
screenwatcher:start()

-- init grid
hs.grid.MARGINX  = 0
hs.grid.MARGINY  = 0
hs.grid.GRIDWIDTH  = 7
hs.grid.GRIDHEIGHT  = 3

-- Resize window for chunk of screen.
-- For x and y: use 0 to expand fully in that dimension, 0.5 to expand halfway
-- For w and h: use 1 for full, 0.5 for half
function push(x, y, w, h)
 local win = hs.window.focusedWindow()
 local f = win:frame()
 local screen = win:screen()
 local max = screen:frame()

 f.x = max.x + (max.w*x)
 f.y = max.y + (max.h*y)
 f.w = max.w*w
 f.h = max.h*h
 win:setFrame(f)
end

-- Show grid
hs.hotkey.bind(pushkey, 'g', hs.grid.show)

-- Push to screen edge
hs.hotkey.bind(pushkey,"h", function() push(0,0,0.5,1) end)   -- left side
hs.hotkey.bind(pushkey,"l", function() push(0.5,0,0.5,1) end) -- right side
hs.hotkey.bind(pushkey,"j", function() push(0,0,1,0.5) end)   -- top half
hs.hotkey.bind(pushkey,"k", function() push(0,0.5,1,0.5) end) -- bottom half

-- Center window with some room to see the desktop
hs.hotkey.bind(pushkey, "m", function() push(0.05,0.05,0.9,0.9) end)
-- Fullscreen
hs.hotkey.bind(pushkey, ";", function() push(0,0,1,1) end)

-- Move active window to previous monitor
hs.hotkey.bind(pushkey, "u", function()
  hs.window.focusedWindow():moveOneScreenWest()
end)

-- Move active window to next monitor
hs.hotkey.bind(pushkey, "i", function()
  hs.window.focusedWindow():moveOneScreenEast()
end)

-- -----------------
-- Applications
-- -----------------

-- Toggle named app's visibility, launching if needed
function toggle_app(name)
  focused = hs.window.focusedWindow()
  if focused then
    app = focused:application()
    if app:title() == name then
      app:hide()
      return
    end
  end
  hs.application.launchOrFocus(name)
end


-- Applications, toggle visibility
hs.hotkey.bind(alt, 'i', function() toggle_app('Iterm') end)
hs.hotkey.bind(alt, 'v', function() toggle_app('Visual Studio code') end)
hs.hotkey.bind(alt, 'g', function() toggle_app('Google Chrome') end)
hs.hotkey.bind(alt, 'c', function() toggle_app('Charles') end)
hs.hotkey.bind(alt, 'd', function() toggle_app('DingTalk') end)
hs.hotkey.bind(alt, 'n', function() toggle_app('NeteaseMusic') end)
-- hs.hotkey.bind(alt, 'e', function() toggle_app('Zeplin') end)
-- hs.hotkey.bind(alt, 'l', function() toggle_app('Lark') end)
-- hs.hotkey.bind(alt, 'n', function() toggle_app('Cmd Markdown') end)
hs.hotkey.bind(alt, 'b', function() toggle_app('Notes') end)
hs.hotkey.bind(alt, 'f', function() toggle_app('Finder') end)
hs.hotkey.bind(alt, 'w', function() toggle_app('Wechat') end)
hs.hotkey.bind(alt, 'm', function() toggle_app('QQMusic') end)
hs.hotkey.bind(alt, 'q', function() toggle_app('QQ') end)
--hs.hotkey.bind(alt, 'l', function() toggle_app('Seal') end)
-- hs.hotkey.bind(alt, 'x', function() toggle_app('Xcode') end)
-- hs.hotkey.bind(alt, 'w', function() toggle_app('Wunderlist') end)
--hs.hotkey.bind(alt, '3', function() toggle_app('Microsoft Edge') end)
-- hs.hotkey.bind(alt, 's', function() toggle_app('Simulator') end)
--hs.hotkey.bind(alt, 'm', function() toggle_app('Simulator') end)


-- -----
-- Misc
-- -----

-- Vim-like keymaps

hs.hotkey.bind(hyper, 'j', function() hs.eventtap.keyStroke({}, 'down') end)
hs.hotkey.bind(hyper, 'k', function() hs.eventtap.keyStroke({}, 'up') end)
hs.hotkey.bind(hyper, 'h', function() hs.eventtap.keyStroke({}, 'left') end)
-- hs.hotkey.bind(hyper, 'l', function() hs.eventtap.keyStroke({}, 'right') end)

-- Help. Lists shortcuts, etc.
-- The terrible spacing looks fine when the alert is actually displayed
hs.hotkey.bind(hyper, "Q", function()
 helpstr = [[Hyper     ⌘⌥⌃⇧
Pushkey             ⌘⌥⌃q
Push     ⌘⌃
Grid      Pushkey-G
]]
 hs.alert.show(helpstr)
end)
