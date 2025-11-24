local MiningGameGuidePanel = class("MiningGameGuidePanel", BasePanel)
MiningGameGuidePanel._tbDefine = {
	{
		sPrefabPath = "Play_Mining/MiningGameGuidePanel.prefab",
		sCtrlName = "Game.UI.Play_Mining.MiningGameGuideCtrl"
	}
}
function MiningGameGuidePanel:Awake()
end
function MiningGameGuidePanel:OnEnable()
end
function MiningGameGuidePanel:OnAfterEnter()
end
function MiningGameGuidePanel:OnDisable()
end
function MiningGameGuidePanel:OnDestroy()
end
function MiningGameGuidePanel:OnRelease()
end
return MiningGameGuidePanel
