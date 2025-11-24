local MiningGameQuestPanel = class("MiningGamePanel", BasePanel)
MiningGameQuestPanel._bIsMainPanel = true
MiningGameQuestPanel._tbDefine = {
	{
		sPrefabPath = "Activity/Mining/MiningGameQuestPanel.prefab",
		sCtrlName = "Game.UI.Play_Mining.MiningGameQuestCtrl"
	}
}
function MiningGameQuestPanel:Awake()
end
function MiningGameQuestPanel:OnEnable()
end
function MiningGameQuestPanel:OnAfterEnter()
end
function MiningGameQuestPanel:OnDisable()
end
function MiningGameQuestPanel:OnDestroy()
end
function MiningGameQuestPanel:OnRelease()
end
return MiningGameQuestPanel
