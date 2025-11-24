local GachaPanel = class("GachaPanel", BasePanel)
GachaPanel._tbDefine = {
	{
		sPrefabPath = "GachaEx/GachaPanel.prefab",
		sCtrlName = "Game.UI.GachaEx.GachaCtrl"
	}
}
function GachaPanel:Awake()
end
function GachaPanel:OnEnable()
end
function GachaPanel:OnDisable()
end
function GachaPanel:OnDestroy()
end
function GachaPanel:OnRelease()
end
return GachaPanel
