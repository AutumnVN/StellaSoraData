local ThrowGiftCtrl = class("ThrowGiftCtrl", BaseCtrl)
local rootPath = "UI_Activity/%s.prefab"
local GameResourceLoader = require("Game.Common.Resource.GameResourceLoader")
local ResTypeAny = GameResourceLoader.ResType.Any
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
ThrowGiftCtrl._mapNodeConfig = {
	TMPLevelScoreTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "ThrowGift_LevelScoreTitle"
	},
	PausePanel = {
		sCtrlName = "Game.UI.Activity.ThrowGifts.ThrowGiftPauseCtrl"
	},
	rtItem = {
		nCount = 2,
		sCtrlName = "Game.UI.Activity.ThrowGifts.ThrowGiftItemUseBtnCtrl"
	},
	rtLevelRoot = {sComponentName = "Transform"},
	btnPause = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Pause"
	},
	TMPLevelTime = {sComponentName = "TMP_Text"},
	TMPLevelScore = {sComponentName = "TMP_Text"},
	TMPTarget = {sComponentName = "TMP_Text"},
	imgItemDescBg = {sComponentName = "Animator"},
	TMPItemDescBottom = {sComponentName = "TMP_Text"},
	imgTimeBg = {},
	rtItemSelect = {
		sCtrlName = "Game.UI.Activity.ThrowGifts.ItemSelect.ThrowGiftItemSelectCtrl"
	},
	rtSettle = {
		sCtrlName = "Game.UI.Activity.ThrowGifts.ThrowGiftSettleCtrl"
	},
	rtTargetHint = {},
	rtTargetHintAnim = {
		sNodeName = "rtTargetHint",
		sComponentName = "Animator"
	},
	TMPTargetHint = {sComponentName = "TMP_Text"},
	TMPTitleTargetHint = {sComponentName = "TMP_Text"},
	rtBuff = {nCount = 4},
	TMPBuffTime = {nCount = 4, sComponentName = "TMP_Text"},
	rtColorAnim = {sComponentName = "Animator"},
	FX_Star = {},
	FX_Snow = {}
}
ThrowGiftCtrl._mapEventConfig = {
	ThrowGift_Exit_OnClick = "OnEvent_ThrowGift_Exit",
	ThrowGift_Restart_OnClick = "OnEvent_ThrowGift_Restart",
	ThrowGift_Continue_OnClick = "OnEvent_ThrowGift_Continue",
	ThrowGiftSettle_Exit = "OnEvent_ThrowGift_Exit",
	ThrowGiftSettle_NextLevel = "OnEvent_ThrowGift_NextLevel",
	ThrowGiftSettle_Restart = "OnEvent_ThrowGift_Restart",
	OnBtnClick_ThrowGiftItemUseBtn = "OnEvent_ThrowGiftItemUseBtn",
	OnBtnClick_ThrowGiftItemConfirmBtn = "OnEvent_ThrowGiftItemConfirmBtn"
}
ThrowGiftCtrl._mapRedDotConfig = {}
function ThrowGiftCtrl:Awake()
	self.nCurTime = 0
end
function ThrowGiftCtrl:FadeIn()
end
function ThrowGiftCtrl:FadeOut()
end
function ThrowGiftCtrl:OnEnable()
	self.nCurItem = {0, 0}
	self.nCurSelectItemIdx = 0
	local param = self:GetPanelParam()
	if type(param) == "table" then
		self.nLevelId = param[1]
	end
	local mapLevelCfgData = ConfigTable.GetData("ThrowGiftLevel", self.nLevelId)
	if mapLevelCfgData == nil then
		return
	end
	self.mapLevelCfgData = mapLevelCfgData
	local mapFloorCfgData = ConfigTable.GetData("ThrowGiftFloor", self.mapLevelCfgData.FloorId)
	if mapFloorCfgData == nil then
		return
	end
	self.mapFloorCfgData = mapFloorCfgData
	self.actData = PlayerData.Activity:GetActivityDataById(self.mapLevelCfgData.ActivityId)
	self.mapRecordLevelData = {}
	self.mapRecordItemData = {}
	if self.actData ~= nil then
		local mapCachedData = self.actData:GetActivityData()
		self.mapRecordLevelData = mapCachedData.tbLevels
		self.mapRecordItemData = mapCachedData.tbItems
	end
	local sPath = string.format(rootPath, self.mapFloorCfgData.SceneName)
	local goLevelPerfab = GameResourceLoader.LoadAsset(ResTypeAny, Settings.AB_ROOT_PATH .. sPath, typeof(Object))
	local goLevel = instantiate(goLevelPerfab, self._mapNode.rtLevelRoot)
	local mapCtrl = self:BindCtrlByNode(goLevel, "Game.UI.Activity.ThrowGifts.ThrowGiftsLevelCtrl")
	local rtLevel = goLevel:GetComponent("RectTransform")
	self.levelCtrl = mapCtrl
	if rtLevel ~= nil then
		rtLevel.anchoredPosition = Vector2(0, 0)
	end
	self:SetScore(0)
	if 0 < self.mapLevelCfgData.CountDownLimit then
		self:SetTime(self.mapLevelCfgData.CountDownLimit)
		self._mapNode.imgTimeBg:SetActive(true)
	else
		self._mapNode.imgTimeBg:SetActive(false)
	end
	self._mapNode.rtItem[1]:SetItem(0)
	self._mapNode.rtItem[2]:SetItem(0)
	self._mapNode.rtItem[1]:PlayAnim(2)
	self._mapNode.rtItem[2]:PlayAnim(2)
	self._mapNode.rtItem[1]:SetIdx(1)
	self._mapNode.rtItem[2]:SetIdx(2)
	self._mapNode.rtBuff[1]:SetActive(false)
	self._mapNode.rtBuff[2]:SetActive(false)
	self._mapNode.rtBuff[3]:SetActive(false)
	self._mapNode.rtBuff[4]:SetActive(false)
	EventManager.Hit(EventId.SetTransition)
	local waitTransion = function()
		self._mapNode.rtTargetHint:SetActive(true)
		self._mapNode.rtTargetHintAnim:Play("rtTargetHint_in")
		WwiseAudioMgr:PostEvent("Mode_Present_paper")
		NovaAPI.SetTMPText(self._mapNode.TMPTargetHint, mapLevelCfgData.ThrowGiftLevelCondDesc)
		self.levelCtrl:SetLevel(self, self.nLevelId, self.actData)
		self.levelCtrl:Pause(true)
		local wait = function()
			self._mapNode.rtTargetHintAnim:Play("rtTargetHint_out")
		end
		local waitAnim = function()
			self.levelCtrl:Pause(false)
			self.levelCtrl:LevelStart()
			self._mapNode.rtTargetHint:SetActive(false)
		end
		self:AddTimer(1, 1.5, wait, true, true, true)
		self:AddTimer(1, 1.7, waitAnim, true, true, true)
	end
	self:AddTimer(1, 1.3, waitTransion, true, true, true)
	self:SetTarget(0, self.mapLevelCfgData.throwGiftLevelParams)
end
function ThrowGiftCtrl:OnDisable()
end
function ThrowGiftCtrl:OnDestroy()
end
function ThrowGiftCtrl:OnRelease()
end
function ThrowGiftCtrl:SetScore(nScore)
	NovaAPI.SetTMPText(self._mapNode.TMPLevelScore, tostring(nScore))
end
function ThrowGiftCtrl:SetTime(nTime)
	if math.floor(nTime) ~= self.nCurTime then
		self.nCurTime = math.floor(nTime)
		NovaAPI.SetTMPText(self._mapNode.TMPLevelTime, tostring(self.nCurTime))
	end
end
function ThrowGiftCtrl:SetTarget(nCur)
	NovaAPI.SetTMPText(self._mapNode.TMPTarget, string.format(self.mapLevelCfgData.ThrowGiftLevelCondDesc .. "(%d/%d)", nCur, self.mapLevelCfgData.throwGiftLevelParams))
end
function ThrowGiftCtrl:OpenItemSelect(tbItem, selectCallback)
	local pos = 1
	if self.nCurItem[1] == 0 or self.nCurItem[1] == nil then
		pos = 1
	elseif self.nCurItem[2] == 0 or self.nCurItem[2] == nil then
		pos = 2
	else
		pos = 1
	end
	local callback = function(nIdx)
		if selectCallback ~= nil and type(selectCallback) == "function" then
			selectCallback(nIdx)
		end
		self.nCurItem[pos] = tbItem[nIdx]
		self._mapNode.rtItem[pos]:SetItem(tbItem[nIdx])
		self._mapNode.rtItem[pos]:PlayAnim(3)
	end
	self._mapNode.rtItemSelect:OpenPanel(tbItem, callback, pos)
end
function ThrowGiftCtrl:OpenSettle(bWin, nScore, nGift)
	self.mapRecordLevelData = {}
	self.mapRecordItemData = {}
	if self.actData ~= nil then
		local mapCachedData = self.actData:GetActivityData()
		self.mapRecordLevelData = mapCachedData.tbLevels
		self.mapRecordItemData = mapCachedData.tbItems
	end
	local bShowNextLevel = false
	local nNextLevelId = self.nLevelId + 1
	local mapNextCfgData = ConfigTable.GetData("ThrowGiftLevel", self.nLevelId, false)
	if mapNextCfgData ~= nil then
		bShowNextLevel = self:GetLevelUnlock(nNextLevelId)
	end
	self._mapNode.rtSettle:ShowSettle(bWin, nScore, nGift, bShowNextLevel)
end
function ThrowGiftCtrl:SetFx(mapState)
	local bShowSnow = mapState[103] ~= nil
	local bShowDouble = mapState[104] ~= nil
	self._mapNode.rtColorAnim.gameObject:SetActive(bShowSnow or bShowDouble)
	self._mapNode.FX_Star:SetActive(bShowDouble)
	self._mapNode.FX_Snow:SetActive(bShowSnow)
	if bShowSnow and bShowDouble then
		self._mapNode.rtColorAnim:Play("rtColorAnim_YB")
	elseif bShowSnow then
		self._mapNode.rtColorAnim:Play("rtColorAnim_B")
	elseif bShowDouble then
		self._mapNode.rtColorAnim:Play("rtColorAnim_Y")
	end
end
function ThrowGiftCtrl:ChangeLevel(nLevelId)
	local callback = function()
		self.levelCtrl:ClearTrackLine()
		local goLevelBefore = self.levelCtrl.gameObject
		self:UnbindCtrlByNode(self.levelCtrl)
		destroy(goLevelBefore)
		self.nCurItem = {0, 0}
		self.nCurSelectItemIdx = 0
		self.nLevelId = nLevelId
		local mapLevelCfgData = ConfigTable.GetData("ThrowGiftLevel", self.nLevelId)
		if mapLevelCfgData == nil then
			return
		end
		self.mapLevelCfgData = mapLevelCfgData
		local mapFloorCfgData = ConfigTable.GetData("ThrowGiftFloor", self.mapLevelCfgData.FloorId)
		if mapFloorCfgData == nil then
			return
		end
		self.mapFloorCfgData = mapFloorCfgData
		self.actData = PlayerData.Activity:GetActivityDataById(self.mapLevelCfgData.ActivityId)
		self.mapRecordLevelData = {}
		self.mapRecordItemData = {}
		if self.actData ~= nil then
			local mapCachedData = self.actData:GetActivityData()
			self.mapRecordLevelData = mapCachedData.tbLevels
			self.mapRecordItemData = mapCachedData.tbItems
		end
		local sPath = string.format(rootPath, self.mapFloorCfgData.SceneName)
		local goLevelPerfab = GameResourceLoader.LoadAsset(ResTypeAny, Settings.AB_ROOT_PATH .. sPath, typeof(Object))
		local goLevel = instantiate(goLevelPerfab, self._mapNode.rtLevelRoot)
		local mapCtrl = self:BindCtrlByNode(goLevel, "Game.UI.Activity.ThrowGifts.ThrowGiftsLevelCtrl")
		local rtLevel = goLevel:GetComponent("RectTransform")
		self.levelCtrl = mapCtrl
		if rtLevel ~= nil then
			rtLevel.anchoredPosition = Vector2(0, 0)
		end
		self:SetScore(0)
		if 0 < self.mapLevelCfgData.CountDownLimit then
			self:SetTime(self.mapLevelCfgData.CountDownLimit)
			self._mapNode.imgTimeBg:SetActive(true)
		else
			self._mapNode.imgTimeBg:SetActive(false)
		end
		self._mapNode.rtItem[1]:SetItem(0)
		self._mapNode.rtItem[2]:SetItem(0)
		self._mapNode.rtItem[1]:SetIdx(1)
		self._mapNode.rtItem[2]:SetIdx(2)
		self._mapNode.rtItem[1]:PlayAnim(2)
		self._mapNode.rtItem[2]:PlayAnim(2)
		self._mapNode.rtBuff[1]:SetActive(false)
		self._mapNode.rtBuff[2]:SetActive(false)
		self._mapNode.rtBuff[3]:SetActive(false)
		self._mapNode.rtBuff[4]:SetActive(false)
		self:SetTarget(0, self.mapLevelCfgData.throwGiftLevelParams)
		local waitTransion = function()
			self._mapNode.rtTargetHint:SetActive(true)
			self._mapNode.rtTargetHintAnim:Play("rtTargetHint_in")
			WwiseAudioMgr:PostEvent("Mode_Present_paper")
			NovaAPI.SetTMPText(self._mapNode.TMPTargetHint, mapLevelCfgData.ThrowGiftLevelCondDesc)
			self.levelCtrl:SetLevel(self, self.nLevelId, self.actData)
			self.levelCtrl:Pause(true)
			local wait = function()
				self._mapNode.rtTargetHintAnim:Play("rtTargetHint_out")
			end
			local waitAnim = function()
				self.levelCtrl:Pause(false)
				self.levelCtrl:LevelStart()
				self._mapNode.rtTargetHint:SetActive(false)
			end
			self:AddTimer(1, 1.5, wait, true, true, true)
			self:AddTimer(1, 1.7, waitAnim, true, true, true)
		end
		self:AddTimer(1, 1.3, waitTransion, true, true, true)
		EventManager.Hit(EventId.SetTransition)
	end
	EventManager.Hit(EventId.SetTransition, 37, callback)
end
function ThrowGiftCtrl:GetLevelUnlock(nLevelId)
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
function ThrowGiftCtrl:SetBuffShow(nBuffId, bShow)
	if nBuffId == 102 then
		self._mapNode.rtBuff[1]:SetActive(bShow)
	elseif nBuffId == 103 then
		self._mapNode.rtBuff[2]:SetActive(bShow)
	elseif nBuffId == 104 then
		self._mapNode.rtBuff[3]:SetActive(bShow)
	elseif nBuffId == 105 then
		self._mapNode.rtBuff[4]:SetActive(bShow)
	end
end
function ThrowGiftCtrl:SetBuffTime(nBuffId, nTime)
	local formatTime = function(nTime)
		nTime = math.floor(nTime)
		local nMin = math.floor(nTime / 60)
		local nSec = nTime % 60
		return string.format("%02d:%02d", nMin, nSec)
	end
	if nBuffId == 102 then
		NovaAPI.SetTMPText(self._mapNode.TMPBuffTime[1], formatTime(nTime))
	elseif nBuffId == 103 then
		NovaAPI.SetTMPText(self._mapNode.TMPBuffTime[2], formatTime(nTime))
	elseif nBuffId == 104 then
		NovaAPI.SetTMPText(self._mapNode.TMPBuffTime[3], formatTime(nTime))
	elseif nBuffId == 105 then
		NovaAPI.SetTMPText(self._mapNode.TMPBuffTime[4], formatTime(nTime))
	end
end
function ThrowGiftCtrl:OnEvent_ThrowGift_Exit()
	if self.levelCtrl ~= nil then
		self.levelCtrl:Pause(false)
		self._mapNode.PausePanel.gameObject:SetActive(false)
	end
	WwiseAudioMgr:PostEvent("Mode_Present_all_stop")
	EventManager.Hit(EventId.ClosePanel, PanelId.ThrowGiftLevelPanel)
end
function ThrowGiftCtrl:OnEvent_ThrowGift_Restart()
	if self.levelCtrl ~= nil then
		self.levelCtrl:Pause(false)
		self._mapNode.PausePanel.gameObject:SetActive(false)
	end
	WwiseAudioMgr:PostEvent("Mode_Present_all_stop")
	self:ChangeLevel(self.nLevelId)
end
function ThrowGiftCtrl:OnEvent_ThrowGift_Continue()
	if self.levelCtrl ~= nil then
		self.levelCtrl:Pause(false)
		self._mapNode.PausePanel.gameObject:SetActive(false)
	end
end
function ThrowGiftCtrl:OnEvent_ThrowGiftItemUseBtn(nIdx, nItemId)
	if self.nCurSelectItemIdx == nIdx then
		self._mapNode.rtItem[self.nCurSelectItemIdx]:PlayAnim(2)
		self.nCurSelectItemIdx = 0
		self._mapNode.imgItemDescBg.gameObject:SetActive(false)
		return
	end
	if self.nCurSelectItemIdx == 0 then
		self._mapNode.imgItemDescBg.gameObject:SetActive(true)
	end
	if self.nCurSelectItemIdx ~= 0 then
		self._mapNode.rtItem[self.nCurSelectItemIdx]:PlayAnim(2)
	end
	self.nCurSelectItemIdx = nIdx
	self._mapNode.rtItem[self.nCurSelectItemIdx]:PlayAnim(1)
	local mapItemCfgData = ConfigTable.GetData("ThrowGiftItem", nItemId)
	if mapItemCfgData == nil then
		self._mapNode.imgItemDescBg.gameObject:SetActive(false)
		return
	end
	NovaAPI.SetTMPText(self._mapNode.TMPItemDescBottom, mapItemCfgData.Desc)
end
function ThrowGiftCtrl:OnEvent_ThrowGiftItemConfirmBtn(nIdx, nItemId)
	self._mapNode.imgItemDescBg.gameObject:SetActive(false)
	self.nCurItem[nIdx] = 0
	self.levelCtrl:ActiveItem(nItemId)
	for i = 1, 2 do
		if i == nIdx then
			self._mapNode.rtItem[i]:PlayAnim(2)
			self._mapNode.rtItem[i]:SetItem(0)
		end
	end
	self.nCurSelectItemIdx = 0
end
function ThrowGiftCtrl:OnEvent_ThrowGift_NextLevel()
	local bShowNextLevel = false
	local nNextLevelId = self.nLevelId + 1
	local mapNextCfgData = ConfigTable.GetData("ThrowGiftLevel", self.nLevelId, false)
	if mapNextCfgData ~= nil then
		bShowNextLevel = self:GetLevelUnlock(nNextLevelId)
	end
	if bShowNextLevel then
		WwiseAudioMgr:PostEvent("Mode_Present_all_stop")
		self:ChangeLevel(nNextLevelId)
	end
end
function ThrowGiftCtrl:OnBtnClick_Pause()
	if self.levelCtrl ~= nil then
		self.levelCtrl:Pause(true)
		self._mapNode.PausePanel.gameObject:SetActive(true)
	end
end
return ThrowGiftCtrl
