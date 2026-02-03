local ThrowGiftLevelSelectPanel = class("ThrowGiftLevelSelectPanel", BasePanel)
ThrowGiftLevelSelectPanel._sUIResRootPath = "UI_Activity/"
ThrowGiftLevelSelectPanel._tbDefine = {
	{
		sPrefabPath = "_400005/ThrowGiftsLevelSelectPanel.prefab",
		sCtrlName = "Game.UI.Activity.ThrowGifts.ThrowGiftLevelSelectCtrl"
	}
}
function ThrowGiftLevelSelectPanel:Awake()
end
function ThrowGiftLevelSelectPanel:OnEnable()
end
function ThrowGiftLevelSelectPanel:OnAfterEnter()
end
function ThrowGiftLevelSelectPanel:OnDisable()
end
function ThrowGiftLevelSelectPanel:OnDestroy()
end
function ThrowGiftLevelSelectPanel:OnRelease()
end
return ThrowGiftLevelSelectPanel
