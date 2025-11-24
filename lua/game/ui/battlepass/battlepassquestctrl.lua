local BattlePassQuestCtrl = class("BattlePassQuestCtrl", BaseCtrl)
BattlePassQuestCtrl._mapNodeConfig = {
	srQuestDaily = {
		sComponentName = "LoopScrollView"
	},
	srQuestWeekly = {
		sComponentName = "LoopScrollView"
	},
	togDaily = {
		sCtrlName = "Game.UI.TemplateEx.TemplateToggleCtrl"
	},
	togWeek = {
		sCtrlName = "Game.UI.TemplateEx.TemplateToggleCtrl"
	},
	btnDaily = {
		sNodeName = "togDaily",
		sComponentName = "UIButton",
		callback = "OnBtnClick_Daily"
	},
	btnWeek = {
		sNodeName = "togWeek",
		sComponentName = "UIButton",
		callback = "OnBtnClick_Weekly"
	},
	btnAllReceive = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_AllReceive"
	},
	TMPWeekLimit = {sComponentName = "TMP_Text"},
	txtBtnAllReceive = {
		sComponentName = "TMP_Text",
		sLanguageId = "BattlePassReceiveAll"
	},
	redDotDailyQuest = {},
	redDotWeekQuest = {}
}
BattlePassQuestCtrl._mapEventConfig = {
	BattlePassQuestReceive = "OnEvent_QuestReceive",
	ShowQuestReward = "ShowQuestReward"
}
BattlePassQuestCtrl._mapRedDotConfig = {
	[RedDotDefine.BattlePass_Quest_Daily] = {
		sNodeName = "redDotDailyQuest"
	},
	[RedDotDefine.BattlePass_Quest_Week] = {
		sNodeName = "redDotWeekQuest"
	}
}
function BattlePassQuestCtrl:Awake()
	self.mapQuestsGrids = {}
end
function BattlePassQuestCtrl:FadeIn()
end
function BattlePassQuestCtrl:FadeOut()
end
function BattlePassQuestCtrl:OnEnable()
	self._mapNode.togDaily:SetText(ConfigTable.GetUIText("BattlePassRewardDaily"))
	if self._panel.questTab == 1 then
		self.curTab = 1
		self._mapNode.togDaily:SetDefault(true)
		self._mapNode.togWeek:SetDefault(false)
		self._mapNode.srQuestDaily.gameObject:SetActive(true)
		self._mapNode.srQuestWeekly.gameObject:SetActive(false)
	else
		self.curTab = 2
		self._mapNode.togDaily:SetDefault(false)
		self._mapNode.togWeek:SetDefault(true)
		self._mapNode.srQuestDaily.gameObject:SetActive(false)
		self._mapNode.srQuestWeekly.gameObject:SetActive(true)
	end
	self.togRefreshTimer = nil
end
function BattlePassQuestCtrl:OnDisable()
	self:UnbindAllCtrl()
	if self.togRefreshTimer ~= nil then
		self.togRefreshTimer:Cancel(false)
	end
end
function BattlePassQuestCtrl:OnDestroy()
end
function BattlePassQuestCtrl:OnRelease()
end
function BattlePassQuestCtrl:Refresh(nExpThisWeek, nCurLevel)
	local mapDailyQuest, mapWeeklyQuest = PlayerData.Quest:GetBattlePassQuestData()
	local nExpLimit = ConfigTable.GetConfigNumber("BattlePassWeeklyExpLimit")
	local bMaxLevel = ConfigTable.GetData("BattlePassLevel", nCurLevel + 1) == nil
	if bMaxLevel then
		NovaAPI.SetTMPText(self._mapNode.TMPWeekLimit, ConfigTable.GetUIText("BattlePassQusetMax"))
	else
		NovaAPI.SetTMPText(self._mapNode.TMPWeekLimit, orderedFormat(ConfigTable.GetUIText("BattlePassQusetExpLimit"), nExpThisWeek, nExpLimit))
	end
	local bFullExp = nExpThisWeek >= nExpLimit
	self.tbDaily = {}
	self.tbWeekly = {}
	local statusOrder = {
		[0] = 1,
		[1] = 2,
		[2] = 0
	}
	local sort = function(a, b)
		if a.nStatus ~= b.nStatus then
			return statusOrder[a.nStatus] > statusOrder[b.nStatus]
		end
		return a.nTid < b.nTid
	end
	local bHasComplete = false
	local nIdx = 0
	for _, mapQuestData in pairs(mapDailyQuest) do
		if mapQuestData.nStatus == 1 then
			bHasComplete = true
			nIdx = 1
		end
		table.insert(self.tbDaily, mapQuestData)
	end
	for _, mapQuestData in pairs(mapWeeklyQuest) do
		if mapQuestData.nStatus == 1 then
			bHasComplete = true
			if nIdx < 1 then
				nIdx = 2
			end
		end
		table.insert(self.tbWeekly, mapQuestData)
	end
	self:SetWeeklyTogText()
	table.sort(self.tbDaily, sort)
	table.sort(self.tbWeekly, sort)
	self.enableQuest = not bMaxLevel and not bFullExp
	self._mapNode.srQuestDaily:Init(#self.tbDaily, self, self.OnGridRefreshDaily)
	self._mapNode.srQuestWeekly:Init(#self.tbWeekly, self, self.OnGridRefreshWeekly)
	self._mapNode.btnAllReceive.gameObject:SetActive(bHasComplete and not bMaxLevel and not bFullExp)
	if self.togRefreshTimer == nil then
		self.togRefreshTimer = self:AddTimer(0, 60, "SetWeeklyTogText", true, true, true, nil)
	end
	return bHasComplete, nIdx
end
function BattlePassQuestCtrl:SetToggle(nIdx)
	if nIdx == 1 then
		self.curTab = 1
		self._mapNode.togDaily:SetDefault(true)
		self._mapNode.togWeek:SetDefault(false)
		self._mapNode.srQuestDaily.gameObject:SetActive(true)
		self._mapNode.srQuestWeekly.gameObject:SetActive(false)
	else
		self.curTab = 2
		self._mapNode.togDaily:SetDefault(false)
		self._mapNode.togWeek:SetDefault(true)
		self._mapNode.srQuestDaily.gameObject:SetActive(false)
		self._mapNode.srQuestWeekly.gameObject:SetActive(true)
	end
end
function BattlePassQuestCtrl:UnbindAllCtrl()
	for _, mapCtrl in pairs(self.mapQuestsGrids) do
		self:UnbindCtrlByNode(mapCtrl)
	end
	self.mapQuestsGrids = {}
end
function BattlePassQuestCtrl:PlayListInAnim()
	if self.curTab == 1 then
		self._mapNode.srQuestDaily:SetAnim(0.07)
		self._mapNode.srQuestDaily:Init(#self.tbDaily, self, self.OnGridRefreshDaily)
	else
		self._mapNode.srQuestWeekly:SetAnim(0.07)
		self._mapNode.srQuestWeekly:Init(#self.tbWeekly, self, self.OnGridRefreshWeekly)
	end
	EventManager.Hit(EventId.TemporaryBlockInput, 0.5)
end
function BattlePassQuestCtrl:OnGridRefreshDaily(goGrid, gridIndex)
	if self.mapQuestsGrids[goGrid] == nil then
		self.mapQuestsGrids[goGrid] = self:BindCtrlByNode(goGrid, "Game.UI.BattlePass.BattlePassQusetGridCtrl")
	end
	local nIdx = gridIndex + 1
	local mapQuestData = self.tbDaily[nIdx]
	if mapQuestData == nil then
		printError("GuideQuestData missing" .. nIdx)
		self.mapQuestsGrids[goGrid]:Refresh(nil, nil)
		return
	end
	local mapQuestCfgData = ConfigTable.GetData("BattlePassQuest", mapQuestData.nTid)
	self.mapQuestsGrids[goGrid]:Refresh(mapQuestData, mapQuestCfgData, self.enableQuest)
end
function BattlePassQuestCtrl:OnGridRefreshWeekly(goGrid, gridIndex)
	if self.mapQuestsGrids[goGrid] == nil then
		self.mapQuestsGrids[goGrid] = self:BindCtrlByNode(goGrid, "Game.UI.BattlePass.BattlePassQusetGridCtrl")
	end
	local nIdx = gridIndex + 1
	local mapQuestData = self.tbWeekly[nIdx]
	if mapQuestData == nil then
		printError("GuideQuestData missing" .. nIdx)
		self.mapQuestsGrids[goGrid]:Refresh(nil, nil)
		return
	end
	local mapQuestCfgData = ConfigTable.GetData("BattlePassQuest", mapQuestData.nTid)
	self.mapQuestsGrids[goGrid]:Refresh(mapQuestData, mapQuestCfgData, self.enableQuest)
end
function BattlePassQuestCtrl:OnEvent_QuestReceive(mapData)
	local mapDailyQuest, mapWeeklyQuest = PlayerData.Quest:GetBattlePassQuestData()
	local nExpLimit = ConfigTable.GetConfigNumber("BattlePassWeeklyExpLimit")
	local bMaxLevel = ConfigTable.GetData("BattlePassLevel", mapData.Level + 1) == nil
	local bFullExp = nExpLimit <= mapData.ExpThisWeek
	if bMaxLevel then
		NovaAPI.SetTMPText(self._mapNode.TMPWeekLimit, ConfigTable.GetUIText("BattlePassQusetMax"))
	else
		NovaAPI.SetTMPText(self._mapNode.TMPWeekLimit, orderedFormat(ConfigTable.GetUIText("BattlePassQusetExpLimit"), mapData.ExpThisWeek, nExpLimit))
	end
	self.tbDaily = {}
	self.tbWeekly = {}
	local statusOrder = {
		[0] = 1,
		[1] = 2,
		[2] = 0
	}
	local sort = function(a, b)
		if a.nStatus ~= b.nStatus then
			return statusOrder[a.nStatus] > statusOrder[b.nStatus]
		end
		return a.nTid < b.nTid
	end
	local bHasComplete = false
	for _, mapQuestData in pairs(mapDailyQuest) do
		table.insert(self.tbDaily, mapQuestData)
		if mapQuestData.nStatus == 1 then
			bHasComplete = true
		end
	end
	for _, mapQuestData in pairs(mapWeeklyQuest) do
		table.insert(self.tbWeekly, mapQuestData)
		if mapQuestData.nStatus == 1 then
			bHasComplete = true
		end
	end
	local mapWeeklyQuestData = self.tbWeekly[1]
	if mapWeeklyQuestData ~= nil then
		local nBattlePassEndTS = PlayerData.BattlePass.nDeadlineTS
		if nBattlePassEndTS < 1 then
			nBattlePassEndTS = mapWeeklyQuestData.nExpire
		end
		local curTime = CS.ClientManager.Instance.serverTimeStamp
		local sumTime = math.min(mapWeeklyQuestData.nExpire, nBattlePassEndTS) - curTime
		local nDay = math.floor(sumTime / 86400)
		local nHour = math.floor((sumTime - nDay * 86400) / 3600)
		local nHourReal = (sumTime - nDay * 86400) / 3600
		if 0 < nDay then
			self._mapNode.togWeek:SetText(orderedFormat(ConfigTable.GetUIText("BattlePassQusetWeekly"), nDay, nHour))
		elseif 1 < nHourReal then
			self._mapNode.togWeek:SetText(orderedFormat(ConfigTable.GetUIText("BattlePassQusetWeeklyHour"), nHour))
		else
			self._mapNode.togWeek:SetText(ConfigTable.GetUIText("Depot_LeftTime_LessThenHour"))
		end
	else
		self._mapNode.togWeek.gameObject:SetActive(false)
	end
	table.sort(self.tbDaily, sort)
	table.sort(self.tbWeekly, sort)
	self.enableQuest = not bMaxLevel and not bFullExp
	self._mapNode.btnAllReceive.gameObject:SetActive(bHasComplete and not bMaxLevel and not bFullExp)
	self._mapNode.srQuestDaily:Init(#self.tbDaily, self, self.OnGridRefreshDaily, nil, true, nil)
	self._mapNode.srQuestWeekly:Init(#self.tbWeekly, self, self.OnGridRefreshWeekly, nil, true, nil)
end
function BattlePassQuestCtrl:OnBtnClick_Daily(btn)
	self._panel.questTab = 1
	if self.curTab == 1 then
		return
	end
	self._mapNode.togDaily:SetTrigger(true)
	self._mapNode.togWeek:SetTrigger(false)
	self.curTab = 1
	self._mapNode.srQuestDaily.gameObject:SetActive(true)
	self._mapNode.srQuestWeekly.gameObject:SetActive(false)
end
function BattlePassQuestCtrl:OnBtnClick_Weekly(btn)
	self._panel.questTab = 2
	if self.curTab == 2 then
		return
	end
	self._mapNode.togDaily:SetTrigger(false)
	self._mapNode.togWeek:SetTrigger(true)
	self.curTab = 2
	self._mapNode.srQuestDaily.gameObject:SetActive(false)
	self._mapNode.srQuestWeekly.gameObject:SetActive(true)
end
function BattlePassQuestCtrl:OnBtnClick_AllReceive(btn)
	PlayerData.Quest:ReceiveBattlePassQuestData(0, nil)
end
function BattlePassQuestCtrl:ShowQuestReward(grid)
	local nIdx = tonumber(grid.name)
	if self.curTab == 1 then
		self._mapNode.srQuestDaily:SetScrollGridPos(nIdx, 0, 1)
	else
		self._mapNode.srQuestWeekly:SetScrollGridPos(nIdx, 0, 1)
	end
end
function BattlePassQuestCtrl:SetWeeklyTogText()
	local mapWeeklyQuestData = self.tbWeekly[1]
	if mapWeeklyQuestData ~= nil then
		local nBattlePassEndTS = PlayerData.BattlePass.nDeadlineTS
		if nBattlePassEndTS < 1 then
			nBattlePassEndTS = mapWeeklyQuestData.nExpire
		end
		local curTime = CS.ClientManager.Instance.serverTimeStamp
		local sumTime = math.min(mapWeeklyQuestData.nExpire, nBattlePassEndTS) - curTime
		local nDay = math.floor(sumTime / 86400)
		local nHour = math.floor((sumTime - nDay * 86400) / 3600)
		local nHourReal = (sumTime - nDay * 86400) / 3600
		if 0 < nDay then
			self._mapNode.togWeek:SetText(orderedFormat(ConfigTable.GetUIText("BattlePassQusetWeekly"), nDay, nHour))
		elseif 1 < nHourReal then
			self._mapNode.togWeek:SetText(orderedFormat(ConfigTable.GetUIText("BattlePassQusetWeeklyHour"), nHour))
		else
			self._mapNode.togWeek:SetText(ConfigTable.GetUIText("Depot_LeftTime_LessThenHour"))
		end
	else
		self._mapNode.togWeek.gameObject:SetActive(false)
	end
end
return BattlePassQuestCtrl
