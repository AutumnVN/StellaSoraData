local ThrowGiftPanel = class("ThrowGiftPanel", BasePanel)
ThrowGiftPanel._sUIResRootPath = "UI_Activity/"
ThrowGiftPanel._tbDefine = {
	{
		sPrefabPath = "_400005/ThrowGiftsPanel.prefab",
		sCtrlName = "Game.UI.Activity.ThrowGifts.ThrowGiftCtrl"
	}
}
function ThrowGiftPanel:Awake()
end
function ThrowGiftPanel:OnEnable()
end
function ThrowGiftPanel:OnAfterEnter()
end
function ThrowGiftPanel:OnDisable()
end
function ThrowGiftPanel:OnDestroy()
end
function ThrowGiftPanel:OnRelease()
end
return ThrowGiftPanel
