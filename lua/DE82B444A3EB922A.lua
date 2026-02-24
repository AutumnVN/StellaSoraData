local PenguinLevel = class("PenguinLevel")
local PenguinCard = require("Game.UI.Play_PenguinCard.PenguinCard")
local TimerManager = require("GameCore.Timer.TimerManager")
local LocalData = require("GameCore.Data.LocalData")
local ConfigData = require("GameCore.Data.ConfigData")
local GameState = {
	Start = 0,
	Prepare = 1,
	Dealing = 2,
	Flip = 3,
	Settlement = 4,
	Complete = 5
}
function PenguinLevel:Init(nFloorId, nLevelId, nActId, tbStarScore)
	self.nFloorId = nFloorId
	self.tbStarScore = tbStarScore or {
		0,
		0,
		0
	}
	self.nLevelId = nLevelId
	self.nActId = nActId
	self.bWarning = true
	self:ParseConfigData()
	self:ParseLocalData()
	EventManager.Hit(EventId.OpenPanel, PanelId.PenguinCard, self)
end
function PenguinLevel:ParseConfigData()
	self.nBaseCardCount = ConfigTable.GetConfigNumber("PenguinCardHandCardCount")
	self.nMaxRound = ConfigTable.GetConfigNumber("PenguinCardMaxRound")
	self.nMaxSlot = ConfigTable.GetConfigNumber("PenguinCardMaxSlot")
	self.nMaxBuyLimit = ConfigTable.GetConfigNumber("PenguinCardHandCardCount")
	self.tbRoundUpgradeCost = ConfigTable.GetConfigNumberArray("PenguinCardRoundUpgradeCost")
	self.tbSlotUpgradeCost = ConfigTable.GetConfigNumberArray("PenguinCardSlotUpgradeCost")
	self.tbBuyLimitUpgradeCost = ConfigTable.GetConfigNumberArray("PenguinCardBuyLimitUpgradeCost")
	self.nFireScore = ConfigTable.GetConfigNumber("PenguinCardFeverScore")
	self.mapBuyCost = {}
	local func_ForEach_Line = function(mapData)
		self.mapBuyCost[mapData.Count] = {
			Turn = mapData.Turn,
			Cost = mapData.Cost
		}
	end
	ForEachTableLine(DataTable.PenguinCardCost, func_ForEach_Line)
	self.mapHandRankRule = {}
	local func_ForEach_Rank = function(mapData)
		self.mapHandRankRule[mapData.Order] = {
			Id = mapData.Id,
			SuitCount = mapData.SuitCount,
			Value = mapData.Value,
			Ratio = mapData.Ratio * ConfigData.IntFloatPrecision
		}
	end
	ForEachTableLine(DataTable.PenguinCardHandRank, func_ForEach_Rank)
end
function PenguinLevel:ParseLocalData()
	local bAuto = LocalData.GetPlayerLocalData("PenguinCardAuto")
	self.bAuto = bAuto == true
	local nSpeed = LocalData.GetPlayerLocalData("PenguinCardSpeed")
	self.nSpeed = nSpeed or 1
end
function PenguinLevel:ParseLevelData(nFloorId)
	local mapLevelCfg = ConfigTable.GetData("PenguinCardFloor", nFloorId)
	if not mapLevelCfg then
		return
	end
	self.nMaxTurn = mapLevelCfg.MaxTurn
	self.nScore = mapLevelCfg.InitialScore
	self.nTotalScore = mapLevelCfg.InitialScore
	self.nSlotCount = mapLevelCfg.InitialSlot
	self.nRoundLimit = mapLevelCfg.InitialRound
	self.nFixedTurnGroupId = mapLevelCfg.FixedTurn
	self.sLevelDesc = mapLevelCfg.Floortips
	self.nBuyLimit = mapLevelCfg.InitialBuyLimit
	self.nWeightGroupId = mapLevelCfg.WeightGroup
	local mapPoolCfg = ConfigTable.GetData("PenguinBaseCardPool", mapLevelCfg.PoolId)
	if not mapPoolCfg then
		return
	end
	self.mapBaseCardPool = {
		tbId = mapPoolCfg.BaseCardId,
		tbWeight = mapPoolCfg.Weight
	}
end
function PenguinLevel:ClearLevelData()
	self.nGameState = nil
	self.nCurTurn = 0
	self.nCurRound = 0
	if self.tbPenguinCardPool == nil then
		self.tbPenguinCardPool = {}
	end
	if self.tbPenguinCard == nil then
		self.tbPenguinCard = {}
		for i = 1, 6 do
			self.tbPenguinCard[i] = 0
		end
	elseif next(self.tbPenguinCard) ~= nil then
		for i = 1, 6 do
			local mapCard = self.tbPenguinCard[i]
			if mapCard ~= 0 then
				self:RecyclePenguinCard(mapCard)
				self.tbPenguinCard[i] = 0
			end
		end
	end
	self.mapLog = {}
	self.nTotalRound = 0
	self.nBestTurnScore = 0
	self.nBestRoundScore = 0
	self.mapHandRankHistory = {}
	self.mapSuitHistory = {}
	self.nGetPenguinCardCount = 0
end
function PenguinLevel:StartGame()
	math.randomseed(os.time())
	self:ClearLevelData()
	self:ParseLevelData(self.nFloorId)
	self:SwitchGameState()
end
function PenguinLevel:CompleteGame()
	local nNextState = GameState.Complete
	self:SwitchNextGameState(nNextState, {bManual = true})
end
function PenguinLevel:RestartGame()
	local nNextState = GameState.Start
	local nWaitTime = self:QuitGameState(nNextState)
	if nWaitTime == 0 then
		self:StartGame()
	else
		TimerManager.Add(1, nWaitTime, self, function()
			self:StartGame()
		end, true, true, true)
		EventManager.Hit(EventId.TemporaryBlockInput, nWaitTime)
	end
end
function PenguinLevel:QuitGame(callback)
	local bAct = false
	if self.nActId then
		local actData = PlayerData.Activity:GetActivityDataById(self.nActId)
		if actData then
			local bOpen = actData:CheckActivityOpen()
			if bOpen then
				bAct = true
				actData:SendActivityPenguinCardSettleReq(self.nLevelId, self.nStar, self.nScore, callback)
			else
				EventManager.Hit(EventId.OpenMessageBox, {
					nType = AllEnum.MessageBox.Alert,
					sContent = ConfigTable.GetUIText("Activity_Invalid_Tip_3")
				})
			end
		end
	end
	if not bAct then
		callback(true)
	end
	self:QuitGameState()
	self:ClearLevelData()
end
function PenguinLevel:SwitchGameState()
	local nNextState = self:CheckNextGameState()
	self:SwitchNextGameState(nNextState)
end
function PenguinLevel:RunGameState(mapParam)
	if self.nGameState == GameState.Start then
		self:RunState_Start()
	elseif self.nGameState == GameState.Prepare then
		self:RunState_Prepare()
	elseif self.nGameState == GameState.Dealing then
		self:RunState_Dealing()
	elseif self.nGameState == GameState.Flip then
		self:RunState_Flip()
	elseif self.nGameState == GameState.Settlement then
		self:RunState_Settlement()
	elseif self.nGameState == GameState.Complete then
		self:RunState_Complete(mapParam)
	end
end
function PenguinLevel:QuitGameState(nNextState)
	local nWaitTime = 0
	if self.nGameState == GameState.Start then
		nWaitTime = self:QuitState_Start()
	elseif self.nGameState == GameState.Prepare then
		nWaitTime = self:QuitState_Prepare(nNextState)
	elseif self.nGameState == GameState.Dealing then
		nWaitTime = self:QuitState_Dealing(nNextState)
	elseif self.nGameState == GameState.Flip then
		nWaitTime = self:QuitState_Flip(nNextState)
	elseif self.nGameState == GameState.Settlement then
		nWaitTime = self:QuitState_Settlement(nNextState)
	elseif self.nGameState == GameState.Complete then
		nWaitTime = self:QuitState_Complete()
	end
	return nWaitTime
end
function PenguinLevel:CheckNextGameState()
	if self.nGameState == nil then
		return GameState.Start
	elseif self.nGameState == GameState.Start then
		return GameState.Prepare
	elseif self.nGameState == GameState.Prepare then
		return GameState.Dealing
	elseif self.nGameState == GameState.Dealing then
		return GameState.Flip
	elseif self.nGameState == GameState.Flip then
		return GameState.Settlement
	elseif self.nGameState == GameState.Settlement then
		if self.nCurRound >= self.nRoundLimit then
			if self.nCurTurn >= self.nMaxTurn then
				return GameState.Complete
			else
				return GameState.Prepare
			end
		else
			return GameState.Dealing
		end
	end
end
function PenguinLevel:SwitchNextGameState(nNextState, mapParam)
	local nWaitTime = self:QuitGameState(nNextState)
	if nWaitTime == 0 then
		self.nGameState = nNextState
		self:RunGameState(mapParam)
	else
		TimerManager.Add(1, nWaitTime, self, function()
			self.nGameState = nNextState
			self:RunGameState(mapParam)
		end, true, true, true)
		EventManager.Hit(EventId.TemporaryBlockInput, nWaitTime)
	end
end
function PenguinLevel:RunState_Start()
	EventManager.Hit("PenguinCard_RunState_Start")
	self:SwitchGameState()
end
function PenguinLevel:QuitState_Start()
	EventManager.Hit("PenguinCard_QuitState_Start")
	return 0
end
function PenguinLevel:RunState_Prepare()
	self.nCurTurn = self.nCurTurn + 1
	self.nCurRound = 0
	self.nTurnBuyCount = 0
	self.nTurnScore = 0
	self.tbSelectablePenguinCard = {}
	self.bSelectedPenguinCard = false
	self:FreeRollPenguinCard()
	EventManager.Hit("PenguinCard_RunState_Prepare")
end
function PenguinLevel:QuitState_Prepare(nNextState)
	for _, v in ipairs(self.tbPenguinCard) do
		if v ~= 0 then
			v:ResetTurnTrigger()
		end
	end
	self:ClearSelectablePenguinCard()
	self.nTurnBuyCount = 0
	self.tbSelectablePenguinCard = {}
	self.bSelectedPenguinCard = false
	self.bPreTurnWin = false
	EventManager.Hit("PenguinCard_QuitState_Prepare", nNextState)
	local nWaitTime = 0
	if nNextState == GameState.Start then
		nWaitTime = 0.6
	elseif nNextState == GameState.Dealing then
		nWaitTime = 0.45
	elseif nNextState == GameState.Complete then
		nWaitTime = 0.6
	end
	return nWaitTime
end
function PenguinLevel:AddRound()
	if self.nRoundLimit == self.nMaxRound then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Tips,
			sSound = "Mode_Card_refresh_falied",
			sContent = ConfigTable.GetUIText("PenguinCard_AddBtnMaxLevel")
		})
		return
	end
	local nCost = self.tbRoundUpgradeCost[self.nRoundLimit + 1]
	if nCost > self.nScore then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Tips,
			sSound = "Mode_Card_refresh_falied",
			sContent = ConfigTable.GetUIText("PenguinCard_NotEnoughScoreUpgrade")
		})
		return
	end
	self.nRoundLimit = self.nRoundLimit + 1
	self:ChangeScore(-1 * nCost)
	EventManager.Hit(EventId.OpenMessageBox, {
		nType = AllEnum.MessageBox.Tips,
		sSound = "Mode_Card_buy",
		sContent = orderedFormat(ConfigTable.GetUIText("PenguinCard_AddRoundSuccess"), self.nRoundLimit)
	})
	EventManager.Hit("PenguinCard_AddRound")
end
function PenguinLevel:AddSlot()
	if self.nSlotCount == self.nMaxSlot then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Tips,
			sSound = "Mode_Card_refresh_falied",
			sContent = ConfigTable.GetUIText("PenguinCard_AddBtnMaxLevel")
		})
		return
	end
	local nCost = self.tbSlotUpgradeCost[self.nSlotCount + 1]
	if nCost > self.nScore then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Tips,
			sSound = "Mode_Card_refresh_falied",
			sContent = ConfigTable.GetUIText("PenguinCard_NotEnoughScoreUpgrade")
		})
		return
	end
	self.nSlotCount = self.nSlotCount + 1
	self:ChangeScore(-1 * nCost)
	EventManager.Hit(EventId.OpenMessageBox, {
		nType = AllEnum.MessageBox.Tips,
		sSound = "Mode_Card_buy",
		sContent = orderedFormat(ConfigTable.GetUIText("PenguinCard_AddSlotSuccess"), self.nSlotCount)
	})
	EventManager.Hit("PenguinCard_AddSlot")
end
function PenguinLevel:AddRoll()
	if self.nBuyLimit == self.nMaxBuyLimit then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Tips,
			sSound = "Mode_Card_refresh_falied",
			sContent = ConfigTable.GetUIText("PenguinCard_AddBtnMaxLevel")
		})
		return
	end
	local nCost = self.tbBuyLimitUpgradeCost[self.nBuyLimit + 1]
	if nCost > self.nScore then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Tips,
			sSound = "Mode_Card_refresh_falied",
			sContent = ConfigTable.GetUIText("PenguinCard_NotEnoughScoreUpgrade")
		})
		return
	end
	self.nBuyLimit = self.nBuyLimit + 1
	self:ChangeScore(-1 * nCost)
	EventManager.Hit(EventId.OpenMessageBox, {
		nType = AllEnum.MessageBox.Tips,
		sSound = "Mode_Card_buy",
		sContent = orderedFormat(ConfigTable.GetUIText("PenguinCard_AddRollSuccess"), self.nBuyLimit)
	})
	EventManager.Hit("PenguinCard_AddRoll")
end
function PenguinLevel:FreeRollPenguinCard()
	local tbId = self:GetRollPenguinCardResult()
	if next(tbId) == nil then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Tips,
			sSound = "Mode_Card_refresh_falied",
			sContent = ConfigTable.GetUIText("PenguinCard_Error_EmptyPenguinCard")
		})
		return
	end
	self:ClearSelectablePenguinCard()
	for _, nId in ipairs(tbId) do
		local mapCard = self:CreatePenguinCard(nId)
		table.insert(self.tbSelectablePenguinCard, mapCard)
	end
	self.bSelectedPenguinCard = false
end
function PenguinLevel:RollPenguinCard()
	if self.nTurnBuyCount >= self.nBuyLimit then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Tips,
			sSound = "Mode_Card_refresh_falied",
			sContent = ConfigTable.GetUIText("PenguinCard_RollMax")
		})
		return
	end
	local nCost = self:GetRollPenguinCardCost()
	if nCost > self.nScore then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Tips,
			sSound = "Mode_Card_refresh_falied",
			sContent = ConfigTable.GetUIText("PenguinCard_NotEnoughScoreRoll")
		})
		return
	end
	local tbId = self:GetRollPenguinCardResult()
	if next(tbId) == nil then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Tips,
			sSound = "Mode_Card_refresh_falied",
			sContent = ConfigTable.GetUIText("PenguinCard_Error_EmptyPenguinCard")
		})
		return
	end
	self.nTurnBuyCount = self.nTurnBuyCount + 1
	self:ChangeScore(-1 * nCost)
	self:ClearSelectablePenguinCard()
	for _, nId in ipairs(tbId) do
		local mapCard = self:CreatePenguinCard(nId)
		table.insert(self.tbSelectablePenguinCard, mapCard)
	end
	self.bSelectedPenguinCard = false
	EventManager.Hit("PenguinCard_RollPenguinCard")
end
function PenguinLevel:SelectPenguinCard(nIndex)
	local mapSelectCard = self.tbSelectablePenguinCard[nIndex]
	local bUpgrade, nAimIndex = self:CheckUpgradePenguinCard(mapSelectCard)
	if not bUpgrade and self:GetOwnPenguinCardCount() >= self.nSlotCount then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("PenguinCard_SlotMax"))
		return
	end
	if bUpgrade then
		local nAddLevel = mapSelectCard.nLevel
		self.tbPenguinCard[nAimIndex]:Upgrade(nAddLevel)
	else
		local mapCard = self:CreatePenguinCard(mapSelectCard.nId)
		self.tbPenguinCard[nAimIndex] = mapCard
	end
	self.tbPenguinCard[nAimIndex]:SetSlotIndex(nAimIndex)
	self.tbPenguinCard[nAimIndex]:ResetGameTrigger()
	self.bSelectedPenguinCard = true
	self.nGetPenguinCardCount = self.nGetPenguinCardCount + 1
	EventManager.Hit("PenguinCard_SelectPenguinCard", nAimIndex, bUpgrade)
end
function PenguinLevel:CheckUpgradePenguinCard(mapSelectCard)
	local bUpgrade = false
	local nFirstEmpty = 0
	local nAimIndex = 0
	for i, v in ipairs(self.tbPenguinCard) do
		if v == 0 and nFirstEmpty == 0 then
			nFirstEmpty = i
		end
		if v ~= 0 and v.nGroupId == mapSelectCard.nGroupId then
			bUpgrade = true
			nAimIndex = i
			break
		end
	end
	if not bUpgrade then
		nAimIndex = nFirstEmpty
	end
	return bUpgrade, nAimIndex
end
function PenguinLevel:SalePenguinCard(nIndex)
	self:ChangeScore(self.tbPenguinCard[nIndex].nSoldPrice)
	local mapCard = self.tbPenguinCard[nIndex]
	local nGroupId = mapCard.nGroupId
	self:RecyclePenguinCard(mapCard)
	self.tbPenguinCard[nIndex] = 0
	EventManager.Hit("PenguinCard_SalePenguinCard", nIndex, nGroupId)
end
function PenguinLevel:GetRollPenguinCardCost()
	local findIntervalIndex = function(x, starts)
		if not starts or #starts == 0 or x < starts[1] then
			return 1
		end
		local low, high = 1, #starts
		local best = 1
		while low <= high do
			local mid = math.floor((low + high) / 2)
			if x >= starts[mid] then
				best = mid
				low = mid + 1
			else
				high = mid - 1
			end
		end
		return best
	end
	local mapData = self.mapBuyCost[self.nTurnBuyCount + 1]
	local nIndex = findIntervalIndex(self.nCurTurn, mapData.Turn)
	local nCost = mapData.Cost[nIndex]
	return nCost
end
function PenguinLevel:ClearSelectablePenguinCard()
	if next(self.tbSelectablePenguinCard) ~= nil then
		for i = #self.tbSelectablePenguinCard, 1, -1 do
			local mapCard = table.remove(self.tbSelectablePenguinCard, i)
			self:RecyclePenguinCard(mapCard)
		end
	end
end
function PenguinLevel:GetRollPenguinCardResult()
	local mapWeightCfg = ConfigTable.GetData("PenguinCardWeight", self.nWeightGroupId * 100 + self.nCurTurn)
	if not mapWeightCfg then
		return {}
	end
	local tbMaxGroupId = self:GetMaxLevelPenguinCard()
	local tbId = self:WeightedRandom(mapWeightCfg.CardList, mapWeightCfg.Weight, 3, tbMaxGroupId)
	return tbId
end
function PenguinLevel:GetMaxLevelPenguinCard()
	local tbGroupId = {}
	for _, v in ipairs(self.tbPenguinCard) do
		if v ~= 0 and v.nLevel == v.nMaxLevel then
			table.insert(tbGroupId, v.nGroupId)
		end
	end
	return tbGroupId
end
function PenguinLevel:RecyclePenguinCard(mapCard)
	mapCard:Clear()
	table.insert(self.tbPenguinCardPool, mapCard)
end
function PenguinLevel:CreatePenguinCard(nId)
	local mapCard
	if next(self.tbPenguinCardPool) == nil then
		mapCard = PenguinCard.new(nId)
	else
		mapCard = table.remove(self.tbPenguinCardPool, 1)
		mapCard:Init(nId)
	end
	return mapCard
end
function PenguinLevel:RunState_Dealing()
	self.nCurRound = self.nCurRound + 1
	self.nTotalRound = self.nTotalRound + 1
	self.tbHandRank = {}
	self.nHandRankId = 0
	self.mapAllSuit = {}
	self.nRoundScore = 0
	self.nRoundValue = 0
	self.nRoundRatio = 1
	self.nRoundMultiRatio = 0
	self.mapCalBaseCardPool = clone(self.mapBaseCardPool)
	for _, v in ipairs(self.tbPenguinCard) do
		if v ~= 0 then
			v:ResetRoundTrigger()
		end
	end
	self:TriggerPenguinCard(GameEnum.PenguinCardTriggerPhase.Dealing)
	self.tbBaseCardId = self:WeightedRandom(self.mapCalBaseCardPool.tbId, self.mapCalBaseCardPool.tbWeight, self.nBaseCardCount, {}, true)
	if 0 < self.nFixedTurnGroupId then
		local nFixedId = self.nFixedTurnGroupId * 10000 + self.nCurTurn * 100 + self.nCurRound
		local mapFixedCfg = ConfigTable.GetData("PenguinCardFixedTurn", nFixedId, true)
		if mapFixedCfg then
			self.tbBaseCardId = mapFixedCfg.BaseCardId
		end
	end
	self.tbShowedCard = {}
	for i = 1, self.nBaseCardCount do
		self.tbShowedCard[i] = false
	end
	EventManager.Hit("PenguinCard_RunState_Dealing")
	self:SwitchGameState()
end
function PenguinLevel:QuitState_Dealing(nNextState)
	EventManager.Hit("PenguinCard_QuitState_Dealing", nNextState)
	local nWaitTime = 0
	if nNextState == GameState.Start then
		nWaitTime = 0.6
	elseif nNextState == GameState.Flip then
		nWaitTime = 0.85
	elseif nNextState == GameState.Complete then
		nWaitTime = 0.6
	end
	return nWaitTime
end
function PenguinLevel:RunState_Flip()
	EventManager.Hit("PenguinCard_RunState_Flip")
	self:PlayAuto()
end
function PenguinLevel:QuitState_Flip(nNextState)
	self:StopAuto()
	EventManager.Hit("PenguinCard_QuitState_Flip", nNextState)
	local nWaitTime = 0
	if nNextState == GameState.Start then
		nWaitTime = 0.6
	elseif nNextState == GameState.Settlement then
		nWaitTime = 1
	elseif nNextState == GameState.Complete then
		nWaitTime = 0.6
	end
	return nWaitTime
end
function PenguinLevel:ShowBaseCard(nIndex)
	local add = function(i)
		if self.tbShowedCard[i] == false then
			self.tbShowedCard[i] = true
			local nId = self.tbBaseCardId[i]
			local mapCfg = ConfigTable.GetData("PenguinBaseCard", nId)
			if mapCfg then
				if not self.mapAllSuit[mapCfg.Suit1] then
					self.mapAllSuit[mapCfg.Suit1] = 0
				end
				self.mapAllSuit[mapCfg.Suit1] = self.mapAllSuit[mapCfg.Suit1] + mapCfg.SuitCount1
				local SuitCards = {}
				if 0 < mapCfg.SuitCount1 then
					table.insert(SuitCards, mapCfg.Suit1)
				end
				if 0 < mapCfg.SuitCount2 then
					table.insert(SuitCards, mapCfg.Suit2)
				end
				local SuitCount = {}
				if 0 < mapCfg.SuitCount1 then
					SuitCount[mapCfg.Suit1] = mapCfg.SuitCount1
				end
				if 0 < mapCfg.SuitCount2 then
					SuitCount[mapCfg.Suit2] = mapCfg.SuitCount2
				end
				self:TriggerPenguinCard(GameEnum.PenguinCardTriggerPhase.Flip, {
					SuitCards = SuitCards,
					SuitCount = SuitCount,
					BaseCard = {nId = nId, nIndex = i}
				})
			end
		end
	end
	local bAll = nIndex == nil
	if bAll then
		for i = 1, self.nBaseCardCount do
			add(i)
		end
	else
		add(nIndex)
	end
	local nShowed = self:GetShowedCardCount()
	if nShowed == self.nBaseCardCount then
		self:CheckHandRank()
		self:SwitchGameState()
	end
	EventManager.Hit("PenguinCard_ShowBaseCard", nIndex)
end
function PenguinLevel:CheckHandRank()
	local tbAllSuit = {}
	for k, v in pairs(self.mapAllSuit) do
		table.insert(tbAllSuit, {nSuit = k, nCount = v})
	end
	table.sort(tbAllSuit, function(a, b)
		return a.nCount > b.nCount
	end)
	for _, v in ipairs(self.mapHandRankRule) do
		self.tbHandRank = {}
		local tbCount = v.SuitCount
		local nType = #tbCount
		local nHasType = #tbAllSuit
		local nAble = 0
		if nType <= nHasType then
			for i = 1, nType do
				if tbAllSuit[i].nCount >= tbCount[i] then
					nAble = nAble + 1
					for _ = 1, tbCount[i] do
						table.insert(self.tbHandRank, tbAllSuit[i].nSuit)
					end
				end
			end
		end
		if nAble == nType then
			self.nHandRankId = v.Id
			self:ChangeRoundScore(v.Value, v.Ratio, 0, true)
			break
		end
	end
end
function PenguinLevel:ChangeRoundScore(nAddValue, nAddRatio, nAddMultiRatio, bFromHandRank)
	local nBeforeScore = self.nRoundScore
	local nBeforeBase = self.nRoundValue
	local nBeforeMultiRatio = self.nRoundMultiRatio
	local nBeforeRatio = self.nRoundRatio
	self.nRoundValue = self.nRoundValue + nAddValue
	self.nRoundMultiRatio = self.nRoundMultiRatio + nAddMultiRatio
	self.nRoundRatio = self.nRoundRatio + nAddRatio
	self.nRoundScore = self.nRoundMultiRatio > 0 and self.nRoundValue * self.nRoundRatio * self.nRoundMultiRatio or self.nRoundValue * self.nRoundRatio
	local nAddScore = self.nRoundScore - nBeforeScore
	self.nTurnScore = self.nTurnScore + nAddScore
	if self.nTurnScore > self.nBestTurnScore then
		self.nBestTurnScore = self.nTurnScore
	end
	if self.nRoundScore > self.nBestRoundScore then
		self.nBestRoundScore = self.nRoundScore
	end
	local nBeforeAllRatio = 0 < nBeforeMultiRatio and nBeforeMultiRatio * nBeforeRatio or nBeforeRatio
	local nAfterAllRatio = self.nRoundMultiRatio > 0 and self.nRoundRatio * self.nRoundMultiRatio or self.nRoundRatio
	EventManager.Hit("PenguinCard_ChangeRoundScore", nBeforeBase, nBeforeAllRatio, nBeforeScore, bFromHandRank)
	if NovaAPI.IsEditorPlatform() then
		printLog("\232\189\174\231\167\175\229\136\134\229\143\152\229\140\150\239\188\154" .. nAddScore .. "  (" .. nBeforeScore .. " -> " .. self.nRoundScore .. ")")
		printLog("\229\159\186\231\161\128\229\143\152\229\140\150\239\188\154" .. nAddValue .. "  (" .. nBeforeBase .. " -> " .. self.nRoundValue .. ")")
		printLog("\229\128\141\231\142\135\229\143\152\229\140\150\239\188\154" .. nAfterAllRatio - nBeforeAllRatio .. "  (" .. nBeforeAllRatio .. " -> " .. nAfterAllRatio .. ")")
	end
end
function PenguinLevel:GetShowedCardCount()
	local nShowed = 0
	for _, v in pairs(self.tbShowedCard) do
		if v then
			nShowed = nShowed + 1
		end
	end
	return nShowed
end
function PenguinLevel:RunState_Settlement()
	if not self.mapHandRankHistory[self.nHandRankId] then
		self.mapHandRankHistory[self.nHandRankId] = 0
	end
	self.mapHandRankHistory[self.nHandRankId] = self.mapHandRankHistory[self.nHandRankId] + 1
	local HandRankSuitCount = {}
	for _, v in ipairs(self.tbHandRank) do
		if not HandRankSuitCount[v] then
			HandRankSuitCount[v] = 0
		end
		HandRankSuitCount[v] = HandRankSuitCount[v] + 1
		if not self.mapSuitHistory[v] then
			self.mapSuitHistory[v] = 0
		end
		self.mapSuitHistory[v] = self.mapSuitHistory[v] + 1
	end
	self:TriggerPenguinCard(GameEnum.PenguinCardTriggerPhase.Settlement, {
		HandRankSuitCount = HandRankSuitCount,
		SuitCount = self.mapAllSuit
	})
	self:AddLog()
	EventManager.Hit("PenguinCard_RunState_Settlement")
	self:PlayAuto()
end
function PenguinLevel:QuitState_Settlement(nNextState)
	self:StopAuto()
	self:ChangeScore(self.nRoundScore)
	self.tbHandRank = {}
	self.nHandRankId = 0
	self.mapAllSuit = {}
	self.nRoundScore = 0
	self.nRoundValue = 0
	self.nRoundRatio = 1
	self.nRoundMultiRatio = 0
	self.mapCalBaseCardPool = {}
	EventManager.Hit("PenguinCard_QuitState_Settlement", nNextState)
	local nWaitTime = 0
	if nNextState == GameState.Start then
		nWaitTime = 0.6
	elseif nNextState == GameState.Dealing then
		nWaitTime = 0.57
	elseif nNextState == GameState.Prepare then
		nWaitTime = 0.57
	elseif nNextState == GameState.Complete then
		nWaitTime = 0.6
	end
	return nWaitTime
end
function PenguinLevel:AddLog()
	if not self.mapLog[self.nCurTurn] then
		self.mapLog[self.nCurTurn] = {
			nTurnScore = 0,
			tbRound = {}
		}
	end
	self.mapLog[self.nCurTurn].nTurnScore = self.nTurnScore
	if not self.mapLog[self.nCurTurn].tbRound[self.nCurRound] then
		self.mapLog[self.nCurTurn].tbRound[self.nCurRound] = {
			nRoundScore = 0,
			tbHandRank = {}
		}
	end
	self.mapLog[self.nCurTurn].tbRound[self.nCurRound].nRoundScore = self.nRoundScore
	self.mapLog[self.nCurTurn].tbRound[self.nCurRound].tbHandRank = clone(self.tbHandRank)
	self.mapLog[self.nCurTurn].tbRound[self.nCurRound].nHandRankId = self.nHandRankId
end
function PenguinLevel:RunState_Complete(mapParam)
	self.nStar = self:GetStar()
	EventManager.Hit("PenguinCard_RunState_Complete")
	if self.nActId then
		local tab = {}
		table.insert(tab, {
			"role_id",
			tostring(PlayerData.Base._nPlayerId)
		})
		table.insert(tab, {
			"activity_id",
			tostring(self.nActId)
		})
		table.insert(tab, {
			"battle_id",
			tostring(self.nLevelId)
		})
		table.insert(tab, {
			"round",
			tostring(self.nCurTurn)
		})
		table.insert(tab, {
			"result",
			tostring(self.nStar == 0 and 2 or 1)
		})
		local nEnd = mapParam and mapParam.bManual == true and 2 or 1
		table.insert(tab, {
			"end_type",
			tostring(nEnd)
		})
		table.insert(tab, {
			"score",
			tostring(self.nScore)
		})
		table.insert(tab, {
			"star",
			tostring(self.nStar)
		})
		local sId = ""
		for i = 1, 6 do
			if self.tbPenguinCard[i] ~= 0 then
				if sId == "" then
					sId = sId .. self.tbPenguinCard[i].nId
				else
					sId = sId .. "," .. self.tbPenguinCard[i].nId
				end
			end
		end
		table.insert(tab, {"card_list", sId})
		table.insert(tab, {
			"skill_1",
			tostring(self.nRoundLimit)
		})
		table.insert(tab, {
			"skill_2",
			tostring(self.nSlotCount)
		})
		table.insert(tab, {
			"skill_3",
			tostring(self.nBuyLimit)
		})
		NovaAPI.UserEventUpload("minigame_PenguinCard", tab)
	end
end
function PenguinLevel:QuitState_Complete()
	self.nStar = 0
	EventManager.Hit("PenguinCard_QuitState_Complete")
	return 0
end
function PenguinLevel:GetMostHandRank()
	local nCount = 0
	local nId = 0
	for k, v in pairs(self.mapHandRankHistory) do
		if v > nCount then
			nCount = v
			nId = k
		end
	end
	return nId, nCount
end
function PenguinLevel:GetMostSuit()
	local nCount = 0
	local nId = 0
	for k, v in pairs(self.mapSuitHistory) do
		if v > nCount then
			nCount = v
			nId = k
		end
	end
	return nId, nCount
end
function PenguinLevel:GetBestPenguinCard()
	local nCount = 0
	local mapCard
	for _, v in ipairs(self.tbPenguinCard) do
		if v ~= 0 and nCount < v.nLevel then
			nCount = v.nLevel
			mapCard = v
		end
	end
	return mapCard
end
function PenguinLevel:SetAutoState(bAuto)
	self.bAuto = bAuto
	LocalData.SetPlayerLocalData("PenguinCardAuto", self.bAuto)
end
function PenguinLevel:SetAutoSpeed(nSpeed)
	self.nSpeed = nSpeed
	LocalData.SetPlayerLocalData("PenguinCardSpeed", self.nSpeed)
	if self.sequence then
		self:StopAuto()
		self:PlayAuto()
	end
end
function PenguinLevel:PlayAuto(bClick)
	if not self.bAuto or self.bPause then
		return
	end
	if self.nGameState == GameState.Flip then
		self.sequence = DOTween.Sequence()
		for j = 1, self.nBaseCardCount do
			if self.tbShowedCard[j] == false then
				self.sequence:AppendCallback(function()
					self:ShowBaseCard(j)
				end)
				self.sequence:AppendInterval(0.2 / self.nSpeed)
			end
		end
		self.sequence:SetUpdate(true)
	elseif self.nGameState == GameState.Settlement then
		local bKeep = not PlayerData.Guide:CheckGuideFinishById(302)
		if EditorSettings and EditorSettings.bJumpGuide then
			bKeep = false
		end
		if bKeep then
			return
		end
		self.sequence = DOTween.Sequence()
		if not bClick then
			self.sequence:AppendInterval((self.nRoundValue >= self.nFireScore and 7 or 5) / self.nSpeed)
		end
		self.sequence:AppendCallback(function()
			EventManager.Hit("PenguinCard_QuitScoreAni")
			if self.nRoundLimit == self.nCurRound and self.nCurTurn < self.nMaxTurn then
				local callback = function()
					self:SwitchGameState()
				end
				EventManager.Hit("PenguinCard_OpenLog", self.nCurTurn, false, callback)
			else
				self:SwitchGameState()
			end
		end)
		self.sequence:SetUpdate(true)
	end
end
function PenguinLevel:StopAuto()
	if self.sequence then
		self.sequence:Kill()
		self.sequence = nil
	end
end
function PenguinLevel:Pause()
	self.bPause = true
	if self.sequence then
		self.sequence:Pause()
	end
	EventManager.Hit("PenguinCard_Pause")
end
function PenguinLevel:Resume()
	self.bPause = false
	if self.sequence then
		self.sequence:Play()
	else
		self:PlayAuto()
	end
	EventManager.Hit("PenguinCard_Resume")
end
function PenguinLevel:ChangeScore(nChange)
	if not nChange or nChange == 0 then
		return
	end
	local nBefore = self.nScore
	self.nScore = self.nScore + nChange
	local nBeforeStar, nStar = 0, 0
	for i, v in ipairs(self.tbStarScore) do
		if v <= nBefore then
			nBeforeStar = i
		end
		if v <= self.nScore then
			nStar = i
		end
	end
	if nBeforeStar < 3 and nStar == 3 and self.nGameState == GameState.Settlement then
		self.bPreTurnWin = true
	end
	EventManager.Hit("PenguinCard_ChangeScore", nBefore, nBeforeStar, nStar)
	if NovaAPI.IsEditorPlatform() then
		printLog("\230\128\187\231\167\175\229\136\134\229\143\152\229\140\150\239\188\154" .. nChange .. "  (" .. nBefore .. " -> " .. self.nScore .. ")")
	end
end
function PenguinLevel:GetStar()
	local nStar = 0
	for i, v in ipairs(self.tbStarScore) do
		if v <= self.nScore then
			nStar = i
		end
	end
	return nStar
end
function PenguinLevel:WeightedRandom(tbId, tbWeight, n, tbExcludeGroupId, bDuplicate)
	if #tbId ~= #tbWeight then
		printError("tbId \229\146\140 tbWeight \233\149\191\229\186\166\229\191\133\233\161\187\231\155\184\229\144\140")
	end
	tbExcludeGroupId = tbExcludeGroupId or {}
	local tbExcludeSet = {}
	for _, v in ipairs(tbExcludeGroupId) do
		tbExcludeSet[v] = true
	end
	local tbCandidates = {}
	for i = 1, #tbId do
		local id = tbId[i]
		local w = tbWeight[i]
		if next(tbExcludeSet) == nil then
			table.insert(tbCandidates, {id = id, weight = w})
		else
			local mapCfg = ConfigTable.GetData("PenguinCard", id)
			if mapCfg and not tbExcludeSet[mapCfg.GroupId] then
				table.insert(tbCandidates, {id = id, weight = w})
			end
		end
	end
	if #tbCandidates == 0 then
		return {}
	end
	local result = {}
	if bDuplicate then
		local totalWeight = 0
		for _, item in ipairs(tbCandidates) do
			totalWeight = totalWeight + item.weight
		end
		for _ = 1, n do
			local r = math.random() * totalWeight
			local cum = 0
			for _, item in ipairs(tbCandidates) do
				cum = cum + item.weight
				if r < cum then
					table.insert(result, item.id)
					break
				end
			end
		end
	else
		local actualN = math.min(n, #tbCandidates)
		for _ = 1, actualN do
			local totalWeight = 0
			for _, item in ipairs(tbCandidates) do
				totalWeight = totalWeight + item.weight
			end
			if totalWeight <= 0 then
				break
			end
			local r = math.random() * totalWeight
			local cum = 0
			for i, item in ipairs(tbCandidates) do
				cum = cum + item.weight
				if r < cum then
					table.insert(result, item.id)
					table.remove(tbCandidates, i)
					break
				end
			end
		end
	end
	return result
end
function PenguinLevel:SetWarning(bAble)
	self.bWarning = bAble
end
function PenguinLevel:GetOwnPenguinCardCount()
	local nCount = 0
	for i = 1, 6 do
		if self.tbPenguinCard[i] ~= 0 then
			nCount = nCount + 1
		end
	end
	return nCount
end
function PenguinLevel:TriggerPenguinCard(nTriggerPhase, mapTriggerSource)
	local callback = function(nEffectType, tbEffectParam)
		if nEffectType == GameEnum.PenguinCardEffectType.AddBaseCardWeight then
			for k, v in pairs(tbEffectParam) do
				local nIndex = table.indexof(self.mapCalBaseCardPool.tbId, tonumber(k))
				self.mapCalBaseCardPool.tbWeight[nIndex] = self.mapCalBaseCardPool.tbWeight[nIndex] + v
			end
		elseif nEffectType == GameEnum.PenguinCardEffectType.ReplaceBaseCard then
			local nAfterId = tbEffectParam[1]
			local nBeforeId = mapTriggerSource.BaseCard.nId
			local nIndex = mapTriggerSource.BaseCard.nIndex
			local mapBeforeCfg = ConfigTable.GetData("PenguinBaseCard", nBeforeId)
			if mapBeforeCfg then
				self.mapAllSuit[mapBeforeCfg.Suit1] = self.mapAllSuit[mapBeforeCfg.Suit1] - mapBeforeCfg.SuitCount1
			end
			self.tbBaseCardId[nIndex] = nAfterId
			local mapAfterCfg = ConfigTable.GetData("PenguinBaseCard", nAfterId)
			if mapAfterCfg then
				if not self.mapAllSuit[mapAfterCfg.Suit1] then
					self.mapAllSuit[mapAfterCfg.Suit1] = 0
				end
				self.mapAllSuit[mapAfterCfg.Suit1] = self.mapAllSuit[mapAfterCfg.Suit1] + mapAfterCfg.SuitCount1
			end
			EventManager.Hit("PenguinCard_ReplaceBaseCard", nIndex)
		elseif nEffectType == GameEnum.PenguinCardEffectType.IncreaseBasicChips then
			self:ChangeRoundScore(tbEffectParam[1], 0, 0)
		elseif nEffectType == GameEnum.PenguinCardEffectType.IncreaseMultiplier then
			self:ChangeRoundScore(0, tbEffectParam[1], 0)
		elseif nEffectType == GameEnum.PenguinCardEffectType.MultiMultiplier then
			self:ChangeRoundScore(0, 0, tbEffectParam[1])
		end
	end
	for _, v in ipairs(self.tbPenguinCard) do
		if v ~= 0 then
			v:Trigger(nTriggerPhase, mapTriggerSource, callback)
		end
	end
end
return PenguinLevel
