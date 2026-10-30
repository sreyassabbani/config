-- Open a new Rex app window from anywhere, including when Rex is not running.
local rex = os.getenv("HOME") .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
local bundle = "com.superlogical.rex"

hs.hotkey.bind({ "cmd" }, "`", function()
  if not hs.application.get(bundle) then
    hs.application.launchOrFocusByBundleID(bundle)
  end
  local attempts = 0
  local function openWindow()
    attempts = attempts + 1
    local task = hs.task.new(rex, function(code, _, stderr)
      if code == 0 then
        return
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
