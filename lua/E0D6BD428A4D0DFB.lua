local MiningStoryPanel = class("MiningStoryPanel", BasePanel)
MiningStoryPanel._bIsMainPanel = false
MiningStoryPanel._sUIResRootPath = "UI_Activity/"
MiningStoryPanel._tbDefine = {
	{
		sPrefabPath = "_400011/MiningStoryPanel.prefab",
		sCtrlName = "Game.UI.Activity.Mining.400011.MiningStoryCtrl"
	}
}
function MiningStoryPanel:Awake()
end
function MiningStoryPanel:OnEnable()
end
function MiningStoryPanel:OnAfterEnter()
end
function MiningStoryPanel:OnDisable()
end
function MiningStoryPanel:OnDestroy()
end
function MiningStoryPanel:OnRelease()
end
return MiningStoryPanel
