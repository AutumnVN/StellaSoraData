local ActivityDataBase = require("GameCore.Data.DataClass.Activity.ActivityDataBase")
local LoginRewardActData = class("LoginRewardActData", ActivityDataBase)
function LoginRewardActData:Init()
	self.nCanReceives = 0
	self.nActual = 0
	self.tbRewardList = {}
	self.loginRewardActCfg = nil
	self:InitRewardList()
end
function LoginRewardActData:InitRewardList()
	local mapActCfg = ConfigTable.GetData("LoginRewardControl", self.nActId)
	if nil == mapActCfg then
		return
	end
	self.loginRewardActCfg = mapActCfg
	local tbRewardList = CacheTable.GetData("_LoginRewardGroup", mapActCfg.RewardsGroup)
	if tbRewardList == nil then
		printError(string.format("LoginRewardGroup\232\161\168\228\184\173\228\184\141\229\173\152\229\156\168\229\165\150\229\138\177\231\187\132id\228\184\186 %s \231\154\132\233\133\141\231\189\174\239\188\129\239\188\129\239\188\129", mapActCfg.RewardsGroup))
		return
	end
	table.sort(tbRewardList, function(a, b)
		return a.Order < b.Order
	end)
	self.tbRewardList = tbRewardList
end
function LoginRewardActData:RefreshLoginData(nReceive, nActual)
	self.nCanReceives = nReceive
	self.nActual = nActual
	for k, v in ipairs(self.tbRewardList) do
		v.Status = 0
		if k <= nReceive then
			v.Status = 1
		end
		if k <= nActual then
			v.Status = 2
		end
	end
end
function LoginRewardActData:ReceiveRewardSuc()
	self:RefreshLoginData(self.nCanReceives, self.nCanReceives)
end
function LoginRewardActData:GetActLoginRewardList()
	return self.tbRewardList
end
function LoginRewardActData:GetCanReceive()
	return self.nCanReceives
end
function LoginRewardActData:GetReceived()
	return self.nActual
end
function LoginRewardActData:CheckCanReceive()
	return self.nCanReceives > self.nActual
end
function LoginRewardActData:GetLoginRewardControlCfg()
	return self.loginRewardActCfg
end
return LoginRewardActData
