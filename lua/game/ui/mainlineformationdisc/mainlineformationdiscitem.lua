local MainlineFormationDiscItem = class("MainlineFormationDiscItem", BaseCtrl)
MainlineFormationDiscItem._mapNodeConfig = {
	none_1 = {sComponentName = "GameObject"},
	tex_Dics_None = {
		sComponentName = "TMP_Text",
		sLanguageId = "MainlineFormationDisc_None"
	},
	none_2 = {sComponentName = "GameObject"},
	none_2_Ani = {
		sNodeName = "AnimRootNone2",
		sComponentName = "Animator"
	},
	tc_disc = {sComponentName = "GameObject"},
	imgIcon = {sComponentName = "Image"},
	imgEET = {sComponentName = "Image"},
	txtLevel = {sComponentName = "TMP_Text"},
	txtLv = {sComponentName = "TMP_Text", sLanguageId = "Lv"},
	txtName = {sComponentName = "TMP_Text"},
	btn_Disc = {
		sComponentName = "UIButton",
		callback = "OnClickChooseDisc"
	},
	btn_Details = {
		sComponentName = "UIButton",
		callback = "OnClickDetails"
	},
	txt_Details = {
		sComponentName = "TMP_Text",
		sLanguageId = "Formation_Btn_Info"
	},
	imgtxt = {
		sComponentName = "TMP_Text",
		sLanguageId = "MainlineFormationDisc_HintEmpty"
	},
	imgDiscStar = {sComponentName = "Image"}
}
MainlineFormationDiscItem._mapEventConfig = {}
function MainlineFormationDiscItem:Refresh(nId, tbNote, isSelectType)
	if nId == 0 then
		if isSelectType then
			self._mapNode.none_2:SetActive(true)
			self._mapNode.none_2_Ani:Play("btnAdd_in")
		else
			self._mapNode.none_1:SetActive(true)
		end
		self._mapNode.tc_disc:SetActive(false)
		self.nId = 0
		return
	else
		self._mapNode.none_1:SetActive(false)
		self._mapNode.none_2:SetActive(false)
		self._mapNode.tc_disc:SetActive(true)
	end
	self.nId = nId
	local mapItem = ConfigTable.GetData_Item(nId)
	local mapCfg = ConfigTable.GetData("Disc", nId)
	if not mapCfg or not mapItem then
		return
	end
	local mapData = PlayerData.Disc:GetDiscById(nId)
	self:SetPngSprite(self._mapNode.imgIcon, mapItem.Icon)
	local sName = AllEnum.ElementIconType.Icon .. mapCfg.EET
	self:SetAtlasSprite(self._mapNode.imgEET, "12_rare", sName)
	NovaAPI.SetTMPText(self._mapNode.txtLevel, mapData.nLevel)
	self:SetAtlasSprite(self._mapNode.imgDiscStar, "12_rare", AllEnum.FrameType_New.DiscLimitS .. AllEnum.FrameColor_New[mapData.nRarity] .. "_0" .. mapData.nStar + 1)
	NovaAPI.SetImageNativeSize(self._mapNode.imgDiscStar)
	NovaAPI.SetTMPText(self._mapNode.txtName, mapData.sName)
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
end
function MainlineFormationDiscItem:OnClickChooseDisc()
	EventManager.Hit("OpenSelectDiscCard", self.nId or 0)
end
function MainlineFormationDiscItem:OnClickDetails()
	EventManager.Hit("OpenSelectDiscDetails", self.nId)
end
return MainlineFormationDiscItem
