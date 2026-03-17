local TrekkerVersusQuestCtrl = class("TrekkerVersusQuestCtrl", BaseCtrl)
TrekkerVersusQuestCtrl._mapNodeConfig = {
	snapshot = {},
	snapshotBtn = {
		sNodeName = "snapshot",
		sComponentName = "Button",
		callback = "ClosePanel"
	},
	btn_Close = {sComponentName = "Button", callback = "ClosePanel"},
	btnClose_quest = {sComponentName = "UIButton", callback = "ClosePanel"},
	aniWindow = {sNodeName = "rtWindow", sComponentName = "Animator"},
	TMPReceiveAll = {
		sComponentName = "TMP_Text",
		sLanguageId = "Quest_Btn_ReceiveAll"
	},
	rtWindow = {},
	btnHeatQuestReceiveAll = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Receive"
	},
	txtWindowTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_QusetTitle"
	},
	btnRewardTab = {
		nCount = 3,
		sComponentName = "UIButton",
		callback = "OnBtnClick_RewardTab"
	},
	txtTabHeat = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "TD_HeatQuestTab"
	},
	txtTabDuel = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "TD_DuelQuestTab"
	},
	txtTabGift = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "TD_GiftQuestTab"
	},
	rtHeatQuest = {},
	lsvHeatQuest = {
		sComponentName = "LoopScrollView"
	},
	txtCurHeatTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_HeatQuestTitle"
	},
	txtCurHeatNum = {sComponentName = "TMP_Text"},
	rtDuelHistory = {},
	txtDuelHistoryTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_DuelHistoryTitle"
	},
	lsvDuelHistory = {
		sComponentName = "LoopScrollView"
	},
	goGridMain = {
		sCtrlName = "Game.UI.TrekkerVersus_600002.TrekkerVersusDuelHistoryGridCtrl"
	},
	rtGiftQuest = {},
	lsvGiftQuest = {
		sComponentName = "LoopScrollView"
	}
}
TrekkerVersusQuestCtrl._mapEventConfig = {
	TrekkerVersusAffixJump = "OnEvent_TrekkerVersusAffixJump"
}
TrekkerVersusQuestCtrl._mapRedDotConfig = {}
function TrekkerVersusQuestCtrl:RefreshHeatQuestTab()
	self._mapNode.lsvHeatQuest:SetAnim(0.05)
	self._mapNode.lsvHeatQuest:Init(#self._tbAllQuestData, self, self.OnGridRefresh, self.OnBtnClickGrid)
	NovaAPI.SetText(self._mapNode.txtCurHeatTitle, self._mapActData:GetCurHeatValue().nSelfHotValue)
end
function TrekkerVersusQuestCtrl:RefreshDuelHistoryTab()
	self._mapNode.lsvDuelHistory:SetAnim(0.05)
	local mapCurDuelData = self._mapActData:GetCurHeatValue()
	local mapInfo = {
		SelfHotValue = mapCurDuelData.nSelfHotValue,
		RivalHotValue = mapCurDuelData.nRivalHotValue
	}
	self._mapNode.goGridMain:Refresh(mapInfo, self._mapActData:GetCurDayNum(), true)
	self._mapNode.lsvDuelHistory:Init(#self.tbDuelHistory, self, self.OnDuelHistoryGridRefresh)
end
function TrekkerVersusQuestCtrl:OnDuelHistoryGridRefresh(goGrid, nIdx)
	local nIndex = nIdx + 1
	if self._mapGridCtrl[goGrid] == nil then
		local gridCtrl = self:BindCtrlByNode(goGrid, "Game.UI.TrekkerVersus_600002.TrekkerVersusDuelHistoryGridCtrl")
		self._mapGridCtrl[goGrid] = gridCtrl
	end
	local mapDuelHistoryData = self.tbDuelHistory[nIndex]
	self._mapGridCtrl[goGrid]:Refresh(mapDuelHistoryData, nIndex, false)
end
function TrekkerVersusQuestCtrl:RefreshGiftQuestTab()
	self._mapNode.lsvGiftQuest:SetAnim(0.05)
	self._mapNode.lsvGiftQuest:Init(#self._tbAllQuestData, self, self.OnGiftQuestGridRefresh, self.OnBtnClickGrid)
end
function TrekkerVersusQuestCtrl:OnGiftQuestGridRefresh(goGrid, nIdx)
	local nIndex = nIdx + 1
	if self._mapGridCtrl[goGrid] == nil then
		local gridCtrl = self:BindCtrlByNode(goGrid, "Game.UI.TrekkerVersus_600002.TrekkerVersusGiftQuestGridCtrl")
		self._mapGridCtrl[goGrid] = gridCtrl
	end
	local mapGiftQuestData = self._tbAllQuestData[nIndex]
	self._mapGridCtrl[goGrid]:Refresh(mapGiftQuestData)
end
function TrekkerVersusQuestCtrl:Awake()
	self._mapGridCtrl = {}
end
function TrekkerVersusQuestCtrl:FadeIn()
end
function TrekkerVersusQuestCtrl:FadeOut()
end
function TrekkerVersusQuestCtrl:OnEnable()
	self._mapAllQuestCfgData = {}
	self._mapNode.rtWindow.gameObject:SetActive(false)
end
function TrekkerVersusQuestCtrl:OnDisable()
end
function TrekkerVersusQuestCtrl:OnDestroy()
end
function TrekkerVersusQuestCtrl:OnRelease()
end
function TrekkerVersusQuestCtrl:ClosePanel()
	self._mapNode.aniWindow:Play("t_window_04_t_out")
	EventManager.Hit(EventId.TemporaryBlockInput, 0.3)
	self:AddTimer(1, 0.3, function()
		self.gameObject:SetActive(false)
		self._mapNode.rtWindow.gameObject:SetActive(false)
		self:UnbindAllGrids()
	end, true, true, true, nil)
end
function TrekkerVersusQuestCtrl:UnbindAllGrids()
	for go, ctrl in pairs(self._mapGridCtrl) do
		self:UnbindCtrlByNode(ctrl)
	end
	self._mapGridCtrl = {}
end
function TrekkerVersusQuestCtrl:OpenPanel(mapActData)
	self.gameObject:SetActive(true)
	self._mapActData = mapActData
	self._tbAllQuestData = self._mapActData:GetAllQuestData()
	self.tbDuelHistory = self._mapActData:GetDuelHistory()
	local wait = function()
		NovaAPI.UIEffectSnapShotCapture(self._mapNode.snapshot)
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		self._mapNode.rtWindow.gameObject:SetActive(true)
		self._mapNode.aniWindow:Play("t_window_04_t_in")
		self:OnBtnClick_RewardTab(nil, 1)
	end
	cs_coroutine.start(wait)
end
function TrekkerVersusQuestCtrl:OnGridRefresh(goGrid, nIdx)
	local nIdx = nIdx + 1
	if self._mapGridCtrl[goGrid] == nil then
		local gridCtrl = self:BindCtrlByNode(goGrid, "Game.UI.TrekkerVersus.TrekkerVersusQuestGridCtrl")
		self._mapGridCtrl[goGrid] = gridCtrl
	end
	local mapQuestData
	mapQuestData = self._tbAllQuestData[nIdx]
	self._mapGridCtrl[goGrid]:Refresh(mapQuestData)
end
function TrekkerVersusQuestCtrl:OnBtnClick_RewardTab(btn, index)
	if self.nRewardTabIndex == index then
		return
	end
	self.nRewardTabIndex = index
	for i = 1, #self._mapNode.btnRewardTab do
		local objBtn = self._mapNode.btnRewardTab[i]
		local imgOn = objBtn.transform:Find("imgTabOnBg")
		local imgOff = objBtn.transform:Find("imgTabOffBg")
		imgOn:SetActive(i == index)
		imgOff:SetActive(i ~= index)
	end
	self._mapNode.rtHeatQuest:SetActive(index == 1)
	self._mapNode.rtDuelHistory:SetActive(index == 2)
	self._mapNode.rtGiftQuest:SetActive(index == 3)
	if index == 1 then
		self:RefreshHeatQuestTab()
	elseif index == 2 then
		self:RefreshDuelHistoryTab()
	elseif index == 3 then
		self:RefreshGiftQuestTab()
	end
end
function TrekkerVersusQuestCtrl:OnBtnClickGrid()
	self:OnBtnClick_Receive()
end
function TrekkerVersusQuestCtrl:OnBtnClick_Receive()
	local refershList = function()
		self._tbAllQuestData = self._mapActData:GetAllQuestData()
		self:UnbindAllGrids()
		self._mapNode.lsvQuest:SetAnim(0.05)
		self._mapNode.lsvQuest:Init(#self._tbAllQuestData, self, self.OnGridRefresh, self.OnBtnClickGrid)
	end
	local callback = function(msgData)
		UTILS.OpenReceiveByChangeInfo(msgData.Change, function()
			refershList()
		end)
	end
	self._mapActData:ReceiveQuestReward(callback)
end
function TrekkerVersusQuestCtrl:OnEvent_TrekkerVersusAffixJump()
	self:ClosePanel()
end
return TrekkerVersusQuestCtrl
