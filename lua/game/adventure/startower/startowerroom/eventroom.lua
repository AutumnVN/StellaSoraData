local BaseRoom = require("Game.Adventure.StarTower.StarTowerRoom.BaseRoom")
local EventRoom = class("EventRoom", BaseRoom)
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
EventRoom._mapEventConfig = {
	LevelStateChanged = "OnEvent_LevelStateChanged",
	InteractiveNpc = "OnEvent_InteractiveNpc"
}
function EventRoom:LevelStart()
	self:HandleCases()
	EventManager.Hit("ShowStarTowerRoomInfo", true, self.parent.nTeamLevel, self.parent.nTeamExp, clone(self.parent._mapNote), clone(self.parent._mapFateCard))
	local nCoin = self.parent._mapItem[AllEnum.CoinItemId.FixedRogCurrency]
	if nCoin == nil then
		nCoin = 0
	end
	local nBuildScore = self.parent:CalBuildScore()
	EventManager.Hit("ShowStarTowerCoin", true, nCoin, nBuildScore)
	EventManager.Hit("PlayStarTowerDiscBgm")
end
function EventRoom:OnEvent_InteractiveNpc(nNpcId, nNpcUid)
	self:HandleNpc(nNpcId, nNpcUid)
end
function EventRoom:OnLoadLevelRefresh()
end
function EventRoom:OnEvent_LevelStateChanged(nState)
	if nState == GameEnum.levelState.Teleporter then
		if self.mapCases[self.EnumCase.OpenDoor] == nil then
			printError("\230\151\160\228\188\160\233\128\129\233\151\168case \230\151\160\230\179\149\232\191\155\229\133\165\228\184\139\228\184\128\229\177\130")
			return
		end
		local tbDoorCase = self.mapCases[self.EnumCase.OpenDoor]
		self.parent:EnterRoom(tbDoorCase[1], tbDoorCase[2])
		return
	end
end
return EventRoom
