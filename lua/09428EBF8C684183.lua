local JointDrillRankingPanel_510005 = class("JointDrillRankingPanel_510005", BasePanel)
JointDrillRankingPanel_510005._sUIResRootPath = "UI_Activity/"
JointDrillRankingPanel_510005._tbDefine = {
	{
		sPrefabPath = "_510005/JointDrillRankingPanel.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrill_2.JointDrillRankingCtrl"
	}
}
function JointDrillRankingPanel_510005:Awake()
	self.mapRankDetail = nil
	self.nGridPos = 0
end
function JointDrillRankingPanel_510005:OnEnable()
end
function JointDrillRankingPanel_510005:OnAfterEnter()
end
function JointDrillRankingPanel_510005:OnDisable()
end
function JointDrillRankingPanel_510005:OnDestroy()
end
function JointDrillRankingPanel_510005:OnRelease()
end
return JointDrillRankingPanel_510005
