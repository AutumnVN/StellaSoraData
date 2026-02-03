local PenguinCardPauseCtrl = class("PenguinCardPauseCtrl", BaseCtrl)
PenguinCardPauseCtrl._mapNodeConfig = {
	blur = {
		sNodeName = "t_fullscreen_blur_blue"
	},
	aniBlur = {
		sNodeName = "t_fullscreen_blur_blue",
		sComponentName = "Animator"
	},
	btnCloseBg = {
		sNodeName = "snapshot",
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	txtWindowTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Title_Pause"
	},
	window = {},
	aniWindow = {sNodeName = "window", sComponentName = "Animator"},
	btnClose = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	txtTurnTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Pause_Turn"
	},
	txtTurnCount = {sComponentName = "TMP_Text"},
	txtLeftTurn = {sComponentName = "TMP_Text"},
	txtTargetTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Pause_StarTarget"
	},
	goStar = {nCount = 3},
	imgStarOff = {nCount = 3},
	imgStarOn = {nCount = 3},
	txtTarget = {nCount = 3, sComponentName = "TMP_Text"},
	btnGiveup = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Giveup"
	},
	txtBtnGiveup = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Btn_Giveup"
	},
	btnRestart = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Restart"
	},
	txtBtnRestart = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Btn_Restart"
	}
}
PenguinCardPauseCtrl._mapEventConfig = {}
function PenguinCardPauseCtrl:Open()
	self._panel.mapLevel:Pause()
	self:PlayInAni()
	self:Refresh()
end
function PenguinCardPauseCtrl:Refresh()
	if self._panel.mapLevel.nGameState == 1 then
		local nLeft = self._panel.mapLevel.nMaxTurn - self._panel.mapLevel.nCurTurn + 1
		NovaAPI.SetTMPText(self._mapNode.txtLeftTurn, orderedFormat(ConfigTable.GetUIText("PenguinCard_Pause_LeftTurn"), nLeft))
		NovaAPI.SetTMPText(self._mapNode.txtTurnCount, orderedFormat(ConfigTable.GetUIText("PenguinCard_Pause_TurnCount"), self._panel.mapLevel.nCurTurn - 1))
	else
		local nLeft = self._panel.mapLevel.nMaxTurn - self._panel.mapLevel.nCurTurn
		NovaAPI.SetTMPText(self._mapNode.txtLeftTurn, orderedFormat(ConfigTable.GetUIText("PenguinCard_Pause_LeftTurn"), nLeft))
		NovaAPI.SetTMPText(self._mapNode.txtTurnCount, orderedFormat(ConfigTable.GetUIText("PenguinCard_Pause_TurnCount"), self._panel.mapLevel.nCurTurn))
	end
	for i, v in ipairs(self._panel.mapLevel.tbStarScore) do
		self._mapNode.imgStarOff[i]:SetActive(v > self._panel.mapLevel.nScore)
		self._mapNode.imgStarOn[i]:SetActive(v <= self._panel.mapLevel.nScore)
		NovaAPI.SetTMPText(self._mapNode.txtTarget[i], orderedFormat(ConfigTable.GetUIText("PenguinCard_Pause_StarDesc"), v))
	end
end
function PenguinCardPauseCtrl:PlayInAni()
	self.gameObject:SetActive(true)
	self._mapNode.blur:SetActive(true)
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		self._mapNode.window:SetActive(true)
		self._mapNode.aniWindow:Play("t_window_04_t_in")
	end
	cs_coroutine.start(wait)
	EventManager.Hit(EventId.TemporaryBlockInput, 0.3)
end
function PenguinCardPauseCtrl:Close()
	self._mapNode.aniWindow:Play("t_window_04_t_out")
	self._mapNode.aniBlur:SetTrigger("tOut")
	self:AddTimer(1, 0.2, function()
		self._mapNode.window:SetActive(false)
		self.gameObject:SetActive(false)
		self._panel.mapLevel:Resume()
	end, true, true, true)
	EventManager.Hit(EventId.TemporaryBlockInput, 0.2)
end
function PenguinCardPauseCtrl:Awake()
	self._mapNode.window:SetActive(false)
end
function PenguinCardPauseCtrl:OnEnable()
end
function PenguinCardPauseCtrl:OnDisable()
end
function PenguinCardPauseCtrl:OnBtnClick_Close()
	self:Close()
end
function PenguinCardPauseCtrl:OnBtnClick_Giveup()
	self:Close()
	self:AddTimer(1, 0.2, function()
		self._panel.mapLevel:GiveupGame()
	end, true, true, true)
end
function PenguinCardPauseCtrl:OnBtnClick_Restart()
	self:Close()
	self:AddTimer(1, 0.2, function()
		self._panel.mapLevel:StartGame()
	end, true, true, true)
end
return PenguinCardPauseCtrl
