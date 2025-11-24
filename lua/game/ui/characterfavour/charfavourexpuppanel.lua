local BasePanel = require("GameCore.UI.BasePanel")
local CharFavourExpUpPanel = class("CharFavourExpUpPanel", BasePanel)
CharFavourExpUpPanel._bIsMainPanel = false
CharFavourExpUpPanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
CharFavourExpUpPanel._tbDefine = {
	{
		sPrefabPath = "CharacterFavour/CharFavourExpUpPanel.prefab",
		sCtrlName = "Game.UI.CharacterFavour.CharFavourExpUpCtrl"
	}
}
function CharFavourExpUpPanel:Awake()
end
function CharFavourExpUpPanel:OnEnable()
end
function CharFavourExpUpPanel:OnDisable()
end
function CharFavourExpUpPanel:OnDestroy()
end
function CharFavourExpUpPanel:OnRelease()
end
return CharFavourExpUpPanel
