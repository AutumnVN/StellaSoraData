local JointDrillRankUpPanel = class("JointDrillRankUpPanel", BasePanel)
JointDrillRankUpPanel._bIsMainPanel = false
JointDrillRankUpPanel._tbDefine = {
	{
		sPrefabPath = "Play_JointDrill/JointDrillRankUpPanel.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrillRankUpCtrl"
	}
}
function JointDrillRankUpPanel:Awake()
end
function JointDrillRankUpPanel:OnEnable()
end
function JointDrillRankUpPanel:OnAfterEnter()
end
function JointDrillRankUpPanel:OnDisable()
end
function JointDrillRankUpPanel:OnDestroy()
end
function JointDrillRankUpPanel:OnRelease()
end
return JointDrillRankUpPanel
