local JointDrillRankingPanel_510003 = class("JointDrillRankingPanel_510003", BasePanel)
JointDrillRankingPanel_510003._sUIResRootPath = "UI_Activity/"
JointDrillRankingPanel_510003._tbDefine = {
	{
		sPrefabPath = "_510003/JointDrillRankingPanel.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrill_2.JointDrillRankingCtrl"
	}
}
function JointDrillRankingPanel_510003:Awake()
	self.mapRankDetail = nil
	self.nGridPos = 0
end
function JointDrillRankingPanel_510003:OnEnable()
end
function JointDrillRankingPanel_510003:OnAfterEnter()
end
function JointDrillRankingPanel_510003:OnDisable()
end
function JointDrillRankingPanel_510003:OnDestroy()
end
function JointDrillRankingPanel_510003:OnRelease()
end
return JointDrillRankingPanel_510003
