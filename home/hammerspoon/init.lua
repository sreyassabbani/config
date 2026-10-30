-- Open a new Rex app window from anywhere, including when Rex is not running.
local rex = os.getenv("HOME") .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
local bundle = "com.superlogical.rex"

hs.hotkey.bind({ "cmd" }, "`", function()
  if not hs.application.get(bundle) then
    hs.application.launchOrFocusByBundleID(bundle)
  end
  local existing = {}
  local app = hs.application.get(bundle)
  if app then
    for _, window in ipairs(app:allWindows()) do
      local id = window:id()
      if id then existing[id] = true end
    end
  end
  local attempts = 0
  local function focusNewWindow(remaining)
    local current = hs.application.get(bundle)
    if current then
      for _, window in ipairs(current:allWindows()) do
        if window:id() and not existing[window:id()] then
          window:focus()
          return
        end
      end
    end
    if remaining > 0 then
      hs.timer.doAfter(0.1, function() focusNewWindow(remaining - 1) end)
    else
      hs.alert.show("Rex opened a window, but it could not be focused")
    end
  end
  local function openWindow()
    attempts = attempts + 1
    local task = hs.task.new(rex, function(code, _, stderr)
      if code == 0 then
        focusNewWindow(20)
      elseif attempts < 10 then
        hs.timer.doAfter(0.5, openWindow)
      else
        hs.alert.show("Could not open a Rex window: " .. stderr)
      end
    end, { "-C", "Blue", "do", "client.window.new" })
    if not task or not task:start() then
      hs.alert.show("Could not start the Rex CLI")
    end
  end
  openWindow()
end)
