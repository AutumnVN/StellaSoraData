local JointDrillLevelSelectPanel = class("JointDrillLevelSelectPanel", BasePanel)
JointDrillLevelSelectPanel._sUIResRootPath = "UI_Activity/"
JointDrillLevelSelectPanel._tbDefine = {
	{
		sPrefabPath = "_510001/JointDrillLevelSelect.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrill_1.JointDrillLevelSelectCtrl"
	}
}
function JointDrillLevelSelectPanel:Awake()
end
function JointDrillLevelSelectPanel:OnEnable()
end
function JointDrillLevelSelectPanel:OnAfterEnter()
end
function JointDrillLevelSelectPanel:OnDisable()
end
function JointDrillLevelSelectPanel:OnDestroy()
end
function JointDrillLevelSelectPanel:OnRelease()
end
return JointDrillLevelSelectPanel
