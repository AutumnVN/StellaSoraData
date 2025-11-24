local MiningGameQuestPanel = class("MiningGamePanel", BasePanel)
MiningGameQuestPanel._bIsMainPanel = true
MiningGameQuestPanel._tbDefine = {
	{
		sPrefabPath = "Activity/Play_Mining_400002/MiningGameQuestPanel.prefab",
		sCtrlName = "Game.UI.Play_Mining_400002.MiningGameQuestCtrl"
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
