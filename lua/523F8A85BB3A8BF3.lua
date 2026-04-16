local PotentialPreselectionPanel = class("PotentialPreselectionPanel", BasePanel)
PotentialPreselectionPanel._tbDefine = {
	{
		sPrefabPath = "PotentialPreselection/PotentialPreselectionListPanel.prefab",
		sCtrlName = "Game.UI.PotentialPreselection.PotentialPreselectionCtrl"
	}
}
function PotentialPreselectionPanel:Awake()
end
function PotentialPreselectionPanel:OnEnable()
end
function PotentialPreselectionPanel:OnDisable()
end
function PotentialPreselectionPanel:OnDestroy()
end
return PotentialPreselectionPanel
