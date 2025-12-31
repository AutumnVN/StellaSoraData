local BreakOutLevelCellCtrl = class("TowerDefenseLevelCellCtrl", BaseCtrl)
local DifficultyState = {
	"Entry",
	"Newbie",
	"Advanced",
	"Expert"
}
BreakOutLevelCellCtrl._mapNodeConfig = {
	txt_Name = {sComponentName = "TMP_Text"},
	img_FinishIcon = {
		sNodeName = "Icon_Finish"
	},
	obj_TipTime = {
		sNodeName = "TipTimeMask"
	},
	txt_Time = {sComponentName = "TMP_Text"},
	obj_TipUnLock = {
		sNodeName = "TipsUnLockMask"
	},
	txt_Lock = {sComponentName = "TMP_Text"},
	obj_TipEndMask = {sNodeName = "TipEndMask"},
	txt_TipEnd = {
		sComponentName = "TMP_Text",
		sLanguageId = "Activity_End"
	},
	btnGrid = {
		sNodeName = "btnGrid",
		sComponentName = "UIButton",
		callback = "OnBtnClick_SelectLevel"
	},
	eventActBannerDrag = {
		sNodeName = "btnGrid",
		sComponentName = "UIDrag",
		callback = "OnDrag_Act"
	},
	redDotNew = {}
}
BreakOutLevelCellCtrl._mapEventConfig = {}
BreakOutLevelCellCtrl._mapRedDotConfig = {}
function BreakOutLevelCellCtrl:SetData(nActId, nLevelId)
	self.ActId = nActId
	self.BreakOutData = PlayerData.Activity:GetActivityDataById(nActId)
	self.nActivityGroupId = ConfigTable.GetData("Activity", nActId).MidGroupId
	if self.levelData ~= nil then
		RedDotManager.UnRegisterNode(RedDotDefine.Activity_BreakOut_DifficultyTap_Level, {
			self.nActivityGroupId,
			self.levelData.nLevelId
		}, self._mapNode.redDotNew)
	end
	self.LevelId = nLevelId
	self.levelData = self.BreakOutData:GetDetailLevelDataById(self.LevelId)
	NovaAPI.SetTMPText(self._mapNode.txt_Name, self.levelData.Name)
	self:RefreshLevelState()
	RedDotManager.RegisterNode(RedDotDefine.Activity_BreakOut_DifficultyTap_Level, {
		self.nActivityGroupId,
		self.LevelId
	}, self._mapNode.redDotNew)
end
function BreakOutLevelCellCtrl:RefreshLevelState()
	self._mapNode.obj_TipTime.gameObject:SetActive(false)
	self._mapNode.obj_TipUnLock.gameObject:SetActive(false)
	self._mapNode.obj_TipEndMask.gameObject:SetActive(false)
	self._mapNode.img_FinishIcon.gameObject:SetActive(false)
	local bIsOpen = self:RefreshLevelTime(self.LevelId)
	if bIsOpen == nil or not bIsOpen then
		return
	end
	local isEnd = self:IsLevelsEndTime()
	if isEnd then
		self._mapNode.img_FinishIcon.gameObject:SetActive(isEnd)
		return
	end
	self:RefreshLevelLockState()
	self:RefreshLevelFinishState()
end
function BreakOutLevelCellCtrl:RefreshLevelTime()
	if self.levelData == nil then
		return
	end
	local curTime = CS.ClientManager.Instance.serverTimeStamp
	if curTime >= self.BreakOutData:GetLevelStartTime(self.LevelId) then
		self._mapNode.obj_TipTime.gameObject:SetActive(false)
		return true
	else
		local remainTime = self.BreakOutData:GetLevelStartTime(self.LevelId) - curTime
		local sTime = self:GetTimeText(remainTime)
		NovaAPI.SetTMPText(self._mapNode.txt_Time, orderedFormat(ConfigTable.GetUIText("TowerDef_TimeTips") or "", sTime))
		self._mapNode.obj_TipTime.gameObject:SetActive(true)
		return false
	end
end
function BreakOutLevelCellCtrl:GetTimeText(remainTime)
	local sTimeStr = ""
	if remainTime <= 60 then
		local sec = math.floor(remainTime)
		sTimeStr = orderedFormat(ConfigTable.GetUIText("Activity_Remain_Time_Sec") or "", sec)
	elseif 60 < remainTime and remainTime <= 3600 then
		local min = math.floor(remainTime / 60)
		local sec = math.floor(remainTime - min * 60)
		if sec == 0 then
			min = min - 1
			sec = 60
		end
		sTimeStr = orderedFormat(ConfigTable.GetUIText("Activity_Remain_Time_Min") or "", min, sec)
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
function BreakOutLevelCellCtrl:RefreshLevelLockState()
	if self.levelData == nil then
		return
	end
	local bIsPreLevelComplete = self.BreakOutData:IsPreLevelComplete(self.LevelId)
	if bIsPreLevelComplete then
		self._mapNode.obj_TipUnLock.gameObject:SetActive(false)
	else
		local nPreLevelId = ConfigTable.GetData("BreakOutLevel", self.LevelId).PreLevelId
		local sDifficultState = ConfigTable.GetUIText(DifficultyState[self.BreakOutData:GetBreakoutLevelDifficult(nPreLevelId)])
		local sTip = orderedFormat(ConfigTable.GetUIText("OpenAfterClearingLevel") or "", sDifficultState, self.BreakOutData:GetBreakoutLevelDifficult(nPreLevelId))
		NovaAPI.SetTMPText(self._mapNode.txt_Lock, sTip)
		self._mapNode.obj_TipUnLock.gameObject:SetActive(true)
	end
end
function BreakOutLevelCellCtrl:RefreshLevelFinishState()
	self._mapNode.img_FinishIcon.gameObject:SetActive(self.BreakOutData:IsLevelComplete(self.LevelId))
end
function BreakOutLevelCellCtrl:IsLevelsEndTime()
	local nCurTime = CS.ClientManager.Instance.serverTimeStamp
	local nEndTime = self.BreakOutData:GetActCloseTime(self.LevelId)
	if nCurTime > nEndTime then
		return true
	end
	return false
end
function BreakOutLevelCellCtrl:OnBtnClick_SelectLevel()
	printLog("\231\130\185\229\135\187\230\140\137\233\146\174")
	local bTimeUnlock, bPreComplete = self.BreakOutData:IsLevelUnlocked(self.LevelId)
	if not bTimeUnlock and not bPreComplete then
		return
	end
	self.BreakOutData:EnterLevelSelect(self.LevelId)
	EventManager.Hit("JumpToLevelDetail", self.ActId, self.LevelId)
end
function BreakOutLevelCellCtrl:OnDrag_Act(mDrag)
	printLog("\230\187\145\229\138\168\230\140\137\233\146\174")
	if self.levelData.Type == GameEnum.ActivityBreakoutLevelType.Entry or self.levelData.Type ~= GameEnum.ActivityBreakoutLevelType.Expert then
	end
	EventManager.Hit("DragLevelList", mDrag)
end
return BreakOutLevelCellCtrl
