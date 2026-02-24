local PenguinCardFlipCtrl = class("PenguinCardFlipCtrl", BaseCtrl)
local WwiseManger = CS.WwiseAudioManager.Instance
local LoopType = CS.DG.Tweening.LoopType
local ScaleUpTime = 0.3
local ScaleDownTime = 0.12
local _, BtnOn = ColorUtility.TryParseHtmlString("#b48339")
local _, BtnOff = ColorUtility.TryParseHtmlString("#3E3C5B")
PenguinCardFlipCtrl._mapNodeConfig = {
	aniHandRankBg = {
		sNodeName = "imgHandRankBg",
		sComponentName = "Animator"
	},
	txtFlipTip = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_FlipAllCardTip"
	},
	txtHandRank = {sComponentName = "TMP_Text"},
	imgSuitCount = {nCount = 6, sComponentName = "Image"},
	btnHandRank = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_HandRank"
	},
	imgRoundTitleBg = {},
	txtRoundTip = {sComponentName = "TMP_Text"},
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
	goNextRoundOn = {},
	btnShowAll = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_ShowAll"
	},
	txtBtnShowAll = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Btn_FlipAll"
	},
	goShowAllOn = {},
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
	},
	aniRoundScoreBaseBg = {
		sNodeName = "imgRoundScoreBaseBg",
		sComponentName = "Animator"
	},
	aniRoundScoreRatioBg = {
		sNodeName = "imgRoundScoreRatioBg",
		sComponentName = "Animator"
	}
}
PenguinCardFlipCtrl._mapEventConfig = {
	PenguinCard_ChangeRoundScore = "OnEvent_ChangeRoundScore",
	PenguinCard_ReplaceBaseCard = "OnEvent_ReplaceBaseCard",
	PenguinCard_ShowBaseCard = "OnEvent_ShowBaseCard",
	PenguinCard_Pause = "OnEvent_Pause",
	PenguinCard_Resume = "OnEvent_Resume",
	PenguinCard_QuitScoreAni = "QuitScoreAni"
}
function PenguinCardFlipCtrl:Refresh_Dealing()
	self._mapNode.imgNextRound:SetActive(false)
	self._mapNode.btnNextRound.gameObject:SetActive(false)
	self._mapNode.imgRoundTitleBg:SetActive(false)
	self._mapNode.goNextRoundOn:SetActive(false)
	self._mapNode.btnShowAll.gameObject:SetActive(true)
	self._mapNode.btnShowAll.interactable = false
	self._mapNode.goShowAllOn:SetActive(false)
	self:RefreshRoundScore()
	self._mapNode.aniRoundScoreBaseBg.gameObject:SetActive(false)
	self._mapNode.aniRoundScoreBaseBg.gameObject:SetActive(true)
	self._mapNode.aniRoundScoreRatioBg.gameObject:SetActive(false)
	self._mapNode.aniRoundScoreRatioBg.gameObject:SetActive(true)
	self._mapNode.aniHandRankBg:Play("PengUinCard_HandRank_Off", 1, 0)
	for i = 1, 5 do
		self._mapNode.btnShow[i].interactable = true
		self._mapNode.PenguinBaseCard[i]:Refresh(self._panel.mapLevel.tbBaseCardId[i])
		self._mapNode.PenguinBaseCard[i]:PlayInAni()
	end
	if self._panel.mapLevel.nCurRound == 1 then
		self.animator:Play("PengUinCard_Flip_in", 0, 0)
		local nAnimTime = NovaAPI.GetAnimClipLength(self.animator, {
			"PengUinCard_Flip_in"
		})
		EventManager.Hit(EventId.TemporaryBlockInput, nAnimTime)
	else
		self.animator:Play("PengUinCard_Flip_Card_in", 0, 0)
		local nAnimTime = NovaAPI.GetAnimClipLength(self.animator, {
			"PengUinCard_Flip_Card_in"
		})
		EventManager.Hit(EventId.TemporaryBlockInput, nAnimTime)
	end
	WwiseManger:PostEvent("Mode_Card_nextround")
end
function PenguinCardFlipCtrl:Refresh_Flip()
	self._mapNode.btnShowAll.interactable = true
	self:StartShowAllOn()
	self.mapHandRankScore = {}
end
function PenguinCardFlipCtrl:Refresh_Settlement()
	if self._panel.mapLevel.nRoundLimit > self._panel.mapLevel.nCurRound then
		self._mapNode.imgNextRound:SetActive(true)
	end
	self._mapNode.btnNextRound.gameObject:SetActive(true)
	self._mapNode.btnNextRound.interactable = false
	self:AddTimer(1, 2 / self._panel.mapLevel.nSpeed, function()
		self._mapNode.btnNextRound.interactable = true
	end, true, true, true)
	self._mapNode.btnShowAll.gameObject:SetActive(false)
	self._mapNode.goShowAllOn:SetActive(false)
	self:RefreshRoundCount()
	self._mapNode.aniHandRankBg:Play("PengUinCard_HandRank_On", 0, 0)
	self:RefreshHandRank()
	for i = 1, 5 do
		self._mapNode.PenguinBaseCard[i]:PlayTriggerAni()
		self._mapNode.btnShow[i].interactable = false
	end
	self:PlayScoreAni()
end
function PenguinCardFlipCtrl:RefreshRoundCount()
	NovaAPI.SetTMPText(self._mapNode.txtRound, orderedFormat(ConfigTable.GetUIText("PenguinCard_LeftRound"), self._panel.mapLevel.nRoundLimit - self._panel.mapLevel.nCurRound))
	if self._panel.mapLevel.nRoundLimit == self._panel.mapLevel.nCurRound then
		NovaAPI.SetTMPText(self._mapNode.txtBtnNextRound, ConfigTable.GetUIText("PenguinCard_Btn_EndTurn"))
		NovaAPI.SetTMPText(self._mapNode.txtRoundTip, ConfigTable.GetUIText("PenguinCard_EndTurnTip"))
	else
		NovaAPI.SetTMPText(self._mapNode.txtBtnNextRound, ConfigTable.GetUIText("PenguinCard_Btn_NextRound"))
		NovaAPI.SetTMPText(self._mapNode.txtRoundTip, ConfigTable.GetUIText("PenguinCard_NextRoundTip"))
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
	local nRatio = self._panel.mapLevel.nRoundMultiRatio > 0 and self._panel.mapLevel.nRoundRatio * self._panel.mapLevel.nRoundMultiRatio or self._panel.mapLevel.nRoundRatio
	NovaAPI.SetTMPText(self._mapNode.txtRoundScoreRatio, string.format("%.1f", nRatio))
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
function PenguinCardFlipCtrl:StartShowAllOn()
	self:StopShowAllOn()
	if self._mapNode.goShowAllOn.activeSelf == true then
		return
	end
	self.timerNextRoundOn = self:AddTimer(1, 3, function()
		self._mapNode.goShowAllOn:SetActive(true)
	end, true, true, true)
end
function PenguinCardFlipCtrl:StopShowAllOn()
	if self.timerNextRoundOn then
		self.timerNextRoundOn:Cancel()
		self.timerNextRoundOn = nil
	end
end
function PenguinCardFlipCtrl:PlayRoundAni()
	for i = 1, 5 do
		self._mapNode.PenguinBaseCard[i]:PlayHideAni()
	end
	self.animator:Play("PengUinCard_Flip_Card_out", 0, 0)
	self._mapNode.aniHandRankBg:Play("PengUinCard_HandRank_Off", 0, 0)
	self:QuitScoreAni()
end
function PenguinCardFlipCtrl:QuitScoreAni()
	if self.sequence then
		self.sequence:Kill()
		self.sequence = nil
		WwiseManger:PostEvent("Mode_Card_stop")
		if not self.bEndScore and self._panel.mapLevel.nRoundMultiRatio and self._panel.mapLevel.nRoundRatio and self._panel.mapLevel.nRoundValue and self._panel.mapLevel.nRoundScore then
			NovaAPI.SetTMPText(self._mapNode.txtRoundScoreBase, self:ThousandsNumber(math.floor(self._panel.mapLevel.nRoundValue)))
			local nRatio = self._panel.mapLevel.nRoundMultiRatio > 0 and self._panel.mapLevel.nRoundRatio * self._panel.mapLevel.nRoundMultiRatio or self._panel.mapLevel.nRoundRatio
			NovaAPI.SetTMPText(self._mapNode.txtRoundScoreRatio, string.format("%.1f", nRatio))
			NovaAPI.SetTMPText(self._mapNode.txtRoundScore, self:ThousandsNumber(math.floor(self._panel.mapLevel.nRoundScore)))
		end
	end
	if self.timerNextRoundOn then
		self.timerNextRoundOn:Cancel()
		self.timerNextRoundOn = nil
	end
end
function PenguinCardFlipCtrl:PlayScoreAni()
	self:QuitScoreAni()
	local bFire = self._panel.mapLevel.nRoundValue >= self.nFireScore
	local nTextTime = bFire and 0.6 / self._panel.mapLevel.nSpeed or 0.4 / self._panel.mapLevel.nSpeed
	self.bEndScore = false
	self.sequence = DOTween.Sequence()
	if self.mapHandRankScore and self.mapHandRankScore.nBeforeValue ~= self.mapHandRankScore.nAfterValue then
		local tw1 = DOTween.To(function()
			return self.mapHandRankScore.nBeforeValue
		end, function(v)
			NovaAPI.SetTMPText(self._mapNode.txtRoundScoreBase, self:ThousandsNumber(math.floor(v)))
		end, self.mapHandRankScore.nAfterValue, nTextTime)
		local tw2 = self._mapNode.trRoundScoreBase:DOScale(1.2, ScaleUpTime / self._panel.mapLevel.nSpeed):SetEase(Ease.OutQuart)
		local tw3 = self._mapNode.trRoundScoreBase:DOScale(1, ScaleDownTime / self._panel.mapLevel.nSpeed):SetEase(Ease.InQuad)
		if bFire then
			self.sequence:AppendCallback(function()
				self:PlayFireAni()
			end)
		end
		self.sequence:AppendCallback(function()
			WwiseManger:PostEvent("Mode_Card_integral")
		end)
		self.sequence:Append(tw2)
		self.sequence:Join(tw1)
		self.sequence:AppendInterval(ScaleUpTime / self._panel.mapLevel.nSpeed)
		self.sequence:Append(tw3)
	end
	if self.mapHandRankScore and self.mapHandRankScore.nBeforeRatio ~= self.mapHandRankScore.nAfterRatio then
		local tw1 = DOTween.To(function()
			return self.mapHandRankScore.nBeforeRatio
		end, function(v)
			NovaAPI.SetTMPText(self._mapNode.txtRoundScoreRatio, string.format("%.1f", v))
		end, self.mapHandRankScore.nAfterRatio, nTextTime)
		local tw2 = self._mapNode.trRoundScoreRatio:DOScale(1.2, ScaleUpTime / self._panel.mapLevel.nSpeed):SetEase(Ease.OutQuart)
		local tw3 = self._mapNode.trRoundScoreRatio:DOScale(1, ScaleDownTime / self._panel.mapLevel.nSpeed):SetEase(Ease.InQuad)
		if bFire then
			self.sequence:AppendCallback(function()
				self:PlayFireAni()
			end)
		end
		self.sequence:AppendCallback(function()
			WwiseManger:PostEvent("Mode_Card_integral")
		end)
		self.sequence:Append(tw2)
		self.sequence:Join(tw1)
		self.sequence:AppendInterval(ScaleUpTime / self._panel.mapLevel.nSpeed)
		self.sequence:Append(tw3)
	end
	self.sequence:AppendCallback(function()
		EventManager.Hit("PenguinCardWaitPlay")
	end)
	if self.mapHandRankScore and self.mapHandRankScore.nAfterValue ~= self._panel.mapLevel.nRoundValue then
		local tw1 = DOTween.To(function()
			return self.mapHandRankScore.nAfterValue
		end, function(v)
			NovaAPI.SetTMPText(self._mapNode.txtRoundScoreBase, self:ThousandsNumber(math.floor(v)))
		end, self._panel.mapLevel.nRoundValue, nTextTime)
		local tw2 = self._mapNode.trRoundScoreBase:DOScale(1.2, ScaleUpTime / self._panel.mapLevel.nSpeed):SetEase(Ease.OutQuart)
		local tw3 = self._mapNode.trRoundScoreBase:DOScale(1, ScaleDownTime / self._panel.mapLevel.nSpeed):SetEase(Ease.InQuad)
		if bFire then
			self.sequence:AppendCallback(function()
				self:PlayFireAni()
			end)
		end
		self.sequence:AppendCallback(function()
			WwiseManger:PostEvent("Mode_Card_integral")
		end)
		self.sequence:Append(tw2)
		self.sequence:Join(tw1)
		self.sequence:AppendInterval(ScaleUpTime / self._panel.mapLevel.nSpeed)
		self.sequence:Append(tw3)
	end
	local nRatio = self._panel.mapLevel.nRoundMultiRatio > 0 and self._panel.mapLevel.nRoundRatio * self._panel.mapLevel.nRoundMultiRatio or self._panel.mapLevel.nRoundRatio
	if self.mapHandRankScore and self.mapHandRankScore.nAfterRatio ~= nRatio then
		local tw1 = DOTween.To(function()
			return self.mapHandRankScore.nAfterRatio
		end, function(v)
			NovaAPI.SetTMPText(self._mapNode.txtRoundScoreRatio, string.format("%.1f", v))
		end, nRatio, nTextTime)
		local tw2 = self._mapNode.trRoundScoreRatio:DOScale(1.2, ScaleUpTime / self._panel.mapLevel.nSpeed):SetEase(Ease.OutQuart)
		local tw3 = self._mapNode.trRoundScoreRatio:DOScale(1, ScaleDownTime / self._panel.mapLevel.nSpeed):SetEase(Ease.InQuad)
		if bFire then
			self.sequence:AppendCallback(function()
				self:PlayFireAni()
			end)
		end
		self.sequence:AppendCallback(function()
			WwiseManger:PostEvent("Mode_Card_integral")
		end)
		self.sequence:Append(tw2)
		self.sequence:Join(tw1)
		self.sequence:AppendInterval(ScaleUpTime / self._panel.mapLevel.nSpeed)
		self.sequence:Append(tw3)
	end
	local callback = dotween_callback_handler(self, function()
		WwiseManger:PostEvent("Mode_Card_coin_stop")
	end)
	local tw1 = DOTween.To(function()
		return 0
	end, function(v)
		NovaAPI.SetTMPText(self._mapNode.txtRoundScore, self:ThousandsNumber(math.floor(v)))
	end, self._panel.mapLevel.nRoundScore, nTextTime):OnComplete(callback)
	local tw2 = self._mapNode.trRoundScore:DOScale(1.1, ScaleUpTime / self._panel.mapLevel.nSpeed):SetEase(Ease.OutQuart)
	local tw3 = self._mapNode.trRoundScore:DOScale(1, ScaleDownTime / self._panel.mapLevel.nSpeed):SetEase(Ease.InQuad)
	self.sequence:AppendCallback(function()
		WwiseManger:PostEvent("Mode_Card_coin")
	end)
	self.sequence:Append(tw2)
	self.sequence:Join(tw1)
	self.sequence:AppendInterval(ScaleUpTime / self._panel.mapLevel.nSpeed)
	self.sequence:Append(tw3)
	self.sequence:AppendCallback(function()
		self._mapNode.imgRoundTitleBg:SetActive(true)
	end)
	self.sequence:SetUpdate(true)
	local reset = dotween_callback_handler(self, function()
		self.bEndScore = true
		self.timerNextRoundOn = self:AddTimer(1, 3, function()
			self._mapNode.goNextRoundOn:SetActive(true)
		end, true, true, true)
	end)
	self.sequence:OnComplete(reset)
end
function PenguinCardFlipCtrl:PlayOutAni()
	for i = 1, 5 do
		self._mapNode.PenguinBaseCard[i]:PlayHideAni()
	end
	self.animator:Play("PengUinCard_Flip_out", 0, 0)
	self:QuitScoreAni()
end
function PenguinCardFlipCtrl:PlayFireAni()
	self._mapNode.aniRoundScoreBaseBg:Play("PengUinCard_Flip_Score_Hot_01")
	self._mapNode.aniRoundScoreBaseBg.speed = self._panel.mapLevel.nSpeed
	self._mapNode.aniRoundScoreRatioBg:Play("PengUinCard_Flip_Score_Hot_02")
	self._mapNode.aniRoundScoreRatioBg.speed = self._panel.mapLevel.nSpeed
end
function PenguinCardFlipCtrl:Awake()
	self.animator = self.gameObject:GetComponent("Animator")
	self.nFireScore = ConfigTable.GetConfigNumber("PenguinCardFeverScore")
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
	self._panel.mapLevel:StopAuto()
	self:QuitScoreAni()
	if self._panel.mapLevel.nRoundLimit == self._panel.mapLevel.nCurRound and self._panel.mapLevel.nCurTurn < self._panel.mapLevel.nMaxTurn then
		local callback = function()
			self._panel.mapLevel:SwitchGameState()
		end
		EventManager.Hit("PenguinCard_OpenLog", self._panel.mapLevel.nCurTurn, false, callback)
	else
		self._panel.mapLevel:SwitchGameState()
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
function PenguinCardFlipCtrl:OnEvent_ChangeRoundScore(nBeforeValue, nBeforeRatio, nBeforeScore, bFromHandRank)
	if bFromHandRank then
		self.mapHandRankScore = {
			nBeforeValue = nBeforeValue,
			nAfterValue = self._panel.mapLevel.nRoundValue,
			nBeforeRatio = nBeforeRatio,
			nAfterRatio = self._panel.mapLevel.nRoundMultiRatio > 0 and self._panel.mapLevel.nRoundRatio * self._panel.mapLevel.nRoundMultiRatio or self._panel.mapLevel.nRoundRatio
		}
		return
	end
	if self._panel.mapLevel.nGameState == 4 then
		return
	end
	local bFire = self._panel.mapLevel.nRoundValue >= self.nFireScore
	if bFire then
		self:PlayFireAni()
	end
	local nTextTime = bFire and 0.6 / self._panel.mapLevel.nSpeed or 0.4 / self._panel.mapLevel.nSpeed
	if nBeforeValue ~= self._panel.mapLevel.nRoundValue then
		WwiseManger:PostEvent("Mode_Card_integral")
		DOTween.To(function()
			return nBeforeValue
		end, function(v)
			NovaAPI.SetTMPText(self._mapNode.txtRoundScoreBase, self:ThousandsNumber(math.floor(v)))
		end, self._panel.mapLevel.nRoundValue, nTextTime)
		local callback = dotween_callback_handler(self, function()
			self._mapNode.trRoundScoreBase:DOScale(1, ScaleDownTime / self._panel.mapLevel.nSpeed):SetEase(Ease.InQuad):SetUpdate(true)
		end)
		self._mapNode.trRoundScoreBase:DOScale(1.2, ScaleUpTime / self._panel.mapLevel.nSpeed):SetEase(Ease.OutQuart):SetUpdate(true):OnComplete(callback)
	end
	local nRatio = 0 < self._panel.mapLevel.nRoundMultiRatio and self._panel.mapLevel.nRoundRatio * self._panel.mapLevel.nRoundMultiRatio or self._panel.mapLevel.nRoundRatio
	if nBeforeRatio ~= nRatio then
		WwiseManger:PostEvent("Mode_Card_integral")
		DOTween.To(function()
			return nBeforeRatio
		end, function(v)
			NovaAPI.SetTMPText(self._mapNode.txtRoundScoreRatio, string.format("%.1f", v))
		end, nRatio, nTextTime)
		local callback = dotween_callback_handler(self, function()
			self._mapNode.trRoundScoreRatio:DOScale(1, ScaleDownTime / self._panel.mapLevel.nSpeed):SetEase(Ease.InQuad):SetUpdate(true)
		end)
		self._mapNode.trRoundScoreRatio:DOScale(1.2, ScaleUpTime / self._panel.mapLevel.nSpeed):SetEase(Ease.OutQuart):SetUpdate(true):OnComplete(callback)
	end
end
function PenguinCardFlipCtrl:OnEvent_ShowBaseCard(nIndex)
	self:StartShowAllOn()
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
function PenguinCardFlipCtrl:OnEvent_Pause()
	if self.sequence then
		self.sequence:Pause()
		WwiseManger:PostEvent("Mode_Card_stop")
	end
end
function PenguinCardFlipCtrl:OnEvent_Resume()
	if self.sequence then
		self.sequence:Play()
	end
end
return PenguinCardFlipCtrl
