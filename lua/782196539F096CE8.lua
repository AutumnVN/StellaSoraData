local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local ThrowGiftData = class("ThrowGiftData", ActivityDataBase)
function ThrowGiftData:Init()
	self.nActId = 0
	self.mapLevels = {}
	self.mapItems = {}
end
function ThrowGiftData:RefreshQuestData(questData)
end
function ThrowGiftData:RefreshThrowGiftData(nActId, msgData)
	self:Init()
	self.nActId = nActId
	for _, mapLevel in ipairs(msgData.Levels) do
		self.mapLevels[mapLevel.LevelId] = mapLevel
	end
	for _, mapItem in ipairs(msgData.Items) do
		self.mapItems[mapItem.ItemId] = mapItem.Count
	end
end
function ThrowGiftData:GetActivityData()
	return {
		nActId = self.nActId,
		mapLevels = clone(self.mapLevels),
		mapItems = clone(self.mapItems)
	}
end
function ThrowGiftData:SettleLevels(nLevelId, nThrowGiftCount, nHitGiftCount, nScore, tbUseItems, bWin, callback)
	local msg = {}
	msg.ActivityId = self.nActId
	msg.LevelId = nLevelId
	msg.ThrowGiftCount = nThrowGiftCount
	msg.HitGiftCount = nHitGiftCount
	msg.Score = nScore
	msg.UseItems = tbUseItems
	msg.Win = bWin
	local msgCallback = function(_, msgData)
		if self.mapLevels[nLevelId] == nil then
			self.mapLevels[nLevelId] = {
				LevelId = nLevelId,
				MaxScore = nScore,
				FirstComplete = bWin
			}
		else
			if self.mapLevels[nLevelId].MaxScore < nScore then
				self.mapLevels[nLevelId].MaxScore = nScore
			end
			self.mapLevels[nLevelId].FirstComplete = bWin or self.mapLevels[nLevelId].FirstComplete
		end
		if callback ~= nil then
			callback()
		end
	end
	HttpNetHandler.SendMsg(NetMsgId.Id.activity_throw_gift_settle_req, msg, nil, msgCallback)
end
return ThrowGiftData
