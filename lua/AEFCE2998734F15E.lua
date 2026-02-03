local PenguinCardInfoCtrl = class("PenguinCardInfoCtrl", BaseCtrl)
local WwiseManger = CS.WwiseAudioManager.Instance
PenguinCardInfoCtrl._mapNodeConfig = {
	blur = {
		sNodeName = "t_fullscreen_blur_blue"
	},
	aniBlur = {
		sNodeName = "t_fullscreen_blur_blue",
		sComponentName = "Animator"
	},
	goInfo = {},
	imgIcon = {sComponentName = "Image"},
	txtLevel = {sComponentName = "TMP_Text"},
	txtName = {sComponentName = "TMP_Text"},
	imgUp = {},
	txtDesc = {sComponentName = "TMP_Text"},
	btnRight = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Right"
	},
	btnLeft = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Left"
	},
	btnSale = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Sale"
	},
	btnBack = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Back"
	},
	txtBtnBack = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Btn_Back"
	},
	btnSelect = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Select"
	},
	txtBtnSelect = {sComponentName = "TMP_Text"}
}
PenguinCardInfoCtrl._mapEventConfig = {
	PenguinCard_OpenInfo = "Open",
	PenguinCard_SelectPenguinCard = "Close",
	PenguinCard_SalePenguinCard = "Close"
}
function PenguinCardInfoCtrl:Open(mapCard, nSelectIndex)
	self._panel.mapLevel:Pause()
	self.mapCard = mapCard
	self.bSelect = nSelectIndex ~= nil
	self.nSelectIndex = nSelectIndex
	if self.bSelect then
		local nMax = #self._panel.mapLevel.tbSelectablePenguinCard
		self._mapNode.btnRight.gameObject:SetActive(1 < nMax)
		self._mapNode.btnLeft.gameObject:SetActive(1 < nMax)
		self._mapNode.btnSale.gameObject:SetActive(false)
		self._mapNode.btnSelect.gameObject:SetActive(true)
		self._mapNode.imgUp:SetActive(false)
	else
		self.tbHasIndex = {}
		for i = 1, 6 do
			if self._panel.mapLevel.tbPenguinCard[i] ~= 0 then
				table.insert(self.tbHasIndex, i)
			end
		end
		local nMax = #self.tbHasIndex
		self._mapNode.btnRight.gameObject:SetActive(1 < nMax)
		self._mapNode.btnLeft.gameObject:SetActive(1 < nMax)
		self._mapNode.btnSale.gameObject:SetActive(self._panel.mapLevel.nGameState == 1)
		self._mapNode.btnSelect.gameObject:SetActive(false)
		self._mapNode.imgUp:SetActive(false)
	end
	self:PlayInAni()
	self:Refresh()
end
function PenguinCardInfoCtrl:Refresh()
	NovaAPI.SetTMPText(self._mapNode.txtName, self.mapCard.sName)
	self:SetSprite(self._mapNode.imgIcon, "UI/Play_PenguinCard/SpriteAtlas/Sprite/" .. self.mapCard.sIcon)
	if self.bSelect then
		local mapSelectCard = self._panel.mapLevel.tbSelectablePenguinCard[self.nSelectIndex]
		local bUpgrade, nAimIndex = self._panel.mapLevel:CheckUpgradePenguinCard(mapSelectCard)
		if bUpgrade then
			self._mapNode.imgUp:SetActive(true)
			local mapUpgradeCard = self._panel.mapLevel.tbPenguinCard[nAimIndex]
			local nAfter = mapUpgradeCard.nLevel + mapSelectCard.nLevel
			nAfter = nAfter > mapUpgradeCard.nMaxLevel and mapUpgradeCard.nMaxLevel or nAfter
			NovaAPI.SetTMPText(self._mapNode.txtLevel, orderedFormat(ConfigTable.GetUIText("PenguinCard_CardLevel"), nAfter))
			local nId = mapUpgradeCard:GetIdByLevel(mapUpgradeCard.nGroupId, nAfter)
			local mapCfg = ConfigTable.GetData("PenguinCard", nId)
			if mapCfg then
				local sDesc = mapUpgradeCard:SetDesc(mapCfg)
				NovaAPI.SetTMPText(self._mapNode.txtDesc, sDesc)
			end
			NovaAPI.SetTMPText(self._mapNode.txtBtnSelect, ConfigTable.GetUIText("PenguinCard_Btn_Upgrade"))
		else
			self._mapNode.imgUp:SetActive(false)
			NovaAPI.SetTMPText(self._mapNode.txtLevel, orderedFormat(ConfigTable.GetUIText("PenguinCard_CardLevel"), self.mapCard.nLevel))
			NovaAPI.SetTMPText(self._mapNode.txtDesc, self.mapCard.sDesc)
			NovaAPI.SetTMPText(self._mapNode.txtBtnSelect, ConfigTable.GetUIText("PenguinCard_Btn_Select"))
		end
	else
		NovaAPI.SetTMPText(self._mapNode.txtLevel, orderedFormat(ConfigTable.GetUIText("PenguinCard_CardLevel"), self.mapCard.nLevel))
		NovaAPI.SetTMPText(self._mapNode.txtDesc, self.mapCard.sDesc)
	end
end
function PenguinCardInfoCtrl:PlayInAni()
	self.gameObject:SetActive(true)
	self._mapNode.blur:SetActive(true)
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		self._mapNode.goInfo:SetActive(true)
	end
	cs_coroutine.start(wait)
	EventManager.Hit(EventId.TemporaryBlockInput, 0.3)
end
function PenguinCardInfoCtrl:Close()
	self._mapNode.aniBlur:SetTrigger("tOut")
	self:AddTimer(1, 0.2, function()
		self._mapNode.goInfo:SetActive(false)
		self.gameObject:SetActive(false)
		self._panel.mapLevel:Resume()
	end, true, true, true)
	EventManager.Hit(EventId.TemporaryBlockInput, 0.2)
end
function PenguinCardInfoCtrl:Awake()
	self._mapNode.goInfo:SetActive(false)
end
function PenguinCardInfoCtrl:OnEnable()
end
function PenguinCardInfoCtrl:OnDisable()
end
function PenguinCardInfoCtrl:OnBtnClick_Right()
	if self.bSelect then
		local nMax = #self._panel.mapLevel.tbSelectablePenguinCard
		if nMax > self.nSelectIndex then
			self.nSelectIndex = self.nSelectIndex + 1
		else
			self.nSelectIndex = 1
		end
		self.mapCard = self._panel.mapLevel.tbSelectablePenguinCard[self.nSelectIndex]
		self:Refresh()
	else
		local nMax = #self.tbHasIndex
		local nIndex = table.indexof(self.tbHasIndex, self.mapCard.nSlotIndex)
		if nMax > nIndex then
			nIndex = nIndex + 1
		else
			nIndex = 1
		end
		self.mapCard = self._panel.mapLevel.tbPenguinCard[self.tbHasIndex[nIndex]]
		self:Refresh()
	end
end
function PenguinCardInfoCtrl:OnBtnClick_Left()
	if self.bSelect then
		local nMax = #self._panel.mapLevel.tbSelectablePenguinCard
		if self.nSelectIndex > 1 then
			self.nSelectIndex = self.nSelectIndex - 1
		else
			self.nSelectIndex = nMax
		end
		self.mapCard = self._panel.mapLevel.tbSelectablePenguinCard[self.nSelectIndex]
		self:Refresh()
	else
		local nMax = #self.tbHasIndex
		local nIndex = table.indexof(self.tbHasIndex, self.mapCard.nSlotIndex)
		if 1 < nIndex then
			nIndex = nIndex - 1
		else
			nIndex = nMax
		end
		self.mapCard = self._panel.mapLevel.tbPenguinCard[self.tbHasIndex[nIndex]]
		self:Refresh()
	end
end
function PenguinCardInfoCtrl:OnBtnClick_Sale()
	if not self.mapCard.nSlotIndex then
		return
	end
	self._panel.mapLevel:SalePenguinCard(self.mapCard.nSlotIndex)
end
function PenguinCardInfoCtrl:OnBtnClick_Back()
	self:Close()
	EventManager.Hit("PenguinCard_CloseCardInfo")
end
function PenguinCardInfoCtrl:OnBtnClick_Select()
	if not self.nSelectIndex then
		return
	end
	self._panel.mapLevel:SelectPenguinCard(self.nSelectIndex)
end
return PenguinCardInfoCtrl
