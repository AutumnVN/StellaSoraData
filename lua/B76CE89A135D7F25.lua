local MiningStoryPanel = class("MiningStoryPanel", BasePanel)
MiningStoryPanel._bIsMainPanel = false
MiningStoryPanel._tbDefine = {
	{
		sPrefabPath = "Activity/Play_Mining_400007/MiningStoryPanel.prefab",
		sCtrlName = "Game.UI.Play_Mining.400007.MiningStoryCtrl"
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
