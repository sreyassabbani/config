-- Launch Rex on a cold start; otherwise open a new app window.
local bundle = "com.superlogical.rex"
local busy = false

hs.hotkey.bind({ "cmd" }, "`", function()
  if busy then return end
  busy = true

  local app = hs.application.get(bundle)
  if not app then
    -- Rex creates its initial window on launch. Don't queue a client action
    -- before the app has connected to its server.
    if not hs.application.launchOrFocusByBundleID(bundle) then
      hs.alert.show("Could not launch Rex")
      busy = false
      return
    end
    local function waitForWindow(remaining)
      local current = hs.application.get(bundle)
      if current and #current:allWindows() > 0 then
        busy = false
      elseif remaining > 0 then
        hs.timer.doAfter(0.2, function() waitForWindow(remaining - 1) end)
      else
        busy = false
        hs.alert.show("Rex launched, but no window appeared")
      end
    end
    waitForWindow(150)
    return
  end

  local existing = {}
  for _, window in ipairs(app:allWindows()) do
    if window:id() then existing[window:id()] = true end
  end

  local function focusNewWindow(remaining)
    local current = hs.application.get(bundle)
    if current then
      for _, window in ipairs(current:allWindows()) do
        if window:id() and not existing[window:id()] then
          window:focus()
          busy = false
          return
        end
      end
    end
    if remaining > 0 then
      hs.timer.doAfter(0.1, function() focusNewWindow(remaining - 1) end)
    else
      busy = false
      hs.alert.show("Rex opened a window, but it could not be focused")
    end
  end

  -- The app menu works even when Rex has no window to receive a client action.
  if app:selectMenuItem({ "File", "New Window" }) then
    focusNewWindow(50)
  else
    busy = false
    hs.alert.show("Could not open a Rex window")
  end
end)
