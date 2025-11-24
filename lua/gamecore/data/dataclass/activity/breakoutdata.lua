local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local LocalData = require("GameCore.Data.LocalData")
local BreakOutData = class("BreakOutData", ActivityDataBase)
function BreakOutData:Init()
	self.allLevelData = {}
end
function BreakOutData:RefreshBreakOutData(actId, msgData)
	self:Init()
	self.nActId = actId
	self.mapActData = PlayerData.Activity:GetActivityDataById(self.nActId)
	if self.mapActData ~= nil then
		self.nEndTime = self.mapActData:GetActEndTime() or 0
		self.nOpenTime = self.mapActData:GetActOpenTime() or 0
	end
	if msgData ~= nil then
		self:CacheAllLevelData(msgData.Levels)
		self:CacheAllCharacterData(msgData.Characters)
	end
end
function BreakOutData:CacheAllLevelData(levelListData)
	self.tbLevelDataList = {}
	for _, v in pairs(levelListData) do
		local levelData = {
			nId = v.Id,
			bFirstComplete = v.FirstCompelete,
			nDifficultyType = ConfigTable.GetData("BreakOutLevel", v.Id).Difficulty
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
			levelData = ConfigTable.GetData("BreakOutLevel", self.nId)
			break
		end
	end
	return levelData
end
function BreakOutData:GetDetailLevelsDataByTab(nSelectedTabIndex)
	local DifficultyLevelData = {}
	for _, v in pairs(self.tbLevelDataList) do
		if v.nDifficultyType == nSelectedTabIndex then
			table.insert(DifficultyLevelData, ConfigTable.GetData("BreakOutLevel", self.nId))
		end
	end
	return DifficultyLevelData
end
function BreakOutData:IsLevelUnlocked(nLevelId)
	local bTimeUnlock, bPreComplete = false, false
	local mapData = self:GetLevelDataById(nLevelId)
	local curTime = CS.ClientManager.Instance.serverTimeStamp
	local remainTime = curTime - (self.nOpenTime or 0 + mapData.DayOpen * 86400)
	local nPreLevelId = mapData.PreLevelId or 0
	local mapLevelStatus = self:GetLevelDataById(nPreLevelId)
	bTimeUnlock = 0 <= remainTime
	bPreComplete = nPreLevelId == 0 or mapLevelStatus ~= nil and mapLevelStatus.bFirstComplete
	return bTimeUnlock, bPreComplete
end
return DifficultyLevelData
