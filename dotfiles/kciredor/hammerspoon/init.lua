local hyper = {"alt"}

hs.hotkey.bind(hyper, 'R', function()
  hs.console.clearConsole()
  hs.reload()
end)

hs.hotkey.bind(hyper, 'C', function()
  hs.application.get("Hammerspoon"):selectMenuItem("Console...")
  hs.application.launchOrFocus("Hammerspoon")
end)

hs.hotkey.bind(hyper, "return", function()
  hs.application.open("/Users/kciredor/Applications/Home Manager Apps/Alacritty.app")
end)


-- Spoon management.
hs.loadSpoon("SpoonInstall")  -- Requires manual install.
spoon.SpoonInstall.use_syncinstall = true

spoon.SpoonInstall:andUse("Seal", {
  hotkeys={toggle={hyper, 'D'}},
  start=true,
  fn = function(s)
    s:loadPlugins({"apps", "useractions"})
    s.plugins.useractions.actions = {
      -- Nixpkgs are symlinked into ~/Applications/Home Manager Apps and symlinks are not indexed by Spotlight, see: https://github.com/LnL7/nix-darwin/issues/139#issuecomment-1230728610.
      ["Alacritty"] = {
         fn = function()
           hs.application.open("/Users/kciredor/Applications/Home Manager Apps/Alacritty.app")
         end,
         icon = hs.image.imageFromAppBundle("org.alacritty"),
      },
      -- Ghidra does not have an app bundle.
      ["Ghidra"] = {
         fn = function()
           hs.execute("/Users/kciredor/bin/ghidra.sh")
         end,
         icon = hs.image.imageFromName(hs.image.systemImageNames.Advanced),
      },
    }
  end,
})

spoon.SpoonInstall:andUse("Caffeine", {
  hotkeys={toggle={hyper, 'S'}},
  start=true,
})


-- Window management. Possible additions:
-- - Throw window to space (see https://github.com/asmagill/hs._asm.spaces and https://github.com/Hammerspoon/hammerspoon/issues/235).
-- - Swap two tiled window positions with hyper-shift-T.
hs.window.animationDuration = 0
hs.window.switcher.ui.showThumbnails = false
hs.window.switcher.ui.showSelectedThumbnail = false

hs.grid.HINTS={
  {'f1','f2','f3','f4','f5','f6','f7','f8','f9','f10'},
  {'1','2','3','4','5','6','7','8','9','0'  },
  {'\'',',','.','P','Y','F','G','C','R','L' },
  {'A','O','E','U','I','D','H','T','N','S'  },
  {';','Q','J','K','X','B','M','W','V', 'Z' }
}
hs.grid.setGrid('4x3')
hs.grid.ui.showExtraKeys = false
hs.hotkey.bind(hyper, 'G', function()
  hs.grid.show()
end)

hs.hotkey.bind(hyper, 'T', function()
  -- FIXME: Does not actually filter on current space with multiple monitors.
  filter = hs.window.filter.new():setCurrentSpace(true)
  hs.window.switcher.new(filter):nextWindow()
end)
hs.hotkey.bind(hyper, 'O', function()
  local win = hs.window.focusedWindow()
  win:moveToScreen(win:screen():next(), true)
end)
hs.hotkey.bind(hyper, 'F', function()
  local win = hs.window.focusedWindow()
  win:maximize()
end)

function layout(l)
  return function()
    filter = hs.window.filter.new():setCurrentSpace(true)

    if l == "tile" then
      -- FIXME: Does not actually filter on current space with multiple monitors yet fullscreen layout works correctly.
      pos = "tile all [0,0,100,100] 1,0"
    end

    if l == "fullscreen" then
      pos = "max 1,0"
    end

    hs.window.layout.apply(hs.window.layout.new({filter, pos}))
  end
end
hs.hotkey.bind(hyper, '1', layout("tile"))
hs.hotkey.bind(hyper, '2', layout("fullscreen"))


hs.alert.show("Hammerspoon Configured")
