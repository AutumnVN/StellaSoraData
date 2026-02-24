local ThrowGiftPanel = class("ThrowGiftPanel", BasePanel)
ThrowGiftPanel._sUIResRootPath = "UI_Activity/"
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
ThrowGiftPanel._tbDefine = {
	{
		sPrefabPath = "_400005/ThrowGiftsPanel.prefab",
		sCtrlName = "Game.UI.Activity.ThrowGifts.ThrowGiftCtrl"
	}
}
function ThrowGiftPanel:Awake()
	GamepadUIManager.EnterAdventure(true)
	GamepadUIManager.EnableGamepadUI("ThrowGiftPanel", {}, nil, true)
end
function ThrowGiftPanel:OnEnable()
end
function ThrowGiftPanel:OnAfterEnter()
end
function ThrowGiftPanel:OnDisable()
end
function ThrowGiftPanel:OnDestroy()
	GamepadUIManager.DisableGamepadUI("ThrowGiftPanel")
	GamepadUIManager.QuitAdventure()
end
function ThrowGiftPanel:OnRelease()
end
return ThrowGiftPanel
