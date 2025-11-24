local BaseCtrl = require("GameCore.UI.BaseCtrl")
local CharFavourGiftCtrl = class("CharFavourGiftCtrl", BaseCtrl)
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
CharFavourGiftCtrl._mapNodeConfig = {
	loopsvGiftList = {
		sNodeName = "svGiftList",
		sComponentName = "LoopScrollView"
	},
	goEmpty = {sNodeName = "Empty", sComponentName = "GameObject"},
	txtGiftCount = {
		sNodeName = "txtGiftCount",
		sComponentName = "TMP_Text"
	},
	rectPreProgress = {
		sNodeName = "imgPreProgress",
		sComponentName = "RectTransform"
	},
	rectProgress = {
		sNodeName = "imgProgress",
		sComponentName = "RectTransform"
	},
	goAffinityInfo = {
		sNodeName = "goAffinityinfo",
		sComponentName = "GameObject"
	},
	goAffinityChangeInfo = {
		sNodeName = "goAffinityChangeInfo",
		sComponentName = "GameObject"
	},
	txtDub = {sNodeName = "txtDub", sComponentName = "TMP_Text"},
	imgCharColor = {
		sNodeName = "imgCharColor",
		sComponentName = "Image"
	},
	imgRareName = {
		sNodeName = "imgRareName",
		sComponentName = "Image"
	},
	txtName = {sNodeName = "txtName", sComponentName = "TMP_Text"},
	safeAreaRoot = {
		sNodeName = "----SafeAreaRoot----",
		sComponentName = "GameObject"
	},
	TopBar = {
		sNodeName = "TopBarPanel",
		sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"
	},
	btnPresent = {
		sComponentName = "UIButton",
		callback = "OnBtn_ClickSendGift"
	},
	txtProgress = {
		sNodeName = "txtProgress",
		sComponentName = "TMP_Text"
	},
	goAffinityinfoBefore = {},
	goAffinityinfoAfter = {},
	goFavourBubble = {
		sNodeName = "imgFavourBubble",
		sComponentName = "GameObject"
	},
	txtFavourBubble = {
		sNodeName = "txtFavourBubble",
		sComponentName = "TMP_Text"
	},
	aniFavour = {
		sNodeName = "aniFavourRoot",
		sComponentName = "Animator"
	},
	t_common_04 = {}
}
CharFavourGiftCtrl._mapEventConfig = {
	[EventId.CharRelatePanelAdvance] = "OnEvent_PanelAdvance",
	[EventId.CharRelatePanelBack] = "OnEvent_PanelBack",
	[EventId.UIBackConfirm] = "OnEvent_Back",
	[EventId.UIHomeConfirm] = "OnEvent_Home",
	[EventId.AffinityChange] = "OnEvent_AffinityChange",
	[EventId.ShowBubbleVoiceText] = "OnEvent_ShowBubbleVoiceText",
	[EventId.IsNewDay] = "OnEvent_NewDay"
}
function CharFavourGiftCtrl:Awake()
	self.progressBarWidth = 552
	self.progressBarMinWidth = 23
	self.progressFixBarWidth = 159
	self.L2dAnimInterval = ConfigTable.GetConfigNumber("AffinityL2dPlayInterval")
	self.tbGridCtrl = {}
end
function CharFavourGiftCtrl:OnEnable()
	if self._panel.nPanelId ~= PanelId.CharFavourGift then
		self._mapNode.safeAreaRoot.gameObject:SetActive(false)
	else
		self._mapNode.safeAreaRoot.gameObject:SetActive(true)
	end
end
function CharFavourGiftCtrl:OnDisable()
	if self.tbGridCtrl then
		for k, v in pairs(self.tbGridCtrl) do
			self:UnbindCtrlByNode(v)
		end
	end
	self.tbGridCtrl = {}
end
function CharFavourGiftCtrl:Refresh()
	self.curChosenItem = nil
	self.curChosenItemGrid = nil
	self._mapNode.goAffinityInfo:SetActive(true)
	self._mapNode.goAffinityChangeInfo:SetActive(false)
	self._mapNode.rectPreProgress.gameObject:SetActive(false)
	self.curCharId = self._panel.nCharId
	local affinityData = PlayerData.Char:GetCharAffinityData(self.curCharId)
	self.curFavourLevel = affinityData.Level
	self.curFavourExp = affinityData.Exp
	self.configData = ConfigTable.GetData_Character(self.curCharId)
	local mapCharDescCfg = ConfigTable.GetData("CharacterDes", self.curCharId)
	local sCncv = ""
	local nCurLanguageIdx = GetLanguageIndex(Settings.sCurrentTxtLanguage)
	if mapCharDescCfg ~= nil then
		if nCurLanguageIdx == 1 then
			sCncv = mapCharDescCfg.CnCv
		elseif nCurLanguageIdx == 3 then
			sCncv = mapCharDescCfg.JpCv
		end
	end
	local mapCharDescCfg = ConfigTable.GetData("CharacterDes", self.curCharId)
	local sColor
	if mapCharDescCfg ~= nil then
		sColor = mapCharDescCfg.CharColor
	else
		sColor = ""
	end
	local _, colorChar = ColorUtility.TryParseHtmlString(sColor)
	NovaAPI.SetImageColor(self._mapNode.imgCharColor, colorChar)
	NovaAPI.SetTMPText(self._mapNode.txtName, self.configData.Name)
	self:SetSprite_FrameColor(self._mapNode.imgRareName, self.configData.Grade, AllEnum.FrameType_New.Text)
	NovaAPI.SetImageNativeSize(self._mapNode.imgRareName)
	NovaAPI.SetTMPText(self._mapNode.txtDub, sCncv)
	local templateId = ConfigTable.GetData("CharAffinityTemplate", self.curCharId).TemplateId
	self.MaxAffintiyLevel = PlayerData.Char:GetMaxAffinityLevel(templateId)
	local percent = 0
	local level = self.curFavourLevel >= self.MaxAffintiyLevel and self.MaxAffintiyLevel or self.curFavourLevel + 1
	local data = CacheTable.GetData("_AffinityLevel", templateId)[level]
	if self.curFavourLevel >= self.MaxAffintiyLevel then
		percent = 1
	else
		percent = self.curFavourExp / data.NeedExp
	end
	local sizeDelta = self._mapNode.rectProgress.sizeDelta
	sizeDelta.x = self.progressBarWidth * percent < self.progressBarMinWidth and self.progressBarMinWidth or self.progressBarWidth * percent
	self._mapNode.rectProgress.sizeDelta = sizeDelta
	NovaAPI.SetTMPText(self._mapNode.txtProgress, string.format("%d/%d", self.curFavourExp, data.NeedExp))
	self._mapNode.rectProgress.gameObject:SetActive(self.curFavourExp > 0)
	local totalCount = ConfigTable.GetConfigValue("AffinityGiftSendCount")
	local curCount = PlayerData.Base:GetSendGiftCount()
	NovaAPI.SetTMPText(self._mapNode.txtGiftCount, string.format("\228\187\138\230\151\165\232\181\160\231\164\188\230\172\161\230\149\176<color=#0abec5>%d</color>/%s", curCount, totalCount))
	self.PreferenceData = ConfigTable.GetData("CharacterDes", self.curCharId)
	self:RefreshAffinityInfo(self._mapNode.goAffinityInfo.transform, self.curFavourLevel)
	self._mapNode.aniFavour:SetInteger("affinity_lv", CacheTable.GetData("_AffinityLevel", templateId)[self.curFavourLevel].AffinityLevelStage)
	self:RefreshItemList()
end
function CharFavourGiftCtrl:RefreshAffinityInfo(goAffinity, nAffinityLevel)
	local templateId = ConfigTable.GetData("CharAffinityTemplate", self.curCharId).TemplateId
	local mapAffinity = CacheTable.GetData("_AffinityLevel", templateId)[nAffinityLevel]
	if mapAffinity == nil then
		return
	end
	local imgHeart = goAffinity:Find("imgHeart"):GetComponent("Image")
	local txtLevel = goAffinity:Find("txtLevel"):GetComponent("TMP_Text")
	local txtBubble = goAffinity:Find("txtBubble"):GetComponent("TMP_Text")
	self:SetPngSprite(imgHeart, mapAffinity.AffinityLevelIcon)
	NovaAPI.SetTMPText(txtLevel, nAffinityLevel .. ConfigTable.GetUIText("Advance_Level_Name"))
	NovaAPI.SetTMPText(txtBubble, mapAffinity.AffinityLevelName)
end
function CharFavourGiftCtrl:RefreshItemList()
	self.tbItemData = {}
	local listCount = 0
	local foreachAffinityGift = function(mapData)
		local count = PlayerData.Item:GetItemCountByID(mapData.Id)
		if 0 < count then
			listCount = listCount + 1
			local itemData = ConfigTable.GetData_Item(mapData.Id)
			table.insert(self.tbItemData, {
				nTid = itemData.Id,
				nRarity = itemData.Rarity,
				nCount = count,
				nExpire = itemData.ExpireType,
				favourLevel = self:GetGiftFavourLevel(itemData.Id)
			})
		end
	end
	ForEachTableLine(DataTable.AffinityGift, foreachAffinityGift)
	self._mapNode.goEmpty:SetActive(listCount == 0)
	self._mapNode.t_common_04:SetActive(0 < listCount)
	self._mapNode.loopsvGiftList.gameObject:SetActive(0 < listCount)
	if 0 < listCount then
		table.sort(self.tbItemData, function(a, b)
			if a.favourLevel == b.favourLevel then
				if a.nRarity == b.nRarity then
					return a.nTid < b.nTid
				end
				return a.nRarity < b.nRarity
			end
			return a.favourLevel < b.favourLevel
		end)
		self._mapNode.loopsvGiftList:Init(listCount, self, self.RefreshItemGrid, self.OnBtn_ClickItemGrid)
	end
end
function CharFavourGiftCtrl:RefreshItemGrid(grid)
	local nIndex = tonumber(grid.name) + 1
	local mapItem = self.tbItemData[nIndex]
	local nInstanceID = grid:GetInstanceID()
	if not self.tbGridCtrl[nInstanceID] then
		local itemObj = grid.transform:Find("btnGrid/AnimRoot/tc_item_02")
		self.tbGridCtrl[nInstanceID] = self:BindCtrlByNode(itemObj, "Game.UI.TemplateEx.TemplateItemCtrl")
	end
	self.tbGridCtrl[nInstanceID]:SetItem(mapItem.nTid, mapItem.nRarity, mapItem.nCount, mapItem.nExpire)
	local imgAffinityLevel = grid.transform:Find("btnGrid/AnimRoot/tc_item_02/imgAffinityGiftLevel"):GetComponent("Image")
	local level = mapItem.favourLevel
	self:SetAtlasSprite(imgAffinityLevel, "11_ico", "zs_present_heart_" .. level)
	if self.lastChosenItem ~= nil and self.lastChosenItem == mapItem.nTid then
		self:OnBtn_ClickItemGrid(grid)
		self.lastChosenItem = nil
	end
end
function CharFavourGiftCtrl:GetGiftFavourLevel(itemId)
	if self.PreferenceData == nil then
		return 2
	end
	local itemData = ConfigTable.GetData("AffinityGift", itemId)
	for k, v in ipairs(itemData.Tags) do
		for k1, v1 in ipairs(self.PreferenceData.PreferTags) do
			if v == v1 then
				return 1
			end
		end
	end
	for k, v in ipairs(itemData.Tags) do
		for k1, v1 in ipairs(self.PreferenceData.HateTags) do
			if v == v1 then
				return 3
			end
		end
	end
	return 2
end
function CharFavourGiftCtrl:GetGiftFeedbackLevel(itemId)
	local level = self:GetGiftFavourLevel(itemId)
	if 1 < level then
		return 3
	end
	local itemData = ConfigTable.GetData_Item(itemId)
	if itemData.Rarity == GameEnum.itemRarity.SSR then
		return 1
	else
		return 2
	end
end
function CharFavourGiftCtrl:OnItemChosen()
	local templateId = ConfigTable.GetData("CharAffinityTemplate", self.curCharId).TemplateId
	if self.curChosenItem == nil then
		self._mapNode.goAffinityChangeInfo:SetActive(false)
		self._mapNode.goAffinityInfo:SetActive(true)
		self._mapNode.rectPreProgress.gameObject:SetActive(false)
		self._mapNode.rectProgress.gameObject:SetActive(self.curFavourExp > 0)
		self:RefreshAffinityInfo(self._mapNode.goAffinityInfo.transform, self.curFavourLevel)
		local data = CacheTable.GetData("_AffinityLevel", templateId)[self.curFavourLevel + 1 > self.MaxAffintiyLevel and self.MaxAffintiyLevel or self.curFavourLevel + 1]
		NovaAPI.SetTMPText(self._mapNode.txtProgress, string.format("%d/%d", self.curFavourExp, data.NeedExp))
		self._mapNode.aniFavour:SetInteger("affinity_lv", CacheTable.GetData("_AffinityLevel", templateId)[self.curFavourLevel].AffinityLevelStage)
		return
	end
	local addedExp = 0
	local data = ConfigTable.GetData("AffinityGift", self.curChosenItem)
	local level = self:GetGiftFavourLevel(self.curChosenItem)
	local AffinityGiftPreferenceProp = ConfigTable.GetConfigNumberArray("AffinityGiftPreferenceProp")
	addedExp = data.BaseAffinity * (AffinityGiftPreferenceProp[level] / 100 + 1)
	local addedLevel = self.curFavourLevel
	if 0 < addedExp then
		local Exp = addedExp
		self:RefreshAffinityInfo(self._mapNode.goAffinityinfoBefore.transform, self.curFavourLevel)
		while 0 < Exp and not (addedLevel >= self.MaxAffintiyLevel) do
			local needExp = CacheTable.GetData("_AffinityLevel", templateId)[addedLevel + 1].NeedExp
			if addedLevel == self.curFavourLevel then
				needExp = needExp - self.curFavourExp
			end
			Exp = Exp - needExp
			if 0 < Exp then
				addedLevel = addedLevel + 1
				if addedLevel >= self.MaxAffintiyLevel then
					Exp = CacheTable.GetData("_AffinityLevel", templateId)[self.MaxAffintiyLevel].NeedExp
					break
				end
			else
				Exp = Exp + needExp
				break
			end
		end
		self:RefreshAffinityInfo(self._mapNode.goAffinityinfoAfter.transform, addedLevel)
		local sizeDelta = self._mapNode.rectPreProgress.sizeDelta
		local percent = 0
		if addedLevel > self.curFavourLevel then
			self._mapNode.rectProgress.gameObject:SetActive(false)
			percent = Exp / CacheTable.GetData("_AffinityLevel", templateId)[addedLevel + 1 > self.MaxAffintiyLevel and self.MaxAffintiyLevel or addedLevel + 1].NeedExp
		else
			self._mapNode.rectProgress.gameObject:SetActive(true)
			percent = (self.curFavourExp + addedExp) / CacheTable.GetData("_AffinityLevel", templateId)[addedLevel + 1 > self.MaxAffintiyLevel and self.MaxAffintiyLevel or addedLevel + 1].NeedExp
		end
		if 1 <= percent then
			percent = 1
		end
		sizeDelta.x = self.progressBarWidth * percent
		self._mapNode.rectPreProgress.sizeDelta = sizeDelta
		NovaAPI.SetTMPText(self._mapNode.txtProgress, string.format("%d/%d", self.curFavourExp + addedExp, CacheTable.GetData("_AffinityLevel", templateId)[addedLevel + 1 > self.MaxAffintiyLevel and self.MaxAffintiyLevel or addedLevel + 1].NeedExp))
	end
	self._mapNode.goAffinityInfo:SetActive(addedLevel == self.curFavourLevel)
	if addedLevel == self.curFavourLevel then
		self._mapNode.aniFavour:SetInteger("affinity_lv", CacheTable.GetData("_AffinityLevel", templateId)[self.curFavourLevel].AffinityLevelStage)
	end
	self._mapNode.rectPreProgress.gameObject:SetActive(0 < addedExp)
	self._mapNode.goAffinityChangeInfo:SetActive(addedLevel > self.curFavourLevel)
end
function CharFavourGiftCtrl:PlayCharAnim(level)
	if self.PreferenceData == nil or self.bPlayCharAnim then
		return
	end
	local bPlay = true
	if self.nLastFavourLevel ~= nil and self.nCurLevel ~= nil then
		bPlay = PlayerData.Voice:CheckPlayGiftVoice(self.nCurLevel, self.nLastFavourLevel)
	end
	if not bPlay then
		return
	end
	local mapData
	if level == 1 then
		mapData = "thankEx"
	elseif level == 2 then
		mapData = "thank"
	elseif level == 3 then
		mapData = "thankSmall"
	end
	if mapData == nil or #mapData == 0 then
		return
	end
	local nIndex = math.random(1, #mapData)
	local sVoKey = mapData[nIndex]
	if sVoKey ~= "" then
		self.charVoiceTimer = self:AddTimer(1, tonumber(self.L2dAnimInterval), "ResetPlayCharAnimState", true, true, true)
		local key = PlayerData.Voice:PlayCharVoice(sVoKey, self.curCharId)
		local data = ConfigTable.GetData("VoDirectory", key)
		if data ~= nil then
			EventManager.Hit("PlayCharL2DAnim", data.motion, false, true)
		end
		self.bPlayCharAnim = true
	end
end
function CharFavourGiftCtrl:ResetPlayCharAnimState()
	self.bPlayCharAnim = false
	self._mapNode.goFavourBubble:SetActive(false)
end
function CharFavourGiftCtrl:PlayProgressAnim(mapBefore, mapAfter, callback)
	local bMaxLv = mapAfter.nLevel == mapAfter.nMaxLevel
	local nAddLevel = mapAfter.nLevel - mapBefore.nLevel
	local nAddCount = 0
	if nAddLevel == 0 then
		nAddCount = 1
	elseif 0 < mapAfter.nExp then
		nAddCount = nAddLevel + 1
	else
		nAddCount = nAddLevel
	end
	local nAniTime = 0.2
	if nAddCount < 6 then
		nAniTime = 0.2
	elseif 6 <= nAddCount then
		nAniTime = 0.1
	end
	local nBeforeToMaxTime = nAniTime * (1 - mapBefore.nExp / mapBefore.nMaxExp)
	local nBeforeToAfterTime = nAniTime * ((mapAfter.nExp - mapBefore.nExp) / mapAfter.nMaxExp)
	local nZeroToAfterTime = nAniTime * mapAfter.nExp / mapAfter.nMaxExp
	local nAllTime = 0
	local heigth = self._mapNode.rectPreProgress.sizeDelta.y
	local sequence = DOTween.Sequence()
	for i = 1, nAddCount - 1 do
		local nTime = i == 1 and nBeforeToMaxTime or nAniTime
		nAllTime = nAllTime + nTime
		sequence:AppendCallback(function()
			WwiseAudioMgr:PlaySound("ui_common_levelUp")
		end)
		sequence:Append(self._mapNode.rectProgress:DOSizeDelta(Vector2(self.progressBarWidth, heigth), nTime))
		sequence:AppendCallback(function()
			self._mapNode.rectProgress.sizeDelta = Vector2(0, heigth)
		end)
	end
	if bMaxLv then
		local nTime = 1 < nAddCount and nAniTime or nBeforeToMaxTime
		nAllTime = nAllTime + nTime
		sequence:AppendCallback(function()
			WwiseAudioMgr:PlaySound("ui_common_levelUp")
		end)
		sequence:Append(self._mapNode.rectProgress:DOSizeDelta(Vector2(self.progressBarWidth, heigth), nTime))
	elseif mapAfter.nExp > 0 then
		local nTime = 1 < nAddCount and nZeroToAfterTime or nBeforeToAfterTime
		nAllTime = nAllTime + nTime
		sequence:AppendCallback(function()
			WwiseAudioMgr:PlaySound("ui_common_levelUp")
		end)
		local width = self.progressBarWidth * mapAfter.nExp / mapAfter.nMaxExp
		sequence:Append(self._mapNode.rectProgress:DOSizeDelta(Vector2(width, heigth), nTime))
	elseif mapAfter.nExp == 0 then
		local nTime = 1 < nAddCount and nAniTime or nBeforeToMaxTime
		nAllTime = nAllTime + nTime
		sequence:AppendCallback(function()
			WwiseAudioMgr:PlaySound("ui_common_levelUp")
		end)
		sequence:Append(self._mapNode.rectProgress:DOSizeDelta(Vector2(self.progressBarWidth, heigth), nTime))
		sequence:AppendCallback(function()
			self._mapNode.rectProgress.sizeDelta = Vector2(0, heigth)
		end)
	end
	sequence:SetUpdate(true)
	nAllTime = nAllTime + 0.2
	EventManager.Hit(EventId.TemporaryBlockInput, nAllTime)
	self:AddTimer(1, nAllTime, callback, true, true, true)
end
function CharFavourGiftCtrl:OnBtn_ClickSendGift()
	if self.curChosenItem == nil then
		return
	end
	local totalCount = ConfigTable.GetConfigNumber("AffinityGiftSendCount")
	local sendCount = PlayerData.Base:GetSendGiftCount()
	if sendCount >= tonumber(totalCount) then
		local tips = orderedFormat(ConfigTable.GetUIText("SendGift_Count_Limit"), sendCount)
		EventManager.Hit(EventId.OpenMessageBox, tips)
		return
	end
	local itemId = self.curChosenItem
	local mapMsg = {
		CharId = self.curCharId,
		GiftId = itemId
	}
	local successCallback = function(_, mapMainData)
		local level = self:GetGiftFeedbackLevel(itemId)
		self:PlayCharAnim(level)
		if mapMainData ~= nil then
			NovaAPI.SetTMPText(self._mapNode.txtGiftCount, string.format("\228\187\138\230\151\165\232\181\160\231\164\188\230\172\161\230\149\176<color=#0abec5>%d</color>/%s", mapMainData.SendGiftCnt, totalCount))
		end
	end
	HttpNetHandler.SendMsg(NetMsgId.Id.char_affinity_gift_send_req, mapMsg, nil, successCallback)
end
function CharFavourGiftCtrl:OnBtn_ClickItemGrid(grid)
	local nInstanceID = grid:GetInstanceID()
	if not self.tbGridCtrl[nInstanceID] then
		return
	end
	local nIndex = tonumber(grid.name) + 1
	local mapItem = self.tbItemData[nIndex]
	local itemCtrl = self.tbGridCtrl[nInstanceID]
	if self.curChosenItem ~= nil and self.curChosenItem == mapItem.nTid then
		itemCtrl:SetMultiSelected_Blue(false)
		self.curChosenItem = nil
		self.curChosenItemGrid = nil
	else
		self.curChosenItem = mapItem.nTid
		itemCtrl:SetMultiSelected_Blue(true)
		if self.curChosenItemGrid ~= nil then
			self.curChosenItemGrid:SetMultiSelected_Blue(false)
		end
		self.curChosenItemGrid = itemCtrl
	end
	self:OnItemChosen()
end
function CharFavourGiftCtrl:OnEvent_PanelAdvance(nClosePanelId, nOpenPanelId)
	self:PlaySwitchAnim(nClosePanelId, nOpenPanelId)
end
function CharFavourGiftCtrl:OnEvent_PanelBack(nClosePanelId, nOpenPanelId)
	self:PlaySwitchAnim(nClosePanelId, nOpenPanelId)
end
function CharFavourGiftCtrl:OnEvent_Back(nPanelId)
	if self._panel._nPanelId == nPanelId and self._panel.nPanelId == PanelId.CharFavourGift then
		EventManager.Hit(EventId.CharRelatePanelClose)
		PlayerData.Voice:StopCharVoice()
		EventManager.Hit("PlayCharL2DAnim", "idle", true, true)
		EventManager.Hit(EventId.CharRelatePanelOpen, PanelId.CharacterRelation, self.curCharId)
	end
end
function CharFavourGiftCtrl:OnEvent_Home(nPanelId)
	if self._panel == nil or self._panel._nPanelId ~= nPanelId or self._panel.nPanelId ~= PanelId.CharFavourGift then
		return
	end
	PanelManager.Home()
end
function CharFavourGiftCtrl:OnEvent_AffinityChange(charId, curLevel, lastFavourLevel, curExp, lastExp)
	if self._panel.nPanelId ~= PanelId.CharFavourGift then
		return
	end
	self.lastChosenItem = self.curChosenItem
	local laseExp = self.curFavourExp
	local affinityData = PlayerData.Char:GetCharAffinityData(self.curCharId)
	self.curFavourExp = affinityData.Exp
	self.nLastFavourLevel = lastFavourLevel
	self.nCurLevel = curLevel
	local templateId = ConfigTable.GetData("CharAffinityTemplate", self.curCharId).TemplateId
	local mapLevelBefore = {
		nLevel = lastFavourLevel,
		nMaxLevel = self.MaxAffintiyLevel,
		nExp = laseExp,
		nMaxExp = CacheTable.GetData("_AffinityLevel", templateId)[lastFavourLevel + 1 > self.MaxAffintiyLevel and self.MaxAffintiyLevel or lastFavourLevel + 1].NeedExp
	}
	local mapLevelAfter = {
		nLevel = curLevel,
		nMaxLevel = self.MaxAffintiyLevel,
		nExp = self.curFavourExp,
		nMaxExp = CacheTable.GetData("_AffinityLevel", templateId)[curLevel + 1 > self.MaxAffintiyLevel and self.MaxAffintiyLevel or curLevel + 1].NeedExp
	}
	local callback = function()
		self:Refresh()
		if curLevel > lastFavourLevel then
			EventManager.Hit(EventId.OpenPanel, PanelId.CharFavourLevelUp, charId, curLevel, lastFavourLevel, curExp, lastExp)
		end
	end
	self._mapNode.rectProgress.gameObject:SetActive(true)
	self._mapNode.rectPreProgress.gameObject:SetActive(false)
	self:PlayProgressAnim(mapLevelBefore, mapLevelAfter, callback)
end
function CharFavourGiftCtrl:OnEvent_ShowBubbleVoiceText(nCharId, nId)
end
function CharFavourGiftCtrl:OnEvent_NewDay()
	local totalCount = ConfigTable.GetConfigValue("AffinityGiftSendCount")
	local curCount = 0
	NovaAPI.SetTMPText(self._mapNode.txtGiftCount, string.format("\228\187\138\230\151\165\232\181\160\231\164\188\230\172\161\230\149\176<color=#0abec5>%d</color>/%s", curCount, totalCount))
end
function CharFavourGiftCtrl:PlaySwitchAnim(nClosePanelId, nOpenPanelId)
	if nClosePanelId == PanelId.CharFavourGift then
		self._mapNode.safeAreaRoot.gameObject:SetActive(false)
		EventManager.Hit("ChangeCharFgTab", true)
	end
	if nOpenPanelId == PanelId.CharFavourGift then
		self._mapNode.safeAreaRoot.gameObject:SetActive(true)
		self:Refresh()
		EventManager.Hit("ChangeCharFgTab", false)
	end
end
return CharFavourGiftCtrl
