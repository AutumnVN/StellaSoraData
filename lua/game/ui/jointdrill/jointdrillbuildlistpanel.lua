local JointDrillBuildListPanel = class("JointDrillBuildListPanel", BasePanel)
JointDrillBuildListPanel._tbDefine = {
	{
		sPrefabPath = "Play_JointDrill/JointDrillBuildList.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrillBuildListCtrl"
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
