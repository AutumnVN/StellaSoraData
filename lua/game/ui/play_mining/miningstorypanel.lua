local MiningStoryPanel = class("MiningStoryPanel", BasePanel)
MiningStoryPanel._bIsMainPanel = false
MiningStoryPanel._tbDefine = {
	{
		sPrefabPath = "Activity/Mining/MiningStoryPanel.prefab",
		sCtrlName = "Game.UI.Play_Mining.MiningStoryCtrl"
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
