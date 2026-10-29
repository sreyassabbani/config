-- Ghostty-compatible tab and split navigation.
rex.bind("ctrl+tab", "client.tab.next")
rex.bind("ctrl+shift+tab", "client.tab.previous")
rex.bind("ctrl+h", "pane.focus.left")
rex.bind("ctrl+j", "pane.focus.down")
rex.bind("ctrl+k", "pane.focus.up")
rex.bind("ctrl+l", "pane.focus.right")
rex.bind("ctrl+shift+enter", "pane.zoom")
rex.unbind("cmd+shift+enter")
rex.unbind("cmd+,") -- Reserved for the macOS Quick Action.

-- Ghostty sends a literal newline on Shift+Enter.
rex.bind("shift+enter", function(ctx)
  if not ctx.block_id then return false end
  local result = rex.block.call("com.superlogical.terminal", "write", { data = "\n" })
  return result ~= nil
end)
