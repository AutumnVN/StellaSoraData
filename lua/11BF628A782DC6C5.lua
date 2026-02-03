local JointDrillQuestPanel = class("JointDrillQuestPanel", BasePanel)
JointDrillQuestPanel._bIsMainPanel = false
JointDrillQuestPanel._sUIResRootPath = "UI_Activity/"
JointDrillQuestPanel._tbDefine = {
	{
		sPrefabPath = "_510003/JointDrillQuestPanel.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrill_2.JointDrillQuestCtrl"
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
