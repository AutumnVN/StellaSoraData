local PotentialIconCtrl = class("PotentialIconCtrl", BaseCtrl)
PotentialIconCtrl._mapNodeConfig = {
	imgIcon = {nCount = 3, sComponentName = "Image"}
}
PotentialIconCtrl._mapEventConfig = {}
PotentialIconCtrl._mapRedDotConfig = {}
function PotentialIconCtrl:SetIcon(nId)
	local itemCfg = ConfigTable.GetData_Item(nId)
	if nil == itemCfg then
		printError("\232\142\183\229\143\150Item\232\161\168\233\133\141\231\189\174\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129id = " .. nId)
		return
	end
	local _, color = ColorUtility.TryParseHtmlString(AllEnum.PotentialRarityCfg[itemCfg.Rarity].sColor)
	local nCornerType = ConfigTable.GetData("Potential", nId).Corner
	self._mapNode.imgIcon[1].gameObject:SetActive(nCornerType ~= 0)
	self._mapNode.imgIcon[2].gameObject:SetActive(nCornerType ~= 0)
	if nCornerType ~= 0 then
		NovaAPI.SetImageColor(self._mapNode.imgIcon[1], color)
		self:SetPngSprite(self._mapNode.imgIcon[1], AllEnum.PotentialCornerIcon[nCornerType].sIconB)
		self:SetPngSprite(self._mapNode.imgIcon[2], AllEnum.PotentialCornerIcon[nCornerType].sIconA)
	end
	self:SetPngSprite(self._mapNode.imgIcon[3], itemCfg.Icon .. AllEnum.PotentialIconSurfix.A)
end
return PotentialIconCtrl
