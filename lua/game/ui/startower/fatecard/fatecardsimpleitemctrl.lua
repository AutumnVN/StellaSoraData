local FateCardSimpleItemCtrl = class("FateCardSimpleItemCtrl", BaseCtrl)
FateCardSimpleItemCtrl._mapNodeConfig = {
	imgRarity = {sComponentName = "Image"},
	imgIcon = {sComponentName = "Image"},
	txtCount = {sComponentName = "TMP_Text"},
	txtCardId = {sComponentName = "TMP_Text"}
}
FateCardSimpleItemCtrl._mapEventConfig = {}
FateCardSimpleItemCtrl._mapRedDotConfig = {}
function FateCardSimpleItemCtrl:SetFateCardItem(nId, nCount)
	self._mapNode.txtCardId.gameObject:SetActive(false)
	local itemCfg = ConfigTable.GetData_Item(nId)
	if nil == itemCfg then
		printError(string.format("\232\142\183\229\143\150Item\232\161\168\230\160\188\233\133\141\231\189\174\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129id = [%s]", nId))
		return
	end
	local fateCardCfg = ConfigTable.GetData("FateCard", nId)
	if nil == fateCardCfg then
		printError(string.format("\232\142\183\229\143\150FateCard\232\161\168\230\160\188\233\133\141\231\189\174\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129id = [%s]", nId))
		return
	end
	local sFrame = AllEnum.FrameType_New.FateCardS .. AllEnum.FrameColor_New[itemCfg.Rarity]
	self:SetAtlasSprite(self._mapNode.imgRarity, "12_rare", sFrame)
	self:SetPngSprite(self._mapNode.imgIcon, itemCfg.Icon2)
	self._mapNode.txtCount.gameObject:SetActive(fateCardCfg.ActiveNumber ~= -1)
	NovaAPI.SetTMPText(self._mapNode.txtCount, nCount)
	NovaAPI.SetTMPText(self._mapNode.txtCardId, nId)
end
return FateCardSimpleItemCtrl
