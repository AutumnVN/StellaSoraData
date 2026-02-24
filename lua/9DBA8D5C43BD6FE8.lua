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
	},
	Confirm = {
		sNodeName = "---Confirm---",
		sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardConfirmCtrl"
	}
}
PenguinCardCtrl._mapEventConfig = {
	PenguinCard_RunState_Start = "RunState_Start",
	PenguinCard_RunState_Prepare = "RunState_Prepare",
	PenguinCard_RunState_Dealing = "RunState_Dealing",
	PenguinCard_RunState_Flip = "RunState_Flip",
	PenguinCard_RunState_Settlement = "RunState_Settlement",
	PenguinCard_RunState_Complete = "RunState_Complete",
	PenguinCard_QuitState_Start = "QuitState_Start",
	PenguinCard_QuitState_Prepare = "QuitState_Prepare",
	PenguinCard_QuitState_Dealing = "QuitState_Dealing",
	PenguinCard_QuitState_Flip = "QuitState_Flip",
	PenguinCard_QuitState_Settlement = "QuitState_Settlement",
	PenguinCard_QuitState_Complete = "QuitState_Complete",
	PenguinCard_Change = "OnEvent_Change"
}
function PenguinCardCtrl:RunState_Start()
	self:CloseAll()
end
function PenguinCardCtrl:QuitState_Start()
end
function PenguinCardCtrl:RunState_Prepare()
	self._mapNode.Prepare.gameObject:SetActive(true)
	self._mapNode.Slot.gameObject:SetActive(true)
	self._mapNode.Result.gameObject:SetActive(false)
	self._mapNode.Flip.gameObject:SetActive(false)
	self._mapNode.Prepare:Refresh()
	self._mapNode.Slot:Refresh()
	if self.bIn then
		self.bIn = false
	else
		WwiseManger:PostEvent("Mode_Card_nextround")
	end
	EventManager.Hit("Guide_PassiveCheck_Msg", "Guide_PenguinCard_301")
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		EventManager.Hit("Guide_PassiveCheck_Msg", "Guide_PenguinCard_303")
	end
	cs_coroutine.start(wait)
end
function PenguinCardCtrl:QuitState_Prepare(nNextState)
	if nNextState == 0 then
		self._mapNode.Slot:PlayOutAni()
		self._mapNode.Prepare:PlayOutAni()
		WwiseManger:PostEvent("Mode_Card_dissolve")
	elseif nNextState == 2 then
		self._mapNode.Prepare:PlayOutAni()
		WwiseManger:PostEvent("Mode_Card_dissolve")
	elseif nNextState == 5 then
		self._mapNode.Slot:PlayOutAni()
		self._mapNode.Prepare:PlayOutAni()
		self.animator:Play("PengUinCard_Bg_Result")
		WwiseManger:PostEvent("Mode_Card_dissolve")
	end
end
function PenguinCardCtrl:RunState_Dealing()
	self._mapNode.Prepare.gameObject:SetActive(false)
	self._mapNode.Flip.gameObject:SetActive(true)
	self._mapNode.Flip:Refresh_Dealing()
	EventManager.Hit("Guide_PassiveCheck_Msg", "Guide_PenguinCard_302")
end
function PenguinCardCtrl:QuitState_Dealing(nNextState)
	if nNextState == 0 then
		self._mapNode.Slot:PlayOutAni()
		self._mapNode.Flip:PlayOutAni()
		WwiseManger:PostEvent("Mode_Card_dissolve")
	elseif nNextState == 5 then
		self._mapNode.Slot:PlayOutAni()
		self._mapNode.Flip:PlayOutAni()
		self.animator:Play("PengUinCard_Bg_Result")
		WwiseManger:PostEvent("Mode_Card_dissolve")
	end
end
function PenguinCardCtrl:RunState_Flip()
	self._mapNode.Flip:Refresh_Flip()
end
function PenguinCardCtrl:QuitState_Flip(nNextState)
	self._mapNode.Flip:StopShowAllOn()
	if nNextState == 0 then
		self._mapNode.Slot:PlayOutAni()
		self._mapNode.Flip:PlayOutAni()
		WwiseManger:PostEvent("Mode_Card_dissolve")
	elseif nNextState == 5 then
		self._mapNode.Slot:PlayOutAni()
		self._mapNode.Flip:PlayOutAni()
		self.animator:Play("PengUinCard_Bg_Result")
		WwiseManger:PostEvent("Mode_Card_dissolve")
	end
end
function PenguinCardCtrl:RunState_Settlement()
	self._mapNode.Flip:Refresh_Settlement()
end
function PenguinCardCtrl:QuitState_Settlement(nNextState)
	if nNextState == 0 then
		self._mapNode.Slot:PlayOutAni()
		self._mapNode.Flip:PlayOutAni()
		WwiseManger:PostEvent("Mode_Card_dissolve")
	elseif nNextState == 1 then
		self._mapNode.Flip:PlayOutAni()
		WwiseManger:PostEvent("Mode_Card_dissolve")
	elseif nNextState == 2 then
		self._mapNode.Flip:PlayRoundAni()
	elseif nNextState == 5 then
		self._mapNode.Slot:PlayOutAni()
		self._mapNode.Flip:PlayOutAni()
		self.animator:Play("PengUinCard_Bg_Result")
		WwiseManger:PostEvent("Mode_Card_dissolve")
	end
end
function PenguinCardCtrl:RunState_Complete()
	self._mapNode.Result:Open()
end
function PenguinCardCtrl:QuitState_Complete()
end
function PenguinCardCtrl:CloseAll()
	self._mapNode.Prepare.gameObject:SetActive(false)
	self._mapNode.Slot.gameObject:SetActive(false)
	self._mapNode.Flip.gameObject:SetActive(false)
	self._mapNode.CardInfo.gameObject:SetActive(false)
	self._mapNode.Pause.gameObject:SetActive(false)
	self._mapNode.HandRank.gameObject:SetActive(false)
	self._mapNode.Result.gameObject:SetActive(false)
	self._mapNode.Log.gameObject:SetActive(false)
	self._mapNode.Confirm.gameObject:SetActive(false)
end
function PenguinCardCtrl:Awake()
	self.bIn = true
	self.animator = self.gameObject:GetComponent("Animator")
	self:CloseAll()
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
