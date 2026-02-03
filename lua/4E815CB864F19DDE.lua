local ThrowGiftItemSelectGridCtrl = class("ThrowGiftItemSelectGridCtrl", BaseCtrl)
ThrowGiftItemSelectGridCtrl._mapNodeConfig = {
	txtBtnConfirm = {sComponentName = "TMP_Text"},
	btnConfirm = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Confirm"
	},
	imgBgSelect = {},
	imgItemIcon = {sComponentName = "Image"},
	TMPItemName = {sComponentName = "TMP_Text"},
	TMPItemDesc = {sComponentName = "TMP_Text"},
	AnimRoot = {
		sNodeName = "AnimRootTop",
		sComponentName = "Animator"
	}
}
ThrowGiftItemSelectGridCtrl._mapEventConfig = {}
ThrowGiftItemSelectGridCtrl._mapRedDotConfig = {}
function ThrowGiftItemSelectGridCtrl:Awake()
end
function ThrowGiftItemSelectGridCtrl:FadeIn()
end
function ThrowGiftItemSelectGridCtrl:FadeOut()
end
function ThrowGiftItemSelectGridCtrl:OnEnable()
	self.Idx = 0
	self.animator = self.gameObject:GetComponent("Animator")
end
function ThrowGiftItemSelectGridCtrl:OnDisable()
end
function ThrowGiftItemSelectGridCtrl:OnDestroy()
end
function ThrowGiftItemSelectGridCtrl:OnRelease()
end
function ThrowGiftItemSelectGridCtrl:Refresh(nItemId)
	self._mapNode.AnimRoot:Play("New State")
	local mapItemCfgData = ConfigTable.GetData("ThrowGiftItem", nItemId)
	if mapItemCfgData == nil then
		self.gameObject:SetActive(false)
		return
	end
	self.gameObject:SetActive(true)
	NovaAPI.SetTMPText(self._mapNode.TMPItemName, mapItemCfgData.Name)
	NovaAPI.SetTMPText(self._mapNode.TMPItemDesc, mapItemCfgData.Desc)
	self:SetPngSprite(self._mapNode.imgItemIcon, mapItemCfgData.Icon)
end
function ThrowGiftItemSelectGridCtrl:SetSelect(bSelect)
	if bSelect then
		self._mapNode.AnimRoot:Play("btnItemSelect_in")
	else
		self._mapNode.AnimRoot:Play("btnItemSelect_out")
	end
	self._mapNode.imgBgSelect:SetActive(bSelect)
end
function ThrowGiftItemSelectGridCtrl:PlaySelectAnim()
	self.animator:Play("btnItemSelectCard_out")
end
function ThrowGiftItemSelectGridCtrl:OnBtnClick_Confirm(btn)
	EventManager.Hit("ThrowGiftItemSelectConfirmClick")
end
return ThrowGiftItemSelectGridCtrl
