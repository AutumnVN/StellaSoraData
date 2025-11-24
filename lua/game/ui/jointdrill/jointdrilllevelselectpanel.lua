local JointDrillLevelSelectPanel = class("JointDrillLevelSelectPanel", BasePanel)
JointDrillLevelSelectPanel._tbDefine = {
	{
		sPrefabPath = "Play_JointDrill/JointDrillLevelSelect.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrillLevelSelectCtrl"
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
