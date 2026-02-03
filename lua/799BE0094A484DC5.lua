local JointDrillRankDetailPanel = class("JointDrillRankDetailPanel", BasePanel)
JointDrillRankDetailPanel._bIsMainPanel = false
JointDrillRankDetailPanel._sUIResRootPath = "UI_Activity/"
JointDrillRankDetailPanel._tbDefine = {
	{
		sPrefabPath = "_510003/JointDrillRankDetailPanel.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrill_2.JointDrillRankDetailCtrl"
	}
}
function JointDrillRankDetailPanel:Awake()
end
function JointDrillRankDetailPanel:OnEnable()
end
function JointDrillRankDetailPanel:OnAfterEnter()
end
function JointDrillRankDetailPanel:OnDisable()
end
function JointDrillRankDetailPanel:OnDestroy()
end
function JointDrillRankDetailPanel:OnRelease()
end
return JointDrillRankDetailPanel
