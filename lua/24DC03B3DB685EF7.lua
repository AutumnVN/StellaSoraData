local NotificationManager = {}
local TimerManager = require("GameCore.Timer.TimerManager")
local Event = require("GameCore.Event.Event")
local SDKManager = CS.SDKManager.Instance
local tbNotification = {}
local bAppSuspended = false
local OnApplicationFocus = function(_, bFocus)
	bAppSuspended = not bFocus
end
function NotificationManager.RegisterNotification(nId, nSubkey, nTime)
	if not SDKManager:IsSDKInit() then
		return
	end
	if not NovaAPI.IsMobilePlatform() then
		return
	end
	local configData = ConfigTable.GetData("NotificationConfig", nId)
	if configData == nil then
		printLog("NotificationManager \230\179\168\229\134\140\230\142\168\233\128\129\229\164\177\232\180\165\239\188\140\233\133\141\231\189\174\232\161\168\230\149\176\230\141\174\228\184\141\229\173\152\229\156\168")
		return
	end
	local setTime = nTime - 5000
	if setTime <= CS.ClientManager.Instance.serverTimeStamp then
		return
	end
	local data = {
		id = nId,
		key = nId + nSubkey,
		time = nTime,
		timer = TimerManager.Add(1, setTime - CS.ClientManager.Instance.serverTimeStamp, nil, function()
			if not bAppSuspended then
				printLog("NotificationManager \231\148\177\232\174\161\230\151\182\229\153\168\232\167\166\229\143\145\231\154\132\229\143\150\230\182\136\230\142\168\233\128\129\230\136\144\229\138\159\239\188\140id:", tostring(nId + nSubkey))
				UnregisterNotification(nId, nSubkey)
			end
		end, true, true, false, nil)
	}
	table.insert(tbNotification, data)
	local sContent = configData.Content
	sContent = string.gsub(sContent, "==PLAYER_NAME==", PlayerData.Base:GetPlayerNickName())
	SDKManager:BuildLocalNotification(nId + nSubkey, configData.Title, sContent, nTime)
	printLog("NotificationManager \230\179\168\229\134\140\230\142\168\233\128\129\230\136\144\229\138\159\239\188\140id:", tostring(nId + nSubkey), "title:", configData.Title, "content:", sContent, "time:", tostring(setTime))
end
function NotificationManager.UnregisterNotification(nId, nSubkey)
	if not SDKManager:IsSDKInit() then
		return
	end
	if not NovaAPI.IsMobilePlatform() then
		return
	end
	local tbRemove = {}
	for i, data in ipairs(tbNotification) do
		if data.id == nId and data.key == nId + nSubkey then
			data.timer:_Stop()
			table.remove(tbNotification, i)
			table.insert(tbRemove, nId + nSubkey)
			break
		end
	end
	SDKManager:DeleteLocalNotification(tbRemove)
	printLog("NotificationManager \229\143\150\230\182\136\230\142\168\233\128\129\230\136\144\229\138\159\239\188\140id:", tostring(nId + nSubkey))
end
local function Uninit()
	EventManager.Remove(EventId.CSLuaManagerShutdown, NotificationManager, Uninit)
	EventManager.Remove("CS2LuaEvent_OnApplicationFocus", NotificationManager, OnApplicationFocus)
end
function NotificationManager.Init()
	EventManager.Add(EventId.CSLuaManagerShutdown, NotificationManager, Uninit)
	EventManager.Add("CS2LuaEvent_OnApplicationFocus", NotificationManager, OnApplicationFocus)
end
return NotificationManager
