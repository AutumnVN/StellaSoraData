local StorySetCtrl = class("StorySetCtrl", BaseCtrl)
StorySetCtrl._mapNodeConfig = {
	TopBar = {
		sNodeName = "TopBarPanel",
		sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"
	},
	imgBgPanel = {},
	imgBgChapter = {sComponentName = "Image"},
	goList = {sNodeName = "---List---"},
	chapterLsv = {
		sComponentName = "LoopScrollView"
	},
	goInfo = {sNodeName = "---Info---"},
	imgChapterIcon = {sComponentName = "Image"},
	txtTitle = {sComponentName = "TMP_Text"},
	txtChapter = {sComponentName = "TMP_Text"},
	sectionLsv = {
		sComponentName = "LoopScrollView"
	}
}
StorySetCtrl._mapEventConfig = {
	[EventId.UIBackConfirm] = "OnEvent_Back",
	[EventId.UIHomeConfirm] = "OnEvent_BackHome",
	[EventId.TransAnimOutClear] = "OnEvent_TransAnimOutClear",
	ReceiveStorySetRewardSuc = "OnEvent_ReceiveStorySetRewardSuc",
	StorySetChapterRefresh = "OnEvent_StorySetChapterRefresh"
}
StorySetCtrl._mapRedDotConfig = {}
local panelType_chapter = 1
local panelType_Section = 2
function StorySetCtrl:Refresh()
	if self.nPanelType == panelType_chapter then
		self.animRoot:Play("StorySetPanel_Switch_List", 0, 0)
		self:RefreshChapter()
	elseif self.nPanelType == panelType_Section then
		self.animRoot:Play("StorySetPanel_Switch_Info", 0, 0)
		self:RefreshSection()
	end
end
function StorySetCtrl:RefreshChapter()
	self._mapNode.goList.gameObject:SetActive(true)
	self._mapNode.goInfo.gameObject:SetActive(false)
	for nInstanceId, v in pairs(self.tbChapterGrid) do
		self:UnbindCtrlByNode(v)
		self.tbChapterGrid[nInstanceId] = nil
	end
	if #self.tbChapter == 0 then
		self._mapNode.chapterLsv:Init(4, self, self.OnRefreshChapterGrid, self.OnChapterGridClick)
	else
		self._mapNode.chapterLsv:Init(#self.tbChapter, self, self.OnRefreshChapterGrid, self.OnChapterGridClick, true)
		if self.bLocation then
			self.bLocation = false
			local nNewIndex = 0
			for k, v in ipairs(self.tbChapter) do
				if v ~= nil and v.bUnlock then
					local nChapterId = v.nId
					local mapCfg = ConfigTable.GetData("StorySetChapter", nChapterId)
					if mapCfg ~= nil and mapCfg.IsShow then
						nNewIndex = k
					end
				end
			end
			if 1 < nNewIndex then
				do
					local wait = function()
						coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
						self._mapNode.chapterLsv:SetScrollGridPos(nNewIndex - 1, 0.5, 0)
					end
					cs_coroutine.start(wait)
				end
			end
		else
			local nRecentChapterId = PlayerData.StorySet:GetRecentChapterId()
			local nNewIndex = 0
			for k, v in ipairs(self.tbChapter) do
				if v ~= nil and v.bUnlock then
					local nChapterId = v.nId
					local mapCfg = ConfigTable.GetData("StorySetChapter", nChapterId)
					if mapCfg ~= nil and mapCfg.Id == nRecentChapterId then
						nNewIndex = k
					end
				end
			end
			if 0 < nNewIndex then
				local wait = function()
					coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
					self._mapNode.chapterLsv:SetScrollGridPos(nNewIndex - 1, 0)
				end
				cs_coroutine.start(wait)
			else
				do
					local wait = function()
						coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
						self._mapNode.chapterLsv:SetScrollGridPos(#self.tbChapter, 0)
					end
					cs_coroutine.start(wait)
				end
			end
		end
	end
end
function StorySetCtrl:OnRefreshChapterGrid(goGrid, gridIndex)
	local nIndex = gridIndex + 1
	local data = self.tbChapter[nIndex]
	local nInstanceId = goGrid:GetInstanceID()
	if not self.tbChapterGrid[nInstanceId] then
		self.tbChapterGrid[nInstanceId] = self:BindCtrlByNode(goGrid, "Game.UI.StorySet.StorySetChapterItemCtrl")
	end
	self.tbChapterGrid[nInstanceId]:RefreshItem(data)
end
function StorySetCtrl:OnChapterGridClick(goGrid, gridIndex)
	local nIndex = gridIndex + 1
	local nInstanceId = goGrid:GetInstanceID()
	local data = self.tbChapter[nIndex]
	if data == nil then
		return
	end
	local mapCfg = ConfigTable.GetData("StorySetChapter", data.nId)
	if mapCfg ~= nil then
		if not mapCfg.IsShow then
			EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("StorySet_Chapter_Empty"))
			return
		end
		if not data.bUnlock then
			if mapCfg.LockText ~= "" then
				EventManager.Hit(EventId.OpenMessageBox, mapCfg.LockText)
			else
				EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("StorySet_Chapter_Lock"))
			end
			return
		end
	end
	local nAnimLen = 0
	if self.tbChapterGrid[nInstanceId] ~= nil then
		nAnimLen = self.tbChapterGrid[nInstanceId]:PlayAnim(false)
	end
	self.nSelectIndex = nIndex
	self.bResetLsvPos = true
	self.nPanelType = panelType_Section
	CS.WwiseAudioManager.Instance:PlaySound("ui_mainline_story_menu")
	if 0 < nAnimLen then
		self:AddTimer(1, nAnimLen, function()
			self:Refresh()
		end, true, true, true)
		EventManager.Hit(EventId.TemporaryBlockInput, nAnimLen)
	else
		self:Refresh()
	end
end
function StorySetCtrl:RefreshSection()
	self._mapNode.goList.gameObject:SetActive(false)
	self._mapNode.goInfo.gameObject:SetActive(true)
	for nInstanceId, v in pairs(self.tbSectionGrid) do
		self:UnbindCtrlByNode(v)
		self.tbSectionGrid[nInstanceId] = nil
	end
	local data = self.tbChapter[self.nSelectIndex]
	if nil ~= data then
		self.tbSectionList = data.tbSectionList
		self._mapNode.sectionLsv:Init(#self.tbSectionList, self, self.OnRefreshSectionGrid, self.OnSectionGridClick, not self.bResetLsvPos)
		local mapChapterCfg = ConfigTable.GetData("StorySetChapter", data.nId)
		if mapChapterCfg ~= nil then
			self:SetPngSprite(self._mapNode.imgChapterIcon, "Icon/MapEpisode/" .. mapChapterCfg.Image)
			self:SetPngSprite(self._mapNode.imgBgChapter, "Icon/MapEpisode/" .. mapChapterCfg.Bg)
			NovaAPI.SetTMPText(self._mapNode.txtTitle, ConfigTable.GetUIText("StorySet_Title") .. mapChapterCfg.Title)
			NovaAPI.SetTMPText(self._mapNode.txtChapter, mapChapterCfg.Name)
		end
	end
	self.bResetLsvPos = false
end
function StorySetCtrl:OnRefreshSectionGrid(goGrid, gridIndex)
	local nIndex = gridIndex + 1
	local data = self.tbSectionList[nIndex]
	local nInstanceId = goGrid:GetInstanceID()
	if not self.tbSectionGrid[nInstanceId] then
		self.tbSectionGrid[nInstanceId] = self:BindCtrlByNode(goGrid, "Game.UI.StorySet.StorySetSectionItemCtrl")
	end
	self.tbSectionGrid[nInstanceId]:RefreshItem(data)
end
function StorySetCtrl:OnSectionGridClick(goGrid, gridIndex)
	local nIndex = gridIndex + 1
	local data = self.tbSectionList[nIndex]
	if data.nStatus == AllEnum.StorySetStatus.Lock then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("StorySet_Section_Lock_Tip"))
		return
	end
	local mapCfg = ConfigTable.GetData("StorySetSection", data.nId)
	if mapCfg ~= nil then
		local avgEndCallback = function()
			EventManager.Hit(EventId.ClosePanel, PanelId.PureAvgStory)
			self.bGetReward = false
			self.bTransitionEnd = false
			if data.nStatus == AllEnum.StorySetStatus.UnLock then
				PlayerData.StorySet:ReceiveStorySetReward(mapCfg.ChapterId, data.nId, function(netMsg)
					self.bGetReward = true
					self.tbReward = netMsg
				end)
			end
		end
		local mapData = {
			nType = AllEnum.StoryAvgType.Plot,
			sAvgId = mapCfg.AVGId,
			nNodeId = nil,
			callback = avgEndCallback
		}
		EventManager.Hit(EventId.OpenPanel, PanelId.PureAvgStory, mapData)
	end
end
function StorySetCtrl:ShowGetReward()
	if self.bGetReward and self.tbReward ~= nil and self.bTransitionEnd then
		UTILS.OpenReceiveByChangeInfo(self.tbReward, function()
			self.tbChapter = PlayerData.StorySet:GetAllChapterList()
			if self.nPanelType == panelType_Section then
				self:RefreshSection()
			end
		end)
		self.bGetReward = false
		self.tbReward = nil
		self.bTransitionEnd = false
	end
end
function StorySetCtrl:Awake()
	self.nSelectIndex = 0
	self.nPanelType = panelType_chapter
	self.bResetLsvPos = true
	local tbParam = self:GetPanelParam()
	if type(tbParam) == "table" then
		self.bLocation = tbParam[1]
	end
end
function StorySetCtrl:OnEnable()
	self.tbChapterGrid = {}
	self.tbSectionGrid = {}
	self.tbChapter = PlayerData.StorySet:GetAllChapterList()
	self.animRoot = self.gameObject:GetComponent("Animator")
	self:Refresh()
	self.animRoot:Play("StorySetPanel_in", 0, 0)
end
function StorySetCtrl:OnDisable()
	for _, v in pairs(self.tbChapterGrid) do
		self:UnbindCtrlByNode(v)
	end
	self.tbChapterGrid = {}
	for _, v in pairs(self.tbSectionGrid) do
		self:UnbindCtrlByNode(v)
	end
	self.tbSectionGrid = {}
end
function StorySetCtrl:OnDestroy()
end
function StorySetCtrl:OnRelease()
end
function StorySetCtrl:OnEvent_Back(nPanelId)
	if self._panel._nPanelId ~= nPanelId then
		return
	end
	if self.nPanelType == panelType_Section then
		self.bResetLsvPos = true
		self.nPanelType = panelType_chapter
		self:Refresh()
	else
		EventManager.Hit(EventId.CloesCurPanel)
	end
end
function StorySetCtrl:OnEvent_BackHome(nPanelId)
	if self._panel._nPanelId ~= nPanelId then
		return
	end
	PanelManager.Home()
end
function StorySetCtrl:OnEvent_TransAnimOutClear()
	self.bTransitionEnd = true
	self:ShowGetReward()
end
function StorySetCtrl:OnEvent_ReceiveStorySetRewardSuc()
	self:ShowGetReward()
end
function StorySetCtrl:OnEvent_StorySetChapterRefresh()
	if self.bSendMsg then
		return
	end
	self.bSendMsg = true
	local serverCallback = function()
		self.tbChapter = PlayerData.StorySet:GetAllChapterList()
		self.bSendMsg = false
		if self.nPanelType == panelType_chapter then
			self:RefreshChapter()
		end
	end
	PlayerData.StorySet:SendGetStorySetData(serverCallback)
end
return StorySetCtrl
