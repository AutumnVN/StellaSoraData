local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local AdvertiseActData = class("AdvertiseActData", ActivityDataBase)
function AdvertiseActData:Init()
	self.nStatus = 0
	self.jointDrillActCfg = nil
	self.bIsMove = ConfigTable.GetData("AdControl", self.actCfg.Id).IsMove
	self:InitConfig()
end
function AdvertiseActData:InitConfig()
end
function AdvertiseActData:RefreshInfinityTowerActData(msgData)
end
function AdvertiseActData:GetActOpenTime()
	return self.nOpenTime
end
function AdvertiseActData:GetActCloseTime()
	return self.nEndTime
end
function AdvertiseActData:GetActSortId()
	if self.bIsMove and self:isFinishAllTasks() then
		return 9999
	else
		return self.actCfg.SortId
	end
end
function AdvertiseActData:isFinishAllTasks()
	local nTotalCount, nReceivedCount = PlayerData.TutorialData:GetProgress()
	local bHasReceiveAllGroup = PlayerData.Quest:CheckTourGroupReward(PlayerData.Quest:GetMaxTourGroupOrderIndex())
	if bHasReceiveAllGroup and nTotalCount == nReceivedCount then
		return true
	end
	return false
end
return AdvertiseActData
