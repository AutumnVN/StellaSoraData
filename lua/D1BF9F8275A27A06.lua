local PenguinCardFlipCtrl = class("PenguinCardFlipCtrl", BaseCtrl)
local WwiseManger = CS.WwiseAudioManager.Instance
local LoopType = CS.DG.Tweening.LoopType
local _, BtnOn = ColorUtility.TryParseHtmlString("#CC8E2B")
local _, BtnOff = ColorUtility.TryParseHtmlString("#796443")
PenguinCardFlipCtrl._mapNodeConfig = {
	goHandRankOff = {},
	txtFlipTip = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_FlipAllCardTip"
	},
	goHandRankOn = {},
	txtHandRank = {sComponentName = "TMP_Text"},
	imgSuitCount = {nCount = 6, sComponentName = "Image"},
	btnHandRank = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_HandRank"
	},
	btnShow = {
		nCount = 5,
		sComponentName = "UIButton",
		callback = "OnBtnClick_Show"
	},
	PenguinBaseCard = {
		nCount = 5,
		sCtrlName = "Game.UI.Play_PenguinCard.PenguinBaseCardCtrl"
	},
	imgNextRound = {},
	txtRound = {sComponentName = "TMP_Text"},
	btnNextRound = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_NextRound"
	},
	txtBtnNextRound = {sComponentName = "TMP_Text"},
	btnShowAll = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_ShowAll"
	},
	txtBtnShowAll = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Btn_FlipAll"
	},
	btnAuto = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Auto"
	},
	imgBtnAuto = {sComponentName = "Image"},
	trAuto = {sNodeName = "imgBtnAuto", sComponentName = "Transform"},
	txtBtnAuto = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Btn_Auto"
	},
	btnSpeed = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Speed"
	},
	txtBtnSpeed = {sComponentName = "TMP_Text"},
	imgBtnSpeed = {nCount = 2, sComponentName = "Image"},
	txtRoundScore = {sComponentName = "TMP_Text"},
	txtRoundScoreCn = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Round_Score"
	},
	txtRoundScoreBase = {sComponentName = "TMP_Text"},
	txtRoundScoreBaseCn = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Round_Base"
	},
	txtRoundScoreRatio = {sComponentName = "TMP_Text"},
	txtRoundScoreRatioCn = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Round_Ratio"
	},
	trRoundScore = {
		sNodeName = "txtRoundScore",
		sComponentName = "Transform"
	},
	trRoundScoreBase = {
		sNodeName = "txtRoundScoreBase",
		sComponentName = "Transform"
	},
	trRoundScoreRatio = {
		sNodeName = "txtRoundScoreRatio",
		sComponentName = "Transform"
	}
}
PenguinCardFlipCtrl._mapEventConfig = {
	PenguinCard_ChangeRoundScore = "OnEvent_ChangeRoundScore",
	PenguinCard_ReplaceBaseCard = "OnEvent_ReplaceBaseCard",
	PenguinCard_ShowBaseCard = "OnEvent_ShowBaseCard"
}
function PenguinCardFlipCtrl:Refresh_Dealing()
	self._mapNode.imgNextRound:SetActive(false)
	self._mapNode.btnNextRound.gameObject:SetActive(false)
	self._mapNode.btnShowAll.gameObject:SetActive(false)
	self:RefreshRoundScore()
	self._mapNode.goHandRankOff:SetActive(true)
	self._mapNode.goHandRankOn:SetActive(false)
	for i = 1, 5 do
		self._mapNode.btnShow[i].interactable = true
		self._mapNode.PenguinBaseCard[i]:Refresh(self._panel.mapLevel.tbBaseCardId[i])
	end
end
function PenguinCardFlipCtrl:Refresh_Flip()
	self._mapNode.btnShowAll.gameObject:SetActive(true)
end
function PenguinCardFlipCtrl:Refresh_Settlement()
	if self._panel.mapLevel.nRoundLimit > self._panel.mapLevel.nCurRound then
		self._mapNode.imgNextRound:SetActive(true)
	end
	self._mapNode.btnNextRound.gameObject:SetActive(true)
	self._mapNode.btnShowAll.gameObject:SetActive(false)
	self:RefreshRoundCount()
	self._mapNode.goHandRankOff:SetActive(false)
	self._mapNode.goHandRankOn:SetActive(true)
	self:RefreshHandRank()
	for i = 1, 5 do
		self._mapNode.PenguinBaseCard[i]:PlayTriggerAni()
		self._mapNode.btnShow[i].interactable = false
	end
end
function PenguinCardFlipCtrl:RefreshRoundCount()
	NovaAPI.SetTMPText(self._mapNode.txtRound, orderedFormat(ConfigTable.GetUIText("PenguinCard_LeftRound"), self._panel.mapLevel.nRoundLimit - self._panel.mapLevel.nCurRound))
	if self._panel.mapLevel.nRoundLimit == self._panel.mapLevel.nCurRound then
		NovaAPI.SetTMPText(self._mapNode.txtBtnNextRound, ConfigTable.GetUIText("PenguinCard_Btn_EndTurn"))
	else
		NovaAPI.SetTMPText(self._mapNode.txtBtnNextRound, ConfigTable.GetUIText("PenguinCard_Btn_NextRound"))
	end
end
function PenguinCardFlipCtrl:RefreshHandRank()
	local nAll = #self._panel.mapLevel.tbHandRank
	for i = 1, 6 do
		self._mapNode.imgSuitCount[i].gameObject:SetActive(i <= nAll)
		if i <= nAll then
			local sName = AllEnum.PenguinCardSuitSprite[self._panel.mapLevel.tbHandRank[i]]
			self:SetSprite(self._mapNode.imgSuitCount[i], "UI/Play_PenguinCard/SpriteAtlas/Sprite/" .. sName)
		end
	end
	local mapCfg = ConfigTable.GetData("PenguinCardHandRank", self._panel.mapLevel.nHandRankId)
	if mapCfg then
		NovaAPI.SetTMPText(self._mapNode.txtHandRank, mapCfg.Title)
	end
end
function PenguinCardFlipCtrl:RefreshRoundScore()
	NovaAPI.SetTMPText(self._mapNode.txtRoundScore, self:ThousandsNumber(clearFloat(self._panel.mapLevel.nRoundScore)))
	NovaAPI.SetTMPText(self._mapNode.txtRoundScoreBase, self:ThousandsNumber(clearFloat(self._panel.mapLevel.nRoundValue)))
	NovaAPI.SetTMPText(self._mapNode.txtRoundScoreRatio, string.format("%.1f", self._panel.mapLevel.nRoundRatio * self._panel.mapLevel.nRoundMultiRatio))
end
function PenguinCardFlipCtrl:RefreshButton()
	self:RefreshAuto()
	self:RefreshSpeed()
end
function PenguinCardFlipCtrl:RefreshAuto()
	NovaAPI.SetImageColor(self._mapNode.imgBtnAuto, self._panel.mapLevel.bAuto and BtnOn or BtnOff)
	NovaAPI.SetTMPColor(self._mapNode.txtBtnAuto, self._panel.mapLevel.bAuto and BtnOn or BtnOff)
	if self._panel.mapLevel.bAuto == true then
		if self.tweener == nil then
			self.tweener = self._mapNode.trAuto:DOLocalRotate(Vector3(0, 0, -360), 2.6, RotateMode.FastBeyond360):SetLoops(-1, LoopType.Restart):SetEase(Ease.Linear):SetUpdate(true)
		end
	elseif self.tweener ~= nil then
		self.tweener:Kill()
		self._mapNode.trAuto.localRotation = Quaternion.identity
		self.tweener = nil
	end
end
function PenguinCardFlipCtrl:RefreshSpeed()
	local bFast = self._panel.mapLevel.nSpeed > 1
	NovaAPI.SetImageColor(self._mapNode.imgBtnSpeed[1], bFast and BtnOn or BtnOff)
	NovaAPI.SetImageColor(self._mapNode.imgBtnSpeed[2], bFast and BtnOn or BtnOff)
	NovaAPI.SetTMPColor(self._mapNode.txtBtnSpeed, bFast and BtnOn or BtnOff)
	NovaAPI.SetTMPText(self._mapNode.txtBtnSpeed, "<size=32>\195\151</size>" .. self._panel.mapLevel.nSpeed)
end
function PenguinCardFlipCtrl:NextRound()
	for i = 1, 5 do
		self._mapNode.PenguinBaseCard[i]:PlayHideAni()
	end
	self:AddTimer(1, 0.567, function()
		self._panel.mapLevel:SwitchGameState()
	end, true, true, true)
	EventManager.Hit(EventId.TemporaryBlockInput, 0.567)
end
function PenguinCardFlipCtrl:NextTurn()
end
function PenguinCardFlipCtrl:Awake()
end
function PenguinCardFlipCtrl:OnEnable()
end
function PenguinCardFlipCtrl:OnDisable()
end
function PenguinCardFlipCtrl:OnBtnClick_HandRank()
	EventManager.Hit("PenguinCard_OpenHandRank")
end
function PenguinCardFlipCtrl:OnBtnClick_Show(btn, nIndex)
	self._panel.mapLevel:ShowBaseCard(nIndex)
end
function PenguinCardFlipCtrl:OnBtnClick_ShowAll(btn)
	self._panel.mapLevel:ShowBaseCard()
end
function PenguinCardFlipCtrl:OnBtnClick_NextRound(btn)
	if self._panel.mapLevel.nRoundLimit == self._panel.mapLevel.nCurRound and self._panel.mapLevel.nCurTurn < self._panel.mapLevel.nMaxTurn then
		local callback = function()
			self._panel.mapLevel:SwitchGameState()
		end
		EventManager.Hit("PenguinCard_OpenLog", self._panel.mapLevel.nCurTurn, false, callback)
	else
		self:NextRound()
	end
end
function PenguinCardFlipCtrl:OnBtnClick_Auto(btn)
	local bAuto = not self._panel.mapLevel.bAuto
	self._panel.mapLevel:SetAutoState(bAuto)
	if self._panel.mapLevel.bAuto then
		self._panel.mapLevel:PlayAuto(true)
	else
		self._panel.mapLevel:StopAuto()
	end
	self:RefreshAuto()
end
function PenguinCardFlipCtrl:OnBtnClick_Speed(btn)
	local nSpeed = 3 - self._panel.mapLevel.nSpeed
	self._panel.mapLevel:SetAutoSpeed(nSpeed)
	self:RefreshSpeed()
end
function PenguinCardFlipCtrl:OnEvent_ChangeRoundScore(nBeforeValue, nBeforeRatio, nBeforeScore)
	if nBeforeValue ~= self._panel.mapLevel.nRoundValue then
		DOTween.To(function()
			return nBeforeValue
		end, function(v)
			NovaAPI.SetTMPText(self._mapNode.txtRoundScoreBase, self:ThousandsNumber(math.floor(v)))
		end, self._panel.mapLevel.nRoundValue, 1)
		local callback = dotween_callback_handler(self, function()
			self._mapNode.trRoundScoreBase:DOScale(1, 0.1)
		end)
		self._mapNode.trRoundScoreBase:DOScale(2, 0.2):SetUpdate(true):OnComplete(callback)
	end
	if nBeforeRatio ~= self._panel.mapLevel.nRoundRatio * self._panel.mapLevel.nRoundMultiRatio then
		DOTween.To(function()
			return nBeforeRatio
		end, function(v)
			NovaAPI.SetTMPText(self._mapNode.txtRoundScoreRatio, string.format("%.1f", v))
		end, self._panel.mapLevel.nRoundRatio * self._panel.mapLevel.nRoundMultiRatio, 1)
		local callback = dotween_callback_handler(self, function()
			self._mapNode.trRoundScoreRatio:DOScale(1, 0.1)
		end)
		self._mapNode.trRoundScoreRatio:DOScale(2, 0.2):SetUpdate(true):OnComplete(callback)
	end
	if nBeforeScore ~= self._panel.mapLevel.nRoundScore then
		DOTween.To(function()
			return nBeforeScore
		end, function(v)
			NovaAPI.SetTMPText(self._mapNode.txtRoundScore, self:ThousandsNumber(math.floor(v)))
		end, self._panel.mapLevel.nRoundScore, 1)
		local callback = dotween_callback_handler(self, function()
			self._mapNode.trRoundScore:DOScale(1, 0.1)
		end)
		self._mapNode.trRoundScore:DOScale(2, 0.2):SetUpdate(true):OnComplete(callback)
	end
end
function PenguinCardFlipCtrl:OnEvent_ShowBaseCard(nIndex)
	if nIndex == nil then
		for i = 1, 5 do
			self._mapNode.PenguinBaseCard[i]:PlayFlipAni()
			self._mapNode.btnShow[i].interactable = false
		end
	else
		self._mapNode.PenguinBaseCard[nIndex]:PlayFlipAni()
		self._mapNode.btnShow[nIndex].interactable = false
	end
end
function PenguinCardFlipCtrl:OnEvent_ReplaceBaseCard(nIndex)
	self._mapNode.PenguinBaseCard[nIndex]:Refresh(self._panel.mapLevel.tbBaseCardId[nIndex], true)
	self._mapNode.PenguinBaseCard[nIndex]:PlayReplaceAni()
	self._mapNode.btnShow[nIndex].interactable = false
end
return PenguinCardFlipCtrl
