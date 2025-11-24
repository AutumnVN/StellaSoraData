local TemplateRandomPropertyCtrl = class("TemplateRandomPropertyCtrl", BaseCtrl)
TemplateRandomPropertyCtrl._mapNodeConfig = {
	imgBg = {sComponentName = "Image"},
	txtTag = {sComponentName = "TMP_Text"},
	txtProperty = {sComponentName = "TMP_Text"},
	txtPropertyValue = {sComponentName = "TMP_Text"},
	TMP_Link = {
		sNodeName = "txtProperty",
		sComponentName = "TMPHyperLink",
		callback = "OnLinkClick_Word"
	}
}
TemplateRandomPropertyCtrl._mapEventConfig = {}
function TemplateRandomPropertyCtrl:SetProperty(nAttrId, nCharId, bLock)
	self.nCharId = nCharId
	self.mapCfg = ConfigTable.GetData("CharGemAttrValue", nAttrId)
	if not self.mapCfg then
		return
	end
	local mapAttributeDesc = self:_GetAttributeDesc()
	if not mapAttributeDesc then
		return
	end
	NovaAPI.SetTMPText(self._mapNode.txtTag, ConfigTable.GetUIText("Equipment_AttrTag_" .. self.mapCfg.Tag))
	local sValue = ""
	sValue = self:_TransValueFormat(tonumber(self.mapCfg.Value), mapAttributeDesc.isPercent, mapAttributeDesc.Format, self.mapCfg.Tag ~= GameEnum.CharGemAttrTag.ATTR)
	NovaAPI.SetTMPText(self._mapNode.txtProperty, UTILS.SubDesc(mapAttributeDesc.RandomAttrDesc, nil, nil, {nCharId = nCharId}))
	NovaAPI.SetTMPText(self._mapNode.txtPropertyValue, sValue)
	self:SetAttrLock(bLock)
end
function TemplateRandomPropertyCtrl:SetAttrLock(bLock)
	if bLock then
		self:SetSprite_FrameColor(self._mapNode.imgBg, self.mapCfg.Rarity, AllEnum.FrameType_New.RandomPropertyLock)
	else
		self:SetSprite_FrameColor(self._mapNode.imgBg, self.mapCfg.Rarity, AllEnum.FrameType_New.RandomProperty)
	end
end
function TemplateRandomPropertyCtrl:_GetAttributeDesc()
	local attrType = self.mapCfg.AttrType
	local attrSubType1 = self.mapCfg.AttrTypeFirstSubtype
	local attrSubType2 = self.mapCfg.AttrTypeSecondSubtype
	local nEffectDescId = self:GetEffectDescId(attrType, attrSubType1, attrSubType2)
	local mapAttributeDesc = ConfigTable.GetData("EffectDesc", nEffectDescId)
	if mapAttributeDesc == nil then
		printError("\230\137\190\228\184\141\229\136\176EffectDesc\229\175\185\229\186\148\233\133\141\231\189\174\239\188\140id = " .. nEffectDescId)
		return false
	else
		return mapAttributeDesc
	end
end
function TemplateRandomPropertyCtrl:_TransValueFormat(nValue, bPercent, nFormat, bAdd)
	local sValue = ""
	if bAdd then
		sValue = orderedFormat(ConfigTable.GetUIText("Equipment_AttrDesc_PlusLevel"), nValue)
	else
		sValue = FormatEffectValue(nValue, bPercent, nFormat)
	end
	return sValue
end
function TemplateRandomPropertyCtrl:GetEffectDescId(attrType, attrSubType1, attrSubType2)
	return attrType * 10000 + attrSubType1 * 10 + attrSubType2
end
function TemplateRandomPropertyCtrl:OnLinkClick_Word(link, sWordId)
	UTILS.ClickWordLink(link, sWordId, {
		nCharId = self.nCharId,
		nLevel = 1,
		nAddLv = tonumber(self.mapCfg.Value)
	})
end
return TemplateRandomPropertyCtrl
