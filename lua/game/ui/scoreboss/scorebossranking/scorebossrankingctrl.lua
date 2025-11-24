local ScoreBossRankingCtrl = class("ScoreBossRankingCtrl", BaseCtrl)
ScoreBossRankingCtrl._mapNodeConfig = {
	TopBarPanel = {
		sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"
	},
	imgBlurBG = {},
	txtLoading = {
		sComponentName = "TMP_Text",
		sLanguageId = "ScorebossRanking_Loading"
	},
	txtRankingListRankTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "STRanking_Rank"
	},
	txtRankingListPlayerTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "ScoreBossRankingPlayerName"
	},
	txtRankingListScoreTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "JointDrill_Rank_Score"
	},
	txtRankingListDetailTitle = {sComponentName = "TMP_Text", sLanguageId = "MoreInfo"},
	txtRefreshTime = {
		sComponentName = "TMP_Text",
		sLanguageId = "STRanking_Refresh_Tips"
	},
	txtRefreshTimeReward = {
		sComponentName = "TMP_Text",
		sLanguageId = "STRanking_Refresh_Tips"
	},
	rtPlayerInfo = {
		sCtrlName = "Game.UI.ScoreBoss.ScoreBossRanking.ScoreBossRankingGridCtrl"
	},
	svRankingInfo = {
		sComponentName = "LoopScrollView"
	},
	goLoading = {},
	goMainContent = {},
	goSafeArea = {
		sNodeName = "----SafeAreaRoot----"
	},
	svRankingReward = {
		sComponentName = "LoopScrollView"
	},
	btnCloseReward = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_CloseReward"
	},
	btnRewardClose = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_CloseReward"
	},
	btnReward = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_ShowReward"
	},
	txtBtnReward = {
		sComponentName = "TMP_Text",
		sLanguageId = "STRanking_Reward_Btn"
	},
	goRewardView = {},
	t_window_04 = {sComponentName = "Animator"},
	goTeamDetail = {
		sCtrlName = "Game.UI.ScoreBoss.ScoreBossRanking.ScoreBossRankingTeamDetailCtrl"
	},
	txtEndTime = {sComponentName = "TMP_Text"},
	txt_Reward_Title = {
		sComponentName = "TMP_Text",
		sLanguageId = "StarTower_Ranking_Reward"
	}
}
ScoreBossRankingCtrl._mapEventConfig = {
	ShowTeamDetail = "OnEvent_ShowTeamDetail",
	[EventId.UIHomeConfirm] = "OnEvent_Home",
	[EventId.UIBackConfirm] = "OnEvent_Back"
}
function ScoreBossRankingCtrl:Awake()
	self._mapRankingGrid = {}
	self._mapRewardGrid = {}
end
function ScoreBossRankingCtrl:OnDisable()
	for go, mapCtrl in pairs(self._mapRankingGrid) do
		self:UnbindCtrlByNode(mapCtrl)
	end
	for go, mapCtrl in pairs(self._mapRewardGrid) do
		self:UnbindCtrlByNode(mapCtrl)
	end
	self._mapRankingGrid = {}
	self._mapRewardGrid = {}
	if self.timerRefreshRanking ~= nil then
		self.timerRefreshRanking:Cancel()
		self.timerRefreshRanking = nil
	end
end
function ScoreBossRankingCtrl:OnEnable()
	self._mapNode.goSafeArea:SetActive(false)
	self._mapNode.imgBlurBG:SetActive(true)
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		self._mapNode.goSafeArea.gameObject:SetActive(true)
		self._mapNode.goLoading.gameObject:SetActive(true)
		self._mapNode.goMainContent.gameObject:SetActive(false)
		PlayerData.ScoreBoss:SendScoreBossApplyReq(function()
			local rankPlayerCount = PlayerData.ScoreBoss:GetRankPlayerCount()
			if 0 < rankPlayerCount then
				self:OpenPanel()
			else
				NovaAPI.SetTMPText(self._mapNode.txtLoading, ConfigTable.GetUIText("STRanking_Empty"))
			end
		end)
		self.timerRefreshRanking = self:AddTimer(0, 600, function()
			PlayerData.ScoreBoss:SendScoreBossApplyReq(function()
				local rankPlayerCount = PlayerData.ScoreBoss:GetRankPlayerCount()
				if 0 < rankPlayerCount then
					self:OpenPanel()
				else
					NovaAPI.SetTMPText(self._mapNode.txtLoading, ConfigTable.GetUIText("STRanking_Empty"))
				end
			end)
		end, true, true, true)
	end
	cs_coroutine.start(wait)
end
function ScoreBossRankingCtrl:OpenPanel()
	self._mapNode.goLoading:SetActive(false)
	self._mapNode.goMainContent:SetActive(true)
	local mapSelfRankingData = PlayerData.ScoreBoss:GetRankSelfMsg()
	self.mapSelfRankingData = mapSelfRankingData
	self._mapNode.rtPlayerInfo:Refresh(0, true)
	local rankTable = PlayerData.ScoreBoss:GetRankTableCount()
	if 0 < rankTable then
		self._mapNode.svRankingInfo.gameObject:SetActive(true)
		self._mapNode.svRankingInfo:Init(rankTable, self, self.OnGridRankingRefresh)
		self:PlayGridItemAnim()
	else
		self._mapNode.svRankingInfo.gameObject:SetActive(false)
	end
	self._mapNode.svRankingReward:Init(PlayerData.ScoreBoss.maxRankCount, self, self.OnGridRankingRewardRefresh)
	self._mapNode.goTeamDetail.gameObject:SetActive(false)
	local endTime = PlayerData.ScoreBoss.EndTime + ConfigTable.GetConfigNumber("SeasonEndThreshold")
	local sTime = os.date("%m/%d %H:%M", endTime)
	local sEndTimeTitle = ConfigTable.GetUIText("ScoreBossRankingEndTime")
	NovaAPI.SetTMPText(self._mapNode.txtEndTime, sEndTimeTitle .. " " .. sTime)
end
function ScoreBossRankingCtrl:OnGridRankingRefresh(grid)
	if self._mapRankingGrid[grid] == nil then
		local mapCtrl = self:BindCtrlByNode(grid, "Game.UI.ScoreBoss.ScoreBossRanking.ScoreBossRankingGridCtrl")
		self._mapRankingGrid[grid] = mapCtrl
	end
	local nIdx = tonumber(grid.name)
	if nIdx == nil then
		return
	end
	nIdx = nIdx + 1
	self._mapRankingGrid[grid]:Refresh(nIdx)
end
function ScoreBossRankingCtrl:OnGridRankingRewardRefresh(grid)
	if self._mapRewardGrid[grid] == nil then
		local mapCtrl = self:BindCtrlByNode(grid, "Game.UI.ScoreBoss.ScoreBossRanking.ScoreBossRewardGridCtrl")
		self._mapRewardGrid[grid] = mapCtrl
	end
	local nIdx = tonumber(grid.name)
	if nIdx == nil then
		return
	end
	nIdx = nIdx + 1
	local rankPlayerCount = 0
	local nSelfIdx = -1.0
	if self.mapSelfRankingData ~= nil then
		rankPlayerCount = PlayerData.ScoreBoss:GetRankPlayerCount()
		if 0 < rankPlayerCount and rankPlayerCount <= 100 then
			nSelfIdx = self.mapSelfRankingData.Rank / 100
		elseif 100 < rankPlayerCount then
			nSelfIdx = self.mapSelfRankingData.Rank / rankPlayerCount
		end
		nSelfIdx = nSelfIdx * 10000
	end
	self._mapRewardGrid[grid]:Refresh(nIdx, nSelfIdx)
end
function ScoreBossRankingCtrl:PlayGridItemAnim()
	local sv = self._mapNode.svRankingInfo
	local sAnim = "go"
	local nAnimTime = 0.1
	local nItemAnimLen = 0
	local listInUse = sv:GetInUseGridIndex()
	self.tbGridInUse = {}
	for i = 0, listInUse.Count - 1 do
		table.insert(self.tbGridInUse, listInUse[i])
	end
	if self.gridItemAnimTimer ~= nil then
		self.gridItemAnimTimer:Cancel()
		self.gridItemAnimTimer = nil
	end
	for k, v in ipairs(self.tbGridInUse) do
		local goGrid = sv.transform:Find("Viewport/Content/" .. v)
		local animRoot = goGrid:GetComponent("Animator")
		if animRoot ~= nil then
			animRoot.gameObject:SetActive(false)
		end
		if k == 1 and animRoot ~= nil then
			animRoot.gameObject:SetActive(true)
			nItemAnimLen = NovaAPI.GetAnimClipLength(animRoot, {sAnim})
			animRoot:Play(sAnim, 0, 0)
		end
	end
	local nCurIndex = 1
	EventManager.Hit(EventId.BlockInput, true)
	self.gridItemAnimTimer = self:AddTimer(0, nAnimTime, function()
		nCurIndex = nCurIndex + 1
		if nCurIndex > #self.tbGridInUse and self.gridItemAnimTimer ~= nil then
			self.gridItemAnimTimer:Cancel()
			self.gridItemAnimTimer = nil
			EventManager.Hit(EventId.BlockInput, false)
			return
		end
		local goGrid = sv.transform:Find("Viewport/Content/" .. self.tbGridInUse[nCurIndex])
		if goGrid ~= nil then
			local animRoot = goGrid:GetComponent("Animator")
			animRoot.gameObject:SetActive(true)
			animRoot:Play(sAnim, 0, 0)
		end
	end, true, true, true)
end
function ScoreBossRankingCtrl:OnEvent_ShowTeamDetail(mapRanking)
	self._mapNode.goTeamDetail.gameObject:SetActive(true)
	self._mapNode.goTeamDetail:Refresh(mapRanking)
end
function ScoreBossRankingCtrl:OnBtnClick_ShowReward()
	self._mapNode.goRewardView:SetActive(true)
	self._mapNode.t_window_04:Play("t_window_04_t_in")
end
function ScoreBossRankingCtrl:OnBtnClick_CloseReward()
	self._mapNode.t_window_04:Play("t_window_04_t_out")
	local close = function()
		self._mapNode.goRewardView:SetActive(false)
	end
	self:AddTimer(1, 0.2, close, true, true, true)
	EventManager.Hit(EventId.TemporaryBlockInput, 0.2)
end
function ScoreBossRankingCtrl:OnEvent_Back(nPanelId)
	EventManager.Hit(EventId.CloesCurPanel)
end
function ScoreBossRankingCtrl:OnEvent_Home(nPanelId)
	if self._panel._nPanelId ~= nPanelId then
		return
	end
	PanelManager.Home()
end
return ScoreBossRankingCtrl
