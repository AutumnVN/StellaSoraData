local BasePanel = require("GameCore.UI.BasePanel")
local CharFavourGiftPanel = class("CharFavourGiftPanel", BasePanel)
CharFavourGiftPanel._tbDefine = {
	{
		sPrefabPath = "CharacterFavour/CharFavourGiftPanel.prefab",
		sCtrlName = "Game.UI.CharacterFavour.CharFavourGiftCtrl"
	}
}
function CharFavourGiftPanel:Awake()
end
function CharFavourGiftPanel:OnEnable()
end
function CharFavourGiftPanel:OnDisable()
end
function CharFavourGiftPanel:OnDestroy()
end
function CharFavourGiftPanel:OnRelease()
end
return CharFavourGiftPanel
