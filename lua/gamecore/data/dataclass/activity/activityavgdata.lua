local ActivityAvgData = class("ActivityAvgData")
local File = CS.System.IO.File
local TimerManager = require("GameCore.Timer.TimerManager")
local LocalData = require("GameCore.Data.LocalData")
local RapidJson = require("rapidjson")
function ActivityAvgData:Init()
	self.tbActivityAvgList = {}
	self.tbCachedReadedActAvg = {}
	self.tbActAvgList = {}
	self.CFG_ChapterStoryNumIds = {}
	self.CFG_Story = {}
	self.CFG_StoryEvidence = {}
	self.CFG_ConditionStoryNumIds = {}
	local forEachLine_Story = function(mapLineData)
		self.CFG_Story[mapLineData.StoryId] = mapLineData.Id
		if self.CFG_ChapterStoryNumIds[mapLineData.ChapterId] == nil then
			self.CFG_ChapterStoryNumIds[mapLineData.ChapterId] = {}
		end
		if mapLineData.ConditionId ~= "" then
			if self.CFG_ConditionStoryNumIds[mapLineData.ConditionId] == nil then
				self.CFG_ConditionStoryNumIds[mapLineData.ConditionId] = {}
			end
			table.insert(self.CFG_ConditionStoryNumIds[mapLineData.ConditionId], mapLineData.Id)
		end
		table.insert(self.CFG_ChapterStoryNumIds[mapLineData.ChapterId], mapLineData.Id)
	end
	local forEachLine_StoryEvidence = function(mapLineData)
		self.CFG_StoryEvidence[mapLineData.EvId] = mapLineData.Id
	end
	ForEachTableLine(DataTable.ActivityStory, forEachLine_Story)
	ForEachTableLine(DataTable.ActivityStoryEvidence, forEachLine_StoryEvidence)
	self.tbStoryIds = {}
	self.tbTempStoryIds = {}
	self.tbEvIds = {}
	self.tbTempEvIds = {}
	self.mapChosen = {}
	self.mapTempCL = {}
	self.mapLatest = {}
	self.mapTempLatestCnt = {}
	self.mapPersonality = {}
	self.mapPersonalityFactor = {}
	self.mapTempPersonality = {}
	self.mapTempPersonalityFactor = {}
	self.mapTempPersonalityCnt = {}
	local y, n = true, false
	self.__data = {
		[0] = {
			n,
			n,
			n
		},
		[1] = {
			y,
			n,
			n
		},
		[2] = {
			n,
			y,
			n
		},
		[3] = {
			y,
			y,
			n
		},
		[4] = {
			n,
			n,
			y
		},
		[5] = {
			y,
			n,
			y
		},
		[6] = {
			n,
			y,
			y
		},
		[7] = {
			y,
			y,
			y
		}
	}
	self.CURRENT_STORY_ID = 0
	self:CacheEvData()
	EventManager.Add(EventId.UpdateWorldClass, self, self.OnEvent_UpdateWorldClass)
end
function ActivityAvgData:UnInit()
	EventManager.Remove(EventId.UpdateWorldClass, self, self.OnEvent_UpdateWorldClass)
end
function ActivityAvgData:ClearTempData()
	self.tbTempStoryIds = {}
	self.tbTempEvIds = {}
	self.mapTempCL = {}
	self.mapTempLatestCnt = {}
	self.mapTempPersonality = {}
	self.mapTempPersonalityFactor = {}
	self.mapTempPersonalityCnt = {}
	self.CURRENT_STORY_ID = 0
end
function ActivityAvgData:SafeCheck()
	if type(self.tbTempStoryIds) ~= "table" then
		return false
	end
	if #self.tbTempStoryIds <= 0 then
		return false
	end
	local _sStoryId = self.tbTempStoryIds[1]
	if type(_sStoryId) ~= "string" then
		return false
	end
	local _nStoryId = self.CFG_Story[_sStoryId]
	if type(_nStoryId) ~= "number" then
		return false
	end
	if type(self.CURRENT_STORY_ID) ~= "number" then
		return false
	end
	if _nStoryId ~= self.CURRENT_STORY_ID then
		return false
	end
	local cfgdata = ConfigTable.GetData("ActivityStory", _nStoryId)
	if cfgdata == nil then
		return false
	end
	return true
end
function ActivityAvgData:CacheAvgData(StoryInfo)
	self.tbStoryIds = {}
	self.tbTempStoryIds = {}
	self.tbEvIds = {}
	self.tbTempEvIds = {}
	self.mapChosen = {}
	self.mapTempCL = {}
	self.mapLatest = {}
	self.mapTempLatestCnt = {}
	self.mapPersonality = {}
	self.mapTempPersonality = {}
	self.mapPersonalityFactor = {}
	self.mapTempPersonalityFactor = {}
	self.mapTempPersonalityCnt = {}
	if StoryInfo == nil then
		return
	end
	if StoryInfo.BuildId then
		self:SetSelBuildId(StoryInfo.BuildId)
	end
	for i, nEvId in ipairs(StoryInfo.Evidences) do
		local cfgData_Evidence = ConfigTable.GetData("ActivityStoryEvidence", nEvId)
		if cfgData_Evidence ~= nil then
			local sEvid = cfgData_Evidence.EvId
			if table.indexof(self.tbEvIds, sEvid) <= 0 then
				table.insert(self.tbEvIds, sEvid)
			end
		end
	end
	local func_Parse = function(uint32Value, nType)
		if nType == 1 then
			return uint32Value & 15
		elseif nType == 2 then
			return (uint32Value & 240) >> 4
		elseif nType == 3 then
			return (uint32Value & 3840) >> 8
		else
			return 0
		end
	end
	for _, Story in pairs(StoryInfo.Stories) do
		local mapCfgDataStory = ConfigTable.GetData("ActivityStory", Story.Id)
		if mapCfgDataStory == nil then
			printError("Stroy Cfg Missing:" .. Story.Id)
		else
			table.insert(self.tbStoryIds, mapCfgDataStory.StoryId)
			local sAvgId = mapCfgDataStory.AvgLuaName
			for __, StoryChoice in pairs(Story.Major) do
				if self.mapChosen[sAvgId] == nil then
					self.mapChosen[sAvgId] = {}
				end
				if self.mapLatest[sAvgId] == nil then
					self.mapLatest[sAvgId] = {}
				end
				self.mapChosen[sAvgId][StoryChoice.Group] = func_Parse(StoryChoice.Value, 1)
				self.mapLatest[sAvgId][StoryChoice.Group] = func_Parse(StoryChoice.Value, 2)
			end
			for __, StoryChoice in pairs(Story.Personality) do
				if self.mapPersonality[sAvgId] == nil then
					self.mapPersonality[sAvgId] = {}
				end
				if self.mapPersonalityFactor[sAvgId] == nil then
					self.mapPersonalityFactor[sAvgId] = {}
				end
				self.mapPersonality[sAvgId][StoryChoice.Group] = func_Parse(StoryChoice.Value, 2)
				self.mapPersonalityFactor[sAvgId][StoryChoice.Group] = func_Parse(StoryChoice.Value, 3)
			end
		end
	end
	self.mapRecentStoryId = decodeJson(LocalData.GetPlayerLocalData("ActivityRecentStoryId")) or {}
	self:RefreshAvgRedDot()
end
function ActivityAvgData:GetChapterIdByActivityId(activityId)
	local chapterId
	local forEachLine_ActivityStoryChapter = function(mapLineData)
		if mapLineData.ActivityId == activityId then
			chapterId = mapLineData.Id
		end
	end
	ForEachTableLine(ConfigTable.Get("ActivityStoryChapter"), forEachLine_ActivityStoryChapter)
	return chapterId
end
function ActivityAvgData:GetChapterStoryNumIds(nChapterId)
	return self.CFG_ChapterStoryNumIds[nChapterId]
end
function ActivityAvgData:GetStoryCfgData(storyId)
	local nId = self.CFG_Story[storyId]
	return ConfigTable.GetData("ActivityStory", nId)
end
function ActivityAvgData:AvgLuaNameToStoryId(sAvgId)
	local nId, storyId
	for k, v in pairs(self.CFG_Story) do
		local data = ConfigTable.GetData("ActivityStory", v)
		if data.AvgLuaName == sAvgId then
			nId = data.Id
			storyId = data.StoryId
			break
		end
	end
	return nId, storyId
end
function ActivityAvgData:CheckIfTrue(bIsMajor, sAvgId, nGroupId, nIndex, nCheckount)
	local n, sCheckTarget = self:AvgLuaNameToStoryId(sAvgId)
	if table.indexof(self.tbTempStoryIds, sCheckTarget) > 0 then
		return self:CheckIfTrue_Client(bIsMajor, sAvgId, nGroupId, nIndex, nCheckount)
	else
		return self:CheckIfTrue_Srv(bIsMajor, sAvgId, nGroupId, nIndex)
	end
end
function ActivityAvgData:CheckIfTrue_Srv(bIsMajor, sAvgId, nGroupId, nIndex)
	local mapData = bIsMajor == true and self.mapLatest or self.mapPersonality
	local mapA = mapData[sAvgId]
	if mapA == nil then
		return false
	end
	local nLatestChosenIndex = mapA[nGroupId]
	if nLatestChosenIndex == nil then
		return false
	end
	return nIndex == nLatestChosenIndex
end
function ActivityAvgData:CheckIfTrue_Client(bIsMajor, sAvgId, nGroupId, nIndex, nCheckount)
	local mapData = bIsMajor == true and self.mapTempLatestCnt or self.mapTempPersonalityCnt
	local mapA = mapData[sAvgId]
	if mapA == nil then
		return false
	end
	mapA = mapA[nGroupId]
	if mapA == nil then
		return false
	end
	local nCount = mapA[nIndex] or 0
	return nCheckount <= nCount
end
function ActivityAvgData:IsUnlock(nConditionIntId)
	if type(nConditionIntId) == "string" and nConditionIntId == "" then
		return true
	end
	local cfgData = ConfigTable.GetData("ActivityStoryCondition", nConditionIntId)
	if cfgData == nil then
		printError("Avg\230\149\176\230\141\174\229\136\164\230\150\173\230\152\175\229\144\166\232\167\163\233\148\129\230\151\182\239\188\140\228\188\160\228\186\134\228\184\128\228\184\170excel\232\161\168\233\135\140\230\178\161\230\156\137\231\154\132 number id:" .. tostring(nConditionIntId))
		return false
	end
	local func_Check = function(tbRequire, tbPlayerData, tbPlayerTempData, bMust)
		if tbRequire == nil then
			return true
		end
		if #tbRequire <= 0 then
			return true
		end
		local bCheckResult, bCheckTempResult, tbCheckResultInfo = bMust, bMust, {}
		for i, v in ipairs(tbRequire) do
			local _b = 0 < table.indexof(tbPlayerData, v)
			if bMust == true then
				bCheckResult = bCheckResult == true and _b == true
			else
				bCheckResult = bCheckResult == true or _b == true
			end
			tbCheckResultInfo[v] = _b
		end
		if bCheckResult == false then
			for i, v in ipairs(tbRequire) do
				if tbCheckResultInfo[v] ~= true then
					local _b = 0 < table.indexof(tbPlayerTempData, v)
					if bMust == true then
						bCheckTempResult = bCheckTempResult == true and _b == true
					else
						bCheckTempResult = bCheckTempResult == true or _b == true
					end
					tbCheckResultInfo[v] = _b
				end
			end
			return bCheckTempResult, tbCheckResultInfo
		else
			return bCheckResult, tbCheckResultInfo
		end
	end
	local tbRequire = {}
	local tbPlayerTempData = {}
	for _, v in ipairs(self.tbEvIds) do
		table.insert(tbRequire, self.CFG_StoryEvidence[v])
	end
	for _, v in ipairs(self.tbTempEvIds) do
		table.insert(tbPlayerTempData, self.CFG_StoryEvidence[v])
	end
	local bMustEvIds, mapMustEvIds = func_Check(cfgData.EvIds_a, tbRequire, tbPlayerTempData, true)
	local bOneOfEvIds, mapOneOfEvIds = func_Check(cfgData.EvIds_b, tbRequire, tbPlayerTempData, false)
	tbRequire = {}
	tbPlayerTempData = {}
	for _, v in ipairs(self.tbStoryIds) do
		table.insert(tbRequire, self.CFG_Story[v])
	end
	for _, v in ipairs(self.tbTempStoryIds) do
		table.insert(tbPlayerTempData, self.CFG_Story[v])
	end
	local bMustStoryIds, mapMustStoryIds = func_Check(cfgData.ActivityStoryId_a, tbRequire, tbPlayerTempData, true)
	local bOneOfStoryIds, mapOneOfStoryIds = func_Check(cfgData.ActivityStoryId_b, tbRequire, tbPlayerTempData, false)
	local nNeedWorldLevel = cfgData.PlayerWorldLevel or 0
	local bNeedLv = nNeedWorldLevel <= PlayerData.Base:GetWorldClass()
	local bMustAchievementIds, mapAchieveInfo = PlayerData.Achievement:CheckAchieveIds(cfgData.AchieveIds)
	local activityId = cfgData.ActivityLevel[1] or 0
	local mustLevelId = cfgData.ActivityLevel[2] or 0
	local levelData = PlayerData.Activity:GetActivityDataById(activityId)
	local bMustActivityLevel = true
	if levelData ~= nil then
		bMustActivityLevel = levelData:GetLevelFirstPassNoneType(mustLevelId)
	end
	local tbResult = {
		{bMustStoryIds, mapMustStoryIds},
		{bOneOfStoryIds, mapOneOfStoryIds},
		{bMustEvIds, mapMustEvIds},
		{bOneOfEvIds, mapOneOfEvIds},
		{bNeedLv, nNeedWorldLevel},
		{bMustAchievementIds, mapAchieveInfo},
		{bMustActivityLevel, mustLevelId}
	}
	local bResult = bMustEvIds == true and bOneOfEvIds == true and bMustStoryIds == true and bOneOfStoryIds == true and bNeedLv == true and bMustAchievementIds == true and bMustActivityLevel == true
	return bResult, tbResult
end
function ActivityAvgData:IsOpen(sAvgId)
	local cfg = self:GetStoryCfgData(sAvgId)
	local chapterConfig = ConfigTable.GetData("ActivityStoryChapter", cfg.ChapterId)
	local activityId = chapterConfig.ActivityId
	local nOpenTime = 0
	if self.tbActAvgList[activityId] ~= nil then
		nOpenTime = self.tbActAvgList[activityId].nOpenTime
	end
	nOpenTime = CS.ClientManager.Instance:GetNextRefreshTime(nOpenTime) - 86400
	local curTime = CS.ClientManager.Instance.serverTimeStamp
	local days = math.floor((curTime - nOpenTime) / 86400)
	return days >= cfg.DayOpen, nOpenTime
end
function ActivityAvgData:MarkStoryId(sAvgId)
	if AVG_EDITOR == true then
	elseif type(self.CURRENT_STORY_ID) == "number" then
		local cfgdata = ConfigTable.GetData("ActivityStory", self.CURRENT_STORY_ID)
		if cfgdata == nil then
			return
		end
	else
		return
	end
	local nId, storyId = self:AvgLuaNameToStoryId(sAvgId)
	if storyId == nil then
		return
	end
	if table.indexof(self.tbTempStoryIds, storyId) <= 0 then
		table.insert(self.tbTempStoryIds, storyId)
	end
end
function ActivityAvgData:MarkEvId(sId)
	if table.indexof(self.tbTempEvIds, sId) <= 0 and 0 >= table.indexof(self.tbEvIds, sId) then
		table.insert(self.tbTempEvIds, sId)
	end
end
function ActivityAvgData:IsChosen(sAvgId, nGroupId, nIndex)
	if self.mapChosen[sAvgId] == nil then
		return false
	end
	if self.mapChosen[sAvgId][nGroupId] == nil then
		return false
	end
	local nCurrent = self.mapChosen[sAvgId][nGroupId]
	local bIsChosen = self.__data[nCurrent][nIndex]
	if self.mapTempCL[sAvgId] == nil then
		self.mapTempCL[sAvgId] = {}
	end
	if self.mapTempCL[sAvgId][nGroupId] == nil then
		self.mapTempCL[sAvgId][nGroupId] = {}
	end
	local bIsChosen_Temp = table.indexof(self.mapTempCL[sAvgId][nGroupId], nIndex) > 0
	return bIsChosen, bIsChosen_Temp
end
function ActivityAvgData:MarkChosen(sAvgId, nGroupId, nIndex)
	if self.mapTempCL[sAvgId] == nil then
		self.mapTempCL[sAvgId] = {}
	end
	if self.mapTempCL[sAvgId][nGroupId] == nil then
		self.mapTempCL[sAvgId][nGroupId] = {}
	end
	local nTableIndex = table.indexof(self.mapTempCL[sAvgId][nGroupId], nIndex)
	if 0 < nTableIndex then
		table.remove(self.mapTempCL[sAvgId][nGroupId], nTableIndex)
	end
	table.insert(self.mapTempCL[sAvgId][nGroupId], nIndex)
	if self.mapTempLatestCnt[sAvgId] == nil then
		self.mapTempLatestCnt[sAvgId] = {}
	end
	if self.mapTempLatestCnt[sAvgId][nGroupId] == nil then
		self.mapTempLatestCnt[sAvgId][nGroupId] = {}
	end
	local nCurCnt = self.mapTempLatestCnt[sAvgId][nGroupId][nIndex] or 0
	nCurCnt = nCurCnt + 1
	self.mapTempLatestCnt[sAvgId][nGroupId][nIndex] = nCurCnt
end
function ActivityAvgData:IsEvidenceUnlock(evidenceId)
	for k, v in ipairs(self.tbEvIds) do
		if v == evidenceId then
			return true
		end
	end
	return false
end
function ActivityAvgData:IsStoryReaded(nStoryId)
	local cfgData = ConfigTable.GetData("ActivityStory", nStoryId)
	if cfgData == nil then
		return false
	end
	if table.indexof(self.tbStoryIds, cfgData.StoryId) > 0 or 0 < table.indexof(self.tbTempStoryIds, cfgData.StoryId) then
		return true
	end
	return false
end
function ActivityAvgData:GetHistoryChoosedPersonality(sAvgId, nGroupId)
	if self.mapPersonality[sAvgId] == nil then
		return nil
	end
	if self.mapPersonality[sAvgId][nGroupId] == nil then
		return nil
	end
	local nValue = self.mapPersonality[sAvgId][nGroupId]
	local tbData = self.__data[nValue]
	for i, v in ipairs(tbData) do
		if v == true then
			return i
		end
	end
	return 0
end
function ActivityAvgData:MarkChoosedPersonality(sAvgId, nGroupId, nIndex, nFactor)
	if self.mapTempPersonality[sAvgId] == nil then
		self.mapTempPersonality[sAvgId] = {}
	end
	if self.mapTempPersonalityFactor[sAvgId] == nil then
		self.mapTempPersonalityFactor[sAvgId] = {}
	end
	local n = 0
	if nIndex == 1 then
		n = 1
	elseif nIndex == 2 then
		n = 2
	elseif nIndex == 3 then
		n = 4
	end
	self.mapTempPersonality[sAvgId][nGroupId] = n
	self.mapTempPersonalityFactor[sAvgId][nGroupId] = nFactor
	if self.mapTempPersonalityCnt[sAvgId] == nil then
		self.mapTempPersonalityCnt[sAvgId] = {}
	end
	if self.mapTempPersonalityCnt[sAvgId][nGroupId] == nil then
		self.mapTempPersonalityCnt[sAvgId][nGroupId] = {}
	end
	local nCurCnt = self.mapTempPersonalityCnt[sAvgId][nGroupId][nIndex] or 0
	nCurCnt = nCurCnt + 1
	self.mapTempPersonalityCnt[sAvgId][nGroupId][nIndex] = nCurCnt
end
function ActivityAvgData:CalcPersonality(nId)
	local cfgData_SRP = ConfigTable.GetData("StoryRolePersonality", nId)
	local tbPersonalityBaseNum = cfgData_SRP.BaseValue
	local nTotalCount = tbPersonalityBaseNum[1] + tbPersonalityBaseNum[2] + tbPersonalityBaseNum[3]
	local tbPData = {
		{
			nIndex = 1,
			nCount = tbPersonalityBaseNum[1],
			nPercent = 0
		},
		{
			nIndex = 2,
			nCount = tbPersonalityBaseNum[2],
			nPercent = 0
		},
		{
			nIndex = 3,
			nCount = tbPersonalityBaseNum[3],
			nPercent = 0
		}
	}
	local tbPersonality = self.mapPersonality
	local tbPersonalityFactor = self.mapPersonalityFactor
	local nFactor = 1
	for sAvgId, v in pairs(tbPersonality) do
		for nGroupId, vv in pairs(v) do
			nFactor = 1
			if tbPersonalityFactor[sAvgId] ~= nil then
				nFactor = tbPersonalityFactor[sAvgId][nGroupId] or 1
			end
			nTotalCount = nTotalCount + nFactor
			local _idx = vv
			if _idx == 4 then
				_idx = 3
			end
			tbPData[_idx].nCount = tbPData[_idx].nCount + nFactor
		end
	end
	for i, v in ipairs(tbPData) do
		tbPData[i].nPercent = tbPData[i].nCount / nTotalCount
	end
	local tbRetPercent = {
		tbPData[1].nPercent,
		tbPData[2].nPercent,
		tbPData[3].nPercent
	}
	local sTitle, sFace, sHead
	table.sort(tbPData, function(a, b)
		return a.nCount > b.nCount
	end)
	local nMaxIndex = tbPData[1].nIndex
	local nMaxPercent = tbPData[1].nPercent
	if 0.9 <= nMaxPercent then
		local tbTitle = {
			cfgData_SRP.Amax,
			cfgData_SRP.Bmax,
			cfgData_SRP.Cmax
		}
		local tbFace = {
			cfgData_SRP.AmaxFace,
			cfgData_SRP.BmaxFace,
			cfgData_SRP.CmaxFace
		}
		local tbHead = {
			cfgData_SRP.AmaxHead,
			cfgData_SRP.BmaxHead,
			cfgData_SRP.CmaxHead
		}
		sTitle = tbTitle[nMaxIndex]
		sFace = tbFace[nMaxIndex]
		sHead = tbHead[nMaxIndex]
	elseif 0.5 <= nMaxPercent then
		local tbTitle = {
			cfgData_SRP.Aplus,
			cfgData_SRP.Bplus,
			cfgData_SRP.Cplus
		}
		local tbFace = {
			cfgData_SRP.AplusFace,
			cfgData_SRP.BplusFace,
			cfgData_SRP.CplusFace
		}
		local tbHead = {
			cfgData_SRP.AplusHead,
			cfgData_SRP.BplusHead,
			cfgData_SRP.CplusHead
		}
		sTitle = tbTitle[nMaxIndex]
		sFace = tbFace[nMaxIndex]
		sHead = tbHead[nMaxIndex]
	elseif math.abs(tbPData[2].nPercent - tbPData[3].nPercent) < 0.1 then
		sTitle = cfgData_SRP.Normal
		sFace = cfgData_SRP.NormalFace
		sHead = cfgData_SRP.NormalHead
	else
		local tbTitleFace = {
			{
				tbIdxs = {1, 2},
				sTitle = cfgData_SRP.Ab,
				sFace = cfgData_SRP.AbFace,
				sHead = cfgData_SRP.AbHead
			},
			{
				tbIdxs = {1, 3},
				sTitle = cfgData_SRP.Ac,
				sFace = cfgData_SRP.AcFace,
				sHead = cfgData_SRP.AcHead
			},
			{
				tbIdxs = {2, 3},
				sTitle = cfgData_SRP.Bc,
				sFace = cfgData_SRP.BcFace,
				sHead = cfgData_SRP.BcHead
			}
		}
		local nBiggerIndex = tbPData[2].nIndex
		for i, v in ipairs(tbTitleFace) do
			if 0 < table.indexof(v.tbIdxs, nMaxIndex) and 0 < table.indexof(v.tbIdxs, nBiggerIndex) then
				sTitle = v.sTitle
				sFace = v.sFace
				sHead = v.sHead
				break
			end
		end
	end
	return tbRetPercent, sTitle, sFace, tbPData, nTotalCount, sHead
end
function ActivityAvgData:SetSelBuildId(nBuildId)
	self.selBuildId = nBuildId
end
function ActivityAvgData:GetCachedBuildId()
	return self.selBuildId
end
function ActivityAvgData:ParseConfig()
	self.tbFirstNode = {}
	local foreachActivityAvgLevel = function(mapData)
		if self.tbActivityAvgList[mapData.ActivityId] == nil then
			self.tbActivityAvgList[mapData.ActivityId] = {}
		end
		if mapData.PreLevelId == 0 then
			self.tbFirstNode[mapData.ActivityId] = mapData.Id
		end
		table.insert(self.tbActivityAvgList[mapData.ActivityId], mapData.Id)
	end
	ForEachTableLine(ConfigTable.Get("ActivityAvgLevel"), foreachActivityAvgLevel)
end
function ActivityAvgData:CacheActivityAvgData(msgData)
	if self.tbActAvgList[msgData.Id] == nil then
		self.tbActAvgList[msgData.Id] = {}
	end
	self.tbActAvgList[msgData.Id].nOpenTime = msgData.StartTime
	self.tbActAvgList[msgData.Id].nEndTime = msgData.EndTime
end
function ActivityAvgData:RefreshActivityAvgData(nActId, msgData)
	self.tbCachedReadedActAvg[nActId] = {}
	for _, avgId in ipairs(msgData.RewardIds) do
		table.insert(self.tbCachedReadedActAvg[nActId], avgId)
	end
	self:RefreshAvgRedDot()
end
function ActivityAvgData:GetStoryIdListByActivityId(activityId)
	if self.tbActivityAvgList[activityId] == nil then
		return {}
	end
	local list = self:SortStoryList(activityId)
	return list
end
function ActivityAvgData:SortStoryList(activityId)
	local list = self.tbActivityAvgList[activityId]
	if self.tbFirstNode[activityId] == nil then
		return list
	end
	local sortedList = {}
	table.insert(sortedList, self.tbFirstNode[activityId])
	for i = 2, #list do
		for _, storyId in ipairs(list) do
			local cfg = ConfigTable.GetData("ActivityAvgLevel", storyId)
			if cfg.PreLevelId == sortedList[i - 1] then
				table.insert(sortedList, storyId)
				break
			end
		end
	end
	self.tbActivityAvgList[activityId] = sortedList
	self.tbFirstNode[activityId] = nil
	return sortedList
end
function ActivityAvgData:IsActivityAvgReaded(activityId, storyId)
	if self.tbCachedReadedActAvg[activityId] == nil then
		return false
	end
	for _, avgId in ipairs(self.tbCachedReadedActAvg[activityId]) do
		if avgId == storyId then
			return true
		end
	end
	return false
end
function ActivityAvgData:HasActivityData(activityId)
	return self.tbActAvgList[activityId] ~= nil
end
function ActivityAvgData:IsActivityAvgUnlock(activityId, storyId)
	if self.tbActAvgList[activityId] == nil then
		return false
	end
	local cfg = ConfigTable.GetData("ActivityAvgLevel", storyId)
	local isPreReaded = self:IsActivityAvgReaded(activityId, cfg.PreLevelId) or cfg.PreLevelId == 0
	local nOpenTime = self.tbActAvgList[activityId].nOpenTime
	nOpenTime = CS.ClientManager.Instance:GetNextRefreshTime(nOpenTime) - 86400
	local curTime = CS.ClientManager.Instance.serverTimeStamp
	local days = math.floor((curTime - nOpenTime) / 86400)
	return days >= cfg.DayOpen, isPreReaded, nOpenTime
end
function ActivityAvgData:GetActivityOpenTime(activityId)
	if self.tbActAvgList[activityId] == nil then
		return 0
	end
	return self.tbActAvgList[activityId].nOpenTime, self.tbActAvgList[activityId].nEndTime
end
function ActivityAvgData:IsNew(activityId, storyId)
	local isTimeUnlock, isPreReaded, nOpenTime = self:IsActivityAvgUnlock(activityId, storyId)
	if not isTimeUnlock or not isPreReaded then
		return false
	end
	if self:IsActivityAvgReaded(activityId, storyId) then
		return false
	end
	return true
end
function ActivityAvgData:GetRecentAcvitityIndex(activityId)
	local list = self:GetStoryIdListByActivityId(activityId)
	if list == nil then
		return 0
	end
	for i = 1, #list do
		if not self:IsActivityAvgReaded(activityId, list[i]) then
			return i
		end
	end
	return 1
end
function ActivityAvgData:RefreshAvgRedDot()
	local tbActGroupRedDot = {}
	for k, v in pairs(self.CFG_ChapterStoryNumIds) do
		local chapterCfg = ConfigTable.GetData("ActivityStoryChapter", k)
		local actId = chapterCfg.ActivityId
		for _, storyId in pairs(v) do
			local bInActGroup, nActGroupId = PlayerData.Activity:IsActivityInActivityGroup(actId)
			if bInActGroup then
				if tbActGroupRedDot[nActGroupId] == nil then
					tbActGroupRedDot[nActGroupId] = false
				end
				local cfg = ConfigTable.GetData("ActivityStory", storyId)
				local isUnlock = self:IsUnlock(cfg.ConditionId)
				local isClicked = LocalData.GetPlayerLocalData("Act_Story_New" .. actId .. storyId) == true
				local isNew = self:IsStoryReaded(storyId) == false
				local curTime = CS.ClientManager.Instance.serverTimeStamp
				local _ActAvg = self.tbActAvgList[actId]
				local isOpen = false
				if _ActAvg ~= nil then
					isOpen = self:IsOpen(cfg.StoryId)
				end
				local actGroupData = PlayerData.Activity:GetActivityGroupDataById(nActGroupId)
				local bActGroupUnlock = actGroupData:IsUnlock()
				local bNew = isUnlock and isNew and not isClicked and isOpen and bActGroupUnlock
				if bNew == true then
					tbActGroupRedDot[nActGroupId] = true
				end
				RedDotManager.SetValid(RedDotDefine.Activity_GroupNew_Avg_Group, {
					nActGroupId,
					actId,
					storyId
				}, bNew)
			end
		end
	end
	for nActGroupId, bRedDot in pairs(tbActGroupRedDot) do
		RedDotManager.SetValid(RedDotDefine.Activity_GroupNew, {nActGroupId}, bRedDot)
	end
	EventManager.Hit("RefreshActivityGroupRedDot")
end
function ActivityAvgData:EnterAvg(avgId, actId)
	self.CURRENT_STORY_ID = avgId
	self.CURRENT_ACTIVITY_ID = actId
	local mapCfgData_Story = ConfigTable.GetData("ActivityAvgLevel", avgId)
	if NovaAPI.IsEditorPlatform() == true then
		local nLanIdx = GetLanguageIndex(Settings.sCurrentTxtLanguage)
		local sRequireRootPath = GetAvgLuaRequireRoot(nLanIdx) .. "Config/"
		local filePath = NovaAPI.ApplicationDataPath .. "/../Lua/" .. sRequireRootPath .. mapCfgData_Story.StoryId .. ".lua"
		if not File.Exists(filePath) then
			EventManager.Hit(EventId.OpenMessageBox, "\230\137\190\228\184\141\229\136\176AVG\233\133\141\231\189\174\230\150\135\228\187\182,\232\175\183\230\163\128\230\159\165\233\133\141\231\189\174\232\161\168\239\188\129\239\188\140Avg\229\144\141\239\188\154" .. mapCfgData_Story.StoryId)
			printError("\230\137\190\228\184\141\229\136\176AVG\233\133\141\231\189\174\230\150\135\228\187\182,\232\175\183\230\163\128\230\159\165\233\133\141\231\189\174\232\161\168\239\188\129\239\188\140Avg\229\144\141\239\188\154" .. mapCfgData_Story.StoryId)
			return
		end
	end
	printLog("\232\191\155AVG\230\188\148\229\135\186\228\186\134 " .. mapCfgData_Story.StoryId)
	EventManager.Add("StoryDialog_DialogEnd", self, self.OnEvent_AvgSTEnd)
	EventManager.Hit("StoryDialog_DialogStart", mapCfgData_Story.StoryId)
end
function ActivityAvgData:CacheEvData()
	self.tbEvData = {}
	local forEachLine_Story = function(storConfig)
		local nConditionId = storConfig.ConditionId
		local mapConditionData = ConfigTable.GetData("ActivityStoryCondition", nConditionId)
		local tbEvIds = {}
		if #mapConditionData.EvIds_a > 0 then
			for k, v in ipairs(mapConditionData.EvIds_a) do
				table.insert(tbEvIds, v)
			end
		end
		if 0 < #mapConditionData.EvIds_b then
			for k, v in ipairs(mapConditionData.EvIds_b) do
				table.insert(tbEvIds, v)
			end
		end
		if #tbEvIds == 0 then
			return
		end
		for i, v in ipairs(tbEvIds) do
			if self.tbEvData[v] == nil then
				self.tbEvData[v] = {}
			end
			table.insert(self.tbEvData[v], storConfig.StoryId)
		end
	end
	ForEachTableLine(DataTable.ActivityStory, forEachLine_Story)
end
function ActivityAvgData:SendMsg_STORY_ENTER(nActivityId, nStoryId, nBuildId, bNewestStory)
	if type(nStoryId) == "string" then
		nStoryId = self.CFG_Story[nStoryId]
		if type(nStoryId) ~= "number" then
			return
		end
	end
	if type(nStoryId) == "number" then
		local cfgdata = ConfigTable.GetData("ActivityStory", nStoryId)
		if cfgdata == nil then
			return
		end
	else
		return
	end
	if nBuildId == nil then
		nBuildId = 0
	end
	local func_cb = function()
		self:ClearTempData()
		if bNewestStory == true then
			self:SetRecentStoryId(nStoryId)
		end
		if nBuildId ~= 0 then
			self.selBuildId = nBuildId
		end
		self.CURRENT_STORY_ID = nStoryId
		local mapCfgData_Story = ConfigTable.GetData("ActivityStory", nStoryId)
		if mapCfgData_Story.IsBattle == true then
			local luaClass = require("Game.Adventure.Story.StoryLevel")
			if luaClass == nil then
				return
			end
			self.curLevel = luaClass
			if type(self.curLevel.BindEvent) == "function" then
				self.curLevel:BindEvent()
			end
			if type(self.curLevel.Init) == "function" then
				self.curLevel:Init(self, nStoryId, nBuildId, true)
			end
			printLog("\232\191\155\230\136\152\230\150\151\229\133\179\229\141\161\228\186\134")
		else
			if NovaAPI.IsEditorPlatform() == true then
				local nLanIdx = GetLanguageIndex(Settings.sCurrentTxtLanguage)
				local sRequireRootPath = GetAvgLuaRequireRoot(nLanIdx) .. "Config/"
				local filePath = NovaAPI.ApplicationDataPath .. "/../Lua/" .. sRequireRootPath .. mapCfgData_Story.AvgLuaName .. ".lua"
				if not File.Exists(filePath) then
					EventManager.Hit(EventId.OpenMessageBox, "\230\137\190\228\184\141\229\136\176AVG\233\133\141\231\189\174\230\150\135\228\187\182,\232\175\183\230\163\128\230\159\165\233\133\141\231\189\174\232\161\168\239\188\129\239\188\140Avg\229\144\141\239\188\154" .. mapCfgData_Story.AvgLuaName)
					printError("\230\137\190\228\184\141\229\136\176AVG\233\133\141\231\189\174\230\150\135\228\187\182,\232\175\183\230\163\128\230\159\165\233\133\141\231\189\174\232\161\168\239\188\129\239\188\140Avg\229\144\141\239\188\154" .. mapCfgData_Story.AvgLuaName)
					return
				end
			end
			printLog("\232\191\155AVG\230\188\148\229\135\186\228\186\134 " .. mapCfgData_Story.AvgLuaName)
			EventManager.Add("AvgSTEnd", self, self.OnEvent_AvgSTEnd)
			EventManager.Hit("StoryDialog_DialogStart", mapCfgData_Story.AvgLuaName, nil, nil, nil, nil, mapCfgData_Story.AvgMotion)
		end
		PlayerData.Avg:ChangeActivityAvgState(true)
	end
	HttpNetHandler.SendMsg(NetMsgId.Id.activity_story_apply_req, {
		ActivityId = nActivityId,
		StoryId = nStoryId,
		BuildId = nBuildId
	}, nil, func_cb)
	self.CURRENT_ACTIVITY_ID = nActivityId
end
function ActivityAvgData:SendMsg_STORY_DONE(callBack, tbBattleEvents)
	local mapSendMsgData = {
		ActivityId = self.CURRENT_ACTIVITY_ID,
		List = {},
		Evidences = {},
		Events = tbBattleEvents == nil and {
			List = {}
		} or tbBattleEvents
	}
	local mapStoryCfg = ConfigTable.GetData("ActivityStory", self.CURRENT_STORY_ID)
	local bBattle = mapStoryCfg.IsBattle
	if bBattle then
		mapSendMsgData.List[1] = {
			StoryId = self.CURRENT_STORY_ID
		}
		if table.indexof(self.tbTempStoryIds, mapStoryCfg.StoryId) <= 0 then
			table.insert(self.tbTempStoryIds, mapStoryCfg.StoryId)
		end
	else
		if self:SafeCheck() ~= true then
			self:ClearTempData()
			local sErrorLog = "error:"
			for i, v in ipairs(self.tbTempStoryIds) do
				sErrorLog = sErrorLog .. tostring(v) .. ","
			end
			sErrorLog = sErrorLog .. tostring(self.CURRENT_STORY_ID)
			printError(sErrorLog)
			local msg = {
				nType = AllEnum.MessageBox.Desc,
				sContent = sErrorLog,
				callbackConfirm = nil,
				bBlur = false
			}
			EventManager.Hit(EventId.OpenMessageBox, msg)
			return
		end
		if #self.tbTempStoryIds > 0 then
			for i, sStoryId in ipairs(self.tbTempStoryIds) do
				local nStoryId = self.CFG_Story[sStoryId]
				mapSendMsgData.List[i] = {
					StoryId = nStoryId,
					Major = {},
					Personality = {}
				}
				local mapStoryCfg = ConfigTable.GetData("ActivityStory", nStoryId)
				if mapStoryCfg ~= nil then
					local sAvgId = mapStoryCfg.AvgLuaName
					local mapGroupData = self.mapTempCL[sAvgId]
					if mapGroupData ~= nil then
						for nGroupId, tbChosen in pairs(mapGroupData) do
							for _, nChoiceIndex in ipairs(tbChosen) do
								local n = 0
								if nChoiceIndex == 1 then
									n = 1
								elseif nChoiceIndex == 2 then
									n = 2
								elseif nChoiceIndex == 3 then
									n = 4
								end
								table.insert(mapSendMsgData.List[i].Major, {
									Group = nGroupId,
									Choice = n,
									Factor = 0
								})
							end
						end
					end
					mapGroupData = self.mapTempPersonality[sAvgId]
					if mapGroupData ~= nil then
						for nGroupId, nLatest in pairs(mapGroupData) do
							local nFactor = 0
							if self.mapTempPersonalityFactor[sAvgId] ~= nil then
								nFactor = self.mapTempPersonalityFactor[sAvgId][nGroupId] or 0
							end
							table.insert(mapSendMsgData.List[i].Personality, {
								Group = nGroupId,
								Choice = nLatest,
								Factor = nFactor
							})
						end
					end
				end
			end
		end
		if 0 < #self.tbTempEvIds then
			for _, sEvId in ipairs(self.tbTempEvIds) do
				table.insert(mapSendMsgData.Evidences, self.CFG_StoryEvidence[sEvId])
			end
		end
		local tbPassId = {}
		for _, v in ipairs(mapSendMsgData.List) do
			table.insert(tbPassId, v.StoryId)
		end
		PlayerData.Char:StoryPass(tbPassId)
	end
	local func_merge = function(tbSrc, tbTarget)
		for i, v in ipairs(tbSrc) do
			if table.indexof(tbTarget, v) <= 0 then
				table.insert(tbTarget, v)
			end
		end
	end
	local func_overwrite = function(tbSrc, tbTarget)
		for sAvgId, v in pairs(tbSrc) do
			if tbTarget[sAvgId] == nil then
				tbTarget[sAvgId] = {}
			end
			for nGroupId, vv in pairs(v) do
				tbTarget[sAvgId][nGroupId] = vv
			end
		end
	end
	local eventStoryId = self.CURRENT_STORY_ID
	local func_succ = function(_, mapChangeInfo)
		if #self.tbTempStoryIds > 1 then
			local nRecentChapterId = self.CFG_Story[self.tbTempStoryIds[#self.tbTempStoryIds]]
			self:SetRecentStoryId(nRecentChapterId)
		end
		func_merge(self.tbTempStoryIds, self.tbStoryIds)
		self.tbTempStoryIds = {}
		func_merge(self.tbTempEvIds, self.tbEvIds)
		self.tbTempEvIds = {}
		for sAvgId, mapGroupData in pairs(self.mapTempCL) do
			if self.mapChosen[sAvgId] == nil then
				self.mapChosen[sAvgId] = {}
			end
			for nGroupId, tbChosen in pairs(mapGroupData) do
				if self.mapChosen[sAvgId][nGroupId] == nil then
					self.mapChosen[sAvgId][nGroupId] = 0
				end
				local nLen = #tbChosen
				for _, nChoiceIndex in ipairs(tbChosen) do
					local n = 0
					if nChoiceIndex == 1 then
						n = 1
					elseif nChoiceIndex == 2 then
						n = 2
					elseif nChoiceIndex == 3 then
						n = 4
					end
					local nCur = self.mapChosen[sAvgId][nGroupId]
					self.mapChosen[sAvgId][nGroupId] = nCur | n
					if _ == nLen then
						if self.mapLatest[sAvgId] == nil then
							self.mapLatest[sAvgId] = {}
						end
						self.mapLatest[sAvgId][nGroupId] = n
					end
				end
			end
		end
		self.mapTempCL = {}
		self.mapTempLatestCnt = {}
		func_overwrite(self.mapTempPersonality, self.mapPersonality)
		self.mapTempPersonality = {}
		self.mapTempPersonalityCnt = {}
		func_overwrite(self.mapTempPersonalityFactor, self.mapPersonalityFactor)
		self.mapTempPersonalityFactor = {}
		if callBack ~= nil then
			callBack(mapChangeInfo)
		end
		local bHasReward = not bBattle and mapChangeInfo and mapChangeInfo.Props and 0 < #mapChangeInfo.Props
		if bHasReward then
			local tbItem = {}
			local tbRewardDisplay = UTILS.DecodeChangeInfo(mapChangeInfo)
			for _, v in pairs(tbRewardDisplay) do
				for k, value in pairs(v) do
					table.insert(tbItem, {
						Tid = value.Tid,
						Qty = value.Qty,
						rewardType = AllEnum.RewardType.First
					})
				end
			end
			local tabEvent = {}
			table.insert(tabEvent, {
				"story_id",
				tostring(eventStoryId)
			})
			local _skip = PlayerData.Avg.bSkip == true and "1" or "0"
			table.insert(tabEvent, {"is_skip", _skip})
			table.insert(tabEvent, {
				"role_id",
				tostring(PlayerData.Base._nPlayerId)
			})
			NovaAPI.UserEventUpload("activity_story", tabEvent)
			local AfterRewardDisplay = function()
				EventManager.Hit("Story_RewardClosed")
			end
			local delayOpen = function()
				UTILS.OpenReceiveByDisplayItem(tbItem, mapChangeInfo, AfterRewardDisplay)
			end
			local nDelayTime = 1
			EventManager.Hit(EventId.TemporaryBlockInput, nDelayTime)
			TimerManager.Add(1, nDelayTime, self, delayOpen, true, true, true)
		end
		EventManager.Hit("Story_Done", bHasReward)
		printLog("\233\128\154\229\133\179\231\187\147\231\174\151\229\174\140\230\136\144")
	end
	printLog("\229\143\145\233\128\129\233\128\154\229\133\179\230\182\136\230\129\175")
	PlayerData.Avg:ChangeActivityAvgState(false)
	HttpNetHandler.SendMsg(NetMsgId.Id.activity_story_settle_req, mapSendMsgData, nil, func_succ)
	self.CURRENT_STORY_ID = 0
end
function ActivityAvgData:OnEvent_AvgSTEnd()
	EventManager.Remove("AvgSTEnd", self, self.OnEvent_AvgSTEnd)
	self:SendMsg_STORY_DONE()
	self:RefreshAvgRedDot()
end
function ActivityAvgData:LevelEnd()
	PlayerData.Build:DeleteTrialBuild()
	if type(self.curLevel.UnBindEvent) == "function" then
		self.curLevel:UnBindEvent()
	end
	self.curLevel = nil
end
function ActivityAvgData:GetLastestStoryId()
	local nMax = 101
	for k, v in pairs(self.tbStoryIds) do
		local curIdx = self.CFG_Story[v]
		if nMax < curIdx then
			nMax = curIdx
		end
	end
	for k, v in pairs(self.tbTempStoryIds) do
		local curIdx = self.CFG_Story[v]
		if nMax < curIdx then
			nMax = curIdx
		end
	end
	return nMax
end
function ActivityAvgData:GetRecentStoryId(nChapterId)
	local nStoryId = self.mapRecentStoryId[tostring(nChapterId)]
	if nStoryId == nil then
		local tbChapterList = self.CFG_ChapterStoryNumIds[nChapterId]
		if tbChapterList ~= nil then
			table.sort(tbChapterList, function(a, b)
				return a < b
			end)
			for i = #tbChapterList, 1, -1 do
				local v = tbChapterList[i]
				if self.tbStoryIds[v] then
					nStoryId = v
					break
				end
			end
			local chapterConfig = ConfigTable.GetData("ActivityStoryChapter", nChapterId)
			nStoryId = chapterConfig.UnlockShowStoryId
		end
	end
	return nStoryId
end
function ActivityAvgData:SetRecentStoryId(nStoryId)
	local cfgData = ConfigTable.GetData("ActivityStory", nStoryId)
	if cfgData ~= nil then
		self.mapRecentStoryId[tostring(cfgData.ChapterId)] = nStoryId
		local sJson = RapidJson.encode(self.mapRecentStoryId)
		printLog(sJson)
		LocalData.SetPlayerLocalData("ActivityRecentStoryId", sJson)
	end
end
function ActivityAvgData:IsActivityStory(nStoryId)
	for k, v in pairs(self.CFG_Story) do
		if v == nStoryId then
			return true
		end
	end
	return false
end
function ActivityAvgData:OnEvent_UpdateWorldClass()
	self:RefreshAvgRedDot()
end
return ActivityAvgData
