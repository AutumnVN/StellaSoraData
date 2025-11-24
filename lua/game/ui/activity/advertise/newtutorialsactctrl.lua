NewTutorialsActCtrl = class("NewTutorialsActCtrl", BaseCtrl)
NewTutorialsActCtrl._mapNodeConfig = {
	btn_GoGuideQusetPanel = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_GoGuideQusetPanel"
	},
	txt_Title1 = {
		sComponentName = "TMP_Text",
		sLanguageId = "QuestPanel_Tab_1"
	},
	txt_Plan1 = {sNodeName = "txt_Plan1", sComponentName = "TMP_Text"},
	txt_Complete1 = {
		sComponentName = "TMP_Text",
		sLanguageId = "Quest_Complete"
	},
	txtBtnGo1 = {
		sComponentName = "TMP_Text",
		sLanguageId = "Quest_JumpTo"
	},
	btn_GoTutorialPanel = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_GoTutorialPanel"
	},
	txt_Title2 = {
		sComponentName = "TMP_Text",
		sLanguageId = "QuestPanel_Tab_4"
	},
	txt_Plan2 = {sNodeName = "txt_Plan2", sComponentName = "TMP_Text"},
	txt_Complete2 = {
		sComponentName = "TMP_Text",
		sLanguageId = "Quest_Complete"
	},
	txtBtnGo2 = {
		sNodeName = "txtBtnGo2",
		sComponentName = "TMP_Text",
		sLanguageId = "Quest_JumpTo"
	}
}
NewTutorialsActCtrl._mapEventConfig = {}
function NewTutorialsActCtrl:InitActData(actData)
	self.actData = actData
	self.nActId = actData:GetActId()
	self.AdConfig = ConfigTable.GetData("AdControl", self.nActId)
	self:Init()
end
function NewTutorialsActCtrl:Init()
	self:RefreshGuideQuset()
	self:RefreshTutorial()
end
function NewTutorialsActCtrl:RefreshGuideQuset()
	local nReceivedCount = 0
	local nTotalCount = PlayerData.Quest:GetMaxTourGroupOrderIndex()
	local nCurTourGroupOrder = PlayerData.Quest:GetCurTourGroupOrder()
	if PlayerData.Quest:CheckTourGroupReward(nTotalCount) then
		self._mapNode.btn_GoGuideQusetPanel.gameObject:SetActive(false)
		self._mapNode.txt_Complete1.gameObject:SetActive(true)
		nReceivedCount = nTotalCount
	else
		nReceivedCount = nCurTourGroupOrder - 1
	end
	local sPanel = orderedFormat(ConfigTable.GetUIText("NewTutorialsAct_Complete") or "", nReceivedCount, nTotalCount)
	NovaAPI.SetTMPText(self._mapNode.txt_Plan1, sPanel)
end
function NewTutorialsActCtrl:RefreshTutorial()
	local nTotalCount, nReceivedCount = PlayerData.TutorialData:GetProgress()
	local sPanel = orderedFormat(ConfigTable.GetUIText("NewTutorialsAct_Complete") or "", nReceivedCount, nTotalCount)
	NovaAPI.SetTMPText(self._mapNode.txt_Plan2, sPanel)
	if nTotalCount == nReceivedCount then
		self._mapNode.btn_GoTutorialPanel.gameObject:SetActive(false)
		self._mapNode.txt_Complete2.gameObject:SetActive(true)
	end
end
function NewTutorialsActCtrl:OnBtnClick_GoGuideQusetPanel()
	EventManager.Hit(EventId.OpenPanel, PanelId.Quest, AllEnum.QuestPanelTab.GuideQuest)
end
function NewTutorialsActCtrl:OnBtnClick_GoTutorialPanel()
	local bPlayCond = PlayerData.Base:CheckFunctionUnlock(GameEnum.OpenFuncType.TutorialLevel, true)
	if not bPlayCond then
		return
	end
	EventManager.Hit(EventId.OpenPanel, PanelId.Quest, AllEnum.QuestPanelTab.Tutorial)
end
function NewTutorialsActCtrl:ClearActivity()
end
return NewTutorialsActCtrl
