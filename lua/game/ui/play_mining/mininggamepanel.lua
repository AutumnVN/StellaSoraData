local MiningGamePanel = class("MiningGamePanel", BasePanel)
MiningGamePanel._bIsMainPanel = true
MiningGamePanel._bAddToBackHistory = true
MiningGamePanel._tbDefine = {
	{
		sPrefabPath = "Play_Mining/MiningGamePanel.prefab",
		sCtrlName = "Game.UI.Play_Mining.MiningGameCtrl"
	}
}
function MiningGamePanel:Awake()
end
function MiningGamePanel:OnEnable()
end
function MiningGamePanel:OnAfterEnter()
end
function MiningGamePanel:OnDisable()
end
function MiningGamePanel:OnDestroy()
end
function MiningGamePanel:OnRelease()
end
return MiningGamePanel
