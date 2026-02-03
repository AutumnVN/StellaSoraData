local ThrowGiftPauseCtrl = class("ThrowGiftPauseCtrl", BaseCtrl)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
ThrowGiftPauseCtrl._mapNodeConfig = {
	blur = {},
	txt_title = {
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_Text_Pause"
	},
	txt_exit = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_Button_Leave"
	},
	txt_restart = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_Button_Re"
	},
	txt_continue = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_Button_Back"
	},
	btn_exit = {
		sComponentName = "NaviButton",
		callback = "OnBtnClick_Exit",
		sAction = "Giveup"
	},
	btn_restart = {
		sComponentName = "NaviButton",
		callback = "OnBtnClick_Restart",
		sAction = "Retry"
	},
	btn_continue = {
		sComponentName = "NaviButton",
		callback = "OnBtnClick_Continue",
		sAction = "Back"
	}
}
ThrowGiftPauseCtrl._mapEventConfig = {}
ThrowGiftPauseCtrl._mapRedDotConfig = {}
function ThrowGiftPauseCtrl:Awake()
	self.tbGamepadUINode = self:GetGamepadUINode()
end
function ThrowGiftPauseCtrl:Open()
	self.gameObject:SetActive(true)
	GamepadUIManager.EnableGamepadUI("ThrowGiftPauseCtrl", self.tbGamepadUINode)
end
function ThrowGiftPauseCtrl:Close()
	GamepadUIManager.DisableGamepadUI("ThrowGiftPauseCtrl")
	self.gameObject:SetActive(false)
end
function ThrowGiftPauseCtrl:OnBtnClick_Exit()
	EventManager.Hit("ThrowGift_Exit_OnClick")
end
function ThrowGiftPauseCtrl:OnBtnClick_Restart()
	EventManager.Hit("ThrowGift_Restart_OnClick")
end
function ThrowGiftPauseCtrl:OnBtnClick_Continue()
	EventManager.Hit("ThrowGift_Continue_OnClick")
end
return ThrowGiftPauseCtrl
