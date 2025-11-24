local TimerManager = require("GameCore.Timer.TimerManager")
local TimerScaleType = require("GameCore.Timer.TimerScaleType")
local ClientManager = CS.ClientManager.Instance
local _bManual = false
local _nDailyCheckInIndex = 0
local templateDailyCheckInData
local ProcessMonthlyCard = function(mapMsgData)
	local mapReward = PlayerData.Item:ProcessRewardChangeInfo(mapMsgData.Change)
	local nEndTime = mapMsgData.EndTime
	local nId = mapMsgData.Id
	local mapNext = {
		mapReward = mapReward,
		nEndTime = nEndTime,
		nRemaining = mapMsgData.Remaining,
		nId = nId
	}
	PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.MonthlyCard, mapNext)
end
local CacheDailyCheckIn = function(nIndex)
	if nIndex == nil then
		return
	end
	_nDailyCheckInIndex = nIndex
end
local ProcessDailyCheckIn = function(mapMsgData)
	_nDailyCheckInIndex = mapMsgData.Index
	if not PlayerData.Base:CheckFunctionUnlock(GameEnum.OpenFuncType.SignIn) then
		templateDailyCheckInData = mapMsgData
		return
	end
	local mapReward = PlayerData.Item:ProcessRewardChangeInfo(mapMsgData.Change)
	PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.DailyCheckIn, mapReward)
end
local CheckDailyCheckIn = function()
	local bOpen = PlayerData.Base:CheckFunctionUnlock(GameEnum.OpenFuncType.SignIn)
	if templateDailyCheckInData ~= nil and bOpen then
		local mapReward = PlayerData.Item:ProcessRewardChangeInfo(templateDailyCheckInData.Change)
		PopUpManager.PopUpEnQueue(GameEnum.PopUpSeqType.DailyCheckIn, mapReward)
		templateDailyCheckInData = nil
	end
end
local GetDailyCheckInList = function(nDays)
	local tbReward = CacheTable.GetData("_SignIn", nDays)
	if not tbReward then
		printError("\229\189\147\229\137\141\230\156\136\231\154\132\229\164\169\230\149\176\230\152\175" .. nDays .. "\239\188\140\230\178\161\230\156\137\231\155\184\229\133\179\233\133\141\231\189\174\239\188\140\230\139\19131\229\164\169\231\154\132\230\149\176\230\141\174\233\161\182\228\186\134")
		tbReward = CacheTable.GetData("_SignIn", 31)
	end
	return tbReward
end
local GetMonthAndDays = function()
	local nServerTimeStampWithTimeZone = ClientManager.serverTimeStampWithTimeZone
	local nYear = tonumber(os.date("!%Y", nServerTimeStampWithTimeZone))
	local nMonth = tonumber(os.date("!%m", nServerTimeStampWithTimeZone))
	local nDay = tonumber(os.date("!%d", nServerTimeStampWithTimeZone))
	local nHour = tonumber(os.date("!%H", nServerTimeStampWithTimeZone))
	if nDay == 1 and nHour < 5 then
		nMonth = nMonth == 1 and 12 or nMonth - 1
	end
	local nNextMonthTime = os.time({
		year = tostring(nYear),
		month = nMonth + 1,
		day = 0
	})
	local nDays = tonumber(os.date("!%d", nNextMonthTime))
	return nMonth, nDays
end
local GetDailyCheckInIndex = function()
	if _nDailyCheckInIndex == 0 then
		printError("\231\173\190\229\136\176\239\188\154\230\178\161\230\156\137\231\173\190\229\136\176\230\149\176\230\141\174\239\188\140\228\184\141\231\159\165\233\129\147\230\152\175\231\173\190\229\136\176\231\172\172\229\135\160\229\164\169")
	end
	return _nDailyCheckInIndex
end
local ProcessTableData = function()
	local _SignIn = {}
	local func_ForEach = function(mapLineData)
		local mapLine = {
			ItemId = mapLineData.ItemId,
			ItemQty = mapLineData.ItemQty
		}
		if not _SignIn[mapLineData.Group] then
			_SignIn[mapLineData.Group] = {}
		end
		_SignIn[mapLineData.Group][mapLineData.Day] = mapLine
	end
	ForEachTableLine(DataTable.SignIn, func_ForEach)
	CacheTable.Set("_SignIn", _SignIn)
end
local Init = function()
	_bManual = false
	_nDailyCheckInIndex = 0
	ProcessTableData()
end
local UnInit = function()
	_bManual = false
	_nDailyCheckInIndex = 0
end
local CacheDailyData = function(nIndex)
	CacheDailyCheckIn(nIndex)
end
local SetManualPanel = function(state)
	_bManual = state
end
local PlayerDailyData = {
	Init = Init,
	UnInit = UnInit,
	GetMonthAndDays = GetMonthAndDays,
	GetDailyCheckInIndex = GetDailyCheckInIndex,
	GetDailyCheckInList = GetDailyCheckInList,
	SetManualPanel = SetManualPanel,
	CacheDailyData = CacheDailyData,
	ProcessMonthlyCard = ProcessMonthlyCard,
	ProcessDailyCheckIn = ProcessDailyCheckIn,
	CheckDailyCheckIn = CheckDailyCheckIn
}
return PlayerDailyData
