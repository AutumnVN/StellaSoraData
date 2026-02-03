local JointDrillRankUpPanel = class("JointDrillRankUpPanel", BasePanel)
JointDrillRankUpPanel._bIsMainPanel = false
JointDrillRankUpPanel._sUIResRootPath = "UI_Activity/"
JointDrillRankUpPanel._tbDefine = {
	{
		sPrefabPath = "_510001/JointDrillRankUpPanel.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrill_1.JointDrillRankUpCtrl"
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
