local ActivityAvgData = class("ActivityAvgData")
local File = CS.System.IO.File
local TimerManager = require("GameCore.Timer.TimerManager")
local LocalData = require("GameCore.Data.LocalData")
function ActivityAvgData:Init()
	self.tbActivityAvgList = {}
	self.tbCachedReadedActAvg = {}
	self.tbActAvgList = {}
	self:ParseConfig()
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
	for k, v in pairs(self.tbActivityAvgList) do
		local actId = k
		if self.tbActAvgList[actId] ~= nil then
			for _, avgId in pairs(v) do
				local bInActGroup, nActGroupId = PlayerData.Activity:IsActivityInActivityGroup(actId)
				if bInActGroup then
					local isClicked = LocalData.GetPlayerLocalData("Act_Story_New" .. actId .. avgId)
					local isNew = self:IsNew(actId, avgId)
					local curTime = CS.ClientManager.Instance.serverTimeStamp
					local isOpen = curTime < self.tbActAvgList[actId].nEndTime and curTime > self.tbActAvgList[actId].nOpenTime
					local actGroupData = PlayerData.Activity:GetActivityGroupDataById(nActGroupId)
					local bActGroupUnlock = actGroupData:IsUnlock()
					RedDotManager.SetValid(RedDotDefine.Activity_GroupNew_Avg_Group, {
						nActGroupId,
						actId,
						avgId
					}, isNew and not isClicked and isOpen and bActGroupUnlock)
				end
			end
		end
	end
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
function ActivityAvgData:OnEvent_AvgSTEnd()
	if not self:IsActivityAvgReaded(self.CURRENT_ACTIVITY_ID, self.CURRENT_STORY_ID) then
		self:SendMsg_STORY_DONE(self.CURRENT_STORY_ID, self.CURRENT_ACTIVITY_ID)
	else
		EventManager.Hit("Activity_Story_Done", false)
	end
	EventManager.Remove("StoryDialog_DialogEnd", self, self.OnEvent_AvgSTEnd)
	self:RefreshAvgRedDot()
end
function ActivityAvgData:SendMsg_STORY_DONE(nStoryId, nActId)
	local mapSendMsgData = {
		ActivityId = nActId,
		LevelId = nStoryId,
		Events = {
			List = {}
		}
	}
	local func_succ = function(_, mapChangeInfo)
		table.insert(self.tbCachedReadedActAvg[nActId], nStoryId)
		local bHasReward = mapChangeInfo and mapChangeInfo.Props and #mapChangeInfo.Props > 0
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
			local AfterRewardDisplay = function()
				EventManager.Hit("Activity_Story_RewardClosed")
			end
			local delayOpen = function()
				UTILS.OpenReceiveByDisplayItem(tbItem, mapChangeInfo, AfterRewardDisplay)
			end
			local nDelayTime = 1.5
			EventManager.Hit(EventId.TemporaryBlockInput, nDelayTime)
			TimerManager.Add(1, nDelayTime, self, delayOpen, true, true, true)
		end
		EventManager.Hit("Activity_Story_Done", bHasReward)
		printLog("\233\128\154\229\133\179\231\187\147\231\174\151\229\174\140\230\136\144")
		if #self.tbCachedReadedActAvg[nActId] == #self.tbActivityAvgList[nActId] then
			EventManager.Hit("ActivityStory_All_Complate")
		end
		self:RefreshAvgRedDot()
	end
	printLog("\229\143\145\233\128\129\233\128\154\229\133\179\230\182\136\230\129\175")
	HttpNetHandler.SendMsg(NetMsgId.Id.activity_avg_reward_receive_req, mapSendMsgData, nil, func_succ)
	self.CURRENT_STORY_ID = 0
end
return ActivityAvgData
