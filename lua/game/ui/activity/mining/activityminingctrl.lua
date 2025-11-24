local ActivityMiningCtrl = class("ActivityMiningCtrl", BaseCtrl)
local TimerManager = require("GameCore.Timer.TimerManager")
local ClientManager = CS.ClientManager.Instance
local axeItemId = 0
ActivityMiningCtrl._mapNodeConfig = {
	btnGo = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Go"
	}
}
function ActivityMiningCtrl:OnDestory(...)
	self:UnInit()
end
function ActivityMiningCtrl:InitActData(actData)
	self.actData = actData
	self:ShowAddAxeCount()
	self:RefreshTimeout()
end
function ActivityMiningCtrl:UnInit(...)
	RedDotManager.UnRegisterNode(RedDotDefine.Activity_Mining_Quest_Group, nil, self._mapNode.reddot_Task)
end
function ActivityMiningCtrl:RefreshTimeout()
	local endTime = self.actData:GetActEndTime()
	local curTime = ClientManager.serverTimeStamp
	local remainTime = endTime - curTime
	if remainTime < 0 then
		TimerManager.Remove(self.remainTimer)
		self.remainTimer = nil
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Alert,
			sContent = ConfigTable.GetUIText("Activity_Invalid_Tip_1"),
			callbackConfirm = function()
				EventManager.Hit(EventId.ClosePanel, PanelId.ActivityList)
			end
		})
		return
	end
	local sTimeStr = ""
	if remainTime <= 60 then
		local sec = math.floor(remainTime)
		sTimeStr = string.format(ConfigTable.GetUIText("Activity_Remain_Time_Sec") or "", sec)
	elseif 60 < remainTime and remainTime <= 3600 then
		local min = math.floor(remainTime / 60)
		local sec = math.floor(remainTime - min * 60)
		if sec == 0 then
			min = min - 1
			sec = 60
		end
		sTimeStr = string.format(ConfigTable.GetUIText("Activity_Remain_Time_Min") or "", min, sec)
	elseif 3600 < remainTime and remainTime <= 86400 then
		local hour = math.floor(remainTime / 3600)
		local min = math.floor((remainTime - hour * 3600) / 60)
		if min == 0 then
			hour = hour - 1
			min = 60
		end
		sTimeStr = string.format(ConfigTable.GetUIText("Activity_Remain_Time_Hour") or "", hour, min)
	elseif 86400 < remainTime then
		local day = math.floor(remainTime / 86400)
		local hour = math.floor((remainTime - day * 86400) / 3600)
		if hour == 0 then
			day = day - 1
			hour = 24
		end
		sTimeStr = string.format(ConfigTable.GetUIText("Activity_Remain_Time_Day") or "", day, hour)
	end
	NovaAPI.SetTMPText(self._mapNode.txtTimeout, sTimeStr)
end
function ActivityMiningCtrl:ShowAddAxeCount()
	local nActId = self.actData:GetActId()
	local data = PlayerData.Activity:GetActivityDataById(nActId)
	local nAddAxeCount = data:GetAddAxeCount()
	if 0 < nAddAxeCount then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Item,
			tbItem = {
				[1] = {nTid = axeItemId, nCount = nAddAxeCount}
			}
		})
		data:ResetAddAxeCount()
	end
end
function ActivityMiningCtrl:OnBtnClick_Go(...)
	local nActId = self.actData:GetActId()
	local tbStoryConfig = self.actData:GetStoryConfigIdList()
	local nCurLevel = self.actData:GetLevel()
	local sNeedPlayAvgyId = 0
	local nStoryId = 0
	local tbAllData = self.actData:GetGroupStoryData()
	for _, v in pairs(tbStoryConfig) do
		if nCurLevel >= v.config.UnlockLayer then
			local temp = v.config.Id
			if not tbAllData[temp].bIsRead then
				sNeedPlayAvgyId = v.config.AvgId
				nStoryId = v.config.Id
			end
			break
		end
	end
	local bAvgReadState = true
	if tbAllData[nStoryId] ~= nil then
		bAvgReadState = false
	end
	if sNeedPlayAvgyId ~= 0 and not bAvgReadState then
		local callback = function(...)
			EventManager.Hit(EventId.ClosePanel, PanelId.PureAvgStory)
			self.actData:RequestFinishAvg(nStoryId)
		end
		local mapData = {
			nType = AllEnum.StoryAvgType.Plot,
			sAvgId = sNeedPlayAvgyId,
			nNodeId = nil,
			callback = callback
		}
		EventManager.Hit(EventId.OpenPanel, PanelId.PureAvgStory, mapData)
	end
	local callback = function()
		EventManager.Hit(EventId.OpenPanel, PanelId.MiningGame, nActId)
	end
	self.actData:RequestLevelData(0, callback)
end
function ActivityMiningCtrl:OnBtnClick_Story(...)
	local nActId = self.actData:GetActId()
	EventManager.Hit(EventId.OpenPanel, PanelId.MiningGameStory, nActId)
end
function ActivityMiningCtrl:OnBtnClick_Task(...)
	local nActId = self.actData:GetActId()
	EventManager.Hit(EventId.OpenPanel, PanelId.MiningGameQuest, nActId)
end
function ActivityMiningCtrl:OnBtnClick_Shop(...)
	local nActId = self.actData:GetActId()
	local tbConfig = ConfigTable.GetData("MiningControl", nActId)
	local nShopId = tbConfig.ShopId
	EventManager.Hit(EventId.OpenPanel, PanelId.ShopPanel, nShopId)
end
function ActivityMiningCtrl:ClearActivity()
end
return ActivityMiningCtrl
