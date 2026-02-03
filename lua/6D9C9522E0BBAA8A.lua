local PenguinCard = class("PenguinCard")
local SuitName = {
	[GameEnum.PenguinBaseCardSuit.Blue] = "<sprite name=\"icon_PengCard_Water_small\">",
	[GameEnum.PenguinBaseCardSuit.Red] = "<sprite name=\"icon_PengCard_Fire_small\">",
	[GameEnum.PenguinBaseCardSuit.Green] = "<sprite name=\"icon_PengCard_Wind_small\">"
}
function PenguinCard:ctor(nId)
	self:Clear()
	self:Init(nId)
end
function PenguinCard:Upgrade(nAddLevel)
	local nAfter = self.nLevel + nAddLevel
	nAfter = nAfter > self.nMaxLevel and self.nMaxLevel or nAfter
	local nId = self:GetIdByLevel(self.nGroupId, nAfter)
	self:Clear()
	self:Init(nId)
end
function PenguinCard:Clear()
	self.nId = nil
	self.nSlotIndex = nil
	self.nGroupId = nil
	self.sName = nil
	self.sIcon = nil
	self.nRarity = nil
	self.nLevel = nil
	self.nMaxLevel = nil
	self.nSoldPrice = nil
	self.nTriggerPhase = nil
	self.nTriggerType = nil
	self.tbTriggerParam = nil
	self.nTriggerProbability = nil
	self.nTriggerLimit = nil
	self.nTriggerLimitParam = nil
	self.nEffectType = nil
	self.tbEffectParam = nil
	self.sDesc = nil
	self.nTriggerCount = nil
end
function PenguinCard:Init(nId)
	self.nId = nId
	self:ParseConfigData(nId)
end
function PenguinCard:ParseConfigData(nId)
	local mapCfg = ConfigTable.GetData("PenguinCard", nId)
	if nil == mapCfg then
		return
	end
	self.nGroupId = mapCfg.GroupId
	self.sName = mapCfg.Title
	self.sIcon = mapCfg.Icon
	self.nRarity = mapCfg.Rarity
	self.nLevel = mapCfg.Level
	self.nMaxLevel = mapCfg.MaxLevel
	self.nSoldPrice = mapCfg.SoldPrice
	self.nTriggerPhase = mapCfg.TriggerPhase
	self.nTriggerType = mapCfg.TriggerType
	self.tbTriggerParam = decodeJson(mapCfg.TriggerParam)
	self.nTriggerProbability = mapCfg.TriggerProbability
	self.nTriggerLimit = mapCfg.TriggerLimit
	self.nTriggerLimitParam = mapCfg.TriggerLimitParam
	self.nEffectType = mapCfg.EffectType
	self.tbEffectParam = decodeJson(mapCfg.EffectParam)
	self.sDesc = self:SetDesc(mapCfg)
end
function PenguinCard:SetSlotIndex(nSlotIndex)
	self.nSlotIndex = nSlotIndex
end
function PenguinCard:SetDesc(mapCfg)
	local ParseTriggerParam = function(tbParam, nIndex)
		if self.nTriggerType == GameEnum.PenguinCardTriggerType.SuitCards then
			local nSuit = tbParam[nIndex]
			return SuitName[nSuit]
		elseif self.nTriggerType == GameEnum.PenguinCardTriggerType.BaseCardId then
			local nBaseCardId = tbParam[nIndex]
			local mapBase = ConfigTable.GetData("PenguinBaseCard", nBaseCardId)
			if mapBase then
				return mapBase.Title
			end
		elseif self.nTriggerType == GameEnum.PenguinCardTriggerType.SuitCount or self.nTriggerType == GameEnum.PenguinCardTriggerType.HandRankSuitCount then
			local mapSuit = {}
			for k, v in pairs(tbParam) do
				local nSuit = tonumber(k)
				if nSuit then
					mapSuit[nSuit] = v
				end
			end
			local i = 1
			for nSuit, v in ipairsSorted(mapSuit) do
				if i == nIndex then
					local sName = ""
					for _ = 1, v do
						sName = sName .. SuitName[nSuit]
					end
					return sName
				end
				i = i + 1
			end
		end
	end
	local ParseEffectParam = function(tbParam, nIndex)
		if self.nEffectType == GameEnum.PenguinCardEffectType.AddBaseCardWeight then
			local tbId = {}
			for k, _ in pairs(tbParam) do
				local nId = tonumber(k)
				if nId then
					table.insert(tbId, nId)
				end
			end
			table.sort(tbId, function(a, b)
				return a < b
			end)
			local nBaseCardId = tbId[nIndex]
			local mapBase = ConfigTable.GetData("PenguinBaseCard", nBaseCardId)
			if mapBase then
				return mapBase.Title
			end
		elseif self.nEffectType == GameEnum.PenguinCardEffectType.ReplaceBaseCard then
			local nBaseCardId = tbParam[nIndex]
			local mapBase = ConfigTable.GetData("PenguinBaseCard", nBaseCardId)
			if mapBase then
				return mapBase.Title
			end
		elseif self.nEffectType == GameEnum.PenguinCardEffectType.IncreaseBasicChips or self.nEffectType == GameEnum.PenguinCardEffectType.IncreaseMultiplier or self.nEffectType == GameEnum.PenguinCardEffectType.MultiMultiplier then
			return tbParam[nIndex]
		end
	end
	local result = string.gsub(mapCfg.Desc, "%b{}", function(token)
		if token == "{TriggerProbability}" then
			return mapCfg.TriggerProbability
		elseif token == "{TriggerLimitParam}" then
			return mapCfg.TriggerLimitParam
		end
		local trigIdx = string.match(token, "^{TriggerParam_(%d+)}$")
		if trigIdx then
			local idx = tonumber(trigIdx)
			return ParseTriggerParam(decodeJson(mapCfg.TriggerParam), idx)
		end
		local effectIdx = string.match(token, "^{EffectParam_(%d+)}$")
		if effectIdx then
			local idx = tonumber(effectIdx)
			return ParseEffectParam(decodeJson(mapCfg.EffectParam), idx)
		end
		return token
	end)
	return result
end
function PenguinCard:ResetGameTrigger()
	if self.nTriggerLimit == GameEnum.PenguinCardTriggerLimit.Game then
		self.nTriggerCount = 0
	end
end
function PenguinCard:ResetRoundTrigger()
	if self.nTriggerLimit == GameEnum.PenguinCardTriggerLimit.Round then
		self.nTriggerCount = 0
	end
end
function PenguinCard:ResetTurnTrigger()
	if self.nTriggerLimit == GameEnum.PenguinCardTriggerLimit.Turn then
		self.nTriggerCount = 0
	end
end
function PenguinCard:Trigger(nTriggerPhase, mapTriggerSource, callback)
	if self.nTriggerLimit ~= GameEnum.PenguinCardTriggerLimit.None and self.nTriggerCount >= self.nTriggerLimitParam then
		return
	end
	if nTriggerPhase ~= self.nTriggerPhase then
		return
	end
	local bAble = self:CheckTriggerAble(mapTriggerSource)
	if not bAble then
		return
	end
	if self.nTriggerLimit ~= GameEnum.PenguinCardTriggerLimit.None then
		self.nTriggerCount = self.nTriggerCount + 1
	end
	if callback then
		printLog("\228\188\129\233\185\133\231\137\140\232\167\166\229\143\145\239\188\154" .. "  " .. self.sName .. "  " .. self.sDesc)
		callback(self.nEffectType, self.tbEffectParam)
	end
	EventManager.Hit("PenguinCardTriggered", self.nSlotIndex)
end
function PenguinCard:CheckTriggerAble(mapTriggerSource)
	local bAble = false
	if self.nTriggerType == GameEnum.PenguinCardTriggerType.None then
		bAble = true
	elseif mapTriggerSource then
		if self.nTriggerType == GameEnum.PenguinCardTriggerType.SuitCards and mapTriggerSource.SuitCards then
			local nAimCount = #self.tbTriggerParam
			local nHasCount = 0
			for _, nAimSuit in ipairs(self.tbTriggerParam) do
				for _, nHasSuit in ipairs(mapTriggerSource.SuitCards) do
					if nAimSuit == nHasSuit then
						nHasCount = nHasCount + 1
					end
				end
			end
			if nAimCount <= nHasCount then
				bAble = true
			end
		elseif self.nTriggerType == GameEnum.PenguinCardTriggerType.SuitCount and mapTriggerSource.SuitCount then
			for k, nAimCount in pairs(self.tbTriggerParam) do
				if not mapTriggerSource.SuitCount[tonumber(k)] or nAimCount > mapTriggerSource.SuitCount[tonumber(k)] then
					return false
				end
			end
			bAble = true
		elseif self.nTriggerType == GameEnum.PenguinCardTriggerType.HandRankSuitCount and mapTriggerSource.HandRankSuitCount then
			for k, nAimCount in pairs(self.tbTriggerParam) do
				if not mapTriggerSource.HandRankSuitCount[tonumber(k)] or nAimCount > mapTriggerSource.HandRankSuitCount[tonumber(k)] then
					return false
				end
			end
			bAble = true
		elseif self.nTriggerType == GameEnum.PenguinCardTriggerType.BaseCardId and mapTriggerSource.BaseCard then
			bAble = mapTriggerSource.BaseCard.nId == self.tbTriggerParam[1]
		end
	end
	local randomValue = math.random(0, 100)
	return bAble and randomValue <= self.nTriggerProbability
end
function PenguinCard:GetIdByLevel(nGroupId, nLevel)
	return nGroupId * 100 + nLevel
end
return PenguinCard
