local PenguinCardItemCtrl = class("PenguinCardItemCtrl", BaseCtrl)
local WwiseManger = CS.WwiseAudioManager.Instance
PenguinCardItemCtrl._mapNodeConfig = {
	AnimRoot = {sComponentName = "Animator"},
	imgBg = {},
	imgIcon = {sComponentName = "Image"},
	txtLevel = {sComponentName = "TMP_Text"},
	txtName = {sComponentName = "TMP_Text"},
	btnOpenInfo = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_OpenInfo"
	}
}
PenguinCardItemCtrl._mapEventConfig = {
	PenguinCardTriggered = "OnEvent_Triggered"
}
function PenguinCardItemCtrl:Refresh_Select(mapCard, nSelectIndex)
	self.mapCard = mapCard
	self.nSelectIndex = nSelectIndex
	self._mapNode.txtLevel.gameObject:SetActive(false)
	self._mapNode.txtName.gameObject:SetActive(true)
	self._mapNode.imgBg:SetActive(true)
	self._mapNode.imgIcon.gameObject:SetActive(true)
	self:SetSprite(self._mapNode.imgIcon, "UI/Play_PenguinCard/SpriteAtlas/Sprite/" .. mapCard.sIcon)
	NovaAPI.SetTMPText(self._mapNode.txtName, mapCard.sName)
	self._mapNode.AnimRoot:Play("PengUinCard_Bd_Shopin", 0, 0)
end
function PenguinCardItemCtrl:Refresh_Slot(mapCard)
	self.mapCard = mapCard
	self._mapNode.txtLevel.gameObject:SetActive(true)
	self._mapNode.txtName.gameObject:SetActive(false)
	self._mapNode.imgBg:SetActive(false)
	self:SetSprite(self._mapNode.imgIcon, "UI/Play_PenguinCard/SpriteAtlas/Sprite/" .. mapCard.sIcon)
	NovaAPI.SetTMPText(self._mapNode.txtLevel, orderedFormat(ConfigTable.GetUIText("PenguinCard_CardLevel"), mapCard.nLevel))
end
function PenguinCardItemCtrl:PlayFlipAni()
	self._mapNode.AnimRoot:Play("PengUinCard_Bd_Shopturn", 0, 0)
	local nAnimTime = NovaAPI.GetAnimClipLength(self._mapNode.AnimRoot, {
		"PengUinCard_Bd_Shopturn"
	})
	self:AddTimer(1, nAnimTime, function()
		self._mapNode.imgIcon.gameObject:SetActive(false)
	end, true, true, true)
end
function PenguinCardItemCtrl:PlayHideAni()
	self._mapNode.AnimRoot:Play("PengUinCard_Bd_Shopout", 0, 0)
end
function PenguinCardItemCtrl:PlaySelectAni(callback)
	self._mapNode.AnimRoot:Play("PengUinCard_Bd_Bdin", 0, 0)
	local nAnimTime = NovaAPI.GetAnimClipLength(self._mapNode.AnimRoot, {
		"PengUinCard_Bd_Bdin"
	})
	self:AddTimer(1, nAnimTime, function()
		if callback then
			callback()
		end
	end, true, true, true)
end
function PenguinCardItemCtrl:PlayUpgradeAni(callback)
	self._mapNode.AnimRoot:Play("PengUinCard_Bd_Up", 0, 0)
	self:AddTimer(1, 0.2, function()
		if callback then
			callback()
		end
	end, true, true, true)
end
function PenguinCardItemCtrl:PlaySaleAni(callback)
	self._mapNode.AnimRoot:Play("PengUinCard_Bd_Bdout", 0, 0)
	local nAnimTime = NovaAPI.GetAnimClipLength(self._mapNode.AnimRoot, {
		"PengUinCard_Bd_Bdout"
	})
	self:AddTimer(1, nAnimTime, function()
		if callback then
			callback()
		end
	end, true, true, true)
end
function PenguinCardItemCtrl:Awake()
end
function PenguinCardItemCtrl:OnEnable()
end
function PenguinCardItemCtrl:OnDisable()
end
function PenguinCardItemCtrl:OnBtnClick_OpenInfo()
	if self.nSelectIndex and self._panel.mapLevel.bSelectedPenguinCard then
		return
	end
	EventManager.Hit("PenguinCard_OpenInfo", self.mapCard, self.nSelectIndex)
end
function PenguinCardItemCtrl:OnEvent_Triggered(nSlotIndex)
	if not (self.mapCard and self.mapCard ~= 0 and self.mapCard.nSlotIndex) or nSlotIndex ~= self.mapCard.nSlotIndex then
		return
	end
	self._mapNode.AnimRoot:Play("PengUinCard_Bd_Open", 0, 0)
	self._mapNode.AnimRoot.speed = self._panel.mapLevel.nSpeed
end
return PenguinCardItemCtrl
