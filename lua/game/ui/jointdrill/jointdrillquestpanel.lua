local JointDrillQuestPanel = class("JointDrillQuestPanel", BasePanel)
JointDrillQuestPanel._bIsMainPanel = false
JointDrillQuestPanel._tbDefine = {
	{
		sPrefabPath = "Play_JointDrill/JointDrillQuestPanel.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrillQuestCtrl"
	}
}
function JointDrillQuestPanel:Awake()
end
function JointDrillQuestPanel:OnEnable()
end
function JointDrillQuestPanel:OnAfterEnter()
end
function JointDrillQuestPanel:OnDisable()
end
function JointDrillQuestPanel:OnDestroy()
end
function JointDrillQuestPanel:OnRelease()
end
return JointDrillQuestPanel
