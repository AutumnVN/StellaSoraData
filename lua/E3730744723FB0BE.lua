local JointDrillBuildListPanel = class("JointDrillBuildListPanel", BasePanel)
JointDrillBuildListPanel._sUIResRootPath = "UI_Activity/"
JointDrillBuildListPanel._tbDefine = {
	{
		sPrefabPath = "_510001/JointDrillBuildList.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrill_1.JointDrillBuildListCtrl"
	}
}
function JointDrillBuildListPanel:Awake()
end
function JointDrillBuildListPanel:OnEnable()
end
function JointDrillBuildListPanel:OnAfterEnter()
end
function JointDrillBuildListPanel:OnDisable()
end
function JointDrillBuildListPanel:OnDestroy()
end
function JointDrillBuildListPanel:OnRelease()
end
return JointDrillBuildListPanel
