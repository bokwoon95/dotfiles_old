hs.hotkey.bind({"cmd", "ctrl"}, "c", function()
  hs.eventtap.keyStroke({"cmd"}, "c")
  hs.pasteboard.setContents(hs.pasteboard.getContents())
end)
