local PenguinCardCtrl = class("PenguinCardCtrl", BaseCtrl)
local WwiseManger = CS.WwiseAudioManager.Instance
PenguinCardCtrl._mapNodeConfig = {
	btnPause = {
		nCount = 2,
		sComponentName = "UIButton",
		callback = "OnBtnClick_Pause"
	},
	Prepare = {
		sNodeName = "---Prepare---",
		sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardPrepareCtrl"
	},
	Flip = {
		sNodeName = "---Flip---",
		sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardFlipCtrl"
	},
	Slot = {
		sNodeName = "---Slot---",
		sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardSlotCtrl"
	},
	Result = {
		sNodeName = "---Result---",
		sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardResultCtrl"
	},
	CardInfo = {
		sNodeName = "---CardInfo---",
		sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardInfoCtrl"
	},
	Pause = {
		sNodeName = "---Pause---",
		sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardPauseCtrl"
	},
	HandRank = {
		sNodeName = "---HandRank---",
		sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardHandRankCtrl"
	},
	Log = {
		sNodeName = "---Log---",
		sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardLogCtrl"
	}
}
PenguinCardCtrl._mapEventConfig = {
	PenguinCard_RunState_Prepare = "RunState_Prepare",
	PenguinCard_RunState_Dealing = "RunState_Dealing",
	PenguinCard_RunState_Flip = "RunState_Flip",
	PenguinCard_RunState_Settlement = "RunState_Settlement",
	PenguinCard_RunState_Complete = "RunState_Complete",
	PenguinCard_Change = "OnEvent_Change"
}
function PenguinCardCtrl:RunState_Prepare()
	self._mapNode.Prepare.gameObject:SetActive(true)
	self._mapNode.Slot.gameObject:SetActive(true)
	self._mapNode.Result.gameObject:SetActive(false)
	self._mapNode.Flip.gameObject:SetActive(false)
	self._mapNode.Prepare:Refresh()
	self._mapNode.Slot:Refresh()
	EventManager.Hit("Guide_PassiveCheck_Msg", "Guide_PenguinCard_301")
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		EventManager.Hit("Guide_PassiveCheck_Msg", "Guide_PenguinCard_303")
	end
	cs_coroutine.start(wait)
end
function PenguinCardCtrl:RunState_Dealing()
	self._mapNode.Prepare.gameObject:SetActive(false)
	self._mapNode.Flip.gameObject:SetActive(true)
	self._mapNode.Flip:Refresh_Dealing()
	EventManager.Hit("Guide_PassiveCheck_Msg", "Guide_PenguinCard_302")
end
function PenguinCardCtrl:RunState_Flip()
	self._mapNode.Flip:Refresh_Flip()
end
function PenguinCardCtrl:RunState_Settlement()
	self._mapNode.Flip:Refresh_Settlement()
end
function PenguinCardCtrl:RunState_Complete()
	self._mapNode.Result:Open()
end
function PenguinCardCtrl:Awake()
	self._mapNode.CardInfo.gameObject:SetActive(false)
	self._mapNode.Pause.gameObject:SetActive(false)
	self._mapNode.HandRank.gameObject:SetActive(false)
	self._mapNode.Result.gameObject:SetActive(false)
	self._mapNode.Log.gameObject:SetActive(false)
end
function PenguinCardCtrl:OnEnable()
	self._panel.mapLevel:StartGame()
	self._mapNode.Flip:RefreshButton()
end
function PenguinCardCtrl:OnDisable()
	self._panel.mapLevel = nil
end
function PenguinCardCtrl:OnBtnClick_Pause(btn)
	self._mapNode.Pause:Open()
end
function PenguinCardCtrl:OnEvent_Change(callback)
	callback(self, self._panel.mapLevel)
end
return PenguinCardCtrl
