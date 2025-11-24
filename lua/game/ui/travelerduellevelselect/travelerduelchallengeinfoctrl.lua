local TravelerDuelChallengeInfoCtrl = class("TravelerDuelChallengeInfoCtrl", BaseCtrl)
local ConfigData = require("GameCore.Data.ConfigData")
TravelerDuelChallengeInfoCtrl._mapNodeConfig = {
	svAffixSelect = {
		sComponentName = "LoopScrollView"
	},
	txtTitleHard = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_AffixHardLevelTitle"
	},
	txtTitleAffix = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_SelectedAffixTitle"
	},
	gridAffix = {},
	rtAffixListContent = {sComponentName = "Transform"},
	ContentAffixSelect = {sComponentName = "Transform"},
	TMPTitleChallengeAttr = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_EnemyAttrTitle"
	},
	TMPTitleChallengeScore = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_ScoreTitle"
	},
	TMPChallengeAttr = {sComponentName = "TMP_Text"},
	TMPChallengeScore = {sComponentName = "TMP_Text"},
	TMPCurLevel = {sComponentName = "TMP_Text"},
	txtRecommendLevelChallenge = {sComponentName = "TMP_Text"},
	imgElementInfoChallenge = {sComponentName = "Image", nCount = 3},
	imgChallengeCover = {sComponentName = "Transform"},
	btnGoChallenge = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Go"
	},
	txtBtnGoChallenge = {
		sComponentName = "TMP_Text",
		sLanguageId = "Maninline_Btn_Go"
	},
	btnDuelQuest = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Quest"
	},
	txtAffixSelectTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_AffixSelectTitle"
	},
	btnClearSelect = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_ClearAllAffix"
	},
	txtClearSelect = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_ClearAffixTitle"
	},
	srAffixList = {
		sComponentName = "UIScrollToClick"
	},
	redDotDuelQuest2 = {},
	goEmpty = {},
	txtEmpty = {
		sComponentName = "TMP_Text",
		sLanguageId = "TDEmptyAffix"
	},
	TMPRecommendBuildTitleChallenge = {
		sComponentName = "TMP_Text",
		sLanguageId = "InfinityTower_Recommend_Construct"
	},
	imgReconmendBuildChallenge = {sComponentName = "Image"},
	imgRankingIcon = {sComponentName = "Image"},
	TMPRanking = {sComponentName = "TMP_Text"},
	TMPScore = {sComponentName = "TMP_Text"},
	TMPUploadTimes = {sComponentName = "TMP_Text"},
	btnRankingHint = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_RankingHint"
	},
	rtRanking = {},
	rtEmpty = {},
	TMPEmptyHint = {
		sComponentName = "TMP_Text",
		sLanguageId = "STRanking_Empty"
	},
	txtBtnRankingDetail = {
		sComponentName = "TMP_Text",
		sLanguageId = "StarTower_Rank_Score_Detail"
	}
}
TravelerDuelChallengeInfoCtrl._mapEventConfig = {}
TravelerDuelChallengeInfoCtrl._mapRedDotConfig = {
	[RedDotDefine.Map_TravelerDuel] = {
		sNodeName = "redDotDuelQuest2"
	}
}
function TravelerDuelChallengeInfoCtrl:Awake()
end
function TravelerDuelChallengeInfoCtrl:FadeIn()
end
function TravelerDuelChallengeInfoCtrl:FadeOut()
end
function TravelerDuelChallengeInfoCtrl:OnEnable()
end
function TravelerDuelChallengeInfoCtrl:OnDisable()
	if self.goCover ~= nil then
		self:UnbindCoverBtn(self.goCover)
		delChildren(self._mapNode.imgChallengeCover)
		self.goCover = nil
	end
	self:ClearListGrids()
end
function TravelerDuelChallengeInfoCtrl:OnDestroy()
end
function TravelerDuelChallengeInfoCtrl:OnRelease()
end
function TravelerDuelChallengeInfoCtrl:Refresh(nLevelId)
	self:ClearListGrids()
	local mapBossLevelData = ConfigTable.GetData("TravelerDuelBossLevel", nLevelId)
	if mapBossLevelData == nil then
		return
	end
	self.nLevelId = nLevelId
	if self.goCover ~= nil then
		self:UnbindCoverBtn(self.goCover)
		delChildren(self._mapNode.imgChallengeCover)
		self.goCover = nil
	end
	local coverPrefab = self:LoadAsset(string.format("%s.prefab", mapBossLevelData.Cover))
	self.goCover = instantiate(coverPrefab, self._mapNode.imgChallengeCover)
	self:BindCoverBtn(self.goCover)
	local mapLevel = ConfigTable.GetData("TravelerDuelChallengeDifficulty", 0)
	if mapLevel ~= nil then
		local rBuildRank = mapLevel.RecommendBuildRank
		local sScore = "Icon/BuildRank/BuildRank_" .. rBuildRank
		self:SetPngSprite(self._mapNode.imgReconmendBuildChallenge, sScore)
		NovaAPI.SetTMPText(self._mapNode.TMPChallengeScore, mapLevel.BaseScore)
		NovaAPI.SetTMPText(self._mapNode.TMPChallengeAttr, string.format("%d%%", mapLevel.Attr))
		NovaAPI.SetTMPText(self._mapNode.txtRecommendLevelChallenge, mapLevel.RecommendScore)
	else
		NovaAPI.SetTMPText(self._mapNode.TMPChallengeScore, "0")
		NovaAPI.SetTMPText(self._mapNode.TMPChallengeAttr, "0%")
		NovaAPI.SetTMPText(self._mapNode.txtRecommendLevelChallenge, "0")
		local sScore = "Icon/BuildRank/BuildRank_" .. 1
		self:SetPngSprite(self._mapNode.imgReconmendBuildChallenge, sScore)
	end
	NovaAPI.SetTMPText(self._mapNode.TMPCurLevel, "0")
	self.mapChallengeData = PlayerData.TravelerDuel:GetTravelerDuelChallenge()
	for i = 1, 3 do
		if mapBossLevelData.EET == nil or mapBossLevelData.EET[i] == nil then
			self._mapNode.imgElementInfoChallenge[i].gameObject:SetActive(false)
		else
			self._mapNode.imgElementInfoChallenge[i].gameObject:SetActive(true)
			self:SetAtlasSprite(self._mapNode.imgElementInfoChallenge[i], "12_rare", AllEnum.ElementIconType.Icon .. mapBossLevelData.EET[i])
		end
	end
	self.selectedAffixIds = {}
	self.tbAllAffix = {}
	self.lastSelAffixId = nil
	local tbAffixCfgData = ConfigTable.GetData("TravelerDuelChallengeSeason", self.mapChallengeData.nIdx)
	if tbAffixCfgData == nil then
		printError("Season Data Missing\239\188\154" .. self.mapChallengeData.nIdx)
		return
	end
	local tbRawData = decodeJson(tbAffixCfgData.AffixGroupIds)
	local mapAffixes = {}
	if tbRawData ~= nil then
		local forEachAffix = function(mapData)
			if table.indexof(tbRawData, mapData.GroupId) > 0 and mapData.GroupId ~= 0 then
				if mapAffixes[mapData.GroupId] == nil then
					mapAffixes[mapData.GroupId] = {}
				end
				table.insert(mapAffixes[mapData.GroupId], mapData.Id)
			end
		end
		ForEachTableLine(DataTable.TravelerDuelChallengeAffix, forEachAffix)
	else
		self._mapNode.svAffixSelect:Init(0, self, self.OnGridRefresh, self.OnBtnClickGrid)
		return
	end
	local Sort = function(a, b)
		local mapCfgDataA = ConfigTable.GetData("TravelerDuelChallengeAffix", a)
		local mapCfgDataB = ConfigTable.GetData("TravelerDuelChallengeAffix", b)
		if mapCfgDataA == nil or mapCfgDataB == nil then
			return mapCfgDataA ~= nil
		end
		if mapCfgDataA.Difficulty ~= mapCfgDataB.Difficulty then
			return mapCfgDataA.Difficulty < mapCfgDataB.Difficulty
		end
		return a[1] < b[1]
	end
	for _, tbAffixes in pairs(mapAffixes) do
		table.sort(tbAffixes, Sort)
	end
	for _, nGroupId in ipairs(tbRawData) do
		if nGroupId == 0 then
			table.insert(self.tbAllAffix, {0, 0})
		elseif mapAffixes[nGroupId] ~= nil then
			for _, value in ipairs(mapAffixes[nGroupId]) do
				table.insert(self.tbAllAffix, {value, nGroupId})
			end
		end
	end
	local nCount = #self.tbAllAffix
	self._mapNode.svAffixSelect:Init(nCount, self, self.OnGridRefresh, self.OnBtnClickGrid)
	self:InitCachedSelectedGridState()
	local mapSelfRanking, _, _, nTimes = PlayerData.TravelerDuel:GetTDRankingData()
	NovaAPI.SetTMPText(self._mapNode.TMPUploadTimes, orderedFormat(ConfigTable.GetUIText("TDRanking_UploadTimes"), nTimes))
	self.bHasUploadRankingTimes = 0 < nTimes
	if mapSelfRanking ~= nil then
		self._mapNode.rtRanking:SetActive(true)
		self._mapNode.rtEmpty:SetActive(false)
		self:SetAtlasSprite(self._mapNode.imgRankingIcon, "12_rare", "travelerduel_rank_" .. mapSelfRanking.nRewardIdx)
		if mapSelfRanking.nRewardIdx == 4 then
			local nRanking = ConfigTable.GetData("TravelerDuelChallengeRankReward", 4).RankUpper * ConfigData.IntFloatPrecision * 100
			NovaAPI.SetTMPText(self._mapNode.TMPRanking, orderedFormat(ConfigTable.GetUIText("TravelerDuel_ChallengeRankTitle1"), nRanking))
		else
			NovaAPI.SetTMPText(self._mapNode.TMPRanking, orderedFormat(ConfigTable.GetUIText("TravelerDuel_ChallengeRankTitle2"), mapSelfRanking.Rank))
		end
		NovaAPI.SetTMPText(self._mapNode.TMPScore, orderedFormat(ConfigTable.GetUIText("TravelerDuel_ChallengeRankScore"), mapSelfRanking.Score))
	else
		self._mapNode.rtRanking:SetActive(false)
		self._mapNode.rtEmpty:SetActive(true)
	end
end
function TravelerDuelChallengeInfoCtrl:BindCoverBtn(goCover)
	local btnInfo = goCover.transform:Find("btnEnemyInfoChallengeInfo")
	if btnInfo ~= nil then
		local compBtn = btnInfo:GetComponent("UIButton")
		if compBtn ~= nil then
			compBtn.onClick:AddListener(function()
				self:OnBtnClick_EnemyInfo()
			end)
		end
	end
end
function TravelerDuelChallengeInfoCtrl:UnbindCoverBtn(goCover)
	local btnInfo = goCover.transform:Find("btnEnemyInfoChallengeInfo")
	if btnInfo ~= nil then
		local compBtn = btnInfo:GetComponent("UIButton")
		if compBtn ~= nil then
			compBtn.onClick:RemoveAllListeners()
		end
	end
end
function TravelerDuelChallengeInfoCtrl:InitCachedSelectedGridState()
	local cachedAffixes, cachedBossId = PlayerData.TravelerDuel:GetCacheAffixids()
	if cachedAffixes ~= nil then
		for index, nAffixId in ipairs(cachedAffixes) do
			local grid = self:GetGridByDataID(nAffixId)
			if grid ~= nil then
				self:OnBtnClickGrid(grid)
				self:RefreshGridSelectState(grid, nAffixId, false)
			else
				self:AddAffixGrid(nAffixId)
			end
		end
	end
end
function TravelerDuelChallengeInfoCtrl:OnGridRefresh(goGrid, gridIndex)
	if self.mapAffixGrid[goGrid] == nil then
		self.mapAffixGrid[goGrid] = self:BindCtrlByNode(goGrid, "Game.UI.TravelerDuelLevelSelect.TravelerDuelChallengeAffixGrid")
	end
	local nIdx = gridIndex + 1
	local tbData = self.tbAllAffix[nIdx]
	local bLine = self.tbAllAffix[nIdx + 1] ~= nil and self.tbAllAffix[nIdx + 1][2] == tbData[2]
	local bSelect = table.indexof(self.selectedAffixIds, tbData[1]) > 0
	local bGroupMask = false
	if not bSelect then
		for _, nSelectId in ipairs(self.selectedAffixIds) do
			local mapAffixCfgDataSelect = ConfigTable.GetData("TravelerDuelChallengeAffix", nSelectId)
			if mapAffixCfgDataSelect == nil then
				return
			end
			if mapAffixCfgDataSelect.GroupId == tbData[2] then
				bGroupMask = true
				break
			end
		end
	end
	local imgFocus = goGrid.transform:Find("btnGrid/imgFocus")
	local bFocus = tbData[1] == self.lastSelAffixId
	if bFocus then
		if imgFocus ~= nil then
			imgFocus.gameObject:SetActive(true)
		end
	elseif imgFocus ~= nil then
		imgFocus.gameObject:SetActive(false)
	end
	if nIdx >= goGrid.transform.parent.childCount then
		goGrid.transform:SetAsLastSibling()
	else
		goGrid.transform:SetSiblingIndex(nIdx)
	end
	self.mapAffixGrid[goGrid]:Refresh(tbData[1], bSelect, bGroupMask, bLine)
end
function TravelerDuelChallengeInfoCtrl:RefreshGridSelectState(goGrid, affixId, bSelect)
	if goGrid == nil then
		return
	end
	if bSelect then
		self.lastSelAffixId = affixId
	else
		self.lastSelAffixId = nil
	end
	local imgFocus = goGrid.transform:Find("btnGrid/imgFocus")
	if imgFocus ~= nil then
		imgFocus.gameObject:SetActive(bSelect)
	end
	local strId = tostring(affixId)
	for index, nAffixId in ipairs(self.selectedAffixIds) do
		local grid = self.tbAffixGrid[index]
		if grid == nil then
			printError("\232\175\141\230\157\161\230\149\176\233\135\143\233\148\153\232\175\175")
			return
		end
		local selNode = grid.transform:Find("selNode")
		local bindGrid = grid.transform:Find("BindGridID")
		if bindGrid ~= nil and selNode ~= nil then
			do
				local textComp = bindGrid.gameObject:GetComponent("Text")
				if textComp ~= nil then
					local text = NovaAPI.GetText(textComp)
					if text == strId then
						selNode.gameObject:SetActive(bSelect)
						if bSelect then
							local wait = function()
								coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
								self._mapNode.srAffixList:ScrollToClick(grid)
							end
							cs_coroutine.start(wait)
						end
					else
						selNode.gameObject:SetActive(false)
					end
				end
			end
		end
	end
end
function TravelerDuelChallengeInfoCtrl:GetGridByDataID(dataID)
	local grid
	for index, tbData in ipairs(self.tbAllAffix) do
		if dataID == tbData[1] then
			grid = self._mapNode.ContentAffixSelect:Find(tostring(index - 1))
			break
		end
	end
	return grid
end
function TravelerDuelChallengeInfoCtrl:OnBtnClickGrid(goGrid, gridIndex)
	if self.mapAffixGrid[goGrid] == nil then
		self.mapAffixGrid[goGrid] = self:BindCtrlByNode(goGrid, "Game.UI.TravelerDuelLevelSelect.TravelerDuelChallengeAffixGrid")
	end
	gridIndex = gridIndex or tonumber(goGrid.name)
	local nIdx = gridIndex + 1
	local tbData = self.tbAllAffix[nIdx]
	if self.lastSelAffixId ~= nil then
		local lastGrid = self:GetGridByDataID(self.lastSelAffixId)
		self:RefreshGridSelectState(lastGrid, self.lastSelAffixId, false)
	end
	if table.indexof(self.selectedAffixIds, tbData[1]) > 0 then
		self:RemoveAffixGrid(tbData[1])
		self.mapAffixGrid[goGrid]:SetSelect(false)
		for index, Data in ipairs(self.tbAllAffix) do
			if index ~= nIdx and Data[2] == tbData[2] then
				local goGridAffix = self._mapNode.ContentAffixSelect:Find(tostring(index - 1)).gameObject
				if goGridAffix ~= nil and self.mapAffixGrid[goGridAffix] ~= nil then
					self.mapAffixGrid[goGridAffix]:SetGroupMask(false)
				end
			end
		end
		self:RefreshGridSelectState(goGrid, tbData[1], false)
	else
		self:AddAffixGrid(tbData[1])
		self.mapAffixGrid[goGrid]:SetSelect(true)
		for index, Data in ipairs(self.tbAllAffix) do
			if index ~= nIdx and Data[2] == tbData[2] then
				local goGridAffix = self._mapNode.ContentAffixSelect:Find(tostring(index - 1)).gameObject
				if goGridAffix ~= nil and self.mapAffixGrid[goGridAffix] ~= nil then
					self.mapAffixGrid[goGridAffix]:SetGroupMask(true)
				end
			end
		end
		self:RefreshGridSelectState(goGrid, tbData[1], true)
	end
end
function TravelerDuelChallengeInfoCtrl:ClearListGrids()
	if self.tbAffixGrid ~= nil then
		for _, goAffixGrid in ipairs(self.tbAffixGrid) do
			destroy(goAffixGrid)
		end
	end
	self.tbAffixGrid = {}
	if self.mapAffixGrid ~= nil then
		for go, mapCtrl in ipairs(self.mapAffixGrid) do
			self:UnbindCtrlByNode(mapCtrl)
		end
	end
	self.mapAffixGrid = {}
end
function TravelerDuelChallengeInfoCtrl:AddAffixGrid(nAffixId)
	local Sort = function(a, b)
		local mapCfgDataA = ConfigTable.GetData("TravelerDuelChallengeAffix", a)
		local mapCfgDataB = ConfigTable.GetData("TravelerDuelChallengeAffix", b)
		if mapCfgDataA == nil or mapCfgDataB == nil then
			return mapCfgDataA ~= nil
		end
		if mapCfgDataA.Difficulty ~= mapCfgDataB.Difficulty then
			return mapCfgDataA.Difficulty < mapCfgDataB.Difficulty
		end
		return a < b
	end
	table.insert(self.selectedAffixIds, nAffixId)
	table.sort(self.selectedAffixIds, Sort)
	local goAffix = instantiate(self._mapNode.gridAffix, self._mapNode.rtAffixListContent)
	goAffix:SetActive(true)
	table.insert(self.tbAffixGrid, goAffix)
	self:RefreshAffixList()
end
function TravelerDuelChallengeInfoCtrl:RemoveAffixGrid(nAffixId)
	table.removebyvalue(self.selectedAffixIds, nAffixId)
	local go = table.remove(self.tbAffixGrid)
	destroy(go)
	self:RefreshAffixList()
end
function TravelerDuelChallengeInfoCtrl:OnClickAffixListButton(goGrid, affixId)
	for index, nAffixId in ipairs(self.selectedAffixIds) do
		local grid = self.tbAffixGrid[index]
		if grid == nil then
			printError("\232\175\141\230\157\161\230\149\176\233\135\143\233\148\153\232\175\175")
			return
		end
		local node = grid.transform:Find("selNode")
		if node ~= nil then
			node.gameObject:SetActive(false)
		end
	end
	local selNode = goGrid.transform:Find("selNode")
	if selNode ~= nil then
		selNode.gameObject:SetActive(true)
		local selIndex
		for index, Data in ipairs(self.tbAllAffix) do
			local id = Data[1]
			if id == affixId then
				selIndex = index - 1
			end
		end
		if selIndex ~= nil then
			self._mapNode.svAffixSelect:SetScrollGridPos(selIndex, 0, 1)
			printLog("\229\143\150\230\182\136" .. tostring(self.lastSelAffixId))
			if self.lastSelAffixId ~= nil then
				local goGridAffix = self:GetGridByDataID(self.lastSelAffixId)
				if goGridAffix ~= nil then
					local gameObj = goGridAffix.gameObject
					local imgFocus = gameObj.transform:Find("btnGrid/imgFocus")
					if imgFocus ~= nil then
						imgFocus.gameObject:SetActive(false)
					end
				end
			end
			self.lastSelAffixId = affixId
			printLog("\233\128\137\228\184\173" .. tostring(selIndex))
			if self.lastSelAffixId ~= nil then
				local goGridAffix = self:GetGridByDataID(self.lastSelAffixId)
				if goGridAffix ~= nil then
					printLog("herer")
					local gameObj = goGridAffix.gameObject
					local imgFocus = gameObj.transform:Find("btnGrid/imgFocus")
					if imgFocus ~= nil then
						imgFocus.gameObject:SetActive(true)
					end
				end
			end
		end
	end
end
function TravelerDuelChallengeInfoCtrl:RefreshAffixList()
	local nTotalDifficulty = 0
	self._mapNode.goEmpty:SetActive(0 >= #self.tbAffixGrid)
	for index, nAffixId in ipairs(self.selectedAffixIds) do
		local goGrid = self.tbAffixGrid[index]
		if goGrid == nil then
			printError("\232\175\141\230\157\161\230\149\176\233\135\143\233\148\153\232\175\175")
			return
		end
		local button = goGrid.transform:GetComponent("Button")
		if button ~= nil then
			button.onClick:RemoveAllListeners()
			local listener = function()
				self:OnClickAffixListButton(goGrid, nAffixId)
			end
			button.onClick:AddListener(listener)
		end
		local mapAffixCfgData = ConfigTable.GetData("TravelerDuelChallengeAffix", nAffixId)
		local imgAffixIcon = goGrid.transform:Find("imgAffixIconBg/imgAffixIcon"):GetComponent("Image")
		local TMPAffixDesc = goGrid.transform:Find("TMPAffixDesc"):GetComponent("TMP_Text")
		local TMPHard = goGrid.transform:Find("imgHardBg/TMPHard"):GetComponent("TMP_Text")
		local bindGrid = goGrid.transform:Find("BindGridID")
		if bindGrid ~= nil then
			local textComp = bindGrid.gameObject:GetComponent("Text")
			if textComp ~= nil then
				NovaAPI.SetText(textComp, tostring(nAffixId))
			end
		end
		self:SetPngSprite(imgAffixIcon, mapAffixCfgData.Icon)
		NovaAPI.SetTMPText(TMPAffixDesc, mapAffixCfgData.Desc)
		NovaAPI.SetTMPText(TMPHard, mapAffixCfgData.Difficulty)
		nTotalDifficulty = nTotalDifficulty + mapAffixCfgData.Difficulty
	end
	NovaAPI.SetTMPText(self._mapNode.TMPCurLevel, nTotalDifficulty)
	local mapLevel = ConfigTable.GetData("TravelerDuelChallengeDifficulty", nTotalDifficulty)
	if mapLevel == nil then
		for i = nTotalDifficulty, 0, -1 do
			if ConfigTable.GetData("TravelerDuelChallengeDifficulty", i) ~= nil then
				mapLevel = ConfigTable.GetData("TravelerDuelChallengeDifficulty", i)
				break
			end
		end
	end
	if mapLevel ~= nil then
		local rBuildRank = mapLevel.RecommendBuildRank
		local sScore = "Icon/BuildRank/BuildRank_" .. rBuildRank
		self:SetPngSprite(self._mapNode.imgReconmendBuildChallenge, sScore)
		NovaAPI.SetTMPText(self._mapNode.TMPChallengeScore, mapLevel.BaseScore)
		NovaAPI.SetTMPText(self._mapNode.TMPChallengeAttr, string.format("%d%%", mapLevel.Attr))
		NovaAPI.SetTMPText(self._mapNode.txtRecommendLevelChallenge, mapLevel.RecommendScore)
	else
		local sScore = "Icon/BuildRank/BuildRank_" .. 1
		self:SetPngSprite(self._mapNode.imgReconmendBuildChallenge, sScore)
		NovaAPI.SetTMPText(self._mapNode.TMPChallengeScore, "0")
		NovaAPI.SetTMPText(self._mapNode.TMPChallengeAttr, "0%")
		NovaAPI.SetTMPText(self._mapNode.txtRecommendLevelChallenge, "0")
	end
end
function TravelerDuelChallengeInfoCtrl:CacheAffixes()
	if self.nLevelId == nil or self.nLevelId == 0 then
		return
	end
	local mapBossLevelData = ConfigTable.GetData("TravelerDuelBossLevel", self.nLevelId)
	PlayerData.TravelerDuel:SetCacheAffixids(self.selectedAffixIds, mapBossLevelData.BossId)
end
function TravelerDuelChallengeInfoCtrl:OnBtnClick_ClearAllAffix()
	self.selectedAffixIds = {}
	if self.tbAffixGrid ~= nil then
		for _, goAffixGrid in ipairs(self.tbAffixGrid) do
			destroy(goAffixGrid)
		end
	end
	self._mapNode.svAffixSelect:ForceRefresh()
	self.tbAffixGrid = {}
	self:RefreshAffixList()
end
function TravelerDuelChallengeInfoCtrl:OnBtnClick_Go()
	local confirmCallback = function()
		local OpenPanel = function()
			EventManager.Hit(EventId.OpenPanel, PanelId.RegionBossFormation, AllEnum.RegionBossFormationType.TravelerDuel, self.nLevelId, self.selectedAffixIds)
		end
		self:CacheAffixes()
		EventManager.Hit(EventId.SetTransition, 2, OpenPanel)
	end
	local msg = {
		nType = AllEnum.MessageBox.Confirm,
		sContent = ConfigTable.GetUIText("TravelerDuel_Rank_Continue_Notice"),
		callbackConfirm = confirmCallback
	}
	if self.bHasUploadRankingTimes then
		confirmCallback()
	else
		EventManager.Hit(EventId.OpenMessageBox, msg)
	end
end
function TravelerDuelChallengeInfoCtrl:OnBtnClick_Quest()
	self:CacheAffixes()
	EventManager.Hit(EventId.OpenPanel, PanelId.TravelerDuelLevelQuestPanel)
end
function TravelerDuelChallengeInfoCtrl:OnBtnClick_RankingHint()
	EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("TD_RankingHint"))
end
function TravelerDuelChallengeInfoCtrl:OnBtnClick_EnemyInfo()
	EventManager.Hit("OpenTravelerDuelMonsterInfo", self.nLevelId)
end
return TravelerDuelChallengeInfoCtrl
