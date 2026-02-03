local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local TrekkerVersusData = class("TrekkerVersusData", ActivityDataBase)
function TrekkerVersusData:Init()
	self.nActId = 0
	self.nRecord = 0
	self.nLastBuildId = 0
	self.tbRecordAffix = {}
	self.tbRecordChar = {}
	self.nRecordBuildLevel = 0
	self.nCachedBuildId = 0
	self.mapQuests = {}
	self.CachedAffixes = {}
	self.bFirstIn = true
	self.nSuccessBattle = 0
	self.nLastBattleHard = 0
end
function TrekkerVersusData:GetActivityData()
	return {
		nActId = self.nActId,
		tbRecordAffix = clone(self.tbRecordAffix),
		tbRecordChar = clone(self.tbRecordChar),
		nRecordBuildLevel = self.nRecordBuildLevel,
		nLastBuildId = self.nLastBuildId,
		nRecord = self.nRecord
	}
end
function TrekkerVersusData:RefreshTrekkerVersusData(nActId, msgData)
	self:Init()
	self.nActId = nActId
	self.nLastBuildId = msgData.BuildId
	self.nCachedBuildId = msgData.BuildId
	self.tbRecordAffix = msgData.Show.AffixIds
	self.tbRecordChar = msgData.Show.CharIds
	self.nRecordBuildLevel = msgData.Show.BuildScore
	local nRecordLevel = 0
	for _, nAffixId in ipairs(self.tbRecordAffix) do
		local mapAffixCfgData = ConfigTable.GetData("TravelerDuelChallengeAffix", nAffixId)
		if mapAffixCfgData ~= nil then
			nRecordLevel = nRecordLevel + mapAffixCfgData.Difficulty
		end
	end
	self.nRecord = nRecordLevel
	for _, mapQuest in ipairs(msgData.Quests) do
		self.mapQuests[mapQuest.Id] = mapQuest
	end
	self:RefreshQusetRedDot()
end
function TrekkerVersusData:EnterTrekkerVersus(nLevelId, nBuildId, tbAffix)
	local callback = function()
		self:SetCachedBuildId(nBuildId)
		self:EnterGame(nLevelId, nBuildId, tbAffix)
	end
	local msg = {
		ActivityId = self.nActId,
		LevelId = nLevelId,
		BuildId = nBuildId,
		AffixIds = tbAffix
	}
	HttpNetHandler.SendMsg(NetMsgId.Id.activity_trekker_versus_apply_req, msg, nil, callback)
end
function TrekkerVersusData:GetTravelerDuelAffixUnlock(nAffixId)
	local mapAffixCfgData = ConfigTable.GetData("TravelerDuelChallengeAffix", nAffixId)
	local curTimeStamp = CS.ClientManager.Instance.serverTimeStamp
	local _fixedTimeStamp = self.nOpenTime + mapAffixCfgData.UnlockDurationTime * 60
	if mapAffixCfgData.UnlockDurationTime > 0 and curTimeStamp < _fixedTimeStamp then
		local sCond = ""
		local sumTime = _fixedTimeStamp - curTimeStamp
		if 86400 < sumTime then
			sCond = orderedFormat(ConfigTable.GetUIText("TDQuest_Day"), math.floor(sumTime / 86400))
		else
			sCond = ConfigTable.GetUIText("TDQuest_LessThenDay")
		end
		return false, 4, sCond
	end
	if 0 < mapAffixCfgData.UnlockDifficulty and self.nRecord < mapAffixCfgData.UnlockDifficulty then
		return false, 3, mapAffixCfgData.UnlockDifficulty
	end
	return true, 0, 0
end
function TrekkerVersusData:GetCachedBuildId()
	return self.nCachedBuildId
end
function TrekkerVersusData:GetAllQuestData()
	local ret = {}
	for _, mapQuest in pairs(self.mapQuests) do
		table.insert(ret, mapQuest)
	end
	local statusOrder = {
		[0] = 1,
		[1] = 2,
		[2] = 0
	}
	local sort = function(a, b)
		if a.Status == b.Status then
			return a.Id < b.Id
		end
		return statusOrder[a.Status] > statusOrder[b.Status]
	end
	table.sort(ret, sort)
	return ret
end
function TrekkerVersusData:SetCachedBuildId(nBuildId)
	self.nCachedBuildId = nBuildId
end
function TrekkerVersusData:SetCacheAffixids(tbAffixes)
	if tbAffixes ~= nil then
		self.CachedAffixes = tbAffixes
	end
end
function TrekkerVersusData:GetCacheAffixids()
	return self.CachedAffixes
end
function TrekkerVersusData:EnterGame(nLevel, nBuildId, tbAffixes)
	if self.curLevel ~= nil then
		printError("\229\189\147\229\137\141\229\133\179\229\141\161level\228\184\141\228\184\186\231\169\1861")
		return
	end
	local luaClass = require("Game.Adventure.TravelerDuelLevel.TravelerDuelLevelData")
	if luaClass == nil then
		return
	end
	self.entryLevelId = nLevel
	self.curLevel = luaClass
	if type(self.curLevel.BindEvent) == "function" then
		self.curLevel:BindEvent()
	end
	if type(self.curLevel.Init) == "function" then
		self.curLevel:Init(self, nLevel, tbAffixes, nBuildId)
	end
end
function TrekkerVersusData:SettleBattle(bSuccess, nLevelId, nTime, tbAffix, nBuildId, msgCallback)
	local callback = function()
		local bNewRecord = false
		if bSuccess then
			local nRecordLevel = 0
			for _, nAffixId in ipairs(tbAffix) do
				local mapAffixCfgData = ConfigTable.GetData("TravelerDuelChallengeAffix", nAffixId)
				if mapAffixCfgData ~= nil then
					nRecordLevel = nRecordLevel + mapAffixCfgData.Difficulty
				end
			end
			if nRecordLevel >= self.nRecord then
				self.nRecord = nRecordLevel
				self.tbRecordAffix = clone(tbAffix)
				bNewRecord = true
				local buildDataCallback = function(mapBuild)
					self.nRecordBuildLevel = mapBuild.nScore
					self.tbRecordChar = {}
					for _, mapBuildChar in ipairs(mapBuild.tbChar) do
						table.insert(self.tbRecordChar, mapBuildChar.nTid)
					end
				end
				PlayerData.Build:GetBuildDetailData(buildDataCallback, nBuildId)
			end
			self.nSuccessBattle = 1
			self.nLastBattleHard = nRecordLevel
		else
			self.nSuccessBattle = -1
			local nRecordLevel = 0
			for _, nAffixId in ipairs(tbAffix) do
				local mapAffixCfgData = ConfigTable.GetData("TravelerDuelChallengeAffix", nAffixId)
				if mapAffixCfgData ~= nil then
					nRecordLevel = nRecordLevel + mapAffixCfgData.Difficulty
				end
			end
			self.nLastBattleHard = nRecordLevel
		end
		if msgCallback ~= nil then
			msgCallback(bNewRecord)
		end
	end
	local msg = {
		ActivityId = self.nActId,
		Time = nTime,
		Passed = bSuccess,
		Events = {
			List = PlayerData.Achievement:GetBattleAchievement(GameEnum.levelType.TravelerDuel, true)
		}
	}
	HttpNetHandler.SendMsg(NetMsgId.Id.activity_trekker_versus_settle_req, msg, nil, callback)
end
function TrekkerVersusData:CheckBattleSuccess()
	local retResult = self.nSuccessBattle
	local retHard = self.nLastBattleHard
	self.nSuccessBattle = 0
	self.nLastBattleHard = 0
	return retResult, retHard
end
function TrekkerVersusData:LevelEnd()
	if type(self.curLevel.UnBindEvent) == "function" then
		self.curLevel:UnBindEvent()
	end
	self.curLevel = nil
end
function TrekkerVersusData:RefreshQuestData(questData)
	self.mapQuests[questData.Id] = questData
	self:RefreshQusetRedDot()
end
function TrekkerVersusData:ReceiveQuestReward(callback)
	local bReceive = false
	for _, mapQuest in pairs(self.mapQuests) do
		if mapQuest.Status == 1 then
			bReceive = true
			break
		end
	end
	local msgCallback = function(_, msgData)
		if callback ~= nil then
			callback(msgData)
		end
		for _, mapQuest in pairs(self.mapQuests) do
			if mapQuest.Status == 1 then
				mapQuest.Status = 2
			end
		end
		self:RefreshQusetRedDot()
	end
	if bReceive then
		local msg = {
			Value = self.nActId
		}
		HttpNetHandler.SendMsg(NetMsgId.Id.activity_trekker_versus_reward_receive_req, msg, nil, msgCallback)
	else
		local sTip = ConfigTable.GetUIText("Quest_ReceiveNone")
		EventManager.Hit(EventId.OpenMessageBox, sTip)
	end
end
function TrekkerVersusData:GetTrekkerVersusCfgData()
	local mapCfgData = ConfigTable.GetData("TravelerDuelChallengeControl", self.nActId)
	return mapCfgData
end
function TrekkerVersusData:GetChallengeStartTime()
	local mapActivityData = ConfigTable.GetData("TravelerDuelChallengeControl", self.nActId)
	if mapActivityData ~= nil then
		return String2Time(mapActivityData.OpenTime)
	end
	return self.nOpenTime
end
function TrekkerVersusData:GetChallengeEndTime()
	local mapActivityData = ConfigTable.GetData("TravelerDuelChallengeControl", self.nActId)
	if mapActivityData ~= nil then
		return String2Time(mapActivityData.EndTime)
	end
	return self.nEndTime
end
function TrekkerVersusData:RefreshQusetRedDot()
	local bVisible = false
	for _, mapQuest in pairs(self.mapQuests) do
		if mapQuest.Status == 1 then
			bVisible = true
			break
		end
	end
	RedDotManager.SetValid(RedDotDefine.TrekkerVersusQuest, nil, bVisible)
	RedDotManager.SetValid(RedDotDefine.TrekkerVersusQuest_1, nil, bVisible)
end
function TrekkerVersusData:GetFirstIn()
	local bFirst = self.bFirstIn
	if self.bFirstIn == true then
		self.bFirstIn = false
	end
	return bFirst
end
return TrekkerVersusData
