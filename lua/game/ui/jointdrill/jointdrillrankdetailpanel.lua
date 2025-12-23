local JointDrilRankDetailPanel = class("JointDrilRankDetailPanel", BasePanel)
JointDrilRankDetailPanel._bIsMainPanel = false
JointDrilRankDetailPanel._sUIResRootPath = "UI_Activity/"
JointDrilRankDetailPanel._tbDefine = {
	{
		sPrefabPath = "_510001/JointDrillRankDetailPanel.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrillRankDetailCtrl"
	}
}
function JointDrilRankDetailPanel:Awake()
end
function JointDrilRankDetailPanel:OnEnable()
end
function JointDrilRankDetailPanel:OnAfterEnter()
end
function JointDrilRankDetailPanel:OnDisable()
end
function JointDrilRankDetailPanel:OnDestroy()
end
function JointDrilRankDetailPanel:OnRelease()
end
return JointDrilRankDetailPanel
