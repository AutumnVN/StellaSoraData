local MatProductionItemCtrl = class("MatProductionItemCtrl", BaseCtrl)
MatProductionItemCtrl._mapNodeConfig = {
	anAudioUI = {sNodeName = "btnGrid", sComponentName = "AkAudioUI"},
	goItem = {
		sCtrlName = "Game.UI.TemplateEx.TemplateItemCtrl"
	},
	txtHave = {
		sComponentName = "TMP_Text",
		sLanguageId = "Crafting_Material_QTY"
	},
	txtHaveCount = {sComponentName = "TMP_Text"},
	txtProductionName = {sComponentName = "TMP_Text"},
	goLock = {},
	imgSelect = {},
	txtLock = {sComponentName = "TMP_Text"}
}
MatProductionItemCtrl._mapEventConfig = {}
function MatProductionItemCtrl:SetData(tbProduction)
	self.nId = tbProduction.Id
	self.bUnlock = tbProduction.Unlock
	self._mapNode.goLock.gameObject:SetActive(not self.bUnlock)
	if not self.bUnlock then
		NovaAPI.SetTMPText(self._mapNode.txtLock, tbProduction.UnlockTip)
	end
	self.nItemId = tbProduction.ShowProductionId == 0 and tbProduction.ProductionId or tbProduction.ShowProductionId
	local nCount = tbProduction.ShowProductionId == 0 and tbProduction.ProductionPerBatch or tbProduction.ShowProductionPerBatch
	if nCount <= 1 then
		nCount = nil
	end
	self._mapNode.goItem:SetItem(self.nItemId, nil, nCount)
	NovaAPI.SetTMPText(self._mapNode.txtProductionName, tbProduction.Name)
	local hasCount = PlayerData.Item:GetItemCountByID(self.nItemId)
	NovaAPI.SetTMPText(self._mapNode.txtHaveCount, hasCount)
	self:SetSelect(false)
	local sAudioEvent = self.bUnlock and "ui_common_slide" or "ui_systerm_locked"
	self._mapNode.anAudioUI:SetAkAudioWiseEventName(sAudioEvent)
end
function MatProductionItemCtrl:RefreshCraftingItem()
	local hasCount = PlayerData.Item:GetItemCountByID(self.nItemId)
	NovaAPI.SetTMPText(self._mapNode.txtHaveCount, hasCount)
end
function MatProductionItemCtrl:SetSelect(bSelect)
	self.bSelect = bSelect
	self._mapNode.imgSelect.gameObject:SetActive(self.bSelect)
end
return MatProductionItemCtrl
