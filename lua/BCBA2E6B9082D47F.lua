local TrekkerVersusCtrl = class("TrekkerVersusCtrl", BaseCtrl)
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local LocalSettingData = require("GameCore.Data.LocalSettingData")
local ClientManager = CS.ClientManager.Instance
local BubbleVoiceManager = require("Game.Actor2D.BubbleVoiceManager")
TrekkerVersusCtrl._mapNodeConfig = {
	TopBarPanel = {
		sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"
	},
	TMPTitleChallenge = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_ChallengeTitle"
	},
	TMPStartChallenge = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_ChallengeBtn"
	},
	TMPRecordTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_RecordTitle"
	},
	TMPEmptyTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_RecordEmptyTitle"
	},
	TMPEmptySubTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_RecordEmptySubTitle"
	},
	imgBgLevelSelect = {
		sNodeName = "----Actor2D----",
		sComponentName = "RawImage"
	},
	trActor2D_PNG = {
		sNodeName = "----Actor2D_PNG----",
		sComponentName = "Transform"
	},
	TMPNpcName = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_NPC2"
	},
	TMPSubTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_NPC1"
	},
	TMPSubName = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_NPC3"
	},
	TMPNpcTime = {sComponentName = "TMP_Text"},
	TMPNpcDate = {sComponentName = "TMP_Text"},
	TMPActivityTime = {sComponentName = "TMP_Text"},
	goBubbleRoot = {
		sNodeName = "----fixed_bubble----"
	},
	btnNpc = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Npc"
	},
	btnChallenge = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Challenge"
	},
	btnFinishMask = {},
	TMPFinish = {
		sComponentName = "TMP_Text",
		sLanguageId = "Activity_End"
	},
	imgTimeBg = {
		sNodeName = "imgTimeBgActivity"
	},
	rtRecordEmptyContent = {},
	rtRecordContent = {},
	svRecordAffix = {
		sComponentName = "LoopScrollView"
	},
	TMPRecord = {sComponentName = "TMP_Text"},
	btnRankReward = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Quest"
	},
	txtBtnRankReward = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_QusetTitle"
	},
	btnRankRewardChallenge = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Quest"
	},
	txtBtnRankRewardChallenge = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_QusetTitle"
	},
	tcChar = {nCount = 3},
	imgItemIcon = {sComponentName = "Image", nCount = 3},
	imgItemRare = {sComponentName = "Image", nCount = 3},
	txtRank = {sComponentName = "TMP_Text", nCount = 3},
	txtLv = {sComponentName = "TMP_Text", nCount = 3},
	TMPBuildRankTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "Template_Score"
	},
	imgStreamerInfo = {},
	goDuelResultBlur = {},
	txtPityLose = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_PityLose"
	},
	goStreamerFavourUp = {},
	imgTabOn = {nCount = 2},
	imgTabOff = {nCount = 2},
	txtTabOn1 = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_HeatDuel"
	},
	txtTabOff1 = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_HeatDuel"
	},
	txtTabOn2 = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_FanGift"
	},
	txtTabOff2 = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_FanGift"
	},
	btnStreamerInfoTab = {
		nCount = 2,
		sComponentName = "UIButton",
		callback = "OnBtnClick_StreamerInfoTab"
	},
	imgHeadStreamerOne = {sComponentName = "Image"},
	imgHeadStreamerTwo = {sComponentName = "Image"},
	txtNameStreamerOne = {sComponentName = "TMP_Text"},
	txtNameStreamerTwo = {sComponentName = "TMP_Text"},
	txtHeatStreamerOne = {sComponentName = "TMP_Text"},
	txtHeatStreamerTwo = {sComponentName = "TMP_Text"},
	txtCurDuelLeftTime = {sComponentName = "TMP_Text"},
	txtDuelRewardTip = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_DuelRewardTip"
	},
	btnDuelRewardTip = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_DuelRewardTip"
	},
	goHeatDuelOnGoing = {},
	goHeatDuelEnd = {},
	imgHeadStreamer = {nCount = 3, sComponentName = "Image"},
	txtNameStreamer = {nCount = 3, sComponentName = "TMP_Text"},
	txtHeatStreamer = {nCount = 3, sComponentName = "TMP_Text"},
	txtHeatDuelEndTip = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_HeatDuelEndTip"
	},
	txtNameFanBanner = {sComponentName = "TMP_Text"},
	goFanBannerHonorTitle = {
		sCtrlName = "Game.UI.FriendEx.HonorTitleCtrl"
	},
	txtContributeTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_ContributeTitle"
	},
	txtFillerNum = {sComponentName = "TMP_Text"},
	btnRewardDetail = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_RewardDetail"
	},
	txtRewardDetail = {
		sComponentName = "TMP_Text",
		sLanguageId = "STRanking_Reward_Btn"
	},
	btnSendGift = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_SendGift"
	},
	txtSendGift = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_SendGift"
	},
	imgBarFiller = {sComponentName = "Image"},
	goMat = {
		nCount = 3,
		sCtrlName = "Game.UI.TemplateEx.TemplateItemCtrl"
	},
	btnAdd = {
		nCount = 3,
		sComponentName = "UIButton",
		callback = "OnBtnClick_Add"
	},
	btnReduce = {
		nCount = 3,
		sComponentName = "UIButton",
		callback = "OnBtnClick_Reduce"
	},
	btnAutoFill = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_AutoFill"
	},
	txtAutoFill = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_AutoFill"
	},
	goHasDuelRecord = {},
	goNoDuelRecord = {},
	txtNoRecordTipBig = {
		sComponentName = "TMP_Text",
		sLanguageId = "STRanking_PlayerInfo_Empty"
	},
	txtNoRecordTipSmall = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_NoRecordTipSmall"
	},
	txtHighestRecord = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_RecordTitle"
	},
	txtHighestRecordNum = {sComponentName = "TMP_Text"},
	txtTimeAccumulated = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_TimeAccumulated"
	},
	txtTimeAccumulatedNum = {sComponentName = "TMP_Text"},
	goHasTimeReward = {},
	btnReceiveTimeReward = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_ReceiveTimeReward"
	},
	goNoTimeReward = {},
	txtNoTimeReward = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_NoTimeReward"
	},
	goIdleRewardOnGoing = {},
	goIdleRewardEnd = {},
	txtIdleRewardEnd = {
		sComponentName = "TMP_Text",
		sLanguageId = "Activity_End"
	},
	btnTimeReward = {
		nCount = 3,
		sComponentName = "UIButton",
		callback = "OnBtnClick_TimeReward"
	},
	txtReceiveTimeReward = {
		sComponentName = "TMP_Text",
		sLanguageId = "Achievement_Btn_Receive"
	},
	goTimeReward = {
		sCount = 3,
		sCtrlName = "Game.UI.TemplateEx.TemplateItemCtrl"
	},
	btnGoToGift = {
		nCount = 2,
		sComponentName = "UIButton",
		callback = "OnBtnClick_GoToGift"
	},
	txtBtnGoToGift = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_GoToGift"
	},
	imgRankIcon = {sComponentName = "Image"},
	txtLeader = {
		sComponentName = "TMP_Text",
		sLanguageId = "Build_Leader"
	},
	txtSub1 = {sComponentName = "TMP_Text", sLanguageId = "Build_Sub"},
	txtSub2 = {sComponentName = "TMP_Text", sLanguageId = "Build_Sub"},
	rt_ChallengeInfo = {
		sCtrlName = "Game.UI.TrekkerVersus_600002.TravelerDuelChallengeInfoCtrl"
	},
	rt_TravelerDuelSelect = {},
	animRoot = {
		sNodeName = "----SafeAreaRoot----",
		sComponentName = "Animator"
	},
	goEnemyInfo = {
		sCtrlName = "Game.UI.MainlineEx.MainlineMonsterInfoCtrl"
	},
	goQuset = {
		sCtrlName = "Game.UI.TrekkerVersus_600002.TrekkerVersusQuestCtrl"
	},
	txtHeatIndicatorNum = {sComponentName = "TMP_Text"},
	txtHeatIndicatorTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_HeatIndicatorTitle"
	},
	txtHeatIndicatorUp = {sComponentName = "TMP_Text"},
	btnHeatReward = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_HeatReward"
	},
	txtBtnHeatReward = {
		sComponentName = "TMP_Text",
		sLanguageId = "TravelerDuel_HeatReward"
	},
	goRewardPanel = {
		sCtrlName = "Game.UI.TrekkerVersus_600002.TrekkerVersusQuestCtrl"
	},
	goRedDotRankReward = {},
	goRedDotRankRewardChallenge = {}
}
TrekkerVersusCtrl._mapEventConfig = {
	TrekkerVersusTimeRefresh = "OnEvent_TrekkerVersusTimeRefresh",
	TrekkerVersusNPCTitleRefresh = "OnEvent_NPCTitleRefresh",
	[EventId.UIHomeConfirm] = "OnEvent_Home",
	[EventId.UIBackConfirm] = "OnEvent_Back",
	[EventId.ShowBubbleVoiceText] = "OnEvent_ShowBubbleVoiceText",
	TrekkerVersusAffixJump = "OnEvent_TrekkerVersusAffixJump",
	TrekkerVersusSelectAffix = "OnEvent_TrekkerVersusSelectAffix"
}
TrekkerVersusCtrl._mapRedDotConfig = {
	[RedDotDefine.TrekkerVersusQuest] = {
		sNodeName = "goRedDotRankRewardChallenge"
	},
	[RedDotDefine.TrekkerVersusQuest_1] = {
		sNodeName = "goRedDotRankReward"
	}
}
function TrekkerVersusCtrl:Awake()
	self.npcTimer = nil
	self.battleRefreshTimer = nil
	self.tbRecordAffixGrid = {}
	local tbParam = self:GetPanelParam()
	self.tbAllAffix = {}
	local tbAffixCfgData = ConfigTable.GetData("TravelerDuelChallengeControl", tbParam[1])
	if tbAffixCfgData == nil then
		printError("Activity Data Missing\239\188\154" .. tbParam[1])
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
		return a < b
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
end
function TrekkerVersusCtrl:FadeIn()
end
function TrekkerVersusCtrl:FadeOut()
end
function TrekkerVersusCtrl:OnEnable()
	self.animTimer = nil
	EventManager.Hit(EventId.SetTransition)
	self._mapNode.goQuset.gameObject:SetActive(false)
	local tbParam = self:GetPanelParam()
	self.mapAffixGrid = {}
	self._nActId = tbParam[1]
	self._ActData = PlayerData.Activity:GetActivityDataById(self._nActId)
	if self._ActData == nil then
		printError("\230\180\187\229\138\168\230\149\176\230\141\174\228\184\141\229\173\152\229\156\168\239\188\154" .. self._nActId)
	end
	self.mapActivityData = self._ActData:GetActivityData()
	local mapActivityData = ConfigTable.GetData("TravelerDuelChallengeControl", self._nActId)
	self.bOpen = false
	if mapActivityData ~= nil then
		self.bOpen = self:IsOpenBattle(mapActivityData.OpenTime, mapActivityData.EndTime)
	end
	self:RefreshOpenBattle()
	local curTime = ClientManager.serverTimeStamp
	local month = os.date("%m", curTime)
	local day = os.date("%d", curTime)
	local hour = os.date("%H", curTime)
	local min = os.date("%M", curTime)
	NovaAPI.SetTMPText(self._mapNode.TMPNpcDate, string.format("%s/%s", month, day))
	NovaAPI.SetTMPText(self._mapNode.TMPNpcTime, string.format("%s:%s", hour, min))
	if nil == self.npcTimer then
		self.npcTimer = self:AddTimer(0, 60, function()
			EventManager.Hit("TrekkerVersusNPCTitleRefresh")
		end, true, true, true)
	end
	local bUseL2D = LocalSettingData.mapData.UseLive2D
	self._mapNode.imgBgLevelSelect.transform.localScale = bUseL2D == true and Vector3.one or Vector3.zero
	self._mapNode.trActor2D_PNG.localScale = bUseL2D == true and Vector3.zero or Vector3.one
	if bUseL2D == true then
		Actor2DManager.SetBoardNPC2D(self:GetPanelId(), self._mapNode.imgBgLevelSelect, 917202)
	else
		Actor2DManager.SetBoardNPC2D_PNG(self._mapNode.trActor2D_PNG, self:GetPanelId(), 917202)
	end
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		self:RefreshRecord()
		if self._panel.curState == nil then
			self._panel.curState = 1
		end
		if self._panel.curState == 1 then
			self._mapNode.animRoot:Play("TrekkerVersuslLevelSelect_in")
		else
			self:OnBtnClick_Challenge(nil)
		end
		self:NpcVoice()
		PlayerData.Voice:StartBoardFreeTimer(917202)
	end
	cs_coroutine.start(wait)
end
function TrekkerVersusCtrl:OnDisable()
	if nil ~= self.npcTimer then
		self.npcTimer:Cancel()
		self.npcTimer = nil
	end
	if nil ~= self.battleRefreshTimer then
		self.battleRefreshTimer:Cancel()
		self.battleRefreshTimer = nil
	end
	self:RemoveAllGrids()
	Actor2DManager.UnsetBoardNPC2D()
	PlayerData.Voice:StopCharVoice()
	PlayerData.Voice:ClearTimer()
	BubbleVoiceManager.StopBubbleAnim()
end
function TrekkerVersusCtrl:OnDestroy()
end
function TrekkerVersusCtrl:OnRelease()
end
function TrekkerVersusCtrl:IsOpenBattle(sStartTime, sEndTime)
	if string.len(sStartTime) == 0 or string.len(sEndTime) == 0 then
		return true
	end
	local nowTime = CS.ClientManager.Instance.serverTimeStamp
	return nowTime > String2Time(sStartTime) and nowTime < String2Time(sEndTime)
end
function TrekkerVersusCtrl:RefreshOpenBattle()
	self:OnEvent_TrekkerVersusTimeRefresh()
	local mapActivityData = ConfigTable.GetData("TravelerDuelChallengeControl", self._nActId)
	local bOpen = false
	if mapActivityData ~= nil then
		bOpen = self:IsOpenBattle(mapActivityData.OpenTime, mapActivityData.EndTime)
	end
	if bOpen then
		local RefreshCallback = function()
			EventManager.Hit("TrekkerVersusTimeRefresh")
		end
		if nil ~= self.battleRefreshTimer then
			self.battleRefreshTimer:Cancel()
			self.battleRefreshTimer = nil
		end
		self.battleRefreshTimer = self:AddTimer(0, 60, RefreshCallback, true, true, true)
	end
end
function TrekkerVersusCtrl:RefreshRecord()
	local nRecord = self.mapActivityData.nRecord
	local tbRecordAffix = self.mapActivityData.tbRecordAffix
	local tbRecordChar = self.mapActivityData.tbRecordChar
	local nRecordBuildLevel = self.mapActivityData.nRecordBuildLevel
	if #tbRecordChar == 0 then
		self._mapNode.rtRecordEmptyContent:SetActive(true)
		self._mapNode.rtRecordContent:SetActive(false)
		return
	end
	self._mapNode.rtRecordEmptyContent:SetActive(false)
	self._mapNode.rtRecordContent:SetActive(true)
	for i = 1, 3 do
		if tbRecordChar[i] ~= nil then
			self._mapNode.tcChar[i].gameObject:SetActive(true)
			local mapChar = ConfigTable.GetData_Character(tbRecordChar[i])
			local mapCharData = PlayerData.Char:GetCharDataByTid(tbRecordChar[i])
			NovaAPI.SetTMPText(self._mapNode.txtRank[i], mapCharData.nLevel)
			local nCharSkinId = mapCharData.nSkinId
			local mapCharSkin = ConfigTable.GetData_CharacterSkin(nCharSkinId)
			self:SetPngSprite(self._mapNode.imgItemIcon[i], mapCharSkin.Icon, AllEnum.CharHeadIconSurfix.XXL)
			local nRarity = mapChar.Grade
			local sFrame = AllEnum.FrameType_New.BoardFrame .. AllEnum.BoardFrameColor[nRarity == GameEnum.characterGrade.R and GameEnum.characterGrade.SR or nRarity]
			self:SetAtlasSprite(self._mapNode.imgItemRare[i], "12_rare", sFrame, true)
		else
			self._mapNode.tcChar[i].gameObject:SetActive(false)
		end
	end
	NovaAPI.SetTMPText(self._mapNode.TMPRecord, nRecord)
	local rank = PlayerData.Build:CalBuildRank(nRecordBuildLevel)
	local sScore = "Icon/BuildRank/BuildRank_" .. rank.Id
	self:SetPngSprite(self._mapNode.imgRankIcon, sScore)
	if 0 < #tbRecordAffix then
		self._mapNode.svRecordAffix.gameObject:SetActive(true)
		self._mapNode.svRecordAffix:Init(#tbRecordAffix, self, self.OnRecordAffixGridRefresh)
	else
		self._mapNode.svRecordAffix.gameObject:SetActive(false)
	end
end
function TrekkerVersusCtrl:OnRecordAffixGridRefresh(goGrid, gridIndex)
	if self.mapAffixGrid[goGrid] == nil then
		self.mapAffixGrid[goGrid] = self:BindCtrlByNode(goGrid, "Game.UI.TrekkerVersus.TravelerDuelChallengeAffixGrid")
	end
	local nIdx = gridIndex + 1
	local nAffixId = self.mapActivityData.tbRecordAffix[nIdx]
	local bLine = false
	self.mapAffixGrid[goGrid]:Refresh(nAffixId, false, false, bLine, self._ActData)
end
function TrekkerVersusCtrl:RemoveAllGrids()
	if self.mapAffixGrid ~= nil then
		for go, mapCtrl in ipairs(self.mapAffixGrid) do
			self:UnbindCtrlByNode(mapCtrl)
		end
	end
	self.mapAffixGrid = {}
end
function TrekkerVersusCtrl:RefreshTimeout(remainTime)
	local sTimeStr = ""
	if remainTime <= 3600 then
		sTimeStr = orderedFormat(ConfigTable.GetUIText("Activity_Remain_Time_LessThenHour"))
	elseif 3600 < remainTime and remainTime <= 86400 then
		local hour = math.floor(remainTime / 3600)
		local min = math.floor((remainTime - hour * 3600) / 60)
		if min == 0 then
			hour = hour - 1
			min = 60
		end
		sTimeStr = orderedFormat(ConfigTable.GetUIText("Activity_Remain_Time_Hour") or "", hour, min)
	elseif 86400 < remainTime then
		local day = math.floor(remainTime / 86400)
		local hour = math.floor((remainTime - day * 86400) / 3600)
		if hour == 0 then
			day = day - 1
			hour = 24
		end
		sTimeStr = orderedFormat(ConfigTable.GetUIText("Activity_Remain_Time_Day") or "", day, hour)
	end
	return sTimeStr
end
function TrekkerVersusCtrl:RefreshStreamerInfo()
	local mapDuelData = self._ActData:GetCurStreamerDuelData()
	if mapDuelData == nil then
		self._mapNode.imgStreamerInfo:SetActive(false)
		return
	end
	self._mapNode.imgStreamerInfo:SetActive(true)
	self._mapNode.goHeatDuelOnGoing:SetActive(self.bOpen)
	self._mapNode.goHeatDuelEnd:SetActive(not self.bOpen)
	if self.bOpen == false then
		return
	end
	local mapHeatData = self._ActData:GetCurHeatValue()
	NovaAPI.SetTMPText(self._mapNode.txtNameStreamerOne, ConfigTable.GetUIText("TravelerDuel_StreamerName") or "")
	self:SetPngSprite(self._mapNode.imgStreamerOne, mapDuelData.StreamerIcon)
	NovaAPI.SetTMPText(self._mapNode.txtHeatStreamerOne, mapHeatData.nSelfHotValue or 0)
	NovaAPI.SetTMPText(self._mapNode.txtNameStreamerTwo, mapDuelData.Name or "")
	self:SetPngSprite(self._mapNode.imgStreamerTwo, mapDuelData.Icon)
	NovaAPI.SetTMPText(self._mapNode.txtHeatStreamerTwo, mapHeatData.nRivalHotValue or 0)
	local nCurTime = ClientManager.serverTimeStamp
	local nNextRefreshTime = CS.ClientManager.Instance:GetNextRefreshTime(nCurTime)
	local sRemainTime = self:RefreshTimeout(nNextRefreshTime)
	local sText = ConfigTable.GetUIText("Depot_LeftTime") or "" .. sRemainTime
	NovaAPI.SetTMPText(self._mapNode.txtCurDuelLeftTime, sText)
end
function TrekkerVersusCtrl:RefreshFanGift()
	NovaAPI.SetTMPText(self._mapNode.txtNameFanBanner, ConfigTable.GetUIText("TravelerDuel_StreamerName") or "")
	local nHonorTitleId = 10078
	local nFanLevel = self._ActData:GetCurFanData().nFanLevel or 0
	self._mapNode.goFanBannerHonorTitle:SetHonotTitle(nHonorTitleId, false, nFanLevel)
	local nNextLevelExp = 0
	local foreachLevelTable = function(mapData)
		if mapData ~= nil and mapData.Level == nFanLevel then
			nNextLevelExp = mapData.NeedExp or 0
		end
	end
	ForEachTableLine(DataTable.TravelerDuelFansLevel, foreachLevelTable)
	local nFanExp = self._ActData:GetCurFanData().nFanExp or 0
	local nFillWidth = nFanExp / nNextLevelExp * self._mapNode.imgBarFiller.rect.width
	if nFillWidth < 30 then
		nFillWidth = 30
	end
	self._mapNode.imgBarFiller.rectTransform.sizeDelta = Vector2.New(nFillWidth, self._mapNode.imgBarFiller.rectTransform.sizeDelta.y)
	for i = 1, 3 do
		local nFanGiftItemId = self.tbFanGiftItem[i].nId
		self._mapNode.goMat[i]:RerfeshGrid({nId = nFanGiftItemId})
	end
end
function TrekkerVersusCtrl:RefreshMat(bInit)
	if bInit then
		for i = 1, 3 do
			local nFanGiftItemId = self.tbFanGiftItem[i].nId
			self._mapNode.goMat[i]:RerfeshGrid({nId = nFanGiftItemId})
		end
	else
		for i = 1, 3 do
			self._mapNode.goMat[i]:SetGridCount(self.tbFanGiftItem[i].nCount or 0)
		end
	end
end
function TrekkerVersusCtrl:RefreshIdleReward()
	self._mapNode.goIdleRewardEnd:SetActive(not self.bOpen)
	self._mapNode.goIdleRewardOnGoing:SetActive(self.bOpen)
	local nCurRecord = self._ActData.nRecord or 0
	self._mapNode.goHasDuelRecord:SetActive(0 < nCurRecord)
	self._mapNode.goNoDuelRecord:SetActive(nCurRecord <= 0)
	if nCurRecord <= 0 then
		return
	end
	NovaAPI.SetTMPText(self._mapNode.txtHighestRecordNum, nCurRecord)
	local nTimeIdleReward = self._ActData.nIdleRewardStartTime or 0
	self.nElapsedTime = CS.ClientManager.Instance.serverTimeStamp - nTimeIdleReward
	local sTimeStr = self:RefreshTimeout(self.nElapsedTime)
	NovaAPI.SetTMPText(self._mapNode.txtTimeAccumulatedNum, sTimeStr)
	if self.timerIdleReward ~= nil then
		self.timerIdleReward:Cancel()
		self.timerIdleReward = nil
	end
	self.timerIdleReward = self:AddTimer(0, 1, function()
		self.nElapsedTime = self.nElapsedTime + 1
		local sStr = self:RefreshTimeout(self.nElapsedTime)
		NovaAPI.SetTMPText(self._mapNode.txtTimeAccumulatedNum, sStr)
	end, true, true, true)
	self.tbIdleReward = self._ActData:GetIdleReward()
	if self.tbIdleReward == nil or #self.tbIdleReward == 0 then
		self._mapNode.goNoTimeReward:SetActive(true)
		return
	end
	self._mapNode.goNoTimeReward:SetActive(false)
	for i = 1, 3 do
		local mapItemData = self.tbIdleReward[i]
		if mapItemData ~= nil then
			self._mapNode.btnTimeReward[i]:SetActive(true)
			self._mapNode.goTimeReward[i]:SetItem(mapItemData.Tid, nil, mapItemData.Qty or 0)
		else
			self._mapNode.btnTimeReward[i]:SetActive(false)
		end
	end
end
function TrekkerVersusCtrl:OnEvent_TrekkerVersusTimeRefresh()
	local mapActivityData = ConfigTable.GetData("TravelerDuelChallengeControl", self._nActId)
	local bOpen = false
	if mapActivityData ~= nil then
		bOpen = self:IsOpenBattle(mapActivityData.OpenTime, mapActivityData.EndTime)
	end
	if bOpen then
		self._mapNode.imgTimeBg:SetActive(true)
		local nEndTime = ClientManager:ISO8601StrToTimeStamp(mapActivityData.EndTime)
		local curTime = CS.ClientManager.Instance.serverTimeStamp
		local remainTime = nEndTime - curTime
		NovaAPI.SetTMPText(self._mapNode.TMPActivityTime, self:RefreshTimeout(remainTime))
		self._mapNode.btnFinishMask:SetActive(false)
		self._mapNode.btnChallenge.interactable = true
	else
		self._mapNode.imgTimeBg:SetActive(false)
		self._mapNode.btnFinishMask:SetActive(true)
		self._mapNode.btnChallenge.interactable = false
		if self._panel.curState ~= 1 then
			self:OnEvent_Back(self._panel._nPanelId)
		end
	end
end
function TrekkerVersusCtrl:OnEvent_NPCTitleRefresh()
	local curTime = ClientManager.serverTimeStamp
	local month = os.date("%m", curTime)
	local day = os.date("%d", curTime)
	local hour = os.date("%H", curTime)
	local min = os.date("%M", curTime)
	NovaAPI.SetTMPText(self._mapNode.TMPNpcDate, string.format("%s/%s", month, day))
	NovaAPI.SetTMPText(self._mapNode.TMPNpcTime, string.format("%s:%s", hour, min))
end
function TrekkerVersusCtrl:OnEvent_Back(nPanelId)
	if self._panel._nPanelId ~= nPanelId then
		return
	end
	if self.bJumpto then
		EventManager.Hit(EventId.CloesCurPanel)
		return
	end
	if self._panel.curState == 1 then
		EventManager.Hit(EventId.CloesCurPanel)
	else
		if self.animTimer ~= nil then
			self.animTimer:Cancel()
			self.animTimer = nil
		end
		self._mapNode.rt_ChallengeInfo:CacheAffixes()
		self._mapNode.animRoot:Play("ChallengeInfo_out")
		local wait = function()
			self._mapNode.rt_ChallengeInfo.gameObject:SetActive(false)
		end
		self._mapNode.rt_TravelerDuelSelect:SetActive(true)
		self._panel.curState = 1
		self.animTimer = self:AddTimer(1, 0.6, wait, true, true, true)
	end
end
function TrekkerVersusCtrl:OnEvent_Home(nPanelId)
	if self._panel._nPanelId ~= nPanelId then
		return
	end
	if self._panel.curState ~= 1 then
		self._mapNode.rt_ChallengeInfo:CacheAffixes()
	end
	PanelManager.Home()
end
function TrekkerVersusCtrl:OnEvent_ShowBubbleVoiceText(nCharId, nId)
	local mapVoDirectoryData = ConfigTable.GetData("VoDirectory", nId)
	if mapVoDirectoryData == nil then
		printError("VoDirectory\230\156\170\230\137\190\229\136\176\230\149\176\230\141\174id:" .. nId)
		return
	end
	if nil ~= mapVoDirectoryData then
		BubbleVoiceManager.PlayFixedBubbleAnim(self._mapNode.goBubbleRoot, mapVoDirectoryData.voResource)
	end
end
function TrekkerVersusCtrl:OnEvent_TrekkerVersusAffixJump(tbJumpAffixes)
	local waitQuestAnim = function()
		local mapActivityData = ConfigTable.GetData("TravelerDuelChallengeControl", self._nActId)
		local bOpen = false
		if mapActivityData ~= nil then
			bOpen = self:IsOpenBattle(mapActivityData.OpenTime, mapActivityData.EndTime)
		end
		if not bOpen then
			EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Activity_End"))
			return
		end
		if self._panel.curState ~= 2 then
			self:OnBtnClick_Challenge()
		end
		self._mapNode.rt_ChallengeInfo:AddJumptoAffixes(tbJumpAffixes)
	end
	self:AddTimer(1, 0.3, waitQuestAnim, true, true, true)
end
function TrekkerVersusCtrl:OnEvent_TrekkerVersusSelectAffix(nCurHard)
	local nHardIdx = math.ceil(nCurHard / 20)
	if 5 < nHardIdx then
		nHardIdx = 5
	end
	local sType = "TrekkerVersus_difficulty" .. tostring(nHardIdx)
	self:PlayNpcVoice(sType)
end
function TrekkerVersusCtrl:OnBtnClick_Challenge(btn)
	if self.animTimer ~= nil then
		self.animTimer:Cancel()
		self.animTimer = nil
	end
	local tbActCfgData = ConfigTable.GetData("TravelerDuelChallengeControl", self._nActId)
	if tbActCfgData ~= nil then
		self._mapNode.rt_ChallengeInfo:Refresh(tbActCfgData.BossLevelId, self.tbAllAffix, self._ActData)
	end
	self._mapNode.animRoot:Play("ChallengeInfo_in")
	local wait = function()
		self._mapNode.rt_TravelerDuelSelect:SetActive(false)
	end
	self._mapNode.rt_ChallengeInfo.gameObject:SetActive(true)
	self._panel.curState = 2
	self.animTimer = self:AddTimer(1, 0.9, wait, true, true, true)
end
function TrekkerVersusCtrl:OnBtnClick_Quest(btn)
	self._mapNode.goQuset:OpenPanel(self._ActData)
end
function TrekkerVersusCtrl:BlockNpc(nTime)
	self.bBlockNpc = true
	local unBlockJump = function()
		self.bBlockNpc = false
	end
	self:AddTimer(1, nTime, unBlockJump, true, true, nil, nil)
end
function TrekkerVersusCtrl:OnBtnClick_Npc()
	if self.bBlockNpc == true then
		return
	end
	PlayerData.Voice:PlayBoardNPCClickVoice(917202)
end
function TrekkerVersusCtrl:OnBtnClick_StreamerInfoTab(index, btn)
	if self.nStreamerInfoTabIndex == index then
		return
	end
	self.nStreamerInfoTabIndex = index
	self._mapNode.imgTabOn1:SetActive(index == 1)
	self._mapNode.imgTabOn2:SetActive(index == 2)
	self._mapNode.imgTabOff1:SetActive(index ~= 1)
	self._mapNode.imgTabOff2:SetActive(index ~= 2)
	self._mapNode.rt_HeatDuel:SetActive(index == 1)
	self._mapNode.rt_StreamerInfo:SetActive(index == 2)
end
function TrekkerVersusCtrl:OnBtnClick_GoToGift(index, btn)
	self:OnBtnClick_StreamerInfoTab(2, btn)
end
function TrekkerVersusCtrl:OnBtnClick_Add(btn, nIndex)
	local nHas = PlayerData.Item:GetItemCountByID(self.tbFanGiftItem[nIndex].nId)
	self.tbFanGiftItem[nIndex].nCount = math.min(self.tbFanGiftItem[nIndex].nCount or 1, nHas)
	self:RefreshMat()
end
function TrekkerVersusCtrl:OnBtnClick_Reduce(btn, nIndex)
	self.tbFanGiftItem[nIndex].nCount = math.max(self.tbFanGiftItem[nIndex].nCount or -1, 0)
	self:RefreshMat()
end
function TrekkerVersusCtrl:OnBtnClick_AutoFill(btn)
	for i = 1, 3 do
		local nHas = PlayerData.Item:GetItemCountByID(self.tbFanGiftItem[i].nId)
		self.tbFanGiftItem[i].nCount = nHas or 0
	end
	self:RefreshMat()
end
function TrekkerVersusCtrl:OnBtnClick_SendGift(btn)
	local tbSendData = {}
	for k, v in pairs(self.tbFanGiftItem) do
		table.insert(tbSendData, {
			Id = v.nId,
			Tid = v.nId,
			Qty = v.nCount
		})
	end
	local reqCallback = function(msgData, nPrevFanLevel, nPrevFanExp)
		self:RefreshMat(true)
		if nPrevFanLevel < self._ActData.nFanLevel then
			self._mapNode.goStreamerFavourUp:SetActive(true)
		end
	end
	self._ActData:RequestSendStreamerGift(tbSendData, reqCallback)
end
function TrekkerVersusCtrl:OnBtnClick_ReceiveTimeReward(btn)
	local cb = function(msgData)
		self:RefreshIdleReward()
	end
	self._ActData:RequestIdleRewardReceive(cb)
end
function TrekkerVersusCtrl:OnBtnClick_TimeReward(index, btn)
end
function TrekkerVersusCtrl:PlayNpcVoice(sType)
	local sVoiceRes = PlayerData.Voice:PlayCharVoice(sType, 917202, nil, true)
end
function TrekkerVersusCtrl:NpcVoice()
	local timeNow = CS.ClientManager.Instance.serverTimeStamp
	local nHour = tonumber(os.date("%H", timeNow))
	local sType = "greet_npc"
	local nLastResult, nLastHard = self._ActData:CheckBattleSuccess()
	if nLastResult == 1 then
		local nHardIdx = math.ceil(nLastHard / 20)
		if 5 < nHardIdx then
			nHardIdx = 5
		end
		sType = "TrekkerVersus_clear" .. tostring(nHardIdx)
	else
		local bFirstIn = self._ActData:GetFirstIn()
		if bFirstIn then
			sType = PlayerData.Voice:GetNPCGreetTimeVoiceKey()
		else
			local nIndex = math.random(1, 2)
			sType = nIndex == 1 and PlayerData.Voice:GetNPCGreetTimeVoiceKey() or "greet_npc"
		end
	end
	self:PlayNpcVoice(sType)
end
return TrekkerVersusCtrl
