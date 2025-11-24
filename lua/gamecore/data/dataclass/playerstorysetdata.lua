local PlayerStorySetData = class("PlayerStorySetData")
function PlayerStorySetData:Init()
	self.tbChapter = {}
	self.bGetData = false
	self:InitConfig()
end
function PlayerStorySetData:InitConfig()
	local funcForeachSection = function(mapData)
		if nil == self.tbChapter[mapData.ChapterId] then
			self.tbChapter[mapData.ChapterId] = {}
			self.tbChapter[mapData.ChapterId].tbSectionList = {}
			self.tbChapter[mapData.ChapterId].bUnlock = false
		end
		table.insert(self.tbChapter[mapData.ChapterId].tbSectionList, {
			nId = mapData.Id,
			nSortId = mapData.SortId,
			nStatus = AllEnum.StorySetStatus.Lock
		})
	end
	ForEachTableLine(ConfigTable.Get("StorySetSection"), funcForeachSection)
	for _, v in pairs(self.tbChapter) do
		if v.tbSectionList ~= nil then
			table.sort(v.tbSectionList, function(a, b)
				return a.nId < b.nId
			end)
		end
	end
end
function PlayerStorySetData:UnInit()
end
function PlayerStorySetData:UpdateStorySetState(bState)
	RedDotManager.SetValid(RedDotDefine.Story_Set_Server, nil, bState)
end
function PlayerStorySetData:CacheStorySetData(netMsg)
	if netMsg.Chapters ~= nil then
		for _, data in ipairs(netMsg.Chapters) do
			if self.tbChapter[data.ChapterId] ~= nil then
				self.tbChapter[data.ChapterId].bUnlock = true
				local nCurIndex = data.SectionIndex or 0
				nCurIndex = nCurIndex + 1
				local bShow = false
				local mapChapterCfg = ConfigTable.GetData("StorySetChapter", data.ChapterId)
				if mapChapterCfg ~= nil then
					bShow = mapChapterCfg.IsShow
				end
				for nIndex, v in ipairs(self.tbChapter[data.ChapterId].tbSectionList) do
					if nIndex <= nCurIndex then
						v.nStatus = AllEnum.StorySetStatus.UnLock
					end
					if 0 < table.indexof(data.RewardedIds, v.nId) then
						v.nStatus = AllEnum.StorySetStatus.Received
					end
					RedDotManager.SetValid(RedDotDefine.Story_Set_Section, {
						data.ChapterId,
						v.nId
					}, v.nStatus == AllEnum.StorySetStatus.UnLock and bShow)
				end
			end
		end
	end
end
function PlayerStorySetData:UnlockNewChapter(nId)
	if self.tbChapter[nId] ~= nil then
		self.tbChapter[nId].bUnlock = true
		local bShow = false
		local mapCfg = ConfigTable.GetData("StorySetChapter", nId)
		if mapCfg ~= nil then
			bShow = mapCfg.IsShow
		end
		for k, v in ipairs(self.tbChapter[nId].tbSectionList) do
			if k == 1 then
				v.nStatus = AllEnum.StorySetStatus.UnLock
				RedDotManager.SetValid(RedDotDefine.Story_Set_Section, {
					nId,
					v.nId
				}, bShow)
				break
			end
		end
	end
end
function PlayerStorySetData:GetAllChapterList()
	local tbChapter = {}
	for nId, v in pairs(self.tbChapter) do
		local mapCfg = ConfigTable.GetData("StorySetChapter", nId)
		if mapCfg ~= nil and mapCfg.IsShow then
			table.insert(tbChapter, {
				nId = nId,
				tbSectionList = v.tbSectionList,
				bUnlock = v.bUnlock
			})
		end
	end
	table.sort(tbChapter, function(a, b)
		return a.nId < b.nId
	end)
	return tbChapter
end
function PlayerStorySetData:TryOpenStorySetPanel(callback)
	if not self.bGetData then
		self:SendGetStorySetData(callback)
	elseif callback ~= nil then
		callback()
	end
end
function PlayerStorySetData:SendGetStorySetData(callback)
	local func_cb = function(_, netMsg)
		RedDotManager.SetValid(RedDotDefine.Story_Set_Server, nil, false)
		if callback ~= nil then
			callback()
		end
	end
	HttpNetHandler.SendMsg(NetMsgId.Id.story_set_info_req, {}, nil, func_cb)
end
function PlayerStorySetData:ReceiveStorySetReward(nChapterId, nSectionId, callback)
	local func_cb = function(_, netMsg)
		if self.tbChapter[nChapterId] ~= nil then
			local nIndex = 0
			for k, v in ipairs(self.tbChapter[nChapterId].tbSectionList) do
				if v.nId == nSectionId then
					nIndex = k
					break
				end
			end
			if nIndex ~= 0 then
				self.tbChapter[nChapterId].tbSectionList[nIndex].nStatus = AllEnum.StorySetStatus.Received
				RedDotManager.SetValid(RedDotDefine.Story_Set_Section, {nChapterId, nSectionId}, false)
				nIndex = nIndex + 1
			end
			if nIndex <= #self.tbChapter[nChapterId].tbSectionList then
				self.tbChapter[nChapterId].tbSectionList[nIndex].nStatus = AllEnum.StorySetStatus.UnLock
				local bShow = false
				local mapCfg = ConfigTable.GetData("StorySetChapter", nChapterId)
				if mapCfg ~= nil then
					bShow = mapCfg.IsShow
				end
				local nId = self.tbChapter[nChapterId].tbSectionList[nIndex].nId
				RedDotManager.SetValid(RedDotDefine.Story_Set_Section, {nChapterId, nId}, bShow)
			end
		end
		if callback ~= nil then
			callback(netMsg)
		end
		EventManager.Hit("ReceiveStorySetRewardSuc")
	end
	local msg = {ChapterId = nChapterId, SectionId = nSectionId}
	HttpNetHandler.SendMsg(NetMsgId.Id.story_set_reward_receive_req, msg, nil, func_cb)
end
return PlayerStorySetData
