local JointDrillRaidPanel = class("JointDrillRaidPanel", BasePanel)
JointDrillRaidPanel._bIsMainPanel = false
JointDrillRaidPanel._sUIResRootPath = "UI_Activity/"
JointDrillRaidPanel._tbDefine = {
	{
		sPrefabPath = "_510003/JointDrillRaidPanel.prefab",
		sCtrlName = "Game.UI.JointDrill.JointDrill_2.JointDrillRaidCtrl"
	}
}
function JointDrillRaidPanel:Awake()
end
function JointDrillRaidPanel:OnEnable()
end
function JointDrillRaidPanel:OnAfterEnter()
end
function JointDrillRaidPanel:OnDisable()
end
function JointDrillRaidPanel:OnDestroy()
end
function JointDrillRaidPanel:OnRelease()
end
return JointDrillRaidPanel
