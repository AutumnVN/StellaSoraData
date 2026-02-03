local LocalData = require("GameCore.Data.LocalData")
local RapidJson = require("rapidjson")
local BreakOutLevelData = class("BreakOutLevelData")
local mapEventConfig = {
	LoadLevelRefresh = "OnEvent_LoadLevelRefresh",
	AdventureModuleEnter = "OnEvent_AdventureModuleEnter",
	BattlePause = "OnEvent_Pause",
	ADVENTURE_LEVEL_UNLOAD_COMPLETE = "OnEvent_UnloadComplete",
	InputEnable = "OnEvent_InputEnable",
	BreakOut_Complete = "SetBreakOut_Complete",
	SetPlayFinishState = "SetPlayFinishState"
}
function BreakOutLevelData:InitData(nLevelId, nCharacterNid, nActId)
	self.nLevelId = nLevelId
	self.tbSkillData = {}
	self.cacheHasDicList = {}
	self.nActId = nActId
	self.nCharacterNid = nCharacterNid
	self.bRestart = false
	self:BindEvent()
	self.tbDropCollect = {}
	self.FloorId = ConfigTable.GetData("BreakOutLevel", nLevelId).FloorId
	self.bIsEnd = true
	self.bIsFinishGame = false
	local sJson = LocalData.GetPlayerLocalData("BreakOutFloorDicId")
	local tb = decodeJson(sJson)
	if type(tb) == "table" then
		self.cacheHasDicList = tb
	end
end
function BreakOutLevelData:RefreshCharSkillCd(nCharacterId, nCD)
	if self.tbCharacterNid == nil then
		return
	end
	self.tbCharacterData[nCharacterId].nCD = nCD
end
function BreakOutLevelData:GetCurrentFloorDrops(FloorData)
	if FloorData == nil then
		return
	end
	for _, DropsId in pairs(FloorData.Drops) do
		local DropData = {Id = DropsId, Count = 0}
		table.insert(self.tbDropCollect, DropData)
	end
	return self.tbDropCollect
end
function BreakOutLevelData:IsTrueDrops(ItemId)
	if self.tbDropCollect ~= nil then
		for _, v in pairs(self.tbDropCollect) do
			if ItemId == v.Id then
				return true
			end
		end
	end
	return false
end
function BreakOutLevelData:BindEvent()
	if type(mapEventConfig) ~= "table" then
		return
	end
	for nEventId, sCallbackName in pairs(mapEventConfig) do
		local callback = self[sCallbackName]
		if type(callback) == "function" then
			EventManager.Add(nEventId, self, callback)
		end
	end
end
function BreakOutLevelData:UnBindEvent()
	if type(mapEventConfig) ~= "table" then
		return
	end
	for nEventId, sCallbackName in pairs(mapEventConfig) do
		local callback = self[sCallbackName]
		if type(callback) == "function" then
			EventManager.Remove(nEventId, self, callback)
		end
	end
end
function BreakOutLevelData:OnEvent_UnloadComplete()
	if not self.bIsEnd then
		local tempData = {
			curChar = self.nCharacterNid,
			nLevelId = self.nLevelId,
			nActId = self.nActId,
			FloorId = self.FloorId
		}
		EventManager.Hit("BreakOutRestart")
		EventManager.Hit("Event_ReStartBreakOut", tempData)
		self.bIsEnd = true
	else
		NovaAPI.EnterModule("MainMenuModuleScene", true)
		self:UnBindEvent()
	end
end
function BreakOutLevelData:SetBreakOut_Complete(bIsEnd)
	self.bIsEnd = bIsEnd
end
function BreakOutLevelData:GetIsBreakOut_Complete()
	return self.bIsEnd
end
function BreakOutLevelData:SetPlayFinishState(bIsFinishGame)
	self.bIsFinishGame = bIsFinishGame
end
function BreakOutLevelData:GetIsFinishGame()
	return self.bIsFinishGame
end
function BreakOutLevelData:OnEvent_AdventureModuleEnter()
	EventManager.Hit(EventId.OpenPanel, PanelId.BreakOutPlayPanel, self.nActId, self.nLevelId, self.nCharacterNid)
end
function BreakOutLevelData:GetFloorHasDic(nFloorId)
	local bResult = true
	if table.indexof(self.cacheHasDicList, nFloorId) == 0 then
		bResult = false
	end
	return bResult
end
function BreakOutLevelData:OnEvent_SetFloorHasDic(nFloorId)
	if table.indexof(self.cacheHasDicList, nFloorId) == 0 then
		table.insert(self.cacheHasDicList, nFloorId)
		local tbLocalSave = {}
		for _, v in ipairs(self.cacheHasDicList) do
			table.insert(tbLocalSave, v)
		end
		LocalData.SetPlayerLocalData("BreakOutFloorDicId", RapidJson.encode(tbLocalSave))
	end
end
return BreakOutLevelData
