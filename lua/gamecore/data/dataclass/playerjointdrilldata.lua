local PlayerJointDrillData = class("PlayerJointDrillData")
local ConfigData = require("GameCore.Data.ConfigData")
local TimerManager = require("GameCore.Timer.TimerManager")
local LocalData = require("GameCore.Data.LocalData")
local ClientManager = CS.ClientManager.Instance
local ListInt = CS.System.Collections.Generic.List(CS.System.Int32)
function PlayerJointDrillData:Init()
	self.nActId = 0
	self.actTimer = nil
	self.nActStatus = 0
	self.tbPassedLevels = {}
	self.bInBattle = false
	self.curLevel = nil
	self.nCurLevelId = 0
	self.nCurLevel = 1
	self.nStartTime = 0
	self.nGameTime = 0
	self._EntryTime = 0
	self._EndTime = 0
	self.mapBossInfo = {}
	self.record = nil
	self.bSimulate = false
	self.tbTeams = {}
	self.nSelectBuildId = 0
	self.nChallengeCount = 0
	self.tbRecordFloors = {}
	self.tbQuests = {}
	self.nTotalScore = 0
	self.nLastRefreshRankTime = 0
	self.nRankingRefreshTime = 600
	self.mapSelfRankData = nil
	self.mapRankList = nil
	self.nTotalRank = 0
	self:InitConfig()
end
function PlayerJointDrillData:UnInit()
end
function PlayerJointDrillData:InitConfig()
	self.nMaxChallengeTime = ConfigTable.GetConfigNumber("JointDrill_Challenge_Time_Max")
	self.nOverFlowChallengeTime = ConfigTable.GetConfigNumber("JointDrill_Challenge_Time_OverFlow")
	local funcForeachMonsterValueTemplete = function(line)
		CacheTable.SetField("_MonsterValueTemplete", line.TemplateId, line.Lv, line)
	end
	ForEachTableLine(ConfigTable.Get("MonsterValueTemplete"), funcForeachMonsterValueTemplete)
	local funcForeachJointDrillLevel = function(line)
		CacheTable.SetField("_JointDrillLevel", line.DrillLevelGroupId, line.Difficulty, line)
	end
	ForEachTableLine(ConfigTable.Get("JointDrillLevel"), funcForeachJointDrillLevel)
	local funcForeachJointDrillLevel = function(line)
		CacheTable.SetField("_JointDrillFloor", line.FloorId, line.BattleLvs, line)
	end
	ForEachTableLine(ConfigTable.Get("JointDrillFloor"), funcForeachJointDrillLevel)
	local funcForeachJointDrillQuest = function(line)
		if nil == CacheTable.GetData("_JointDrillQuest", line.GroupId) then
			CacheTable.SetData("_JointDrillQuest", line.GroupId, {})
		end
		CacheTable.InsertData("_JointDrillQuest", line.GroupId, line)
	end
	ForEachTableLine(ConfigTable.Get("JointDrillQuest"), funcForeachJointDrillQuest)
	self.nRankCount = 0
	local funcForeachJointDrillRank = function(line)
		self.nRankCount = self.nRankCount + 1
	end
	ForEachTableLine(ConfigTable.Get("JointDrillRank"), funcForeachJointDrillRank)
end
local EncodeTempDataJson = function(mapData)
	local stTempData = CS.JointDrillTempData(1)
	if mapData.mapCharacterTempData ~= nil and next(mapData.mapCharacterTempData) ~= nil then
		local mapCharacterTempData = mapData.mapCharacterTempData
		local stCharacter = {}
		local tbHp = mapCharacterTempData.hpInfo
		for nCharId, mapEffect in pairs(mapCharacterTempData.effectInfo) do
			if stCharacter[nCharId] == nil then
				stCharacter[nCharId] = CS.JointDrillCharacter(nCharId, tbHp[nCharId])
			end
			for nEtfId, mapEft in pairs(mapEffect.mapEffect) do
				stCharacter[nCharId].tbEffect:Add(CS.StarTowerEffect(nEtfId, mapEft.nCount, mapEft.nCd))
			end
		end
		for nCharId, mapBuff in pairs(mapCharacterTempData.buffInfo) do
			if stCharacter[nCharId] == nil then
				stCharacter[nCharId] = CS.JointDrillCharacter(nCharId, tbHp[nCharId])
			end
			for _, buffInfo in ipairs(mapBuff) do
				stCharacter[nCharId].tbBuff:Add(CS.StarTowerBuffInfo(buffInfo.Id, buffInfo.CD, buffInfo.nNum))
			end
		end
		for nCharId, mapStatus in pairs(mapCharacterTempData.stateInfo) do
			if stCharacter[nCharId] == nil then
				stCharacter[nCharId] = CS.JointDrillCharacter(nCharId, tbHp[nCharId])
			end
			stCharacter[nCharId].stateInfo = CS.StarTowerState(mapStatus.nState, mapStatus.nStateTime)
		end
		for nCharId, mapAmmoInfo in pairs(mapCharacterTempData.ammoInfo) do
			if stCharacter[nCharId] == nil then
				stCharacter[nCharId] = CS.JointDrillCharacter(nCharId, tbHp[nCharId])
			end
			stCharacter[nCharId].ammoInfo = CS.StarTowerAmmoInfo(mapAmmoInfo.nCurAmmo, mapAmmoInfo.nAmmo1, mapAmmoInfo.nAmmo2, mapAmmoInfo.nAmmo3, mapAmmoInfo.nAmmoMax1, mapAmmoInfo.nAmmoMax2, mapAmmoInfo.nAmmoMax3)
		end
		for _, skill in ipairs(mapCharacterTempData.skillInfo) do
			stTempData.skillInfo:Add(CS.StarTowerSkill(skill.nCharId, skill.nSkillId, skill.nCd, skill.nSectionAmount, skill.nSectionResumeTime, skill.nUseTimeHint, skill.nEnergy))
		end
		stTempData.summonMonsterInfo = mapCharacterTempData.sommonInfo
		for _, st in pairs(stCharacter) do
			stTempData.characterInfo:Add(st)
		end
	end
	local mapBossTempData = mapData.mapBossTempData
	stTempData.bossInfo = mapBossTempData
	local jsonData, length = NovaAPI.ParseJointDrillDataCompressed(stTempData)
	return jsonData, length
end
local DecodeTempDataJson = function(sData)
	local tempData = {}
	tempData.mapCharacterTempData = {}
	tempData.mapBossTempData = {}
	tempData.mapCharacterTempData.skillInfo = {}
	local stData = NovaAPI.DecodeJointDrillDataCompressed(sData)
	local nCount = stData.skillInfo.Count
	for index = 0, nCount - 1 do
		local stSkill = stData.skillInfo[index]
		table.insert(tempData.mapCharacterTempData.skillInfo, {
			nCharId = stSkill.nCharId,
			nSkillId = stSkill.nSkillId,
			nCd = stSkill.nCd,
			nSectionAmount = stSkill.nSectionAmount,
			nSectionResumeTime = stSkill.nSectionResumeTime,
			nUseTimeHint = stSkill.nUseTimeHint,
			nEnergy = stSkill.nEnergy
		})
	end
	local nCharCount = stData.characterInfo.Count
	for index = 0, nCharCount - 1 do
		local stChar = stData.characterInfo[index]
		local nCharId = stChar.nCharId
		local nHp = stChar.nHp
		if tempData.mapCharacterTempData.hpInfo == nil then
			tempData.mapCharacterTempData.hpInfo = {}
		end
		tempData.mapCharacterTempData.hpInfo[nCharId] = nHp
		local nEffectCount = stChar.tbEffect.Count
		if tempData.mapCharacterTempData.effectInfo == nil then
			tempData.mapCharacterTempData.effectInfo = {}
		end
		if tempData.mapCharacterTempData.effectInfo[nCharId] == nil then
			tempData.mapCharacterTempData.effectInfo[nCharId] = {
				mapEffect = {}
			}
		end
		for e = 0, nEffectCount - 1 do
			local stEffect = stChar.tbEffect[e]
			tempData.mapCharacterTempData.effectInfo[nCharId].mapEffect[stEffect.nId] = {
				nCount = stEffect.nCount,
				nCd = stEffect.nCd
			}
		end
		local nBuffCount = stChar.tbBuff.Count
		if tempData.mapCharacterTempData.buffInfo == nil then
			tempData.mapCharacterTempData.buffInfo = {}
		end
		if tempData.mapCharacterTempData.buffInfo[nCharId] == nil then
			tempData.mapCharacterTempData.buffInfo[nCharId] = {}
		end
		for b = 0, nBuffCount - 1 do
			local stBuff = stChar.tbBuff[b]
			table.insert(tempData.mapCharacterTempData.buffInfo[nCharId], {
				Id = stBuff.Id,
				CD = stBuff.CD,
				nNum = stBuff.nNum
			})
		end
		if stChar.stateInfo ~= nil then
			if tempData.mapCharacterTempData.stateInfo == nil then
				tempData.mapCharacterTempData.stateInfo = {}
			end
			tempData.mapCharacterTempData.stateInfo[nCharId] = {
				jsonStr = "",
				nState = stChar.stateInfo.nState,
				nStateTime = stChar.stateInfo.nStateTime
			}
		end
		if stChar.ammoInfo ~= nil then
			if tempData.mapCharacterTempData.ammoInfo == nil then
				tempData.mapCharacterTempData.ammoInfo = {}
			end
			tempData.mapCharacterTempData.ammoInfo[nCharId] = {
				nCurAmmo = stChar.ammoInfo.nCurAmmo,
				nAmmo1 = stChar.ammoInfo.nAmmo1,
				nAmmo2 = stChar.ammoInfo.nAmmo2,
				nAmmo3 = stChar.ammoInfo.nAmmo3,
				nAmmoMax1 = stChar.ammoInfo.nAmmoMax1,
				nAmmoMax2 = stChar.ammoInfo.nAmmoMax2,
				nAmmoMax3 = stChar.ammoInfo.nAmmoMax3
			}
		end
	end
	if stData.summonMonsterInfo ~= nil and tempData.mapCharacterTempData.sommonInfo == nil then
		tempData.mapCharacterTempData.sommonInfo = stData.summonMonsterInfo
	end
	tempData.mapBossTempData = stData.bossInfo
	return tempData
end
function PlayerJointDrillData:EncodeTempDataJson(mapData)
	return EncodeTempDataJson(mapData)
end
function PlayerJointDrillData:DecodeTempDataJson()
	if self.record ~= nil then
		return DecodeTempDataJson(self.record)
	end
end
function PlayerJointDrillData:CacheJointDrillData(nActId, msgData)
	self.nActId = nActId
	self.tbPassedLevels = msgData.PassedLevels
	if msgData.Meta ~= nil then
		self.bInBattle = msgData.Meta.LevelId ~= 0
		self.nCurLevelId = msgData.Meta.LevelId
		self.nCurLevel = msgData.Meta.Floor
		self.mapBossInfo.nHp = msgData.Meta.BossHP
		self.mapBossInfo.nHpMax = msgData.Meta.BossHPMax
		self.nStartTime = msgData.Meta.StartTime
		self.record = msgData.Meta.Record
		self.tbTeams = msgData.Meta.Teams
		self.bSimulate = msgData.Meta.Simulate
		self._EntryTime = msgData.Meta.StartTime
		if self.bInBattle then
			self:StartChallengeTime()
		else
			self:ChallengeEnd()
		end
		self.nTotalScore = msgData.Meta.TotalScore
	end
	if msgData.Quests ~= nil then
		self.tbQuests = msgData.Quests
	end
	self:RefreshJointDrillQuestRedDot()
	self:StartActTimer()
end
function PlayerJointDrillData:CheckPassedId(nLevelId)
	if self.tbPassedLevels ~= nil then
		for _, v in ipairs(self.tbPassedLevels) do
			if v.LevelId == nLevelId then
				return true
			end
		end
	end
	return false
end
function PlayerJointDrillData:IsJointDrillUnlock(nLevelId)
	local mapLevelCfg = ConfigTable.GetData("JointDrillLevel", nLevelId)
	if mapLevelCfg == nil then
		return false
	end
	local nPreLevelId = mapLevelCfg.PreLevelId
	if nPreLevelId == 0 then
		return true
	end
	return self:CheckPassedId(nPreLevelId)
end
function PlayerJointDrillData:GetMonsterMaxHp(nMonsterId, nDifficulty)
	local nMaxHp = 0
	local mapMonsterCfg = ConfigTable.GetData("Monster", nMonsterId)
	if mapMonsterCfg == nil then
		return 0
	end
	local mapAdjustCfg = ConfigTable.GetData("MonsterValueTempleteAdjust", mapMonsterCfg.Templete)
	if mapAdjustCfg == nil then
		return 0
	end
	local mapCfgList = CacheTable.GetData("_MonsterValueTemplete", mapAdjustCfg.TemplateId)
	if mapCfgList == nil then
		return 0
	end
	local mapCfg = mapCfgList[nDifficulty]
	if mapCfg == nil then
		return 0
	end
	local nValue = mapCfg.Hp
	local nRatio = mapAdjustCfg.HpRatio
	local nFix = mapAdjustCfg.HpFix
	nMaxHp = math.floor(nValue * (1 + nRatio * ConfigData.IntFloatPrecision) + nFix)
	return nMaxHp
end
function PlayerJointDrillData:GetMonsterName(nMonsterId)
	local mapMonsterCfg = ConfigTable.GetData("Monster", nMonsterId)
	if mapMonsterCfg ~= nil then
		local nSkinId = mapMonsterCfg.FAId
		local mapSkinCfg = ConfigTable.GetData("MonsterSkin", nSkinId)
		if mapSkinCfg ~= nil then
			local nManualId = mapSkinCfg.MonsterManual
			local mapManualCfg = ConfigTable.GetData("MonsterManual", nManualId)
			if mapManualCfg ~= nil then
				return mapManualCfg.Name
			end
		end
	end
	return ""
end
function PlayerJointDrillData:StartChallengeTime()
	if self.challengeTimer ~= nil then
		self.challengeTimer:Cancel()
		self.challengeTimer = nil
	end
	local nOpenTime = self.nStartTime
	local refreshTime = function()
		local nCurTime = CS.ClientManager.Instance.serverTimeStamp
		local nTime = self.nMaxChallengeTime - (nCurTime - nOpenTime)
		if 0 <= nTime then
			EventManager.Hit("RefreshChallengeTime", nTime)
		end
		return nTime
	end
	local nTime = refreshTime()
	if 0 < nTime then
		self.challengeTimer = TimerManager.Add(0, 1, nil, function()
			local nTime = refreshTime()
			if nTime <= 0 then
				self.challengeTimer:Cancel()
				self.challengeTimer = nil
				if self.curLevel ~= nil then
					self.curLevel:JointDrillTimeOut()
				end
			end
		end, true, true, true)
	end
end
function PlayerJointDrillData:StartActTimer()
	if self.actTimer ~= nil then
		self.actTimer:Cancel()
		self.actTimer = nil
	end
	local actData = PlayerData.Activity:GetActivityDataById(self.nActId)
	if actData ~= nil then
		local nChallengeStartTime = actData:GetChallengeStartTime()
		local nChallengeEndTime = actData:GetChallengeEndTime()
		local nActEndTime = actData:GetActCloseTime()
		self.nActStatus = 0
		local refreshTime = function()
			local nRemainTime = 0
			local nCurTime = ClientManager.serverTimeStamp
			if nCurTime < nChallengeStartTime then
				self.nActStatus = AllEnum.JointDrillActStatus.WaitStart
				nRemainTime = nChallengeStartTime - nCurTime
			elseif nCurTime <= nChallengeEndTime then
				self.nActStatus = AllEnum.JointDrillActStatus.Start
				nRemainTime = nChallengeEndTime - nCurTime
			elseif nCurTime > nChallengeEndTime and nCurTime < nActEndTime then
				self.nActStatus = AllEnum.JointDrillActStatus.WaitClose
				nRemainTime = nActEndTime - nCurTime
			elseif nCurTime >= nActEndTime then
				self.nActStatus = AllEnum.JointDrillActStatus.Closed
				nRemainTime = 0
			end
			EventManager.Hit("RefreshJointDrillActTime", self.nActStatus, nRemainTime)
			if nRemainTime <= 0 and self.actTimer ~= nil and self.nActStatus == AllEnum.JointDrillActStatus.Closed then
				self.actTimer:Cancel()
				self.actTimer = nil
				return
			end
		end
		refreshTime()
		if self.actTimer == nil then
			self.actTimer = TimerManager.Add(0, 1, nil, refreshTime, true, true, true)
		end
	end
end
function PlayerJointDrillData:RefreshJointDrillQuestRedDot()
	local bHasReward = false
	for _, v in ipairs(self.tbQuests) do
		if v.Status == 1 then
			bHasReward = true
			break
		end
	end
	RedDotManager.SetValid(RedDotDefine.JointDrillQuest, nil, bHasReward)
end
function PlayerJointDrillData:EnterJointDrill(nLevelId, nBuildId, bSimulate, bChangeLevel, nCurLevel)
	local mapLevelCfg = ConfigTable.GetData("JointDrillLevel", nLevelId)
	if mapLevelCfg == nil then
		printError("\230\137\190\228\184\141\229\136\176\230\128\187\229\138\155\230\136\152\229\133\179\229\141\161\230\149\176\230\141\174\239\188\129\239\188\129\239\188\129levelId = " .. tostring(nLevelId))
		return
	end
	local nHp, nHpMax = 0, 0
	if self.record == nil or self.record == "" then
		nHpMax = self:GetMonsterMaxHp(mapLevelCfg.BossId, mapLevelCfg.Difficulty)
		nHp = nHpMax
	else
		local mapTemp = DecodeTempDataJson(self.record)
		if mapTemp ~= nil and mapTemp.mapBossTempData ~= nil and mapTemp.mapBossTempData.nBossId ~= 0 then
			nHpMax = mapTemp.mapBossTempData.nHpMax
			nHp = mapTemp.mapBossTempData.nHp
		end
	end
	if nHpMax == 0 then
		printError(string.format("[\230\128\187\229\138\155\230\136\152]\232\142\183\229\143\150boss\232\161\128\233\135\143\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129 levelId = %s, bossId = %s", nLevelId, mapLevelCfg.BossId))
		return
	end
	local enterLevel = function(mapNetData)
		if self.curLevel == nil then
			local luaClass = require("Game.Adventure.JointDrill.JointDrillLevelData")
			if luaClass == nil then
				return
			end
			self.curLevel = luaClass
			if type(self.curLevel.BindEvent) == "function" then
				self.curLevel:BindEvent()
			end
		end
		self.nCurLevelId = nLevelId
		self.bInBattle = true
		self.bSimulate = bSimulate
		self.mapBossInfo = {}
		self.mapBossInfo.nHp = nHp
		self.mapBossInfo.nHpMax = nHpMax
		if nCurLevel == nil then
			nCurLevel = self.nCurLevel
		end
		if mapNetData ~= nil then
			self.nStartTime = mapNetData.StarTime
			self._EntryTime = mapNetData.StarTime
			local sKey = LocalData.GetPlayerLocalData("JointDrillRecordKey") or ""
			if sKey ~= nil and sKey ~= "" then
				NovaAPI.DeleteRecFile(sKey)
			end
			sKey = tostring(mapNetData.StarTime)
			LocalData.SetPlayerLocalData("JointDrillRecordKey", sKey)
			LocalData.SetPlayerLocalData("JointDrillRecordFloorId", 0)
			LocalData.SetPlayerLocalData("JointDrillRecordExcludeId", 0)
			self:EventUpload(1)
		end
		self:StartChallengeTime()
		if type(self.curLevel.Init) == "function" then
			self.curLevel:Init(self, nLevelId, nBuildId, nCurLevel, bChangeLevel)
		end
	end
	local netCallback = function(_, netMsg)
		enterLevel(netMsg)
	end
	if self.bInBattle and not bChangeLevel then
		self:ContinueJointDrill(nBuildId, enterLevel)
	elseif not bChangeLevel then
		local msg = {
			LevelId = nLevelId,
			BuildId = nBuildId,
			BossHp = nHp,
			BossHpMax = nHpMax,
			Simulate = bSimulate
		}
		HttpNetHandler.SendMsg(NetMsgId.Id.joint_drill_apply_req, msg, nil, netCallback)
	else
		enterLevel()
	end
end
function PlayerJointDrillData:ChangeLevel(nLevel)
	self:EnterJointDrill(self.nCurLevelId, self.nSelectBuildId, self.bSimulate, true, nLevel)
end
function PlayerJointDrillData:RestartBattle()
	self:EnterJointDrill(self.nCurLevelId, self.nSelectBuildId, self.bSimulate, true, self.nCurLevel)
end
function PlayerJointDrillData:ContinueJointDrill(nBuildId, callback)
	local NetCallback = function(_, netMsg)
		local sKey = LocalData.GetPlayerLocalData("JointDrillRecordKey") or ""
		if sKey == "" or sKey ~= tostring(self.nStartTime) then
			if sKey ~= "" then
				NovaAPI.DeleteRecFile(sKey)
			end
			sKey = tostring(self.nStartTime)
			LocalData.SetPlayerLocalData("JointDrillRecordKey", self.nStartTime)
		end
		if callback ~= nil then
			callback()
		end
	end
	local msg = {BuildId = nBuildId}
	HttpNetHandler.SendMsg(NetMsgId.Id.joint_drill_continue_req, msg, nil, NetCallback)
end
function PlayerJointDrillData:JointDrillGameOver(callback, bSettle)
	self:SetRecorderExcludeIds()
	self:StopRecord()
	self._EndTime = ClientManager.serverTimeStamp
	local NetCallback = function(_, netMsg)
		local nScoreOld = 0
		if self.mapSelfRankData ~= nil then
			nScoreOld = self.mapSelfRankData.Score
		end
		if netMsg.Old ~= netMsg.New then
			self:SendJointDrillRankMsg()
		end
		self:UploadRecordFile(netMsg.Token)
		if not self.bSimulate then
			self.nTotalScore = self.nTotalScore + netMsg.FightScore + netMsg.HpScore + netMsg.DifficultyScore
		end
		EventManager.Hit(EventId.ClosePanel, PanelId.JointDrillBuildList)
		EventManager.Hit("RefreshJointDrillLevel")
		if callback ~= nil then
			callback(netMsg)
		end
		if bSettle then
			local nResultType = AllEnum.JointDrillResultType.ChallengeEnd
			local mapScore = {}
			local nTotalScore = PlayerData.JointDrill:GetTotalRankScore()
			local mapChange, mapItems = {}, {}
			local nOld, nNew = 0, 0
			if netMsg ~= nil then
				mapChange = netMsg.Change or {}
				mapItems = netMsg.Items or {}
				local nScore = netMsg.FightScore + netMsg.HpScore + netMsg.DifficultyScore
				mapScore = {
					FightScore = netMsg.FightScore,
					HpScore = netMsg.HpScore,
					DifficultyScore = netMsg.DifficultyScore,
					nTotalScore = nTotalScore,
					nScore = nScore,
					nScoreOld = nScoreOld
				}
				nOld = netMsg.Old
				nNew = netMsg.New
			end
			EventManager.Hit(EventId.OpenPanel, PanelId.JointDrillResult, nResultType, self.nCurLevel, 0, self.nCurLevelId, self.mapBossInfo, mapScore, mapItems, mapChange, nOld, nNew, self.bSimulate, #self.tbTeams)
		end
		self:EventUpload(4, 0)
		self:ChallengeEnd()
	end
	HttpNetHandler.SendMsg(NetMsgId.Id.joint_drill_game_over_req, {}, nil, NetCallback)
end
function PlayerJointDrillData:JointDrillGiveUp(nFloor, nTime, nDamage, nBossHp, sRecord, mapBuild, callback)
	self:SetRecorderExcludeIds()
	self:StopRecord()
	local NetCallback = function(_, netMsg)
		self.record = sRecord
		self.nCurLevel = nFloor
		self.mapBossInfo.nHp = nBossHp
		if callback ~= nil then
			callback(netMsg)
		end
		if netMsg.Old ~= netMsg.New then
			self:SendJointDrillRankMsg()
		end
	end
	local msg = {
		Floor = nFloor,
		Time = nTime,
		Damage = nDamage,
		BossHp = nBossHp,
		Record = sRecord
	}
	HttpNetHandler.SendMsg(NetMsgId.Id.joint_drill_give_up_req, msg, nil, NetCallback)
end
function PlayerJointDrillData:JointDrillRetreat(mapBuild, callback)
	self:SetRecorderExcludeIds(true)
	self:StopRecord()
	local NetCallback = function(_, netMsg)
		self:RemoveJointDrillTeam(mapBuild)
		if callback ~= nil then
			callback()
		end
	end
	HttpNetHandler.SendMsg(NetMsgId.Id.joint_drill_retreat_req, {}, nil, NetCallback)
end
function PlayerJointDrillData:JointDrillSettle(mapBuild, nTime, nDamage, callback)
	self:SetRecorderExcludeIds()
	self:StopRecord()
	self:AddJointDrillTeam(mapBuild, nTime, nDamage)
	self._EndTime = ClientManager.serverTimeStamp
	local NetCallback = function(_, netMsg)
		self:UploadRecordFile(netMsg.Token)
		if not self.bSimulate then
			local nScore = netMsg.FightScore + netMsg.HpScore + netMsg.DifficultyScore
			self.nTotalScore = self.nTotalScore + nScore
			table.insert(self.tbPassedLevels, {
				LevelId = self.nCurLevelId,
				Score = nScore
			})
		end
		EventManager.Hit(EventId.ClosePanel, PanelId.JointDrillBuildList)
		if callback ~= nil then
			callback(netMsg)
		end
		if netMsg.Old ~= netMsg.New then
			self:SendJointDrillRankMsg()
		end
		self:EventUpload(4, 1)
	end
	local tbSamples = UTILS.GetBattleSamples()
	local sKey = LocalData.GetPlayerLocalData("JointDrillRecordKey") or ""
	local bSuccess, nCheckSum = NovaAPI.GetRecorderKey(sKey)
	local tbSendSample = {Sample = tbSamples, Checksum = nCheckSum}
	local msg = {
		Time = nTime,
		Damage = nDamage,
		sample = tbSendSample,
		Events = {
			List = PlayerData.Achievement:GetBattleAchievement(GameEnum.levelType.JointDrill, true)
		}
	}
	HttpNetHandler.SendMsg(NetMsgId.Id.joint_drill_settle_req, msg, nil, NetCallback)
end
function PlayerJointDrillData:JointDrillSync(nFloor, nTime, nDamage, nBossHp, nBossHpMax, sRecord, callback)
	local NetCallback = function(_, netMsg)
		self.record = sRecord
		self.mapBossInfo.nHp = nBossHp
		self.mapBossInfo.nHpMax = nBossHpMax
		if callback ~= nil then
			callback()
		end
	end
	local msg = {
		Floor = nFloor,
		Time = nTime,
		Damage = nDamage,
		BossHp = nBossHp,
		BossHpMax = nBossHpMax,
		Record = sRecord
	}
	HttpNetHandler.SendMsg(NetMsgId.Id.joint_drill_sync_req, msg, nil, NetCallback)
end
function PlayerJointDrillData:LevelEnd(nType)
	if self.curLevel ~= nil and type(self.curLevel.UnBindEvent) == "function" then
		self.curLevel:UnBindEvent()
	end
	self.curLevel = nil
	self.nGameTime = 0
	if nType ~= AllEnum.JointDrillResultType.Retreat then
		self.nSelectBuildId = 0
	end
end
function PlayerJointDrillData:ChallengeEnd()
	if self.curLevel ~= nil and type(self.curLevel.UnBindEvent) == "function" then
		self.curLevel:UnBindEvent()
	end
	self.bInBattle = false
	self.curLevel = nil
	self.nCurLevelId = 0
	self.nCurLevel = 1
	self.nStartTime = 0
	self.nGameTime = 0
	self.bSimulate = false
	self.record = nil
	self.tbTeams = {}
	self.nSelectBuildId = 0
	self.tbRecordFloors = {}
	if self.challengeTimer ~= nil then
		self.challengeTimer:Cancel()
		self.challengeTimer = nil
	end
	self._EntryTime = 0
	self._EndTime = 0
end
function PlayerJointDrillData:ResetRecord(sRecord)
	self.record = sRecord
end
function PlayerJointDrillData:GetJointDrillLevelId()
	return self.nCurLevelId
end
function PlayerJointDrillData:GetJointDrillCurLevel()
	return self.nCurLevel
end
function PlayerJointDrillData:GetJointDrillStartTime()
	return self.nStartTime
end
function PlayerJointDrillData:GetJointDrillBossInfo()
	return self.mapBossInfo
end
function PlayerJointDrillData:GetJointDrillBuildList()
	return self.tbTeams
end
function PlayerJointDrillData:GetJointDrillBattleCount()
	return #self.tbTeams
end
function PlayerJointDrillData:CheckChallengeCount()
	if self.nCurLevelId ~= 0 then
		local mapLevelCfg = ConfigTable.GetData("JointDrillLevel", self.nCurLevelId)
		if mapLevelCfg ~= nil then
			if #self.tbTeams < mapLevelCfg.MaxBattleNum then
				return true
			else
				EventManager.Hit(EventId.ClosePanel, PanelId.JointDrillBuildList)
				self:JointDrillGameOver()
				return false
			end
		end
		return false
	end
	return true
end
function PlayerJointDrillData:CheckJointDrillInBattle()
	return self.bInBattle
end
function PlayerJointDrillData:GetMaxChallengeCount(nLevelId)
	local mapLevelCfg = ConfigTable.GetData("JointDrillLevel", nLevelId)
	if mapLevelCfg ~= nil then
		return mapLevelCfg.MaxBattleNum
	end
	return 0
end
function PlayerJointDrillData:SetSelBuildId(nBuildId)
	self.nSelectBuildId = nBuildId
end
function PlayerJointDrillData:GetCachedBuild()
	return self.nSelectBuildId
end
function PlayerJointDrillData:GetBossHpBarNum()
	if self.nCurLevelId ~= nil then
		local mapCfg = ConfigTable.GetData("JointDrillLevel", self.nCurLevelId)
		if mapCfg ~= nil then
			return mapCfg.HpBarNum
		end
	end
	return 40
end
function PlayerJointDrillData:AddJointDrillTeam(mapBuildData, nTime, nDamage)
	local bInsert = false
	for _, v in ipairs(self.tbTeams) do
		if v.BuildId == mapBuildData.nBuildId then
			bInsert = true
			v.Damage = nDamage
			v.Time = nTime
			break
		end
	end
	if not bInsert then
		local tbChar = {}
		for _, mapChar in ipairs(mapBuildData.tbChar) do
			local nCharId = mapChar.nTid
			local nLv = PlayerData.Char:GetCharLv(nCharId)
			table.insert(tbChar, {CharId = nCharId, CharLevel = nLv})
		end
		local teamData = {
			Chars = tbChar,
			BuildScore = mapBuildData.nScore,
			Damage = nDamage,
			Time = nTime,
			BuildId = mapBuildData.nBuildId
		}
		table.insert(self.tbTeams, teamData)
	end
end
function PlayerJointDrillData:RemoveJointDrillTeam(mapBuildData)
	local nIndex = 0
	for k, v in ipairs(self.tbTeams) do
		if v.BuildId == mapBuildData.nBuildId then
			nIndex = k
			break
		end
	end
	if nIndex ~= 0 then
		table.remove(self.tbTeams, nIndex)
	end
end
function PlayerJointDrillData:SetGameTime(nTime)
	self.nGameTime = nTime
end
function PlayerJointDrillData:GetGameTime()
	return self.nGameTime
end
function PlayerJointDrillData:GetBattleSimulate()
	return self.bSimulate
end
function PlayerJointDrillData:AddRecordFloorList()
	local nValue = LocalData.GetPlayerLocalData("JointDrillRecordFloorId") or 0
	nValue = nValue + 1
	table.insert(self.tbRecordFloors, nValue)
	LocalData.SetPlayerLocalData("JointDrillRecordFloorId", nValue)
	NovaAPI.SetRecorderFloorId(nValue)
end
function PlayerJointDrillData:AddRecordExcludeId(nId)
	local nValue = LocalData.GetPlayerLocalData("JointDrillRecordExcludeId") or 0
	nValue = 1 << nId - 1 | nValue
	LocalData.SetPlayerLocalData("JointDrillRecordExcludeId", nValue)
end
function PlayerJointDrillData:SetRecorderExcludeIds(bRemove)
	local tbFloorId = ListInt()
	if bRemove then
		for _, v in ipairs(self.tbRecordFloors) do
			self:AddRecordExcludeId(v)
		end
	end
	local nExcludeValue = LocalData.GetPlayerLocalData("JointDrillRecordExcludeId") or 0
	if 0 < nExcludeValue then
		local tbTemp = {}
		while 0 < nExcludeValue do
			table.insert(tbTemp, 1, nExcludeValue % 2)
			nExcludeValue = math.floor(nExcludeValue / 2)
		end
		printTable(tbTemp)
		for k, v in ipairs(tbTemp) do
			if v == 1 then
				tbFloorId:Add(#tbTemp - k + 1)
			end
		end
	end
	self.tbRecordFloors = {}
	NovaAPI.SetRecorderExcludeIds(tbFloorId)
end
function PlayerJointDrillData:StopRecord()
	NovaAPI.StopRecord()
end
function PlayerJointDrillData:UploadRecordFile(sToken)
	local sKey = LocalData.GetPlayerLocalData("JointDrillRecordKey") or ""
	if sKey ~= nil and sKey ~= "" then
		if sToken ~= nil and sToken ~= "" then
			NovaAPI.UploadStartowerFile(sToken, sKey)
		else
			NovaAPI.DeleteRecFile(sKey)
		end
	end
	LocalData.SetPlayerLocalData("JointDrillRecordKey", "")
end
function PlayerJointDrillData:CheckActChallengeTime()
	local actData = PlayerData.Activity:GetActivityDataById(self.nActId)
	if actData ~= nil then
		local nChallengeEndTime = actData:GetChallengeEndTime()
		local nCurTime = ClientManager.serverTimeStamp
		if nChallengeEndTime <= nCurTime then
			return false
		end
		return true
	end
	return false
end
function PlayerJointDrillData:GetActStatus()
	return self.nActStatus
end
function PlayerJointDrillData:SendJointDrillRankMsg()
	local NetCallback = function(_, netMsg)
		self.nLastRefreshRankTime = netMsg.LastRefreshTime
		self.mapSelfRankData = netMsg.Self
		self.mapRankList = netMsg.Rank
		self.nTotalRank = netMsg.Total or 0
		EventManager.Hit("GetJointDrillRankSuc")
	end
	HttpNetHandler.SendMsg(NetMsgId.Id.joint_drill_rank_req, {}, nil, NetCallback)
end
function PlayerJointDrillData:GetSelfRankData()
	return self.mapSelfRankData
end
function PlayerJointDrillData:GetRankList()
	return self.mapRankList
end
function PlayerJointDrillData:GetRankRewardCount()
	return self.nRankCount
end
function PlayerJointDrillData:GetTotalRankCount()
	return self.nTotalRank
end
function PlayerJointDrillData:GetLastRankRefreshTime()
	return self.nLastRefreshRankTime, self.nRankingRefreshTime
end
function PlayerJointDrillData:GetTotalRankScore()
	return self.nTotalScore
end
function PlayerJointDrillData:SendJointDrillSweepMsg(nLevelId, nCount, callback)
	local NetCallback = function(_, netMsg)
		EventManager.Hit("JointDrillRaidSuccess", netMsg)
		if callback ~= nil then
			callback(netMsg)
		end
		self.nTotalScore = netMsg.Score
		self:EventUpload(5)
	end
	local msg = {LevelId = nLevelId, Count = nCount}
	HttpNetHandler.SendMsg(NetMsgId.Id.joint_drill_sweep_req, msg, nil, NetCallback)
end
function PlayerJointDrillData:SendReceiveQuestReward(callback)
	local NetCallback = function(_, netMsg)
		UTILS.OpenReceiveByChangeInfo(netMsg, function()
			if callback ~= nil then
				callback()
			end
		end)
	end
	HttpNetHandler.SendMsg(NetMsgId.Id.joint_drill_quest_reward_receive_req, {}, nil, NetCallback)
end
function PlayerJointDrillData:RefreshQuestData(questData)
	local bHasData = false
	for k, v in ipairs(self.tbQuests) do
		if v.Id == questData.Id then
			self.tbQuests[k] = questData
			bHasData = true
			break
		end
	end
	if not bHasData then
		table.insert(self.tbQuests, questData)
	end
	self:RefreshJointDrillQuestRedDot()
end
function PlayerJointDrillData:GetRewardQuestList()
	local tbQuests = {}
	for _, v in ipairs(self.tbQuests) do
		local nSortStatus = 0
		if v.Status == 0 then
			nSortStatus = 1
		elseif v.Status == 1 then
			nSortStatus = 0
		elseif v.Status == 2 then
			nSortStatus = 2
		end
		v.SortStatus = nSortStatus
		table.insert(tbQuests, v)
	end
	return tbQuests
end
function PlayerJointDrillData:EventUpload(action, result)
	result = result or ""
	local nCostTime = 0
	if action == 4 then
		nCostTime = self._EndTime - self._EntryTime
	end
	local tabUpLevel = {}
	table.insert(tabUpLevel, {
		"action",
		tostring(action)
	})
	table.insert(tabUpLevel, {
		"role_id",
		tostring(PlayerData.Base._nPlayerId)
	})
	table.insert(tabUpLevel, {
		"game_cost_time",
		tostring(nCostTime)
	})
	table.insert(tabUpLevel, {
		"battle_id",
		tostring(self.nCurLevelId)
	})
	table.insert(tabUpLevel, {
		"battle_result",
		tostring(result)
	})
	table.insert(tabUpLevel, {
		"team_num",
		tostring(#self.tbTeams)
	})
	table.insert(tabUpLevel, {
		"simulate",
		tostring(self.bSimulate and 1 or 0)
	})
	NovaAPI.UserEventUpload("joint_drill_battle", tabUpLevel)
end
return PlayerJointDrillData
