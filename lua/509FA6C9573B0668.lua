local ThrowGiftsLevelCtrl = class("ThrowGiftsLevelCtrl", BaseCtrl)
local GameResourceLoader = require("Game.Common.Resource.GameResourceLoader")
local ResTypeAny = GameResourceLoader.ResType.Any
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
ThrowGiftsLevelCtrl._mapNodeConfig = {
	Scene = {sComponentName = "Transform"},
	rtScene = {
		sNodeName = "Scene",
		sComponentName = "RectTransform"
	},
	rtGoalRoot = {sComponentName = "Transform"},
	rtObstacleRoot = {sComponentName = "Transform"},
	rtSpecialObstacleRoot = {sComponentName = "Transform"},
	rtBeginning = {
		sComponentName = "RectTransform"
	},
	rttBeginningDrag = {
		sComponentName = "UIDrag",
		callback = "OnDrag_Beginning"
	},
	rtBeginningLine = {
		sComponentName = "RectTransform"
	},
	rtPenguinRoot = {sComponentName = "Transform"},
	BeginningDot = {
		sComponentName = "RectTransform",
		sNodeName = "imgBeginningDot_",
		nCount = 30
	},
	templateBullet = {},
	rtBeginningPos = {
		sComponentName = "RectTransform"
	},
	rtBottle = {
		sComponentName = "RectTransform"
	},
	rtBottleAnim = {sComponentName = "Animator", sNodeName = "rtBottle"},
	BeginningPenguinRoot = {sComponentName = "Animator"},
	rtBlindLevelTrack = {
		sCtrlName = "Game.UI.Activity.ThrowGifts.ThrowGiftLevelTrackLineCtrl"
	},
	rtTemplateTrack = {},
	TMPBeginningCountHint = {sComponentName = "TMP_Text"},
	imgBeginningHint = {},
	rtPenguinBeginningHint = {sComponentName = "Transform"},
	rtDebug = {},
	DebugDot = {
		sComponentName = "RectTransform",
		sNodeName = "imgDebugPoint_",
		nCount = 8
	}
}
ThrowGiftsLevelCtrl._mapEventConfig = {}
ThrowGiftsLevelCtrl._mapRedDotConfig = {}
local rootPath = "UI_Activity/_400005/GoalPerfab/Goal%s.prefab"
function ThrowGiftsLevelCtrl:Awake()
	self.bDebugMode = false
	self.curGiftPenguin = nil
	self.nLevelType = 0
	self.tbObstacle = {}
	self.mapGoal = {}
	self.tbGiftPenguin = {}
	self.sceneSize = {0, 0}
	self.scenePivot = {0, 0}
	self.mapItemPoolConfig = {}
	self.activeGoal = {}
	self.nTotalPenguinCount = -1
	self.curPenguinIdx = 1
	self.curPenguinType = 1
	self.nNextPenguinType = 1
	self.curPenguinSpecialType = 0
	self.nLevelTime = -1
	self.nLevelScore = 0
	self.nTotalThrowGiftCount = 0
	self.nTotalHitGoalCount = 0
	self.nTotalUseItemCount = 0
	self.mapItemUseCount = {}
	self.mapExObstacleOrigin = {}
	self.tbExObstacleCur = {}
	self.bFlying = false
	self.nFlyingTime = 0
	self.maxVelocity = 1200
	self.minVelovity = 400
	self.nLinePointInterval = 0.05
	self.nGoalSpeed = 100
	self.nAngelMax = 90
	self.nAngleMin = -30
	self.nAG = 500
	self.nNavigationPenguinSpeed = 600
	self.nCurActiveItem = 0
	self.mapCurActiveState = {}
	self.tbItemTrackCtrl = {}
	self.curDragBeginPos = nil
	self.dragState = false
	self._mapNode.rtBeginningLine.gameObject:SetActive(false)
	self._mapNode.templateBullet.gameObject:SetActive(false)
	self._mapNode.imgBeginningHint:SetActive(false)
	local forEachItemPool = function(mapData)
		if self.mapItemPoolConfig[mapData.PoolId] == nil then
			self.mapItemPoolConfig[mapData.PoolId] = {}
		end
		table.insert(self.mapItemPoolConfig[mapData.PoolId], {
			nItemId = mapData.ItemId,
			Weight = mapData.Weight
		})
	end
	ForEachTableLine(DataTable.ThrowGiftItemPool, forEachItemPool)
end
function ThrowGiftsLevelCtrl:FadeIn()
end
function ThrowGiftsLevelCtrl:FadeOut()
end
function ThrowGiftsLevelCtrl:OnEnable()
	EventManager.Hit("ThrowGiftSetSpeacialFunc", self)
end
function ThrowGiftsLevelCtrl:OnDisable()
	self:ClearTrackLine()
end
function ThrowGiftsLevelCtrl:OnDestroy()
end
function ThrowGiftsLevelCtrl:OnRelease()
end
function ThrowGiftsLevelCtrl:ClearTrackLine()
	for _, mapCtrl in ipairs(self.tbItemTrackCtrl) do
		mapCtrl:DestroyAll()
		self:UnbindCtrlByNode(mapCtrl)
	end
	self._mapNode.rtBlindLevelTrack:DestroyAll()
	self.tbItemTrackCtrl = {}
end
function ThrowGiftsLevelCtrl:SetLevel(parent, nLevelId, mapActData)
	self.nLevelScore = 0
	self.parent = parent
	self.actData = mapActData
	self.nLevelId = nLevelId
	self.mapItemUseCount = {}
	local mapLevelCfgData = ConfigTable.GetData("ThrowGiftLevel", nLevelId)
	if mapLevelCfgData == nil then
		return
	end
	self.mapLevelCfgData = mapLevelCfgData
	local mapFloorCfgData = ConfigTable.GetData("ThrowGiftFloor", self.mapLevelCfgData.FloorId)
	if mapFloorCfgData == nil then
		return
	end
	if self.mapLevelCfgData.Difficulty == GameEnum.ThrowGiftDifficulty.Blind then
		self._mapNode.rtBlindLevelTrack.gameObject:SetActive(true)
	end
	self.mapFloorCfgData = mapFloorCfgData
	self.nTotalPenguinCount = self.mapFloorCfgData.GiftNum
	if self.nTotalPenguinCount == 0 then
		self.nTotalPenguinCount = -1
	end
	self.nLevelTime = self.mapLevelCfgData.CountDownLimit
	if self.nLevelTime == 0 then
		self.nLevelTime = -1
	end
	self.curPenguinIdx = 1
	self.sceneSize = {
		self._mapNode.Scene.rect.width,
		self._mapNode.Scene.rect.height
	}
	self.scenePivot = {
		self._mapNode.Scene.pivot.x,
		self._mapNode.Scene.pivot.y
	}
	local rtView = self.gameObject:GetComponent("RectTransform")
	self.viewSize = {0, 0}
	if rtView ~= nil then
		self.viewSize = {
			rtView.rect.width,
			rtView.rect.height
		}
	end
	self._mapNode.rtDebug:SetActive(self.bDebugMode)
	local nChildCount = self._mapNode.rtObstacleRoot.childCount
	for i = 0, nChildCount - 1 do
		local goObstacle = self._mapNode.rtObstacleRoot:GetChild(i)
		if goObstacle ~= nil then
			local rtObstacle = goObstacle:GetComponent("RectTransform")
			if rtObstacle ~= nil then
				local tbBounds = self:GetLocalSpaceRect(rtObstacle)
				table.insert(self.tbObstacle, tbBounds)
				print(tbBounds[1] .. " " .. tbBounds[2] .. " " .. tbBounds[3] .. " " .. tbBounds[4] .. " ")
			end
		end
	end
	local nChildCount = self._mapNode.rtSpecialObstacleRoot.childCount
	for i = 0, nChildCount - 1 do
		local goObstacle = self._mapNode.rtSpecialObstacleRoot:GetChild(i)
		if goObstacle ~= nil then
			local rtObstacle = goObstacle:GetComponent("RectTransform")
			if rtObstacle ~= nil then
				local sName = rtObstacle.gameObject.name
				local nId = tonumber(sName)
				if nId == nil then
					printError("Special obstacl name error!" .. sName)
				else
					local mapExObstacleCfgData = ConfigTable.GetData("ThrowGiftSpecialObstacle", nId)
					if mapExObstacleCfgData ~= nil then
						local nInstanceId = rtObstacle.gameObject:GetInstanceID()
						self.mapExObstacleOrigin[nInstanceId] = {}
						local tbBounds = self:GetLocalSpaceRect(rtObstacle)
						self.mapExObstacleOrigin[nInstanceId].tbBounds = tbBounds
						self.mapExObstacleOrigin[nInstanceId].mapConfig = mapExObstacleCfgData
						self.mapExObstacleOrigin[nInstanceId].gameObject = rtObstacle.gameObject
						table.insert(self.tbExObstacleCur, nInstanceId)
						print(tbBounds[1] .. " " .. tbBounds[2] .. " " .. tbBounds[3] .. " " .. tbBounds[4] .. " ")
					end
				end
			end
		end
	end
	local nGoalSpawnpointCount = self._mapNode.rtGoalRoot.childCount
	for i = 0, nGoalSpawnpointCount - 1 do
		local goGoalSpawnpoint = self._mapNode.rtGoalRoot:GetChild(i)
		if goGoalSpawnpoint ~= nil then
			local sName = goGoalSpawnpoint.gameObject.name
			local nId = tonumber(sName)
			if nId == nil then
				printError("\233\133\141\231\189\174\233\148\153\232\175\175 \230\151\160\230\179\149\232\189\172\230\141\162\228\184\186ID:" .. sName)
			else
				local mapSpConfig = ConfigTable.GetData("ThrowGiftSpawnPoints", nId)
				if mapSpConfig ~= nil then
					self.mapGoal[nId] = {}
					self.mapGoal[nId].rtPoint = goGoalSpawnpoint
					self.mapGoal[nId].mapConfig = mapSpConfig
					self.mapGoal[nId].tbExtractedItems = {}
					local nItemPoolId = mapSpConfig.ItemPool
					self.mapGoal[nId].tbOrginPool = self.mapItemPoolConfig[nItemPoolId] == nil and {} or clone(self.mapItemPoolConfig[nItemPoolId])
					self.mapGoal[nId].curCondId = {}
					self.mapGoal[nId].nCurGoalIdx = 1
					self.mapGoal[nId].VxDir = 1
					self.mapGoal[nId].VyDir = 1
				end
			end
		end
	end
	for nSpawnPointId, mapConfigData in pairs(self.mapGoal) do
		if mapConfigData.mapConfig.InitShow then
			self:CreateGoal(nSpawnPointId, mapConfigData)
		end
	end
	if self.mapUpdateTimer ~= nil then
		self.mapUpdateTimer:Cancel()
		self.mapUpdateTimer = nil
	end
	self.mapUpdateTimer = self:AddTimer(0, 0, "OnUpdate", true, true, true)
	if self.nTotalPenguinCount ~= 0 then
		if 0 < self.nTotalPenguinCount then
			self.nTotalPenguinCount = self.nTotalPenguinCount - 1
		end
		if 0 <= self.nTotalPenguinCount then
			NovaAPI.SetTMPText(self._mapNode.TMPBeginningCountHint, self.nTotalPenguinCount + 1)
		else
			NovaAPI.SetTMPText(self._mapNode.TMPBeginningCountHint, "\226\136\158")
		end
		if self.curPenguinIdx > #self.mapFloorCfgData.InitialGiftSort then
			if 0 < #self.mapFloorCfgData.GiftRandom then
				self.curPenguinType = self.mapFloorCfgData.GiftRandom[math.random(#self.mapFloorCfgData.GiftRandom)]
			else
				self.curPenguinType = 1
			end
		else
			self.curPenguinType = self.mapFloorCfgData.InitialGiftSort[self.curPenguinIdx]
		end
		self.curPenguinIdx = self.curPenguinIdx + 1
		self._mapNode.BeginningPenguinRoot.gameObject:SetActive(true)
		self._mapNode.rtBottleAnim:Play("rtBottle_in")
		self._mapNode.BeginningPenguinRoot:Play("penguinRoot_jump")
		WwiseAudioMgr:PostEvent("Mode_Present_shylock_jump")
		self:SetPenguinType(self._mapNode.BeginningPenguinRoot.transform, self.curPenguinType)
		self:SetPenguinType(self._mapNode.rtBottle:Find("AnimRoot/penguinRoot"), self.curPenguinType)
		self:SetBeginningAngle(0, 0)
		local wait = function()
			if self.nTotalPenguinCount ~= 0 then
				self._mapNode.BeginningPenguinRoot.gameObject:SetActive(true)
				self._mapNode.BeginningPenguinRoot:Play("penguinRoot_in")
				WwiseAudioMgr:PostEvent("Mode_Present_shylock")
				self.nNextPenguinType = 1
				if self.curPenguinIdx > #self.mapFloorCfgData.InitialGiftSort then
					if 0 < #self.mapFloorCfgData.GiftRandom then
						self.nNextPenguinType = self.mapFloorCfgData.GiftRandom[math.random(#self.mapFloorCfgData.GiftRandom)]
					else
						self.nNextPenguinType = 1
					end
				else
					self.nNextPenguinType = self.mapFloorCfgData.InitialGiftSort[self.curPenguinIdx]
				end
				self:SetPenguinType(self._mapNode.BeginningPenguinRoot.transform, self.nNextPenguinType)
			else
				self._mapNode.BeginningPenguinRoot.gameObject:SetActive(false)
			end
			self._mapNode.imgBeginningHint:SetActive(true)
			self:SetPenguinType(self._mapNode.rtPenguinBeginningHint, self.curPenguinType)
		end
		wait()
	else
		self._mapNode.BeginningPenguinRoot.gameObject:SetActive(false)
		self:LevelEnd()
	end
end
function ThrowGiftsLevelCtrl:FlyOver(nDelayTime, HitGoalId)
	local waitAnim = function()
		self.nLevelType = 0
		if self.mapLevelCfgData.ThrowGiftLevelCond == GameEnum.ThrowGiftLevelCond.ThrowCount or self.mapLevelCfgData.ThrowGiftLevelCond == GameEnum.ThrowGiftLevelCond.ThrowCountAfterTime then
			self.parent:SetTarget(self.nTotalThrowGiftCount)
		elseif self.mapLevelCfgData.ThrowGiftLevelCond == GameEnum.ThrowGiftLevelCond.Score or self.mapLevelCfgData.ThrowGiftLevelCond == GameEnum.ThrowGiftLevelCond.ScoreAfterTime then
			self.parent:SetTarget(self.nLevelScore)
		elseif self.mapLevelCfgData.ThrowGiftLevelCond == GameEnum.ThrowGiftLevelCond.HitCount or self.mapLevelCfgData.ThrowGiftLevelCond == GameEnum.ThrowGiftLevelCond.HitCountAfterTime then
			self.parent:SetTarget(self.nTotalHitGoalCount)
		end
		if self.mapLevelCfgData.ThrowGiftLevelCond == GameEnum.ThrowGiftLevelCond.ThrowCount then
			self.parent:SetTarget(self.nTotalThrowGiftCount)
			if self.nTotalThrowGiftCount >= self.mapLevelCfgData.throwGiftLevelParams then
				self:LevelEnd(true, 0)
				return
			end
		elseif self.mapLevelCfgData.ThrowGiftLevelCond == GameEnum.ThrowGiftLevelCond.Score then
			self.parent:SetTarget(self.nLevelScore)
			if self.nLevelScore >= self.mapLevelCfgData.throwGiftLevelParams then
				self:LevelEnd(true, 0)
				return
			end
		elseif self.mapLevelCfgData.ThrowGiftLevelCond == GameEnum.ThrowGiftLevelCond.HitCount then
			self.parent:SetTarget(self.nTotalHitGoalCount)
			if self.nTotalHitGoalCount >= self.mapLevelCfgData.throwGiftLevelParams then
				self:LevelEnd(true, 0)
				return
			end
		end
		if self.nTotalPenguinCount ~= 0 then
			self.beginningTweener = DOTween.To(function()
				return self._mapNode.rtBottle.localEulerAngles.z - 360
			end, function(v)
				self._mapNode.rtBottle.localEulerAngles = Vector3(0, 0, v)
			end, 0, 0.5):OnComplete(function()
				self:SetBeginningAngle(0, 0)
				if 0 < self.nTotalPenguinCount and self.mapCurActiveState[102] == nil then
					self.nTotalPenguinCount = self.nTotalPenguinCount - 1
				end
				if 0 <= self.nTotalPenguinCount then
					NovaAPI.SetTMPText(self._mapNode.TMPBeginningCountHint, self.nTotalPenguinCount + 1)
				else
					NovaAPI.SetTMPText(self._mapNode.TMPBeginningCountHint, "\226\136\158")
				end
				if self.curPenguinIdx > #self.mapFloorCfgData.InitialGiftSort then
					if 0 < #self.mapFloorCfgData.GiftRandom then
						self.curPenguinType = self.nNextPenguinType
					else
						self.curPenguinType = 1
					end
				else
					self.curPenguinType = self.mapFloorCfgData.InitialGiftSort[self.curPenguinIdx]
				end
				self.curPenguinIdx = self.curPenguinIdx + 1
				self._mapNode.BeginningPenguinRoot.gameObject:SetActive(true)
				self._mapNode.rtBottleAnim:Play("rtBottle_in")
				self._mapNode.BeginningPenguinRoot:Play("penguinRoot_jump")
				WwiseAudioMgr:PostEvent("Mode_Present_shylock_jump")
				self:SetPenguinType(self._mapNode.BeginningPenguinRoot.transform, self.curPenguinType)
				self:SetPenguinType(self._mapNode.rtBottle:Find("AnimRoot/penguinRoot"), self.curPenguinType)
				self:SetBeginningAngle(0, 0)
				local wait = function()
					self.nLevelType = 1
					self._mapNode.imgBeginningHint:SetActive(true)
					self:SetPenguinType(self._mapNode.rtPenguinBeginningHint, self.curPenguinType)
					if self.nTotalPenguinCount ~= 0 then
						self._mapNode.BeginningPenguinRoot.gameObject:SetActive(true)
						self._mapNode.BeginningPenguinRoot:Play("penguinRoot_in")
						WwiseAudioMgr:PostEvent("Mode_Present_shylock")
						self.nNextPenguinType = 1
						if self.curPenguinIdx > #self.mapFloorCfgData.InitialGiftSort then
							if 0 < #self.mapFloorCfgData.GiftRandom then
								self.nNextPenguinType = self.mapFloorCfgData.GiftRandom[math.random(#self.mapFloorCfgData.GiftRandom)]
							else
								self.nNextPenguinType = 1
							end
						else
							self.nNextPenguinType = self.mapFloorCfgData.InitialGiftSort[self.curPenguinIdx]
						end
						self:SetPenguinType(self._mapNode.BeginningPenguinRoot.transform, self.nNextPenguinType)
					else
						self._mapNode.BeginningPenguinRoot.gameObject:SetActive(false)
					end
				end
				self:AddTimer(1, 0.5, wait, true, true, true)
			end)
		else
			self._mapNode.BeginningPenguinRoot.gameObject:SetActive(false)
			self:LevelEnd(false, 1)
			return
		end
		if HitGoalId ~= nil then
			local mapSpawnPointData = self.mapGoal[HitGoalId]
			if mapSpawnPointData ~= nil and #mapSpawnPointData.tbOrginPool > 0 then
				do
					local tbCurPool = {}
					if mapSpawnPointData.mapConfig.PoolType then
						for _, mapItemData in ipairs(mapSpawnPointData.tbOrginPool) do
							if 1 > table.indexof(mapSpawnPointData.tbExtractedItems, mapItemData.nItemId) then
								table.insert(tbCurPool, mapItemData)
							end
						end
						if #tbCurPool < 2 then
							tbCurPool = {}
							mapSpawnPointData.tbExtractedItems = {}
							for _, mapItemData in ipairs(mapSpawnPointData.tbOrginPool) do
								table.insert(tbCurPool, mapItemData)
							end
						end
					else
						for _, mapItemData in ipairs(mapSpawnPointData.tbOrginPool) do
							table.insert(tbCurPool, mapItemData)
						end
					end
					local tbItems = {}
					for i = 1, 2 do
						local selected = 0
						local totalWeight = 0
						for _, mapItemData in ipairs(tbCurPool) do
							totalWeight = totalWeight + mapItemData.Weight
						end
						local random = math.random(0, totalWeight)
						local curWeight = 0
						for nIdx, mapItemData in ipairs(tbCurPool) do
							curWeight = curWeight + mapItemData.Weight
							if random <= curWeight then
								table.insert(tbItems, mapItemData.nItemId)
								selected = nIdx
								break
							end
						end
						table.remove(tbCurPool, selected)
					end
					local callback = function(nIdx)
						self:Pause(false)
						if mapSpawnPointData.mapConfig.PoolType then
							table.insert(mapSpawnPointData.tbExtractedItems, tbItems[nIdx])
						end
					end
					self.parent:OpenItemSelect(tbItems, callback)
					self:Pause(true)
				end
			end
		end
		local rtScenePos = self._mapNode.rtScene.anchoredPosition
		self._mapNode.rtScene.anchoredPosition = Vector2(0, rtScenePos.y)
		for nInstanceId, mapConfig in pairs(self.mapExObstacleOrigin) do
			if mapConfig.mapConfig.Reset and 1 > table.indexof(self.tbExObstacleCur, nInstanceId) then
				table.insert(self.tbExObstacleCur, nInstanceId)
				mapConfig.gameObject:SetActive(true)
			end
		end
	end
	if nDelayTime == nil or nDelayTime == 0 then
		waitAnim()
	else
		self:AddTimer(1, nDelayTime, waitAnim, true, true, true)
	end
end
function ThrowGiftsLevelCtrl:LevelEnd(bPass, nCond)
	if self.mapUpdateTimer ~= nil then
		self.mapUpdateTimer:Cancel()
		self.mapUpdateTimer = nil
	end
	local openSettle = function()
		self.parent:OpenSettle(bPass, self.nLevelScore, self.nTotalHitGoalCount)
	end
	if self.actData ~= nil then
		local tbUseItems = {}
		for nItemId, nCount in pairs(self.mapItemUseCount) do
			table.insert(tbUseItems, {ItemId = nItemId, Count = nCount})
		end
		self.actData:SettleLevels(self.nLevelId, self.nTotalThrowGiftCount, self.nTotalHitGoalCount, self.nLevelScore, tbUseItems, bPass, openSettle)
	else
		openSettle()
	end
end
function ThrowGiftsLevelCtrl:Pause(bPause)
	if self.mapUpdateTimer ~= nil then
		self.mapUpdateTimer:Pause(bPause)
	end
end
function ThrowGiftsLevelCtrl:ActiveItem(nItemId)
	if self.mapItemUseCount[nItemId] == nil then
		self.mapItemUseCount[nItemId] = 0
	end
	self.mapItemUseCount[nItemId] = self.mapItemUseCount[nItemId] + 1
	if nItemId == 101 then
		if 0 < self.nLevelTime then
			self.nLevelTime = self.nLevelTime + 3
		end
	elseif 106 <= nItemId and nItemId <= 108 then
		self.curPenguinSpecialType = nItemId
		if not self.bFlying then
			if nItemId == 108 then
				WwiseAudioMgr:PostEvent("Mode_Present_prop_anteena")
			else
				WwiseAudioMgr:PostEvent("Mode_Present_prop_gear")
			end
			self:SetPenguinType(self._mapNode.rtBottle:Find("AnimRoot/penguinRoot"), nItemId)
			self:SetPenguinType(self._mapNode.rtPenguinBeginningHint, nItemId)
		end
	else
		self.mapCurActiveState[nItemId] = 10
		self.parent:SetFx(self.mapCurActiveState)
		if nItemId == 105 then
			WwiseAudioMgr:PostEvent("Mode_Present_prop_power")
			self:SetPenguinType(self._mapNode.BeginningPenguinRoot.transform, self.nNextPenguinType)
			self:SetPenguinType(self._mapNode.rtBottle:Find("AnimRoot/penguinRoot"), self.curPenguinType)
			self:SetPenguinType(self._mapNode.rtPenguinBeginningHint, self.curPenguinType)
		elseif nItemId == 103 then
			WwiseAudioMgr:PostEvent("Mode_Present_lowtime_lp")
		elseif nItemId == 104 then
			WwiseAudioMgr:PostEvent("Mode_Present_doubletime_lp")
		end
		self.parent:SetBuffShow(nItemId, true)
		self.parent:SetBuffTime(nItemId, 10)
	end
end
function ThrowGiftsLevelCtrl:LevelStart()
	if self.mapLevelCfgData.Difficulty == GameEnum.ThrowGiftDifficulty.Blind then
		self.nLevelType = 3
		local maxScenePosX = -math.abs((1 - self.scenePivot[1]) * self.sceneSize[1])
		self.beginningTweener = DOTween.To(function()
			return 0
		end, function(v)
			local sum = v <= 0.5 and v or v <= 2.5 and 0.5 or 3 - v
			local posX = math.sin(math.pi * sum) * maxScenePosX
			local rtScenePos = self._mapNode.rtScene.anchoredPosition
			self._mapNode.rtScene.anchoredPosition = Vector2(posX, rtScenePos.y)
		end, 3, 3):OnComplete(function()
			self.nLevelType = 1
		end)
	else
		self.nLevelType = 1
	end
end
function ThrowGiftsLevelCtrl:CheckAABB(bounds1, bounds2)
	return bounds1[2] >= bounds2[1] and bounds1[1] <= bounds2[2] and bounds1[4] >= bounds2[3] and bounds1[3] <= bounds2[4]
end
function ThrowGiftsLevelCtrl:CheckAABBGoal(bounds1, goalPos, tbOffsets, bGoal)
	if self.bDebugMode then
		if bGoal then
			self._mapNode.DebugDot[1].anchoredPosition = Vector2(tbOffsets[1] + goalPos.x, tbOffsets[3] + goalPos.y)
			self._mapNode.DebugDot[2].anchoredPosition = Vector2(tbOffsets[2] + goalPos.x, tbOffsets[3] + goalPos.y)
			self._mapNode.DebugDot[3].anchoredPosition = Vector2(tbOffsets[1] + goalPos.x, tbOffsets[4] + goalPos.y)
			self._mapNode.DebugDot[4].anchoredPosition = Vector2(tbOffsets[2] + goalPos.x, tbOffsets[4] + goalPos.y)
		else
			self._mapNode.DebugDot[5].anchoredPosition = Vector2(tbOffsets[1] + goalPos.x, tbOffsets[3] + goalPos.y)
			self._mapNode.DebugDot[6].anchoredPosition = Vector2(tbOffsets[2] + goalPos.x, tbOffsets[3] + goalPos.y)
			self._mapNode.DebugDot[7].anchoredPosition = Vector2(tbOffsets[1] + goalPos.x, tbOffsets[4] + goalPos.y)
			self._mapNode.DebugDot[8].anchoredPosition = Vector2(tbOffsets[2] + goalPos.x, tbOffsets[4] + goalPos.y)
		end
	end
	return bounds1[2] >= tbOffsets[1] + goalPos.x and bounds1[1] <= tbOffsets[2] + goalPos.x and bounds1[4] >= tbOffsets[3] + goalPos.y and bounds1[3] <= tbOffsets[4] + goalPos.y
end
function ThrowGiftsLevelCtrl:GetLocalSpaceRect(rectTransform)
	if rectTransform == nil then
		return {
			0,
			0,
			0,
			0
		}
	end
	local pivotX = rectTransform.pivot.x
	local pivotY = rectTransform.pivot.y
	local width = rectTransform.rect.width
	local height = rectTransform.rect.height
	local xMin = -pivotX * width + rectTransform.anchoredPosition.x
	local xMax = (1 - pivotX) * width + rectTransform.anchoredPosition.x
	local yMin = -pivotY * height + rectTransform.anchoredPosition.y
	local yMax = (1 - pivotY) * height + rectTransform.anchoredPosition.y
	return {
		xMin,
		xMax,
		yMin,
		yMax
	}
end
function ThrowGiftsLevelCtrl:OnUpdate()
	if self.mapUpdateTimer == nil then
		return
	end
	local nDeltaTime = self.mapUpdateTimer:GetDelTime()
	if self.nLevelTime > 0 then
		if self.nLevelType ~= 3 then
			if self.mapCurActiveState[103] ~= nil then
				self.nLevelTime = self.nLevelTime - nDeltaTime * 0.5
			else
				self.nLevelTime = self.nLevelTime - nDeltaTime
			end
		end
		self.nLevelTime = math.max(self.nLevelTime, 0)
		self.parent:SetTime(self.nLevelTime)
		if self.nLevelTime <= 0 then
			if self.mapLevelCfgData.ThrowGiftLevelCond == GameEnum.ThrowGiftLevelCond.ThrowCountAfterTime then
				if self.nTotalThrowGiftCount >= self.mapLevelCfgData.throwGiftLevelParams then
					self:LevelEnd(true, 0)
				else
					self:LevelEnd(false, 1)
				end
			elseif self.mapLevelCfgData.ThrowGiftLevelCond == GameEnum.ThrowGiftLevelCond.ScoreAfterTime then
				if self.nLevelScore >= self.mapLevelCfgData.throwGiftLevelParams then
					self:LevelEnd(true, 0)
				else
					self:LevelEnd(false, 1)
				end
			elseif self.mapLevelCfgData.ThrowGiftLevelCond == GameEnum.ThrowGiftLevelCond.HitCountAfterTime then
				if self.nTotalHitGoalCount >= self.mapLevelCfgData.throwGiftLevelParams then
					self:LevelEnd(true, 0)
				else
					self:LevelEnd(false, 1)
				end
			else
				self:LevelEnd(false, 2)
			end
			return
		end
	end
	local tbRemovedState = {}
	for nState, nTime in pairs(self.mapCurActiveState) do
		self.mapCurActiveState[nState] = self.mapCurActiveState[nState] - nDeltaTime
		self.parent:SetBuffTime(nState, nTime)
		if 0 >= self.mapCurActiveState[nState] then
			table.insert(tbRemovedState, nState)
			self.parent:SetBuffShow(nState, false)
		end
	end
	local bChange = 0 < #tbRemovedState
	for _, nState in ipairs(tbRemovedState) do
		self.mapCurActiveState[nState] = nil
		if nState == 105 then
			self:SetPenguinType(self._mapNode.BeginningPenguinRoot.transform, self.nNextPenguinType)
			self:SetPenguinType(self._mapNode.rtBottle:Find("AnimRoot/penguinRoot"), self.curPenguinType)
			self:SetPenguinType(self._mapNode.rtPenguinBeginningHint, self.curPenguinType)
			if self.bFlying and self.curGiftPenguin ~= nil then
				local goPenguin = self.curGiftPenguin.goGiftPenguin
				local rtPenguin = goPenguin:GetComponent("RectTransform")
				local goImgRoot = rtPenguin:Find("imgRoot")
				local imgFx = goImgRoot:Find("imgFx")
				imgFx.gameObject:SetActive(false)
			end
		elseif nState == 103 then
			WwiseAudioMgr:PostEvent("Mode_Present_lowtime_lp_stop")
		elseif nState == 104 then
			WwiseAudioMgr:PostEvent("Mode_Present_doubletime_lp_stop")
		end
	end
	if bChange then
		self.parent:SetFx(self.mapCurActiveState)
	end
	for nId, mapAciveGoal in pairs(self.activeGoal) do
		local mapConfig = self.mapGoal[nId]
		local moveX = 0
		local moveY = 0
		if mapConfig ~= nil then
			moveX = mapConfig.mapConfig.MoveX
			moveY = mapConfig.mapConfig.MoveY
			if 0 < moveX or 0 < moveY then
				local curPos = mapAciveGoal.rtGoal.anchoredPosition
				local rtSpawnPoint = mapConfig.rtPoint
				local nXMax = rtSpawnPoint.anchoredPosition.x + moveX
				local nYMax = rtSpawnPoint.anchoredPosition.y + moveY
				local nXMin = rtSpawnPoint.anchoredPosition.x - moveX
				local nYMin = rtSpawnPoint.anchoredPosition.y - moveY
				local nCurMove = 0
				if self.mapCurActiveState[103] ~= nil then
					nCurMove = self.nGoalSpeed * nDeltaTime * 0.5
				else
					nCurMove = self.nGoalSpeed * nDeltaTime
				end
				local nAfterX = curPos.x + nCurMove * mapConfig.VxDir
				local nAfterY = curPos.y + nCurMove * mapConfig.VyDir
				if nXMax < nAfterX then
					nAfterX = nXMax
					mapConfig.VxDir = -mapConfig.VxDir
				elseif nXMin > nAfterX then
					nAfterX = nXMin
					mapConfig.VxDir = -mapConfig.VxDir
				end
				if nYMax < nAfterY then
					nAfterY = nYMax
					mapConfig.VyDir = -mapConfig.VyDir
				elseif nYMin > nAfterY then
					nAfterY = nYMin
					mapConfig.VyDir = -mapConfig.VyDir
				end
				mapAciveGoal.rtGoal.anchoredPosition = Vector2(nAfterX, nAfterY)
			end
		end
	end
	if not self.bFlying then
		return
	end
	if self.curGiftPenguin == nil then
		return
	end
	local nCurPosX, nCurPosY, curGiftPenguinBounds
	if self.curGiftPenguin.nSpecialType == 106 then
		nCurPosX, nCurPosY, curGiftPenguinBounds = self:NavigationPenguinUpdate(nDeltaTime)
	elseif self.curGiftPenguin.nSpecialType == 107 then
		nCurPosX, nCurPosY, curGiftPenguinBounds = self:HelmetPenguinUpdate(nDeltaTime)
	elseif self.curGiftPenguin.nSpecialType == 108 then
		nCurPosX, nCurPosY, curGiftPenguinBounds = self:AntennaPenguinUpdate(nDeltaTime)
	else
		nCurPosX, nCurPosY, curGiftPenguinBounds = self:NormalPenguinUpdate(nDeltaTime)
	end
	if not self.bFlying then
		self:FlyOver()
		return
	end
	if self.mapLevelCfgData.Difficulty == GameEnum.ThrowGiftDifficulty.Blind and self.nFlyingTime - self._mapNode.rtBlindLevelTrack.nPrevTimer >= self.nLinePointInterval * 2 then
		self._mapNode.rtBlindLevelTrack.nPrevTimer = self.nFlyingTime
		self._mapNode.rtBlindLevelTrack:AddDot(Vector2(nCurPosX, nCurPosY))
	end
	local hitGoalId = 0
	local hitPos
	for nId, mapAciveGoal in pairs(self.activeGoal) do
		local GoalParentPos = mapAciveGoal.rtGoal.anchoredPosition
		local bHitGoal = self:CheckAABBGoal(curGiftPenguinBounds, GoalParentPos, mapAciveGoal.tbOffsetHitArea, true)
		if bHitGoal then
			local curVy = self.curGiftPenguin.nStartVelocityY - self.nFlyingTime * self.nAG
			if 0 < curVy and self.curGiftPenguin.nSpecialType ~= 106 and self.curGiftPenguin.nSpecialType ~= 107 then
				print("hit goal edge")
				destroy(self.curGiftPenguin.goGiftPenguin.gameObject)
				self.curGiftPenguin = nil
				self.bFlying = false
				break
			else
				print("hit goal\239\188\129")
				hitPos = Vector2(nCurPosX, nCurPosY)
				destroy(self.curGiftPenguin.goGiftPenguin.gameObject)
				hitGoalId = nId
				self.curGiftPenguin = nil
				self.bFlying = false
				break
			end
		end
		if self.curGiftPenguin.nSpecialType ~= 107 then
			local bHitObstacle = self:CheckAABBGoal(curGiftPenguinBounds, GoalParentPos, mapAciveGoal.tbOffsetObstacle)
			if bHitObstacle then
				self:DestroyPenguin()
				self.bFlying = false
				break
			end
		end
	end
	if 0 < hitGoalId then
		self:HitGoal(hitPos, hitGoalId)
		self:FlyOver(0.5, hitGoalId)
		return
	end
	if not self.bFlying then
		self:FlyOver()
		return
	end
	if nCurPosX > 0.5 * self.sceneSize[1] or nCurPosX < -0.5 * self.sceneSize[1] or nCurPosY > 0.5 * self.sceneSize[2] or nCurPosY < -0.5 * self.sceneSize[2] then
		print("hit border")
		self:DestroyPenguin()
		self.bFlying = false
	end
	if not self.bFlying then
		self:FlyOver()
		return
	end
	local rtScenePos = self._mapNode.rtScene.anchoredPosition
	local curPosXInScreen = self.sceneSize[1] * 0.5 + nCurPosX + rtScenePos.x
	if curPosXInScreen > self.viewSize[1] / 2 then
		local sumX = curPosXInScreen - self.viewSize[1] / 2
		local nFinX = rtScenePos.x - sumX
		local maxScenePosX = (1 - self.scenePivot[1]) * self.sceneSize[1]
		if nFinX <= -math.abs(maxScenePosX) then
			nFinX = -math.abs(maxScenePosX)
		end
		self._mapNode.rtScene.anchoredPosition = Vector2(nFinX, rtScenePos.y)
	end
end
function ThrowGiftsLevelCtrl:NormalPenguinUpdate(nDeltaTime)
	self.nFlyingTime = self.nFlyingTime + nDeltaTime
	local nCurPosX = self.curGiftPenguin.mapStartPos.x + self.nFlyingTime * self.curGiftPenguin.nStartVelocityX
	local nCurPosY = self.curGiftPenguin.mapStartPos.y + self.nFlyingTime * self.curGiftPenguin.nStartVelocityY - 0.5 * self.nAG * self.nFlyingTime * self.nFlyingTime
	self.curGiftPenguin.goGiftPenguin.anchoredPosition = Vector2(nCurPosX, nCurPosY)
	local curGiftPenguinBounds = self:GetLocalSpaceRect(self.curGiftPenguin.goGiftPenguin)
	local curVy = self.curGiftPenguin.nStartVelocityY - self.nAG * self.nFlyingTime
	if self.curGiftPenguin.rtImgRoot ~= nil then
		local nFlyAngle = math.deg(math.atan(curVy, self.curGiftPenguin.nStartVelocityX))
		self.curGiftPenguin.rtImgRoot.localEulerAngles = Vector3(0, 0, nFlyAngle)
	end
	for _, tbBounds in ipairs(self.tbObstacle) do
		local bHit = self:CheckAABB(curGiftPenguinBounds, tbBounds)
		if bHit then
			self:DestroyPenguin()
			self.bFlying = false
			break
		end
	end
	if not self.bFlying then
		return
	end
	local tbHittedObs = {}
	for _, nSpecialId in ipairs(self.tbExObstacleCur) do
		local mapConfig = self.mapExObstacleOrigin[nSpecialId]
		if mapConfig ~= nil then
			local bHit = self:CheckAABB(curGiftPenguinBounds, mapConfig.tbBounds)
			if bHit then
				self.bFlying = self:HitSpecialObstacle(nSpecialId)
				table.insert(tbHittedObs, nSpecialId)
				if not self.bFlying then
					self:DestroyPenguin()
					break
				end
			end
		end
	end
	for _, nId in ipairs(tbHittedObs) do
		table.removebyvalue(self.tbExObstacleCur, nId, true)
	end
	return nCurPosX, nCurPosY, curGiftPenguinBounds
end
function ThrowGiftsLevelCtrl:AntennaPenguinUpdate(nDeltaTime)
	self.nFlyingTime = self.nFlyingTime + nDeltaTime
	local nCurPosX = self.curGiftPenguin.mapStartPos.x + self.nFlyingTime * self.curGiftPenguin.nStartVelocityX
	local nCurPosY = self.curGiftPenguin.mapStartPos.y + self.nFlyingTime * self.curGiftPenguin.nStartVelocityY - 0.5 * self.nAG * self.nFlyingTime * self.nFlyingTime
	self.curGiftPenguin.goGiftPenguin.anchoredPosition = Vector2(nCurPosX, nCurPosY)
	local curGiftPenguinBounds = self:GetLocalSpaceRect(self.curGiftPenguin.goGiftPenguin)
	if self.tbItemTrackCtrl[self.curGiftPenguin.nTrackIdx] ~= nil then
		local mapTrackCtrl = self.tbItemTrackCtrl[self.curGiftPenguin.nTrackIdx]
		if self.nFlyingTime - mapTrackCtrl.nPrevTimer >= self.nLinePointInterval * 2 then
			mapTrackCtrl.nPrevTimer = self.nFlyingTime
			mapTrackCtrl:AddDot(Vector2(nCurPosX, nCurPosY))
		end
	end
	local curVy = self.curGiftPenguin.nStartVelocityY - self.nAG * self.nFlyingTime
	if self.curGiftPenguin.rtImgRoot ~= nil then
		local nFlyAngle = math.deg(math.atan(curVy, self.curGiftPenguin.nStartVelocityX))
		self.curGiftPenguin.rtImgRoot.localEulerAngles = Vector3(0, 0, nFlyAngle)
	end
	for _, tbBounds in ipairs(self.tbObstacle) do
		local bHit = self:CheckAABB(curGiftPenguinBounds, tbBounds)
		if bHit then
			self:DestroyPenguin()
			self.bFlying = false
			break
		end
	end
	if not self.bFlying then
		return
	end
	local tbHittedObs = {}
	for _, nSpecialId in ipairs(self.tbExObstacleCur) do
		local mapConfig = self.mapExObstacleOrigin[nSpecialId]
		if mapConfig ~= nil then
			local bHit = self:CheckAABB(curGiftPenguinBounds, mapConfig.tbBounds)
			if bHit then
				self.bFlying = self:HitSpecialObstacle(nSpecialId)
				table.insert(tbHittedObs, nSpecialId)
				if not self.bFlying then
					self:DestroyPenguin()
					break
				end
			end
		end
	end
	for _, nId in ipairs(tbHittedObs) do
		table.removebyvalue(self.tbExObstacleCur, nId, true)
	end
	return nCurPosX, nCurPosY, curGiftPenguinBounds
end
function ThrowGiftsLevelCtrl:HelmetPenguinUpdate(nDeltaTime)
	self.nFlyingTime = self.nFlyingTime + nDeltaTime
	local nCurPosX = self.curGiftPenguin.mapStartPos.x + self.nFlyingTime * self.curGiftPenguin.nStartVelocityX
	local nCurPosY = self.curGiftPenguin.mapStartPos.y + self.nFlyingTime * self.curGiftPenguin.nStartVelocityY - 0.5 * self.nAG * self.nFlyingTime * self.nFlyingTime
	self.curGiftPenguin.goGiftPenguin.anchoredPosition = Vector2(nCurPosX, nCurPosY)
	local curGiftPenguinBounds = self:GetLocalSpaceRect(self.curGiftPenguin.goGiftPenguin)
	local curVy = self.curGiftPenguin.nStartVelocityY - self.nAG * self.nFlyingTime
	if self.curGiftPenguin.rtImgRoot ~= nil then
		local nFlyAngle = math.deg(math.atan(curVy, self.curGiftPenguin.nStartVelocityX))
		self.curGiftPenguin.rtImgRoot.localEulerAngles = Vector3(0, 0, nFlyAngle)
	end
	local tbHittedObs = {}
	for _, nSpecialId in ipairs(self.tbExObstacleCur) do
		local mapConfig = self.mapExObstacleOrigin[nSpecialId]
		if mapConfig ~= nil then
			local bHit = self:CheckAABB(curGiftPenguinBounds, mapConfig.tbBounds)
			if bHit then
				self:HitSpecialObstacle(nSpecialId)
				table.insert(tbHittedObs, nSpecialId)
			end
		end
	end
	for _, nId in ipairs(tbHittedObs) do
		table.removebyvalue(self.tbExObstacleCur, nId, true)
	end
	return nCurPosX, nCurPosY, curGiftPenguinBounds
end
function ThrowGiftsLevelCtrl:NavigationPenguinUpdate(nDeltaTime)
	local checkGetGoal = function(nCurPosX, nCurPosY)
		for nId, mapAciveGoal in pairs(self.activeGoal) do
			local nGoalPosX = mapAciveGoal.rtGoal.anchoredPosition.x
			local nGoalPosY = mapAciveGoal.rtGoal.anchoredPosition.y
			if nCurPosX >= mapAciveGoal.tbOffsetHitArea[1] + nGoalPosX and nCurPosX <= mapAciveGoal.tbOffsetHitArea[2] + nGoalPosX and nCurPosY >= nGoalPosY then
				return mapAciveGoal.rtGoal
			end
		end
		return nil
	end
	self.nFlyingTime = self.nFlyingTime + nDeltaTime
	local t_stop = self.curGiftPenguin.nStartVelocityY / self.nAG
	local nCurPosY = 0
	local nCurPosX = 0
	if self.curGiftPenguin.targetGoal == nil then
		if t_stop >= self.nFlyingTime then
			nCurPosY = self.curGiftPenguin.mapStartPos.y + self.nFlyingTime * self.curGiftPenguin.nStartVelocityY - 0.5 * self.nAG * self.nFlyingTime * self.nFlyingTime
		else
			nCurPosY = self.curGiftPenguin.mapStartPos.y + t_stop * self.curGiftPenguin.nStartVelocityY - 0.5 * self.nAG * t_stop * t_stop
		end
		nCurPosX = self.curGiftPenguin.mapStartPos.x + self.nFlyingTime * self.curGiftPenguin.nStartVelocityX
		local checkGoal = checkGetGoal(nCurPosX, nCurPosY)
		if checkGoal ~= nil then
			self.curGiftPenguin.targetGoal = checkGoal
			self.curGiftPenguin.nGetTargetTime = self.nFlyingTime
		end
	else
		if t_stop >= self.curGiftPenguin.nGetTargetTime then
			nCurPosY = self.curGiftPenguin.mapStartPos.y + self.curGiftPenguin.nGetTargetTime * self.curGiftPenguin.nStartVelocityY - 0.5 * self.nAG * self.curGiftPenguin.nGetTargetTime * self.curGiftPenguin.nGetTargetTime
		else
			nCurPosY = self.curGiftPenguin.mapStartPos.y + t_stop * self.curGiftPenguin.nStartVelocityY - 0.5 * self.nAG * t_stop * t_stop
		end
		local nSumTime = self.nFlyingTime - self.curGiftPenguin.nGetTargetTime
		nCurPosY = nCurPosY - nSumTime * self.nNavigationPenguinSpeed
		local nTargetX = self.curGiftPenguin.targetGoal.anchoredPosition.x
		nCurPosX = self.curGiftPenguin.goGiftPenguin.anchoredPosition.x
		local sumMove = (nTargetX - nCurPosX) / 0.1 * nDeltaTime
		nCurPosX = sumMove + nCurPosX
	end
	self.curGiftPenguin.goGiftPenguin.anchoredPosition = Vector2(nCurPosX, nCurPosY)
	local curGiftPenguinBounds = self:GetLocalSpaceRect(self.curGiftPenguin.goGiftPenguin)
	local curVy = math.max(self.curGiftPenguin.nStartVelocityY - self.nAG * self.nFlyingTime, 0)
	if self.curGiftPenguin.rtImgRoot ~= nil then
		if self.curGiftPenguin.targetGoal == nil then
			local nFlyAngle = math.deg(math.atan(curVy, self.curGiftPenguin.nStartVelocityX))
			self.curGiftPenguin.rtImgRoot.localEulerAngles = Vector3(0, 0, nFlyAngle)
		else
			local nCurAngle = self.curGiftPenguin.rtImgRoot.localEulerAngles.z
			local nAngle = 90 * nDeltaTime
			nCurAngle = math.min(nCurAngle + nAngle, 90)
			self.curGiftPenguin.rtImgRoot.localEulerAngles = Vector3(0, 0, nCurAngle)
		end
	end
	for _, tbBounds in ipairs(self.tbObstacle) do
		local bHit = self:CheckAABB(curGiftPenguinBounds, tbBounds)
		if bHit then
			print("hit Obstacle")
			destroy(self.curGiftPenguin.goGiftPenguin.gameObject)
			self.curGiftPenguin = nil
			self.bFlying = false
			break
		end
	end
	if not self.bFlying then
		return
	end
	local tbHittedObs = {}
	for _, nSpecialId in ipairs(self.tbExObstacleCur) do
		local mapConfig = self.mapExObstacleOrigin[nSpecialId]
		if mapConfig ~= nil then
			local bHit = self:CheckAABB(curGiftPenguinBounds, mapConfig.tbBounds)
			if bHit then
				self.bFlying = self:HitSpecialObstacle(nSpecialId)
				table.insert(tbHittedObs, nSpecialId)
				if not self.bFlying then
					self:DestroyPenguin()
					break
				end
			end
		end
	end
	for _, nId in ipairs(tbHittedObs) do
		table.removebyvalue(self.tbExObstacleCur, nId, true)
	end
	return nCurPosX, nCurPosY, curGiftPenguinBounds
end
function ThrowGiftsLevelCtrl:SetBeginningAngle(nAngle, nVelocity)
	local fixedAngle = nAngle == 0 and 0 or nAngle - 90
	self._mapNode.rtBottle.localEulerAngles = Vector3(0, 0, fixedAngle)
	local sumScale = nVelocity / self.maxVelocity * 0.2
	self._mapNode.rtBottle.localScale = Vector3(1 + sumScale, 1 - sumScale, 1)
end
function ThrowGiftsLevelCtrl:SetBeginningLine(nAngle, nVelocity)
	if self.curPenguinSpecialType == 106 then
		if nVelocity == 0 then
			self._mapNode.rtBeginningLine.gameObject:SetActive(false)
			return
		end
		self._mapNode.rtBeginningLine.gameObject:SetActive(true)
		self._mapNode.rtBeginningLine.position = self._mapNode.rtBeginningPos.position
		local vX = nVelocity * math.cos(math.rad(nAngle))
		local vY = nVelocity * math.sin(math.rad(nAngle))
		local t_stop = vY / self.nAG
		for i = 1, 30 do
			if i <= 10 then
				local dotx = self.nLinePointInterval * i * vX
				local dotY = 0
				if t_stop >= self.nLinePointInterval * i then
					dotY = self.nLinePointInterval * i * vY - 0.5 * self.nAG * (self.nLinePointInterval * i) * (self.nLinePointInterval * i)
				else
					dotY = t_stop * vY - 0.5 * self.nAG * t_stop * t_stop
				end
				self._mapNode.BeginningDot[i].anchoredPosition = Vector2(dotx, dotY)
				self._mapNode.BeginningDot[i].gameObject:SetActive(true)
			else
				self._mapNode.BeginningDot[i].gameObject:SetActive(false)
			end
		end
	elseif self.curPenguinSpecialType == 108 then
		if nVelocity == 0 then
			self._mapNode.rtBeginningLine.gameObject:SetActive(false)
			return
		end
		self._mapNode.rtBeginningLine.gameObject:SetActive(true)
		self._mapNode.rtBeginningLine.position = self._mapNode.rtBeginningPos.position
		local vX = nVelocity * math.cos(math.rad(nAngle))
		local vY = nVelocity * math.sin(math.rad(nAngle))
		for i = 1, 30 do
			local dotx = self.nLinePointInterval * i * vX
			local dotY = self.nLinePointInterval * i * vY - 0.5 * self.nAG * (self.nLinePointInterval * i) * (self.nLinePointInterval * i)
			self._mapNode.BeginningDot[i].anchoredPosition = Vector2(dotx, dotY)
			self._mapNode.BeginningDot[i].gameObject:SetActive(true)
		end
	else
		if nVelocity == 0 then
			self._mapNode.rtBeginningLine.gameObject:SetActive(false)
			return
		end
		self._mapNode.rtBeginningLine.gameObject:SetActive(true)
		self._mapNode.rtBeginningLine.position = self._mapNode.rtBeginningPos.position
		local vX = nVelocity * math.cos(math.rad(nAngle))
		local vY = nVelocity * math.sin(math.rad(nAngle))
		for i = 1, 30 do
			if i <= 10 then
				local dotx = self.nLinePointInterval * i * vX
				local dotY = self.nLinePointInterval * i * vY - 0.5 * self.nAG * (self.nLinePointInterval * i) * (self.nLinePointInterval * i)
				self._mapNode.BeginningDot[i].anchoredPosition = Vector2(dotx, dotY)
				self._mapNode.BeginningDot[i].gameObject:SetActive(true)
			else
				self._mapNode.BeginningDot[i].gameObject:SetActive(false)
			end
		end
	end
end
function ThrowGiftsLevelCtrl:HitSpecialObstacle(nSpecialId)
	local mapOriginConfig = self.mapExObstacleOrigin[nSpecialId]
	if mapOriginConfig ~= nil then
		mapOriginConfig.gameObject:SetActive(false)
		if mapOriginConfig.mapConfig.Type == GameEnum.SpecialObstacleType.Obstacle then
			return false
		elseif mapOriginConfig.mapConfig.Type == GameEnum.SpecialObstacleType.Score then
			local nScore = mapOriginConfig.mapConfig.Param[1]
			if nScore ~= nil then
				self:AddScore(nScore)
			end
			return true
		end
	end
	return true
end
function ThrowGiftsLevelCtrl:AddScore(nScore)
	self.nLevelScore = self.nLevelScore + nScore
	if self.mapCurActiveState[105] ~= nil then
		self.nLevelScore = self.nLevelScore + nScore
	end
	self.parent:SetScore(self.nLevelScore)
end
function ThrowGiftsLevelCtrl:SetPenguinType(rtPenguinRoot, nType)
	if rtPenguinRoot == nil then
		return
	end
	local rtRed = rtPenguinRoot:Find("penguin_red")
	local rtYellow = rtPenguinRoot:Find("penguin_yellow")
	local rtGreen = rtPenguinRoot:Find("penguin_green")
	local rtGoggles = rtPenguinRoot:Find("penguin_goggles")
	local rtAntenna = rtPenguinRoot:Find("penguin_antenna")
	local rtHelmet = rtPenguinRoot:Find("penguin_helmet")
	local imgFx = rtPenguinRoot:Find("imgFx")
	rtRed.gameObject:SetActive(nType == 2)
	rtYellow.gameObject:SetActive(nType == 3)
	rtGreen.gameObject:SetActive(nType == 1)
	rtGoggles.gameObject:SetActive(nType == 106)
	rtAntenna.gameObject:SetActive(nType == 108)
	rtHelmet.gameObject:SetActive(nType == 107)
	imgFx.gameObject:SetActive(self.mapCurActiveState[105] ~= nil)
end
function ThrowGiftsLevelCtrl:CreateGoal(nSpawnPointId, mapConfig)
	local pointOriginPosX = mapConfig.rtPoint.anchoredPosition.x
	local pointOriginPosY = mapConfig.rtPoint.anchoredPosition.y
	local randomX = math.random(-mapConfig.mapConfig.SpawnRangeTypeX, mapConfig.mapConfig.SpawnRangeTypeX)
	local randomY = math.random(-mapConfig.mapConfig.SpawnRangeTypeY, mapConfig.mapConfig.SpawnRangeTypeY)
	local nType = 0
	if mapConfig.mapConfig.IsRandom then
		nType = mapConfig.mapConfig.GoalType[math.random(1, #mapConfig.mapConfig.GoalType)]
	else
		if mapConfig.nCurGoalIdx > #mapConfig.mapConfig.GoalType then
			mapConfig.nCurGoalIdx = 1
		end
		nType = mapConfig.mapConfig.GoalType[mapConfig.nCurGoalIdx]
		mapConfig.nCurGoalIdx = mapConfig.nCurGoalIdx + 1
	end
	local sPath = string.format(rootPath, nType)
	local goGoalPerfab = GameResourceLoader.LoadAsset(ResTypeAny, Settings.AB_ROOT_PATH .. sPath, typeof(Object))
	if goGoalPerfab ~= nil then
		local goGoal = instantiate(goGoalPerfab, self._mapNode.rtGoalRoot)
		if self.activeGoal[nSpawnPointId] ~= nil then
			destroy(self.activeGoal[nSpawnPointId].rtGoal.gameObject)
			self.activeGoal[nSpawnPointId].rtGoal = nil
			self.activeGoal[nSpawnPointId].rtHitArea = nil
			self.activeGoal[nSpawnPointId].rtObstacle = nil
		end
		self.activeGoal[nSpawnPointId] = {}
		local rtGoal = goGoal:GetComponent("RectTransform")
		rtGoal.anchoredPosition = Vector2(pointOriginPosX + randomX, pointOriginPosY + randomY)
		local rtHitArea = rtGoal:Find("HitArea")
		local rtObstacle = rtGoal:Find("Obstacle")
		if rtHitArea == nil or rtObstacle == nil then
			printError("\233\162\132\229\136\182\228\189\147\231\187\147\230\158\132\233\148\153\232\175\175\239\188\154" .. sPath)
			destroy(goGoal)
			return
		end
		self.activeGoal[nSpawnPointId].rtGoal = rtGoal
		local rtCompHitArea = rtHitArea:GetComponent("RectTransform")
		local rtCompObstacle = rtObstacle:GetComponent("RectTransform")
		local xMinOffsetrtHitArea = rtCompHitArea.anchoredPosition.x - rtCompHitArea.pivot.x * rtCompHitArea.rect.width
		local xMaxOffsetrtHitArea = rtCompHitArea.anchoredPosition.x + (1 - rtCompHitArea.pivot.x) * rtCompHitArea.rect.width
		local yMinOffsetrtHitArea = rtCompHitArea.anchoredPosition.y - rtCompHitArea.pivot.y * rtCompHitArea.rect.height
		local yMaxOffsetrtHitArea = rtCompHitArea.anchoredPosition.y + (1 - rtCompHitArea.pivot.y) * rtCompHitArea.rect.height
		self.activeGoal[nSpawnPointId].tbOffsetHitArea = {
			xMinOffsetrtHitArea,
			xMaxOffsetrtHitArea,
			yMinOffsetrtHitArea,
			yMaxOffsetrtHitArea
		}
		local xMinOffsetObstacle = rtCompObstacle.anchoredPosition.x - rtCompObstacle.pivot.x * rtCompObstacle.rect.width
		local xMaxOffsetObstacle = rtCompObstacle.anchoredPosition.x + (1 - rtCompObstacle.pivot.x) * rtCompObstacle.rect.width
		local yMinOffsetObstacle = rtCompObstacle.anchoredPosition.y - rtCompObstacle.pivot.y * rtCompObstacle.rect.height
		local yMaxOffsetObstacle = rtCompObstacle.anchoredPosition.y + (1 - rtCompObstacle.pivot.y) * rtCompObstacle.rect.height
		self.activeGoal[nSpawnPointId].tbOffsetObstacle = {
			xMinOffsetObstacle,
			xMaxOffsetObstacle,
			yMinOffsetObstacle,
			yMaxOffsetObstacle
		}
	end
end
function ThrowGiftsLevelCtrl:CreateThrowPenguin(nAngle, nVelocity, initPos, nType, nSpecialType)
	self._mapNode.imgBeginningHint:SetActive(false)
	local goPenguin = instantiate(self._mapNode.templateBullet, self._mapNode.rtPenguinRoot)
	local rtPenguin = goPenguin:GetComponent("RectTransform")
	local goImgRoot = rtPenguin:Find("imgRoot")
	local imgFx = goImgRoot:Find("imgFx")
	local rtRed = goImgRoot:Find("penguin_red")
	local rtYellow = goImgRoot:Find("penguin_yellow")
	local rtGreen = goImgRoot:Find("penguin_green")
	local rtGoggles = goImgRoot:Find("penguin_goggles")
	local rtAntenna = goImgRoot:Find("penguin_antenna")
	local rtHelmet = goImgRoot:Find("penguin_helmet")
	local rtImgRoot
	if goImgRoot ~= nil then
		rtImgRoot = goImgRoot:GetComponent("RectTransform")
	end
	rtRed.gameObject:SetActive(nType == 2)
	rtYellow.gameObject:SetActive(nType == 3)
	rtGreen.gameObject:SetActive(nType == 1)
	rtGoggles.gameObject:SetActive(nSpecialType == 106)
	rtAntenna.gameObject:SetActive(nSpecialType == 108)
	rtHelmet.gameObject:SetActive(nSpecialType == 107)
	imgFx.gameObject:SetActive(self.mapCurActiveState[105] ~= nil)
	rtPenguin.anchoredPosition = initPos
	goPenguin:SetActive(true)
	if self.mapLevelCfgData.Difficulty == GameEnum.ThrowGiftDifficulty.Blind then
		self._mapNode.rtBlindLevelTrack:Reset()
	end
	local mapGiftPenguin = {
		goGiftPenguin = rtPenguin,
		nState = 0,
		nSpecialType = nSpecialType,
		nType = nType,
		nStartAngle = nAngle,
		nStartVelocityX = nVelocity * math.cos(math.rad(nAngle)),
		nStartVelocityY = nVelocity * math.sin(math.rad(nAngle)),
		mapStartPos = initPos,
		rtImgRoot = rtImgRoot,
		targetGoal = nil,
		nGetTargetTime = 0,
		nTrackIdx = 0
	}
	if nSpecialType == 108 then
		local rtTrack = instantiate(self._mapNode.rtTemplateTrack, self._mapNode.rtScene)
		rtTrack.transform:SetAsFirstSibling()
		rtTrack:SetActive(true)
		local mapTrackCtrl = self:BindCtrlByNode(rtTrack.gameObject, "Game.UI.Activity.ThrowGifts.ThrowGiftLevelTrackLineCtrl")
		mapTrackCtrl:Reset()
		table.insert(self.tbItemTrackCtrl, mapTrackCtrl)
		mapGiftPenguin.nTrackIdx = #self.tbItemTrackCtrl
	end
	return mapGiftPenguin
end
function ThrowGiftsLevelCtrl:HitGoal(hitPos, hitGoalId)
	local mapSpawnPointData = self.mapGoal[hitGoalId]
	if mapSpawnPointData == nil then
		return
	end
	local mapCurGoalCfg = self.activeGoal[hitGoalId]
	if mapCurGoalCfg == nil then
		return
	end
	self.nTotalHitGoalCount = self.nTotalHitGoalCount + 1
	WwiseAudioMgr:PostEvent("Mode_Present_in")
	local AfterAnim = function()
		destroy(mapCurGoalCfg.rtGoal.gameObject)
		self.activeGoal[hitGoalId] = nil
		if self.curPenguinType == mapSpawnPointData.mapConfig.Type then
			self:AddScore(200)
		else
			self:AddScore(100)
		end
		if mapSpawnPointData.mapConfig.ActiveCond == GameEnum.ThrowGiftSpawnCond.Random then
			local tbRandom = {}
			for _, nCondSpawnId in ipairs(mapSpawnPointData.mapConfig.SpawnParam) do
				if self.activeGoal[nCondSpawnId] == nil then
					table.insert(tbRandom, nCondSpawnId)
				end
			end
			if 0 < #tbRandom then
				local nRandomId = tbRandom[math.random(1, #tbRandom)]
				if nRandomId ~= nil then
					local mapConfig = self.mapGoal[nRandomId]
					if mapConfig ~= nil then
						self:CreateGoal(nRandomId, mapConfig)
					end
				end
			end
		else
			for nId, mapGoalCfg in pairs(self.mapGoal) do
				if mapGoalCfg.mapConfig.ActiveCond > 0 and #mapGoalCfg.mapConfig.SpawnParam > 0 and 0 < table.indexof(mapGoalCfg.mapConfig.SpawnParam, hitGoalId) then
					if mapGoalCfg.mapConfig.ActiveCond == GameEnum.ThrowGiftSpawnCond.Partial then
						if self.activeGoal[nId] == nil then
							self:CreateGoal(nId, mapGoalCfg)
						end
					elseif mapGoalCfg.mapConfig.ActiveCond == GameEnum.ThrowGiftSpawnCond.All then
						table.insert(mapGoalCfg.curCondId, hitGoalId)
						local bActive = true
						for _, nCondSpawnId in ipairs(mapGoalCfg.mapConfig.SpawnParam) do
							if 1 > table.indexof(mapGoalCfg.curCondId, nCondSpawnId) then
								bActive = false
								break
							end
						end
						if bActive and self.activeGoal[nId] == nil then
							mapGoalCfg.curCondId = {}
							self:CreateGoal(nId, mapGoalCfg)
						end
					end
				end
			end
		end
	end
	local rtAnimRoot = mapCurGoalCfg.rtGoal:Find("AnimRoot")
	if rtAnimRoot == nil then
		AfterAnim()
	else
		local animComp = rtAnimRoot:GetComponent("Animator")
		if animComp == nil then
			AfterAnim()
		else
			animComp:Play("BasketFx_in")
			self:AddTimer(1, 0.5, AfterAnim, true, true, true)
		end
	end
end
function ThrowGiftsLevelCtrl:DestroyPenguin()
	WwiseAudioMgr:PostEvent("Mode_Present_out")
	local tempPenguin = self.curGiftPenguin.goGiftPenguin.gameObject.transform
	self.curGiftPenguin = nil
	local wait = function()
		destroy(tempPenguin.gameObject)
	end
	local imgRoot = tempPenguin:Find("imgRoot")
	local imgSmoke = tempPenguin:Find("imgSmoke")
	if imgRoot == nil or imgSmoke == nil then
		wait()
		return
	end
	imgRoot.gameObject:SetActive(false)
	imgSmoke.gameObject:SetActive(true)
	self:AddTimer(1, 0.5, wait, true, true, true)
end
function ThrowGiftsLevelCtrl:OnDrag_Beginning(mDrag)
	if self.nLevelType ~= 1 or self.bFlying then
		return
	end
	if mDrag.DragEventType == AllEnum.UIDragType.DragStart then
		local uipos = GameUIUtils.ScreenPointToLocalPointInRectangle(mDrag.EventData.position, mDrag.gameObject.transform.parent.transform)
		self.curDragBeginPos = {
			x = uipos.x,
			y = uipos.y
		}
		local nAngle = 0
		local nVelocity = 0
		self:SetBeginningAngle(nAngle, nVelocity)
		self:SetBeginningLine(nAngle, nVelocity)
		self.nCurAngle = nAngle
		self.nCurVelocity = nVelocity
		WwiseAudioMgr:PostEvent("Mode_Present_pre_lp")
	elseif mDrag.DragEventType == AllEnum.UIDragType.Drag then
		if self.curDragBeginPos == nil then
			return
		end
		local uipos = GameUIUtils.ScreenPointToLocalPointInRectangle(mDrag.EventData.position, mDrag.gameObject.transform.parent.transform)
		local nSumX = self.curDragBeginPos.x - uipos.x
		local nSumY = self._mapNode.rtBeginning.anchoredPosition.y - uipos.y
		local nAngle = nSumY * 0.2
		if nAngle > self.nAngelMax then
			nAngle = self.nAngelMax
		elseif nAngle < self.nAngleMin then
			nAngle = self.nAngleMin
		end
		local nVelocity = 0
		if 0 < nSumX then
			nVelocity = math.sqrt(nSumY * nSumY + nSumX * nSumX) * 2
			if nVelocity > self.maxVelocity then
				nVelocity = self.maxVelocity
			elseif nVelocity < 10 then
				nVelocity = 0
			end
		end
		self.nCurAngle = nAngle
		if nVelocity < self.minVelovity then
			nVelocity = self.minVelovity
		end
		self.nCurVelocity = nVelocity
		self:SetBeginningAngle(nAngle, nVelocity)
		self:SetBeginningLine(nAngle, nVelocity)
	elseif mDrag.DragEventType == AllEnum.UIDragType.DragEnd then
		if self.curDragBeginPos == nil then
			return
		end
		if self.nCurVelocity == 0 then
			return
		end
		self.curDragBeginPos = nil
		self.bFlying = true
		self.nFlyingTime = 0
		self:SetBeginningAngle(self.nCurAngle, 0)
		self:SetBeginningLine(0, 0)
		local nStartVelocity = self.nCurVelocity
		local nStartAngle = self.nCurAngle
		self.nCurAngle = 0
		self.nCurVelocity = 0
		self._mapNode.rtBottleAnim:Play("rtBottle_out")
		WwiseAudioMgr:PostEvent("Mode_Present_pre_lp_stop")
		WwiseAudioMgr:PostEvent("Mode_Present_fire")
		local wait = function()
			local worldPos = self._mapNode.rtBeginningPos:TransformPoint(Vector3.zero)
			local sumPos = self._mapNode.rtBeginning:InverseTransformPoint(worldPos)
			local beginningPos = self._mapNode.rtBeginning.anchoredPosition
			local mapGiftPenguin = self:CreateThrowPenguin(nStartAngle, nStartVelocity, Vector2(beginningPos.x + sumPos.x, beginningPos.y + sumPos.y), self.curPenguinType, self.curPenguinSpecialType)
			self.curPenguinSpecialType = 0
			self.curGiftPenguin = mapGiftPenguin
			self.nTotalThrowGiftCount = self.nTotalThrowGiftCount + 1
		end
		self:AddTimer(1, 0.12, wait, true, true, true)
	end
end
return ThrowGiftsLevelCtrl
