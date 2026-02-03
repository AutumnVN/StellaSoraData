local ThrowGiftLevelSelectCtrl = class("ThrowGiftLevelSelectCtrl", BaseCtrl)
local tbProgress = {
	0,
	0.3,
	0.7,
	1
}
local mapDifficultyBtn = {
	[1] = GameEnum.ThrowGiftDifficulty.Easy,
	[2] = GameEnum.ThrowGiftDifficulty.Normal,
	[3] = GameEnum.ThrowGiftDifficulty.Speed,
	[4] = GameEnum.ThrowGiftDifficulty.Blind
}
ThrowGiftLevelSelectCtrl._mapNodeConfig = {
	TMPBtnTarget = {
		sComponentName = "TMP_Text",
		sLanguageId = "ThrowGift_Target"
	},
	TMPBtnItem = {
		sComponentName = "TMP_Text",
		sLanguageId = "ThrowGift_Item"
	},
	imgLineTop = {sComponentName = "Image"},
	TMPGroupName = {sComponentName = "TMP_Text"},
	rtPenguin = {sComponentName = "Animator"},
	DecoRoot = {sComponentName = "Animator"},
	imgBgAnim = {sComponentName = "Animator"},
	rtLevelInfo = {
		nCount = 2,
		sCtrlName = "Game.UI.Activity.ThrowGifts.ThrowGiftLevelInfoGridCtrl"
	},
	btnItemDic = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_ItemDic"
	},
	btnLevelCtrl = {
		sNodeName = "btnLevel",
		nCount = 4,
		sCtrlName = "Game.UI.Activity.ThrowGifts.ThrowGiftLevelSelectBtmBtnCtrl"
	},
	btnLevel = {
		nCount = 4,
		sComponentName = "UIButton",
		callback = "OnBtnClick_GroupBtn"
	},
	rtItemInfo = {
		sCtrlName = "Game.UI.Activity.ThrowGifts.ThrowGiftItemDicCtrl"
	},
	btnPrev = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Prev"
	},
	btnNext = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Next"
	},
	TopBar = {
		sNodeName = "TopBarPanel",
		sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"
	}
}
ThrowGiftLevelSelectCtrl._mapEventConfig = {}
ThrowGiftLevelSelectCtrl._mapRedDotConfig = {}
function ThrowGiftLevelSelectCtrl:Awake()
	self._switchAnimTimer = nil
end
function ThrowGiftLevelSelectCtrl:FadeIn()
end
function ThrowGiftLevelSelectCtrl:FadeOut()
end
function ThrowGiftLevelSelectCtrl:OnEnable()
	self._mapNode.rtPenguin.speed = 1
	self._mapNode.DecoRoot.speed = 1
	local param = self:GetPanelParam()
	if type(param) == "table" then
		self.nActivityId = param[1]
	end
	self.rootAnim = self.gameObject:GetComponent("Animator")
	self.mapLevelGroup = {}
	self._mapNode.rtItemInfo.gameObject:SetActive(false)
	self.actData = PlayerData.Activity:GetActivityDataById(self.nActivityId)
	self.mapRecordLevelData = {}
	self.mapRecordItemData = {}
	if self.actData ~= nil then
		local mapCachedData = self.actData:GetActivityData()
		self.mapRecordLevelData = mapCachedData.tbLevels
		self.mapRecordItemData = mapCachedData.tbItems
	end
	local foreachLevel = function(mapData)
		if mapData.ActivityId == self.nActivityId then
			if self.mapLevelGroup[mapData.Difficulty] == nil then
				self.mapLevelGroup[mapData.Difficulty] = {}
			end
			table.insert(self.mapLevelGroup[mapData.Difficulty], mapData)
		end
	end
	ForEachTableLine(DataTable.ThrowGiftLevel, foreachLevel)
	local sort = function(a, b)
		return a.Id < b.Id
	end
	for _, tbLevel in pairs(self.mapLevelGroup) do
		table.sort(tbLevel, sort)
	end
	self:RefreshLevelInfo()
	self:RefreshLevelInfoGrid()
	local nCurIdx = 1
	for i = 1, 4 do
		local enumDifficulty = mapDifficultyBtn[i]
		local bUnlock = table.indexof(self.tbUnlockedGroup, enumDifficulty) > 0
		local bClear = 0 < table.indexof(self.tbClearedGroup, enumDifficulty)
		self._mapNode.btnLevelCtrl[i]:SetBtnState(bUnlock, bClear)
		self._mapNode.btnLevelCtrl[i]:SetBtnCurState(enumDifficulty == self.curGroup)
		self._mapNode.btnLevelCtrl[i]:SetBtnSelectState(enumDifficulty <= self.curGroup)
		if enumDifficulty == self.curGroup then
			nCurIdx = i
		end
	end
	self._mapNode.imgBgAnim:Play("ThrowGiftsBgSwitch_in" .. nCurIdx)
	NovaAPI.SetImageFillAmount(self._mapNode.imgLineTop, tbProgress[nCurIdx])
end
function ThrowGiftLevelSelectCtrl:OnDisable()
end
function ThrowGiftLevelSelectCtrl:OnDestroy()
end
function ThrowGiftLevelSelectCtrl:OnRelease()
end
function ThrowGiftLevelSelectCtrl:RefreshLevelInfo()
	self.actData = PlayerData.Activity:GetActivityDataById(self.nActivityId)
	self.mapRecordLevelData = {}
	self.mapRecordItemData = {}
	if self.actData ~= nil then
		local mapCachedData = self.actData:GetActivityData()
		self.mapRecordLevelData = mapCachedData.tbLevels
		self.mapRecordItemData = mapCachedData.tbItems
	end
	self.tbUnlockedGroup = {}
	self.tbClearedGroup = {}
	for _, nEnum in pairs(GameEnum.ThrowGiftDifficulty) do
		if self.mapLevelGroup[nEnum] ~= nil then
			for _, mapLevelCfgData in ipairs(self.mapLevelGroup[nEnum]) do
				if self:GetLevelUnlock(mapLevelCfgData.Id) and table.indexof(self.tbUnlockedGroup, nEnum) < 1 then
					table.insert(self.tbUnlockedGroup, nEnum)
				end
			end
		end
	end
	table.sort(self.tbUnlockedGroup)
	table.sort(self.tbClearedGroup)
	self.curGroup = #self.tbUnlockedGroup > 0 and self.tbUnlockedGroup[#self.tbUnlockedGroup] or GameEnum.ThrowGiftDifficulty.Easy
	for nGroup, tbLevelData in pairs(self.mapLevelGroup) do
		local bClear = true
		for _, mapLevelCfgData in ipairs(tbLevelData) do
			if self.mapRecordLevelData[mapLevelCfgData.Id] == nil or not self.mapRecordLevelData[mapLevelCfgData.Id].FirstComplete then
				bClear = false
			end
		end
		if bClear then
			table.insert(self.tbClearedGroup, nGroup)
		end
	end
end
function ThrowGiftLevelSelectCtrl:RefreshLevelInfoGrid()
	local tbCurGroup = self.mapLevelGroup[self.curGroup]
	for i = 1, 2 do
		local nLevelId = tbCurGroup[i].Id
		local bUnlock = tbCurGroup[i].PreLevelId > 0 and self.mapRecordLevelData[tbCurGroup[i].PreLevelId] ~= nil and self.mapRecordLevelData[tbCurGroup[i].PreLevelId].FirstComplete or true
		local nMaxScore = self.mapRecordLevelData[nLevelId] == nil and 0 or self.mapRecordLevelData[nLevelId].MaxScore
		local bPass = self.mapRecordLevelData[nLevelId] ~= nil and self.mapRecordLevelData[nLevelId].FirstComplete or false
		self._mapNode.rtLevelInfo[i]:Refresh(nLevelId, bUnlock, nMaxScore, bPass)
	end
	NovaAPI.SetTMPText(self._mapNode.TMPGroupName, ConfigTable.GetUIText("ThrowGift_Difficulty" .. self.curGroup) or "")
end
function ThrowGiftLevelSelectCtrl:GetLevelPass(nLevelId)
	if self.mapRecordLevelData[nLevelId] ~= nil and self.mapRecordLevelData[nLevelId].FirstComplete then
		return true
	end
	return false
end
function ThrowGiftLevelSelectCtrl:GetLevelUnlock(nLevelId)
	local mapLevelCfgData = ConfigTable.GetData("ThrowGiftLevel", nLevelId)
	if mapLevelCfgData == nil then
		return false
	end
	if mapLevelCfgData.PreLevelId ~= 0 then
		return self.mapRecordLevelData[mapLevelCfgData.PreLevelId] ~= nil and self.mapRecordLevelData[mapLevelCfgData.PreLevelId].FirstComplete
	else
		return true
	end
end
function ThrowGiftLevelSelectCtrl:OnBtnClick_GroupBtn(btn, nIdx)
	local enumDifficulty = mapDifficultyBtn[nIdx]
	if self.curGroup == enumDifficulty then
		return
	end
	if table.indexof(self.tbUnlockedGroup, enumDifficulty) < 1 then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("ThrowGift_GroupLockHint") or "")
		return
	end
	self.curGroup = enumDifficulty
	self:RefreshLevelInfoGrid()
	local nCurIdx = 1
	for i = 1, 4 do
		local enumDifficulty = mapDifficultyBtn[i]
		self._mapNode.btnLevelCtrl[i]:SetBtnCurState(enumDifficulty == self.curGroup)
		self._mapNode.btnLevelCtrl[i]:SetBtnSelectState(enumDifficulty <= self.curGroup)
		if enumDifficulty == self.curGroup then
			nCurIdx = i
		end
	end
	NovaAPI.SetImageFillAmount(self._mapNode.imgLineTop, tbProgress[nCurIdx])
	self._mapNode.imgBgAnim:Play("ThrowGiftsBgSwitch_in" .. nCurIdx)
	self.rootAnim:Play("ThrowGiftsLevelSelectPanel_switch")
	local wait = function()
		self._mapNode.rtPenguin.speed = 1
		self._mapNode.DecoRoot.speed = 1
		self._switchAnimTimer = nil
	end
	self._mapNode.rtPenguin.speed = 3
	self._mapNode.DecoRoot.speed = 20
	if self._switchAnimTimer ~= nil then
		self._switchAnimTimer:Cancel()
		self._switchAnimTimer = nil
	end
	self._switchAnimTimer = self:AddTimer(1, 0.6, wait, true, true, true)
end
function ThrowGiftLevelSelectCtrl:OnBtnClick_Next()
	local nCurIdx = 1
	for nIdx, nEnum in ipairs(mapDifficultyBtn) do
		if self.curGroup == nEnum then
			nCurIdx = nIdx
		end
	end
	if nCurIdx == 4 then
		nCurIdx = 1
	else
		nCurIdx = nCurIdx + 1
	end
	local enumDifficulty = mapDifficultyBtn[nCurIdx]
	if 1 > table.indexof(self.tbUnlockedGroup, enumDifficulty) then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("ThrowGift_GroupLockHint") or "")
		return
	end
	self.curGroup = enumDifficulty
	self:RefreshLevelInfoGrid()
	local nCurIdx = 1
	for i = 1, 4 do
		local enumDifficulty = mapDifficultyBtn[i]
		self._mapNode.btnLevelCtrl[i]:SetBtnCurState(enumDifficulty == self.curGroup)
		self._mapNode.btnLevelCtrl[i]:SetBtnSelectState(enumDifficulty <= self.curGroup)
		if enumDifficulty == self.curGroup then
			nCurIdx = i
		end
	end
	NovaAPI.SetImageFillAmount(self._mapNode.imgLineTop, tbProgress[nCurIdx])
	self._mapNode.imgBgAnim:Play("ThrowGiftsBgSwitch_in" .. nCurIdx)
	self.rootAnim:Play("ThrowGiftsLevelSelectPanel_switch")
	local wait = function()
		self._mapNode.rtPenguin.speed = 1
		self._mapNode.DecoRoot.speed = 1
		self._switchAnimTimer = nil
	end
	self._mapNode.rtPenguin.speed = 3
	self._mapNode.DecoRoot.speed = 20
	if self._switchAnimTimer ~= nil then
		self._switchAnimTimer:Cancel()
		self._switchAnimTimer = nil
	end
	self._switchAnimTimer = self:AddTimer(1, 0.6, wait, true, true, true)
end
function ThrowGiftLevelSelectCtrl:OnBtnClick_Prev()
	local nCurIdx = 1
	for nIdx, nEnum in ipairs(mapDifficultyBtn) do
		if self.curGroup == nEnum then
			nCurIdx = nIdx
		end
	end
	if nCurIdx == 1 then
		nCurIdx = 4
	else
		nCurIdx = nCurIdx - 1
	end
	local enumDifficulty = mapDifficultyBtn[nCurIdx]
	if 1 > table.indexof(self.tbUnlockedGroup, enumDifficulty) then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("ThrowGift_GroupLockHint") or "")
		return
	end
	self.curGroup = enumDifficulty
	self:RefreshLevelInfoGrid()
	local nCurIdx = 1
	for i = 1, 4 do
		local enumDifficulty = mapDifficultyBtn[i]
		self._mapNode.btnLevelCtrl[i]:SetBtnCurState(enumDifficulty == self.curGroup)
		self._mapNode.btnLevelCtrl[i]:SetBtnSelectState(enumDifficulty <= self.curGroup)
		if enumDifficulty == self.curGroup then
			nCurIdx = i
		end
	end
	NovaAPI.SetImageFillAmount(self._mapNode.imgLineTop, tbProgress[nCurIdx])
	self._mapNode.imgBgAnim:Play("ThrowGiftsBgSwitch_in" .. nCurIdx)
	self.rootAnim:Play("ThrowGiftsLevelSelectPanel_switch")
	local wait = function()
		self._mapNode.rtPenguin.speed = 1
		self._mapNode.DecoRoot.speed = 1
		self._switchAnimTimer = nil
	end
	self._mapNode.rtPenguin.speed = 3
	self._mapNode.DecoRoot.speed = 20
	if self._switchAnimTimer ~= nil then
		self._switchAnimTimer:Cancel()
		self._switchAnimTimer = nil
	end
	self._switchAnimTimer = self:AddTimer(1, 0.6, wait, true, true, true)
end
function ThrowGiftLevelSelectCtrl:OnBtnClick_ItemDic()
	self._mapNode.rtItemInfo:OpenPanel()
end
return ThrowGiftLevelSelectCtrl
