local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local LocalData = require("GameCore.Data.LocalData")
local BreakOutData = class("BreakOutData", ActivityDataBase)
local RapidJson = require("rapidjson")
local RedDotManager = require("GameCore.RedDot.RedDotManager")
local ClientManager = CS.ClientManager.Instance
function BreakOutData:Init()
	self.allLevelData = {}
	self.cacheEnterLevelList = {}
end
function BreakOutData:RefreshBreakOutData(actId, msgData)
	self:Init()
	self.nActId = actId
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
function BreakOutData:CacheIsUnlocked(CharacterId)
	for _, v in pairs(self.tbUnLockedCharacterDataList) do
		if v.nId == CharacterId then
			return true
		end
	end
	return false
end
function BreakOutData:GetDataFromBreakOutCharacter(CharacterId)
	for _, v in pairs(self.tbUnLockedCharacterDataList) do
		if v.nId == CharacterId then
			return CacheTable.GetData("_BreakOutCharacter", CharacterId)
		end
	end
	return nil
end
function BreakOutData:GetBattleCount(CharacterId)
	for _, v in pairs(self.tbUnLockedCharacterDataList) do
		if v.nId == CharacterId then
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
function BreakOutData:GetLevelIsNew()
	local bResult = false
	local levelData = self:GetLevelData(levelId)
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
	if table.indexof(self.cacheEnterLevelList, levelId) == 0 then
		table.insert(self.cacheEnterLevelList, levelId)
		RedDotManager.SetValid(RedDotDefine.Activity_BreakOut_DifficultyTap_Level, {
			nActivityGroupId,
			levelId
		}, false)
		LocalData.SetPlayerLocalData("BreakOutLevel", RapidJson.encode(self.cacheEnterLevelList))
		self:RefreshRedDot()
	end
end
function BreakOutData:IsLevelUnlocked(nLevelId)
	local bTimeUnlock, bPreComplete = false, false
	local mapData = self:GetLevelDataById(nLevelId)
	local curTime = CS.ClientManager.Instance.serverTimeStamp
	local remainTime = curTime - (self.nOpenTime or 0 + mapData.DayOpen * 86400)
	local nPreLevelId = mapData.nPreLevelId or 0
	local bIsLevelComplete = self:IsLevelComplete(nPreLevelId)
	bTimeUnlock = 0 <= remainTime
	bPreComplete = nPreLevelId == nil or bIsLevelComplete
	return bTimeUnlock, bPreComplete
end
function BreakOutData:IsLevelTimeUnlocked(nLevelId)
	local bTimeUnlock = false
	local mapData = self:GetLevelDataById(nLevelId)
	if mapData == nil then
		return false
	end
	local curTime = CS.ClientManager.Instance.serverTimeStamp
	local remainTime = curTime - (self.nOpenTime or 0 + mapData.DayOpen * 86400)
	bTimeUnlock = 0 <= remainTime
	return bTimeUnlock
end
function BreakOutData:GetLevelStartTime(nLevelId)
	local levelConfig = ConfigTable.GetData("BreakOutLevel", nLevelId)
	if levelConfig == nil then
		return 0
	end
	local openDayNextTime = ClientManager:GetNextRefreshTime(ClientManager.serverTimeStamp)
	return openDayNextTime + (levelConfig.DayOpen - 1) * 86400
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
function BreakOutData:GetActCloseTime(nLevelId)
	local nActivityId = ConfigTable.GetData("BreakOutLevel", nLevelId).ActivityId
	nEndTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(ConfigTable.GetData("Activity", nActivityId).EndTime)
	return nEndTime
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
return BreakOutData
