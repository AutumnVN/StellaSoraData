local PenguinCardItemCtrl = class("PenguinCardItemCtrl", BaseCtrl)
local WwiseManger = CS.WwiseAudioManager.Instance
local _, NotMaxLevel = ColorUtility.TryParseHtmlString("#FFF7EA")
local _, MaxLevel = ColorUtility.TryParseHtmlString("#ffe075")
PenguinCardItemCtrl._mapNodeConfig = {
	AnimRoot = {sComponentName = "Animator"},
	imgBg = {},
	imgIcon = {sComponentName = "Image"},
	txtLevel = {sComponentName = "TMP_Text"},
	txtName = {sComponentName = "TMP_Text"},
	imgUp = {},
	txtTrigger = {nCount = 2, sComponentName = "TMP_Text"},
	aniTrigger = {
		sNodeName = "txtTrigger",
		nCount = 2,
		sComponentName = "Animator"
	},
	goTrigger = {},
	btnOpenInfo = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_OpenInfo"
	}
}
PenguinCardItemCtrl._mapEventConfig = {
	PenguinCardTriggered = "OnEvent_Triggered",
	PenguinCardWaitPlay = "OnEvent_WaitPlay"
}
function PenguinCardItemCtrl:Refresh_Select(mapCard, nSelectIndex, bRoll)
	self.mapCard = mapCard
	self.nSelectIndex = nSelectIndex
	self._mapNode.txtLevel.gameObject:SetActive(false)
	self._mapNode.txtName.gameObject:SetActive(true)
	self._mapNode.imgBg:SetActive(bRoll)
	self._mapNode.imgIcon.gameObject:SetActive(true)
	self._mapNode.goTrigger:SetActive(false)
	self:SetSprite(self._mapNode.imgIcon, "UI/Play_PenguinCard/SpriteAtlas/Sprite/" .. mapCard.sIcon)
	NovaAPI.SetTMPText(self._mapNode.txtName, mapCard.sName)
	local bUpgrade = self._panel.mapLevel:CheckUpgradePenguinCard(mapCard)
	self._mapNode.imgUp:SetActive(bUpgrade)
	self._mapNode.AnimRoot:Play("PengUinCard_Bd_Shopin", 0, 0)
end
function PenguinCardItemCtrl:Refresh_Slot(mapCard)
	self.mapCard = mapCard
	self.nEffectCount = 0
	self.bWaitPlay = false
	self._mapNode.txtLevel.gameObject:SetActive(true)
	self._mapNode.txtName.gameObject:SetActive(false)
	self._mapNode.imgBg:SetActive(false)
	self._mapNode.imgUp:SetActive(false)
	self._mapNode.goTrigger:SetActive(false)
	self:SetSprite(self._mapNode.imgIcon, "UI/Play_PenguinCard/SpriteAtlas/Sprite/" .. mapCard.sIcon)
	NovaAPI.SetTMPText(self._mapNode.txtLevel, orderedFormat(ConfigTable.GetUIText("PenguinCard_CardLevel"), mapCard.nLevel))
	if mapCard.nLevel == mapCard.nMaxLevel then
		NovaAPI.SetTMPColor(self._mapNode.txtLevel, MaxLevel)
	else
		NovaAPI.SetTMPColor(self._mapNode.txtLevel, NotMaxLevel)
	end
end
function PenguinCardItemCtrl:RefreshUpgrade(nGroupId)
	if self.mapCard.nGroupId == nGroupId then
		self._mapNode.imgUp:SetActive(false)
	end
end
function PenguinCardItemCtrl:PlayFlipAni()
	self._mapNode.imgBg:SetActive(true)
	self._mapNode.txtName.gameObject:SetActive(false)
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
	WwiseManger:PostEvent("Mode_Card_appear")
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
	WwiseManger:PostEvent("Mode_Card_levelup")
	self:AddTimer(1, 0.2, function()
		if callback then
			callback()
		end
	end, true, true, true)
end
function PenguinCardItemCtrl:PlaySaleAni(callback)
	self._mapNode.goTrigger:SetActive(false)
	self._mapNode.AnimRoot:Play("PengUinCard_Bd_Bdout", 0, 0)
	WwiseManger:PostEvent("Mode_Card_giveup")
	local nAnimTime = NovaAPI.GetAnimClipLength(self._mapNode.AnimRoot, {
		"PengUinCard_Bd_Bdout"
	})
	self:AddTimer(1, nAnimTime, function()
		if callback then
			callback()
		end
	end, true, true, true)
end
function PenguinCardItemCtrl:PlayTriggerAni()
	if self.bTriggerCd then
		self:PlayEffectAni()
		return
	end
	if not self.bTriggerCd then
		self.bTriggerCd = true
		self:AddTimer(1, 1.433, function()
			self.bTriggerCd = false
		end, true, true, true)
	end
	self._mapNode.AnimRoot:Play("PengUinCard_Bd_Open", 0, 0)
	self._mapNode.AnimRoot.speed = self._panel.mapLevel.nSpeed
	WwiseManger:PostEvent("Mode_Card_cast")
	self.nEffectCount = 0
	self:PlayEffectAni()
end
function PenguinCardItemCtrl:PlayEffectAni()
	if self.nEffectCount == nil then
		self.nEffectCount = 0
	end
	local sDesc = ""
	if self.mapCard.nEffectType == GameEnum.PenguinCardEffectType.IncreaseBasicChips then
		self.nEffectCount = self.nEffectCount + self.mapCard.tbEffectParam[1]
		sDesc = orderedFormat(ConfigTable.GetUIText("PenguinCard_Trigger_AddScore"), self.nEffectCount)
	elseif self.mapCard.nEffectType == GameEnum.PenguinCardEffectType.IncreaseMultiplier then
		self.nEffectCount = self.nEffectCount + self.mapCard.tbEffectParam[1]
		sDesc = orderedFormat(ConfigTable.GetUIText("PenguinCard_Trigger_AddRatio"), self.nEffectCount)
	elseif self.mapCard.nEffectType == GameEnum.PenguinCardEffectType.MultiMultiplier then
		self.nEffectCount = self.nEffectCount + self.mapCard.tbEffectParam[1]
		sDesc = orderedFormat(ConfigTable.GetUIText("PenguinCard_Trigger_MultiRatio"), self.nEffectCount)
	end
	self._mapNode.goTrigger:SetActive(sDesc ~= "")
	if self.mapCard.nEffectType == GameEnum.PenguinCardEffectType.IncreaseBasicChips then
		self._mapNode.txtTrigger[1].gameObject:SetActive(false)
		self._mapNode.txtTrigger[2].gameObject:SetActive(true)
		NovaAPI.SetTMPText(self._mapNode.txtTrigger[2], sDesc)
		self._mapNode.aniTrigger[2]:Play("PengUinCard_Bd_Trigger_in", 0, 0)
		self._mapNode.aniTrigger[2].speed = self._panel.mapLevel.nSpeed
	elseif self.mapCard.nEffectType == GameEnum.PenguinCardEffectType.IncreaseMultiplier or self.mapCard.nEffectType == GameEnum.PenguinCardEffectType.MultiMultiplier then
		self._mapNode.txtTrigger[1].gameObject:SetActive(true)
		self._mapNode.txtTrigger[2].gameObject:SetActive(false)
		NovaAPI.SetTMPText(self._mapNode.txtTrigger[1], sDesc)
		self._mapNode.aniTrigger[1]:Play("PengUinCard_Bd_Trigger_in", 0, 0)
		self._mapNode.aniTrigger[1].speed = self._panel.mapLevel.nSpeed
	end
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
	if self.mapCard.nTriggerPhase == GameEnum.PenguinCardTriggerPhase.Settlement then
		self.bWaitPlay = true
		return
	end
	self:PlayTriggerAni()
end
function PenguinCardItemCtrl:OnEvent_WaitPlay()
	if self.bWaitPlay == true then
		self.bWaitPlay = false
		self:PlayTriggerAni()
	end
end
return PenguinCardItemCtrl
