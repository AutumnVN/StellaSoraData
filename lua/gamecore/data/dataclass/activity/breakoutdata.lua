local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local BreakOutData = class("BreakOutData", ActivityDataBase)
local LocalData = require("GameCore.Data.LocalData")
local RapidJson = require("rapidjson")
local RedDotManager = require("GameCore.RedDot.RedDotManager")
local ClientManager = CS.ClientManager.Instance
local BreakOutLevelData = require("GameCore.Data.DataClass.Activity.BreakOutLevelData")
function BreakOutData:Init()
	self.allLevelData = {}
	self.cacheEnterLevelList = {}
	self.BreakOutLevelData = BreakOutLevelData.new()
	self.tempData = nil
	self.ActEnd = self:IsActTimeEnd()
	self:AddListeners()
end
function BreakOutData:AddListeners()
	EventManager.Add("MilkoutCharacterUnlock", self, self.On_BreakoutCharacter_Unlock)
	EventManager.Add("ClearAllLevels", self, self.OnEvent_GMClearAllLevels)
end
function BreakOutData:RefreshBreakOutData(actId, msgData)
	self:Init()
	self.nActId = actId
	self.mapActData = PlayerData.Activity:GetActivityDataById(self.nActId)
	if self.mapActData ~= nil then
		self.nEndTime = self.mapActData:GetActEndTime() or 0
	end
	if msgData ~= nil then
		self:CacheAllLevelData(msgData.Levels)
		self:CacheAllCharacterData(msgData.Characters)
	end
	local sJson = LocalData.GetPlayerLocalData("BreakOutLevel")
	local tb = decodeJson(sJson)
	if type(tb) == "table" then
		self.cacheEnterLevelList = tb
	end
	self:RefreshRedDot()
end
function BreakOutData:CacheAllCharacterData(UnLockedCharacterData)
	self.tbUnLockedCharacterDataList = {}
	for _, v in pairs(UnLockedCharacterData) do
		local CharacterData = {
			nId = v.Id,
			nBattleTimes = v.BattleTimes
		}
		table.insert(self.tbUnLockedCharacterDataList, CharacterData)
	end
end
function BreakOutData:CacheIsUnlocked(CharacterNid)
	for _, v in pairs(self.tbUnLockedCharacterDataList) do
		if v.nId == CharacterNid then
			return true
		end
	end
	return false
end
function BreakOutData:GetDataFromBreakOutCharacter(CharacterNid)
	for _, v in pairs(self.tbUnLockedCharacterDataList) do
		if v.nId == CharacterNid then
			return ConfigTable.GetData("BreakOutCharacter", CharacterNid)
		end
	end
	return nil
end
function BreakOutData:GetSkillData(CharacterNid)
	local tbCharacterData
	self:GetDataFromBreakOutCharacter(CharacterNid)
	if tbCharacterData == nil then
		return nil
	else
		return tbCharacterData.SkillId
	end
end
function BreakOutData:GetBattleCount(CharacterNid)
	for _, v in pairs(self.tbUnLockedCharacterDataList) do
		if v.nId == CharacterNid then
			return v.nBattleTimes
		end
	end
	return 0
end
function BreakOutData:CacheAllLevelData(levelListData)
	self.tbLevelDataList = {}
	for _, v in pairs(levelListData) do
		local levelData = {
			nId = v.Id,
			bFirstComplete = v.FirstComplete,
			nDifficultyType = ConfigTable.GetData("BreakOutLevel", v.Id).Type,
			nPreLevelId = ConfigTable.GetData("BreakOutLevel", v.Id).PreLevelId
		}
		table.insert(self.tbLevelDataList, levelData)
	end
end
function BreakOutData:IsAllLevelComplete()
	for _, v in pairs(self.tbLevelDataList) do
		if not v.bFirstComplete then
			return false
		end
	end
	return true
end
function BreakOutData:GetLevelData()
	return self.tbLevelDataList
end
function BreakOutData:GetLevelDataById(nId)
	local levelData
	for _, v in pairs(self.tbLevelDataList) do
		if v.nId == nId then
			levelData = v
			break
		end
	end
	return levelData
end
function BreakOutData:UpdateLevelData(levelData)
	for _, v in pairs(self.tbLevelDataList) do
		if v.nId == levelData.Id then
			v.bFirstComplete = levelData.FirstComplete
			break
		end
	end
	local levelConfig = ConfigTable.GetData("BreakOutLevel", levelData.Id)
	if levelConfig == nil then
		return
	end
	if not self:GetPlayState() or self:IsLevelUnlocked(levelData.Id) then
	end
end
function BreakOutData:UpdateCharacterData(CharacterData)
	for _, v in pairs(self.tbUnLockedCharacterDataList) do
		if v.nId == CharacterData.CharacterNid then
			v.nBattleTimes = v.nBattleTimes + 1
			EventManager.Hit("RefreshCharacterBattleTimes")
			break
		end
	end
end
function BreakOutData:GetDetailLevelDataById(nId)
	local levelData
	for _, v in pairs(self.tbLevelDataList) do
		if v.nId == nId then
			levelData = ConfigTable.GetData("BreakOutLevel", nId)
			break
		end
	end
	return levelData
end
function BreakOutData:GetDetailFloorDataById(nId)
	local FloorData
	for _, v in pairs(self.tbLevelDataList) do
		if v.nId == nId then
			nFloorId = ConfigTable.GetData("BreakOutLevel", nId).FloorId
			FloorData = ConfigTable.GetData("BreakOutFloor", nFloorId)
			break
		end
	end
	return FloorData
end
function BreakOutData:GetLevelsByTab(nTabIndex)
	local levelData = {}
	for _, v in pairs(self.tbLevelDataList) do
		if v.nDifficultyType == nTabIndex then
			table.insert(levelData, ConfigTable.GetData("BreakOutLevel", v.nId))
		end
	end
	local sortFunc = function(a, b)
		local aConfig = ConfigTable.GetData("BreakOutLevel", a.Id)
		local bConfig = ConfigTable.GetData("BreakOutLevel", b.Id)
		return aConfig.Difficulty < bConfig.Difficulty
	end
	table.sort(levelData, sortFunc)
	return levelData
end
function BreakOutData:GetBreakoutLevelTypeNum()
	local nNum = 0
	for _, _ in pairs(GameEnum.ActivityBreakoutLevelType) do
		nNum = nNum + 1
	end
	return nNum
end
function BreakOutData:GetBreakoutPreLevelIdName(nLevelId)
	local LevelData = ConfigTable.GetData("BreakOutLevel", nLevelId)
	if LevelData == nil then
		return
	else
		local nPreLevelId = ConfigTable.GetData("BreakOutLevel", nLevelId).PreLevelId
		local PreLevelIdName = ConfigTable.GetData("BreakOutLevel", nPreLevelId).Name
		return PreLevelIdName
	end
end
function BreakOutData:GetBreakoutLevelDifficult(nLevelId)
	local LevelData = ConfigTable.GetData("BreakOutLevel", nLevelId)
	if LevelData == nil then
		return
	else
		return LevelData.Type
	end
end
function BreakOutData:GetCurrentSelectedTabIndex()
	local EasyDifficultyType = GameEnum.ActivityBreakoutLevelType.Expert
	for _, levelData in ipairs(self.tbLevelDataList) do
		if not levelData.bFirstComplete and EasyDifficultyType >= levelData.nDifficultyType then
			EasyDifficultyType = levelData.nDifficultyType
		end
	end
	return EasyDifficultyType
end
function BreakOutData:RefreshRedDot()
	if self.tbLevelDataList == nil then
		return
	end
	local bRedDot = false
	local nActivityGroupId = ConfigTable.GetData("Activity", self.nActId).MidGroupId
	for _, levelData in ipairs(self.tbLevelDataList) do
		if self:IsLevelTimeUnlocked(levelData.nId) then
			if self.ActEnd then
				bRedDot = false
			else
				bRedDot = self:GetLevelIsNew(levelData.nId)
			end
			RedDotManager.SetValid(RedDotDefine.Activity_BreakOut_DifficultyTap_Level, {
				nActivityGroupId,
				levelData.nId
			}, bRedDot)
		end
	end
end
function BreakOutData:IsActTimeEnd()
	local isEnd = false
	local LevelEndTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(ConfigTable.GetConfigValue("BreakOut_LevelClosed"))
	local nCurTime = CS.ClientManager.Instance.serverTimeStamp
	if LevelEndTime ~= nil then
		return LevelEndTime < nCurTime
	else
		printError("config \232\161\168\239\188\154" .. "BreakOut_LevelClosed" .. " Value\230\149\176\230\141\174\228\184\186\231\169\186")
	end
	return isEnd
end
function BreakOutData:GetLevelIsNew(levelId)
	local bResult = false
	local levelData = self:GetLevelDataById(levelId)
	if levelData ~= nil and levelData.bFirstComplete == false and table.indexof(self.cacheEnterLevelList, levelId) == 0 then
		bResult = true
	end
	return bResult
end
function BreakOutData:EnterLevelSelect(nLevelId)
	local levelData = ConfigTable.GetData("BreakOutLevel", nLevelId)
	if levelData == nil then
		return
	end
	local nActivityGroupId = ConfigTable.GetData("Activity", levelData.ActivityId).MidGroupId
	if table.indexof(self.cacheEnterLevelList, nLevelId) == 0 or RedDotManager.GetValid(RedDotDefine.Activity_BreakOut_DifficultyTap_Level, {nActivityGroupId, nLevelId}) then
		table.insert(self.cacheEnterLevelList, nLevelId)
		local tbLocalSave = {}
		for _, v in ipairs(self.cacheEnterLevelList) do
			table.insert(tbLocalSave, v)
		end
		RedDotManager.SetValid(RedDotDefine.Activity_BreakOut_DifficultyTap_Level, {nActivityGroupId, nLevelId}, false)
		LocalData.SetPlayerLocalData("BreakOutLevel", RapidJson.encode(tbLocalSave))
		self:RefreshRedDot()
	end
end
function BreakOutData:IsLevelUnlocked(nLevelId)
	local bTimeUnlock, bPreComplete = false, false
	local mapData = self:GetDetailLevelDataById(nLevelId)
	local curTime = CS.ClientManager.Instance.serverTimeStamp
	local openTime = CS.ClientManager.Instance:GetNextRefreshTime(self.nOpenTime) - 86400
	local remainTime = openTime + mapData.DayOpen * 86400 - curTime
	local nPreLevelId = mapData.PreLevelId or 0
	local bIsLevelComplete = self:IsLevelComplete(nPreLevelId)
	bTimeUnlock = remainTime <= 0
	bPreComplete = nPreLevelId == nil or bIsLevelComplete
	return bTimeUnlock, bPreComplete
end
function BreakOutData:IsLevelTimeUnlocked(nLevelId)
	local bTimeUnlock = false
	local remainTime = self:GetLevelStartTime(nLevelId)
	if remainTime then
		bTimeUnlock = remainTime <= 0
	end
	return bTimeUnlock
end
function BreakOutData:GetLevelStartTime(nLevelId)
	local mapData = self:GetDetailLevelDataById(nLevelId)
	if mapData == nil then
		return nil
	end
	local curTime = CS.ClientManager.Instance.serverTimeStamp
	local openTime = CS.ClientManager.Instance:GetNextRefreshTime(self.nOpenTime) - 86400
	local remainTime = openTime + mapData.DayOpen * 86400 - curTime
	return remainTime
end
function BreakOutData:IsPreLevelComplete(nLevelId)
	local nPreLevelId = ConfigTable.GetData("BreakOutLevel", nLevelId).PreLevelId
	if nPreLevelId == 0 then
		return true
	end
	return self:GetLevelDataById(nPreLevelId).bFirstComplete
end
function BreakOutData:IsLevelComplete(nLevelId)
	if nLevelId == 0 then
		return true
	end
	local nLevelData = self:GetLevelDataById(nLevelId)
	return nLevelData.bFirstComplete
end
function BreakOutData:GetUnFinishEasyLevel()
	local EasyDifficultyType = GameEnum.ActivityBreakoutLevelType.Expert
	local levelId
	for _, levelData in ipairs(self.tbLevelDataList) do
		if not levelData.bFirstComplete and EasyDifficultyType >= levelData.nDifficultyType then
			EasyDifficultyType = levelData.nDifficultyType
			levelId = levelData.nId
		end
	end
	return levelId
end
function BreakOutData:RequestFinishLevel(arrayData, cb)
	self:UpdateCharacterData({
		CharacterNid = arrayData.CharId
	})
	EventManager.Hit("SetPlayFinishState", true)
	if not arrayData.Win then
		local mapMsg = arrayData
		local failCallback = function()
			if cb ~= nil then
				cb()
			end
		end
		EventManager.Hit(EventId.ClosePanel, PanelId.BreakOutLevelDetailPanel)
		HttpNetHandler.SendMsg(NetMsgId.Id.milkout_settle_req, mapMsg, nil, failCallback)
		return
	end
	self:CreateTempData(arrayData.LevelId, arrayData.Win)
	local mapMsg = arrayData
	local successCallback = function(_, mapMainData)
		cb(mapMainData)
		self:UpdateLevelData({
			Id = arrayData.LevelId,
			FirstComplete = arrayData.Win
		})
	end
	EventManager.Hit(EventId.ClosePanel, PanelId.BreakOutLevelDetailPanel)
	HttpNetHandler.SendMsg(NetMsgId.Id.milkout_settle_req, mapMsg, nil, successCallback)
end
function BreakOutData:CreateTempData(nLevelId, bResult)
	self.tempData = {nLevelId = nLevelId, bResult = bResult}
end
function BreakOutData:GetTempData()
	return self.tempData
end
function BreakOutData:ClearTempData()
	self.tempData = nil
end
function BreakOutData:On_BreakoutCharacter_Unlock(mapMsgData)
	if self.nActId ~= mapMsgData.ActivityId then
		return
	end
	self:RefreshCharacterData(mapMsgData.CharId)
end
function BreakOutData:RefreshCharacterData(charId)
	local bIsLock = true
	for _, v in pairs(self.tbUnLockedCharacterDataList) do
		if v.Id == charId then
			bIsLock = false
			break
		end
	end
	if bIsLock then
		local CharacterData = {nId = charId, nBattleTimes = 0}
		table.insert(self.tbUnLockedCharacterDataList, CharacterData)
	end
end
function BreakOutData:OnEvent_GMClearAllLevels(mapMsgData)
	if mapMsgData ~= nil then
		self:CacheAllLevelData(mapMsgData.Levels)
	end
end
return BreakOutData
