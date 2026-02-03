local PenguinCardPrepareCtrl = class("PenguinCardPrepareCtrl", BaseCtrl)
local WwiseManger = CS.WwiseAudioManager.Instance
local _, Black = ColorUtility.TryParseHtmlString("#3E3C5B")
local _, Red = ColorUtility.TryParseHtmlString("#ef3d5c")
local _, LineOff = ColorUtility.TryParseHtmlString("#8C8296")
local _, LineOn = ColorUtility.TryParseHtmlString("#756980")
PenguinCardPrepareCtrl._mapNodeConfig = {
	txtAddMax = {
		nCount = 3,
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_AddBtnMax"
	},
	btnAddRound = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_AddRound"
	},
	txtBtnAddRound = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Btn_AddRound"
	},
	txtAddRoundCost = {sComponentName = "TMP_Text"},
	goAddRoundOn = {},
	goAddRoundOff = {},
	btnAddSlot = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_AddSlot"
	},
	txtBtnAddSlot = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Btn_AddSlot"
	},
	txtAddSlotCost = {sComponentName = "TMP_Text"},
	goAddSlotOn = {},
	goAddSlotOff = {},
	btnAddRoll = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_AddRoll"
	},
	txtBtnAddRoll = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Btn_AddRoll"
	},
	txtAddRollCost = {sComponentName = "TMP_Text"},
	goAddRollOn = {},
	goAddRollOff = {},
	txtScore = {sComponentName = "TMP_Text"},
	imgStarOff = {nCount = 3},
	imgStarOn = {nCount = 3},
	imgLine = {nCount = 2, sComponentName = "Image"},
	imgStarProgress = {
		sComponentName = "RectTransform"
	},
	txtLeftTurn = {sComponentName = "TMP_Text"},
	txtSelectTip = {sComponentName = "TMP_Text"},
	PenguinCardItem = {
		nCount = 3,
		sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardItemCtrl"
	},
	btnRoll = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Roll"
	},
	txtBtnRoll = {sComponentName = "TMP_Text"},
	txtRollCost = {sComponentName = "TMP_Text"},
	btnStartTurn = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_StartTurn"
	},
	txtBtnStartTurn = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Btn_NextTurn"
	}
}
PenguinCardPrepareCtrl._mapEventConfig = {
	PenguinCard_AddRound = "OnEvent_AddRound",
	PenguinCard_AddSlot = "OnEvent_AddSlot",
	PenguinCard_AddRoll = "OnEvent_AddRoll",
	PenguinCard_ChangeScore = "OnEvent_ChangeScore",
	PenguinCard_RollPenguinCard = "OnEvent_RollPenguinCard",
	PenguinCard_SelectPenguinCard = "OnEvent_SelectPenguinCard"
}
function PenguinCardPrepareCtrl:Refresh()
	self:RefreshAddRound()
	self:RefreshAddSlot()
	self:RefreshAddRoll()
	self:RefreshScore()
	self:RefreshLeftTurn()
	self:RefreshRoll()
end
function PenguinCardPrepareCtrl:RefreshAddRound()
	local bMax = self._panel.mapLevel.nRoundLimit >= self._panel.mapLevel.nMaxRound
	self._mapNode.goAddRoundOn:SetActive(not bMax)
	self._mapNode.goAddRoundOff:SetActive(bMax)
	if not bMax then
		self:RefreshAddRoundCost()
	end
end
function PenguinCardPrepareCtrl:RefreshAddRoundCost()
	if self._panel.mapLevel.nRoundLimit >= self._panel.mapLevel.nMaxRound then
		return
	end
	local nCost = self._panel.mapLevel.tbRoundUpgradeCost[self._panel.mapLevel.nRoundLimit + 1]
	NovaAPI.SetTMPText(self._mapNode.txtAddRoundCost, self:ThousandsNumber(nCost))
	NovaAPI.SetTMPColor(self._mapNode.txtAddRoundCost, nCost > self._panel.mapLevel.nScore and Red_Unable or Black)
end
function PenguinCardPrepareCtrl:RefreshAddSlot()
	local bMax = self._panel.mapLevel.nSlotCount >= self._panel.mapLevel.nMaxSlot
	self._mapNode.goAddSlotOn:SetActive(not bMax)
	self._mapNode.goAddSlotOff:SetActive(bMax)
	if not bMax then
		self:RefreshAddSlotCost()
	end
end
function PenguinCardPrepareCtrl:RefreshAddSlotCost()
	if self._panel.mapLevel.nSlotCount >= self._panel.mapLevel.nMaxSlot then
		return
	end
	local nCost = self._panel.mapLevel.tbSlotUpgradeCost[self._panel.mapLevel.nSlotCount + 1]
	NovaAPI.SetTMPText(self._mapNode.txtAddSlotCost, self:ThousandsNumber(nCost))
	NovaAPI.SetTMPColor(self._mapNode.txtAddSlotCost, nCost > self._panel.mapLevel.nScore and Red_Unable or Black)
end
function PenguinCardPrepareCtrl:RefreshAddRoll()
	local bMax = self._panel.mapLevel.nBuyLimit >= self._panel.mapLevel.nMaxBuyLimit
	self._mapNode.goAddRollOn:SetActive(not bMax)
	self._mapNode.goAddRollOff:SetActive(bMax)
	if not bMax then
		self:RefreshAddRollCost()
	end
end
function PenguinCardPrepareCtrl:RefreshAddRollCost()
	if self._panel.mapLevel.nBuyLimit >= self._panel.mapLevel.nMaxBuyLimit then
		return
	end
	local nCost = self._panel.mapLevel.tbBuyLimitUpgradeCost[self._panel.mapLevel.nBuyLimit + 1]
	NovaAPI.SetTMPText(self._mapNode.txtAddRollCost, self:ThousandsNumber(nCost))
	NovaAPI.SetTMPColor(self._mapNode.txtAddRollCost, nCost > self._panel.mapLevel.nScore and Red_Unable or Black)
end
function PenguinCardPrepareCtrl:RefreshScore()
	NovaAPI.SetTMPText(self._mapNode.txtScore, self:ThousandsNumber(clearFloat(self._panel.mapLevel.nScore)))
	local nMax = self._panel.mapLevel.tbStarScore[3]
	if nMax == 0 then
		nMax = self._panel.mapLevel.nScore
	end
	local nP = self._panel.mapLevel.nScore / nMax
	if 1 < nP then
		nP = 1
	end
	self._mapNode.imgStarProgress.sizeDelta = Vector2(nP * 276.94, 24)
	for i, v in ipairs(self._panel.mapLevel.tbStarScore) do
		self._mapNode.imgStarOff[i]:SetActive(v > self._panel.mapLevel.nScore)
		self._mapNode.imgStarOn[i]:SetActive(v <= self._panel.mapLevel.nScore)
		if i < 3 then
			NovaAPI.SetImageColor(self._mapNode.imgLine[i], v > self._panel.mapLevel.nScore and LineOff or LineOn)
		end
	end
end
function PenguinCardPrepareCtrl:RefreshLeftTurn()
	local nLeft = self._panel.mapLevel.nMaxTurn - self._panel.mapLevel.nCurTurn + 1
	NovaAPI.SetTMPText(self._mapNode.txtLeftTurn, orderedFormat(ConfigTable.GetUIText("PenguinCard_LeftTurn"), nLeft))
end
function PenguinCardPrepareCtrl:RefreshRoll()
	self:RefreshRollCard()
	self:RefreshRollDesc()
	self:RefreshRollCost()
end
function PenguinCardPrepareCtrl:RefreshRollCard()
	local nMax = #self._panel.mapLevel.tbSelectablePenguinCard
	for i = 1, 3 do
		self._mapNode.PenguinCardItem[i].gameObject:SetActive(i <= nMax)
		if i <= nMax then
			self._mapNode.PenguinCardItem[i]:Refresh_Select(self._panel.mapLevel.tbSelectablePenguinCard[i], i)
		end
	end
end
function PenguinCardPrepareCtrl:RefreshRollDesc()
	if self._panel.mapLevel.nBuyLimit == 0 then
		NovaAPI.SetTMPText(self._mapNode.txtBtnRoll, ConfigTable.GetUIText("PenguinCard_Btn_Roll"))
	elseif self._panel.mapLevel.nTurnBuyCount == self._panel.mapLevel.nBuyLimit then
		local sSuffix = orderedFormat(ConfigTable.GetUIText("PenguinCard_Btn_RollSuffix"), "<color=#bd3059>0</color>", self._panel.mapLevel.nBuyLimit)
		NovaAPI.SetTMPText(self._mapNode.txtBtnRoll, ConfigTable.GetUIText("PenguinCard_Btn_Roll") .. sSuffix)
	else
		local sSuffix = orderedFormat(ConfigTable.GetUIText("PenguinCard_Btn_RollSuffix"), self._panel.mapLevel.nBuyLimit - self._panel.mapLevel.nTurnBuyCount, self._panel.mapLevel.nBuyLimit)
		NovaAPI.SetTMPText(self._mapNode.txtBtnRoll, ConfigTable.GetUIText("PenguinCard_Btn_Roll") .. sSuffix)
	end
	if self._panel.mapLevel.bSelectedPenguinCard then
		NovaAPI.SetTMPText(self._mapNode.txtSelectTip, ConfigTable.GetUIText("PenguinCard_SelectCardDoneTip"))
	else
		NovaAPI.SetTMPText(self._mapNode.txtSelectTip, ConfigTable.GetUIText("PenguinCard_SelectCardTip"))
	end
end
function PenguinCardPrepareCtrl:RefreshRollCost()
	if self._panel.mapLevel.nBuyLimit == 0 then
		self._mapNode.txtRollCost.gameObject:SetActive(false)
		return
	end
	if self._panel.mapLevel.nTurnBuyCount == self._panel.mapLevel.nBuyLimit then
		self._mapNode.txtRollCost.gameObject:SetActive(false)
		return
	end
	self._mapNode.txtRollCost.gameObject:SetActive(true)
	local nCost = self._panel.mapLevel:GetRollPenguinCardCost()
	NovaAPI.SetTMPText(self._mapNode.txtRollCost, self:ThousandsNumber(nCost))
	NovaAPI.SetTMPColor(self._mapNode.txtRollCost, nCost > self._panel.mapLevel.nScore and Red or White_Normal)
end
function PenguinCardPrepareCtrl:StartTurn()
	local nMax = #self._panel.mapLevel.tbSelectablePenguinCard
	for i = 1, nMax do
		self._mapNode.PenguinCardItem[i]:PlayHideAni()
	end
	self:AddTimer(1, 0.5, function()
		self._panel.mapLevel:SwitchGameState()
	end, true, true, true)
	EventManager.Hit(EventId.TemporaryBlockInput, 0.5)
end
function PenguinCardPrepareCtrl:Awake()
end
function PenguinCardPrepareCtrl:OnEnable()
end
function PenguinCardPrepareCtrl:OnDisable()
end
function PenguinCardPrepareCtrl:OnBtnClick_AddRoll(btn)
	self._panel.mapLevel:AddRoll()
end
function PenguinCardPrepareCtrl:OnBtnClick_AddSlot(btn)
	self._panel.mapLevel:AddSlot()
end
function PenguinCardPrepareCtrl:OnBtnClick_AddRound(btn)
	self._panel.mapLevel:AddRound()
end
function PenguinCardPrepareCtrl:OnBtnClick_Roll(btn)
	self._panel.mapLevel:RollPenguinCard()
end
function PenguinCardPrepareCtrl:OnBtnClick_StartTurn(btn)
	if not self._panel.mapLevel.bSelectedPenguinCard then
		local msg = {
			nType = AllEnum.MessageBox.Confirm,
			sContent = ConfigTable.GetUIText("PenguinCard_Tip_NotSelectedPenguinCard"),
			callbackConfirm = function()
				self:StartTurn()
			end
		}
		EventManager.Hit(EventId.OpenMessageBox, msg)
	else
		self:StartTurn()
	end
end
function PenguinCardPrepareCtrl:OnEvent_AddRoll()
	self:RefreshAddRoll()
	self:RefreshRollDesc()
	self:RefreshRollCost()
end
function PenguinCardPrepareCtrl:OnEvent_AddSlot()
	self:RefreshAddSlot()
end
function PenguinCardPrepareCtrl:OnEvent_AddRound()
	self:RefreshAddRound()
end
function PenguinCardPrepareCtrl:OnEvent_ChangeScore(nBefore)
	self:RefreshAddRoundCost()
	self:RefreshAddSlotCost()
	self:RefreshAddRollCost()
	DOTween.To(function()
		return nBefore
	end, function(v)
		NovaAPI.SetTMPText(self._mapNode.txtScore, self:ThousandsNumber(math.floor(v)))
	end, self._panel.mapLevel.nScore, 1)
	local nMax = self._panel.mapLevel.tbStarScore[3]
	if nMax == 0 then
		nMax = self._panel.mapLevel.nScore
	end
	local nP = self._panel.mapLevel.nScore / nMax
	if 1 < nP then
		nP = 1
	end
	self._mapNode.imgStarProgress:DOSizeDelta(Vector2(nP * 276.94, 24), 0.5)
	for i, v in ipairs(self._panel.mapLevel.tbStarScore) do
		self._mapNode.imgStarOff[i]:SetActive(v > self._panel.mapLevel.nScore)
		self._mapNode.imgStarOn[i]:SetActive(v <= self._panel.mapLevel.nScore)
		if i < 3 then
			NovaAPI.SetImageColor(self._mapNode.imgLine[i], v > self._panel.mapLevel.nScore and LineOff or LineOn)
		end
	end
end
function PenguinCardPrepareCtrl:OnEvent_RollPenguinCard()
	self:RefreshRoll()
	EventManager.Hit(EventId.TemporaryBlockInput, 0.5)
end
function PenguinCardPrepareCtrl:OnEvent_SelectPenguinCard()
	local nMax = #self._panel.mapLevel.tbSelectablePenguinCard
	for i = 1, nMax do
		self._mapNode.PenguinCardItem[i]:PlayFlipAni()
	end
	self:RefreshRollDesc()
end
return PenguinCardPrepareCtrl
