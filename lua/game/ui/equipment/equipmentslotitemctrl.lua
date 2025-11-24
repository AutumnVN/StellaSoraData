local EquipmentSlotItemCtrl = class("EquipmentSlotItemCtrl", BaseCtrl)
EquipmentSlotItemCtrl._mapNodeConfig = {
	goEmpty = {},
	imgAbleBg = {sComponentName = "Image"},
	txtUnEquip = {
		sComponentName = "TMP_Text",
		sLanguageId = "CharEquipment_UnEquip"
	},
	imgLockBg = {sComponentName = "Image"},
	txtLockDesc = {sComponentName = "TMP_Text"},
	imgLockType = {sComponentName = "Image"},
	imgChoose = {},
	goEquip = {},
	imgEquipmentIcon = {sComponentName = "Image"}
}
EquipmentSlotItemCtrl._mapEventConfig = {}
EquipmentSlotItemCtrl._mapRedDotConfig = {}
function EquipmentSlotItemCtrl:Init(mapSlot, nCharId)
	self.mapSlot = mapSlot
	local bEmpty = mapSlot.nGemIndex == 0
	local bUnlock = mapSlot.bUnlock
	self._mapNode.goEmpty.gameObject:SetActive(bEmpty or not bUnlock)
	self._mapNode.imgAbleBg.gameObject:SetActive(bEmpty and bUnlock)
	self._mapNode.imgLockBg.gameObject:SetActive(not bUnlock)
	self._mapNode.goEquip.gameObject:SetActive(not bEmpty and bUnlock)
	local nGemId = PlayerData.Equipment:GetGemIdBySlot(nCharId, mapSlot.nSlotId)
	local mapGemCfg = ConfigTable.GetData("CharGem", nGemId)
	if not mapGemCfg then
		return
	end
	if not bUnlock then
		self:SetPngSprite(self._mapNode.imgLockType, mapGemCfg.IconBg)
		NovaAPI.SetTMPText(self._mapNode.txtLockDesc, orderedFormat(ConfigTable.GetUIText("Equipment_SlotActiveLevel"), mapSlot.nLevel))
	elseif bUnlock and not bEmpty then
		self:SetPngSprite(self._mapNode.imgEquipmentIcon, mapGemCfg.Icon)
	end
	if mapSlot.nSlotId == 1 and bEmpty and bUnlock then
		local mapSlotCfg = ConfigTable.GetData("CharGemSlotControl", mapSlot.nSlotId)
		local nHasCount = PlayerData.Item:GetItemCountByID(mapGemCfg.GenerateCostTid)
		if nHasCount >= mapSlotCfg.GeneratenCostQty then
			EventManager.Hit("Guide_PassiveCheck_Msg", "Guide_EquipmentSlot")
		end
	end
	self:SetChooseState(false)
end
function EquipmentSlotItemCtrl:SetChooseState(bChoose)
	self._mapNode.imgChoose.gameObject:SetActive(bChoose)
end
function EquipmentSlotItemCtrl:PlayAnim()
	local sAnimName = ""
	sAnimName = "imgEquipmentIcon_in"
	self.animRoot:Play(sAnimName, 0, 0)
end
function EquipmentSlotItemCtrl:Awake()
	self.animRoot = self.gameObject:GetComponent("Animator")
end
return EquipmentSlotItemCtrl
