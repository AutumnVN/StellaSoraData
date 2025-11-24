local MainlineFormationDiscCard = class("MainlineFormationDiscCard", BaseCtrl)
MainlineFormationDiscCard._mapNodeConfig = {
	imgIcon = {sComponentName = "Image"},
	imgEET = {sComponentName = "Image"},
	txtLevel = {sComponentName = "TMP_Text"},
	txtLv = {sComponentName = "TMP_Text", sLanguageId = "Lv"},
	imgDiscStar = {sComponentName = "Image"},
	Select = {},
	Select_bg = {},
	Select_Mask = {},
	TMPSelectTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "RoguelikeBuild_Manage_SelectedTitle"
	}
}
MainlineFormationDiscCard._mapEventConfig = {
	Disc_Select_Active = "SetSelectActive"
}
function MainlineFormationDiscCard:Refresh(nId, tbNote, bSelect)
	self.nId = nId
	local mapItem = ConfigTable.GetData_Item(nId)
	local mapCfg = ConfigTable.GetData("Disc", nId)
	if not mapCfg or not mapItem then
		return
	end
	local mapData = PlayerData.Disc:GetDiscById(nId)
	self:SetPngSprite(self._mapNode.imgIcon, mapItem.Icon .. AllEnum.OutfitIconSurfix.OutInfo)
	local sName = AllEnum.ElementIconType.Icon .. mapCfg.EET
	self:SetAtlasSprite(self._mapNode.imgEET, "12_rare", sName)
	NovaAPI.SetTMPText(self._mapNode.txtLevel, mapData.nLevel)
	self:SetAtlasSprite(self._mapNode.imgDiscStar, "12_rare", AllEnum.FrameType_New.DiscLimitS .. AllEnum.FrameColor_New[mapData.nRarity] .. "_0" .. mapData.nStar + 1)
	NovaAPI.SetImageNativeSize(self._mapNode.imgDiscStar)
	for i = 1, 3 do
	end
	if tbNote then
		for k, v in ipairs(tbNote) do
			if 4 <= k then
				printError("\233\159\179\231\172\166\231\167\141\231\177\187\233\133\141\229\135\186\232\182\133\232\191\1353\228\184\170\239\188\140\230\152\159\231\155\152Id:" .. nId)
				break
			end
		end
	end
	self:SetSelect(bSelect)
end
function MainlineFormationDiscCard:SetSelect(bSelect)
	self._mapNode.Select:SetActive(bSelect)
	self._mapNode.Select_bg:SetActive(bSelect)
	self._mapNode.Select_Mask:SetActive(bSelect)
end
function MainlineFormationDiscCard:SetSelectActive(nId)
	if self.nId == nId then
		self:SetSelect(true)
	end
end
return MainlineFormationDiscCard
