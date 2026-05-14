local JointDrillRankingPanel_510001 = class("JointDrillRankingPanel_510001", BasePanel)
JointDrillRankingPanel_510001._sUIResRootPath = "UI_Activity/"
JointDrillRankingPanel_510001._tbDefine = {
	{
		sPrefabPath = "_510001/JointDrillRankingPanel.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrill_1.JointDrillRankingCtrl"
	}
}
function JointDrillRankingPanel_510001:Awake()
	self.mapRankDetail = nil
	self.nGridPos = 0
end
function JointDrillRankingPanel_510001:OnEnable()
end
function JointDrillRankingPanel_510001:OnAfterEnter()
end
function JointDrillRankingPanel_510001:OnDisable()
end
function JointDrillRankingPanel_510001:OnDestroy()
end
function JointDrillRankingPanel_510001:OnRelease()
end
return JointDrillRankingPanel_510001
