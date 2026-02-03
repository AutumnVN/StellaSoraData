local ThrowGiftItemDicCtrl = class("ThrowGiftItemDicCtrl", BaseCtrl)
ThrowGiftItemDicCtrl._mapNodeConfig = {
	btnItemCtrl = {
		sNodeName = "btnItem",
		nCount = 8,
		sCtrlName = "Game.UI.Activity.ThrowGifts.ThrowGiftItemDicGridCtrl"
	},
	btnItem = {
		sComponentName = "UIButton",
		nCount = 8,
		callback = "OnBtnClick_Item"
	},
	btnClose = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	btnShortcutBg = {
		sComponentName = "NaviButton",
		callback = "OnBtnClick_CloseDesc"
	},
	rtCardInfo = {},
	rtCardInfoAnim = {sNodeName = "rtCardInfo", sComponentName = "Animator"},
	AnimRootItemInfo = {sComponentName = "Animator"},
	imgItemIconInfo = {sComponentName = "Image"},
	TMPItemNameInfo = {sComponentName = "TMP_Text"},
	TMPItemDescInfo = {sComponentName = "TMP_Text"}
}
ThrowGiftItemDicCtrl._mapEventConfig = {}
ThrowGiftItemDicCtrl._mapRedDotConfig = {}
function ThrowGiftItemDicCtrl:Awake()
end
function ThrowGiftItemDicCtrl:FadeIn()
end
function ThrowGiftItemDicCtrl:FadeOut()
end
function ThrowGiftItemDicCtrl:OnEnable()
	self.tbItem = {}
	local forEachItem = function(mapData)
		table.insert(self.tbItem, mapData)
	end
	ForEachTableLine(DataTable.ThrowGiftItem, forEachItem)
	local sort = function(a, b)
		return a.Id < b.Id
	end
	table.sort(self.tbItem, sort)
	for i = 1, 8 do
		if self.tbItem[i] ~= nil then
			self._mapNode.btnItem[i].gameObject:SetActive(true)
			self._mapNode.btnItemCtrl[i]:SetItem(self.tbItem[i].Id)
		else
			self._mapNode.btnItem[i].gameObject:SetActive(false)
		end
	end
end
function ThrowGiftItemDicCtrl:OnDisable()
end
function ThrowGiftItemDicCtrl:OnDestroy()
end
function ThrowGiftItemDicCtrl:OnRelease()
end
function ThrowGiftItemDicCtrl:OpenPanel()
	self.gameObject:SetActive(true)
end
function ThrowGiftItemDicCtrl:OnBtnClick_Item(btn, nIdx)
	local mapConfig = self.tbItem[nIdx]
	if mapConfig == nil then
		return
	end
	NovaAPI.SetTMPText(self._mapNode.TMPItemNameInfo, mapConfig.Name)
	NovaAPI.SetTMPText(self._mapNode.TMPItemDescInfo, mapConfig.Desc)
	self:SetPngSprite(self._mapNode.imgItemIconInfo, mapConfig.Icon)
	self._mapNode.rtCardInfo:SetActive(true)
end
function ThrowGiftItemDicCtrl:OnBtnClick_CloseDesc(btn)
	self._mapNode.rtCardInfoAnim:Play("rtCardInfo_out")
	local wait = function()
		self._mapNode.rtCardInfo:SetActive(false)
	end
	self:AddTimer(1, 0.2, wait, true, true, true)
end
function ThrowGiftItemDicCtrl:OnBtnClick_Close(btn)
	self._mapNode.AnimRootItemInfo:Play("rtItemInfo_out")
	local wait = function()
		self.gameObject:SetActive(false)
	end
	self:AddTimer(1, 0.2, wait, true, true, true)
end
return ThrowGiftItemDicCtrl
