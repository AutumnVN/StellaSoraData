EXE_EDITOR = true
require("GameCore.GameCore")
EventManager.Hit(EventId.OpenPanel, PanelId.ExeEditor)
local goLaunchUI = GameObject.Find("==== Builtin UI ====/LaunchUI")
GameObject.Destroy(goLaunchUI)
