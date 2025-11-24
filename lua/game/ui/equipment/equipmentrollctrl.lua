local EquipmentRollCtrl = class("EquipmentRollCtrl", BaseCtrl)
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
EquipmentRollCtrl._mapNodeConfig = {
	TopBar = {
		sNodeName = "TopBarPanel",
		sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"
	},
	imgEquipmentIcon = {sComponentName = "Image"},
	txtEquipmentName = {sComponentName = "TMP_Text"},
	txtEquipmentDesc = {sComponentName = "TMP_Text"},
	txtLockSwitch = {
		sComponentName = "TMP_Text",
		sLanguageId = "Equipment_Roll_LockRoll"
	},
	btnSwitch = {
		nCount = 2,
		sComponentName = "UIButton",
		callback = "OnBtnClick_Switch"
	},
	txtLockLimit = {
		sComponentName = "TMP_Text",
		sLanguageId = "Equipment_Roll_LockAttrTitle"
	},
	txtLockLimitCount = {sComponentName = "TMP_Text"},
	txtTitleCurAttr = {
		sComponentName = "TMP_Text",
		sLanguageId = "Equipment_Roll_CurAttr"
	},
	goProperty = {
		nCount = 4,
		sCtrlName = "Game.UI.TemplateEx.TemplateRandomPropertyCtrl"
	},
	btnUnlock = {
		nCount = 4,
		sComponentName = "UIButton",
		callback = "OnBtnClick_Unlock"
	},
	btnLock = {
		nCount = 4,
		sComponentName = "UIButton",
		callback = "OnBtnClick_Lock"
	},
	txtAlterEmpty = {
		sComponentName = "TMP_Text",
		sLanguageId = "Equipment_Roll_NoneRolled"
	},
	goAlter = {},
	goPropertyAlter = {
		nCount = 4,
		sCtrlName = "Game.UI.TemplateEx.TemplateRandomPropertyCtrl"
	},
	btnConfirm = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Confirm"
	},
	btnRoll = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Roll"
	},
	txtBtnConfirm = {
		sComponentName = "TMP_Text",
		sLanguageId = "Equipment_Btn_ConfirmRollResult"
	},
	txtBtnRoll = {
		sComponentName = "TMP_Text",
		sLanguageId = "Equipment_Btn_Reroll"
	},
	imgConfirmMask = {},
	imgCostIcon = {nCount = 2, sComponentName = "Image"},
	txtCostCount = {nCount = 2, sComponentName = "TMP_Text"},
	goCost2 = {},
	Replace = {
		sNodeName = "----Replace----",
		sCtrlName = "Game.UI.Equipment.EquipmentAttrReplaceCtrl"
	}
}
EquipmentRollCtrl._mapEventConfig = {}
function EquipmentRollCtrl:RefreshData()
	local nGemId = PlayerData.Equipment:GetGemIdBySlot(self.nCharId, self.nSlotId)
	self.mapGemCfg = ConfigTable.GetData("CharGem", nGemId)
	self.mapSlotCfg = ConfigTable.GetData("CharGemSlotControl", self.nSlotId)
	local tbEquipment = PlayerData.Equipment:GetEquipmentBySlot(self.nCharId, self.nSlotId)
	self.mapEquipment = tbEquipment[self.nSelectGemIndex]
	self.tbLockAttr = {}
	self._mapNode.TopBar:CreateCoin({
		self.mapGemCfg.RefreshCostTid,
		self.mapSlotCfg.LockItemTid
	})
end
function EquipmentRollCtrl:Refresh()
	self:RefreshData()
	self:RefreshEquipmentInfo()
	self:RefreshAttr()
	self:RefreshAlterAttr()
	self:RefreshCoin()
	self:RefreshConfirm()
end
function EquipmentRollCtrl:RefreshEquipmentInfo()
	self:SetPngSprite(self._mapNode.imgEquipmentIcon, self.mapGemCfg.Icon)
	local sRoman = ConfigTable.GetUIText("RomanNumeral_" .. self.nSelectGemIndex)
	local sSuf = orderedFormat(ConfigTable.GetUIText("Equipment_NameIndexSuffix"), sRoman)
	NovaAPI.SetTMPText(self._mapNode.txtEquipmentName, self.mapGemCfg.Title .. sSuf)
	NovaAPI.SetTMPText(self._mapNode.txtEquipmentDesc, self.mapGemCfg.Desc)
	local nLockAttr = self:GetAttrLockCount()
	NovaAPI.SetTMPText(self._mapNode.txtLockLimitCount, orderedFormat(ConfigTable.GetUIText("Equipment_Roll_LockAttrCount"), nLockAttr, self.mapSlotCfg.LockableNum))
	self:RefreshLock()
end
function EquipmentRollCtrl:GetAttrLockCount()
	local nLockAttr = 0
	for _, v in pairs(self.tbLockAttr) do
		if v == true then
			nLockAttr = nLockAttr + 1
		end
	end
	return nLockAttr
end
function EquipmentRollCtrl:RefreshLock()
	self._mapNode.btnSwitch[1].gameObject:SetActive(not self.mapEquipment.bLock)
	self._mapNode.btnSwitch[2].gameObject:SetActive(self.mapEquipment.bLock)
end
function EquipmentRollCtrl:RefreshAttr()
	for i = 1, 4 do
		self._mapNode.goProperty[i]:SetProperty(self.mapEquipment.tbAffix[i], self.nCharId)
		self:RefreshAttrLock(i)
	end
end
function EquipmentRollCtrl:RefreshAttrLock(nIndex)
	local bAttrLock = self.tbLockAttr[nIndex] == true
	self._mapNode.btnUnlock[nIndex].gameObject:SetActive(bAttrLock)
	self._mapNode.btnLock[nIndex].gameObject:SetActive(not bAttrLock)
end
function EquipmentRollCtrl:RefreshAlterAttr(bRoll)
	if bRoll then
		self._mapNode.goAlter.gameObject:SetActive(false)
	end
	local bEmpty = self.mapEquipment:CheckAlterEmpty()
	self._mapNode.txtAlterEmpty.gameObject:SetActive(bEmpty)
	self._mapNode.goAlter.gameObject:SetActive(not bEmpty)
	if not bEmpty then
		for i = 1, 4 do
			self._mapNode.goPropertyAlter[i]:SetProperty(self.mapEquipment.tbAlterAffix[i], self.nCharId, self.tbLockAttr[i])
		end
	end
end
function EquipmentRollCtrl:RefreshCoin()
	local nLockAttr = self:GetAttrLockCount()
	local bUseLock = 0 < nLockAttr
	self._mapNode.goCost2.gameObject:SetActive(bUseLock)
	self._mapNode.imgCostIcon[2].gameObject:SetActive(bUseLock)
	self._mapNode.txtCostCount[2].gameObject:SetActive(bUseLock)
	if bUseLock then
		self:SetSprite_Coin(self._mapNode.imgCostIcon[2], self.mapSlotCfg.LockItemTid)
		local nHas = PlayerData.Item:GetItemCountByID(self.mapSlotCfg.LockItemTid)
		NovaAPI.SetTMPText(self._mapNode.txtCostCount[2], self.mapSlotCfg.LockItemQty * nLockAttr)
		NovaAPI.SetTMPColor(self._mapNode.txtCostCount[2], nHas < self.mapSlotCfg.LockItemQty * nLockAttr and Red_Unable or Blue_Normal)
	end
	self:SetSprite_Coin(self._mapNode.imgCostIcon[1], self.mapGemCfg.RefreshCostTid)
	local nHas = PlayerData.Item:GetItemCountByID(self.mapGemCfg.RefreshCostTid)
	NovaAPI.SetTMPText(self._mapNode.txtCostCount[1], self.mapSlotCfg.RefreshCostQty)
	NovaAPI.SetTMPColor(self._mapNode.txtCostCount[1], nHas < self.mapSlotCfg.RefreshCostQty and Red_Unable or Blue_Normal)
end
function EquipmentRollCtrl:RefreshConfirm()
	local bEmpty = self.mapEquipment:CheckAlterEmpty()
	self._mapNode.imgConfirmMask:SetActive(bEmpty)
end
function EquipmentRollCtrl:GetRareCount(tbAffix)
	local nRareCount = 0
	for _, v in ipairs(tbAffix) do
		if v ~= 0 then
			local mapCfg = ConfigTable.GetData("CharGemAttrValue", v)
			if mapCfg and mapCfg.Rarity == GameEnum.itemRarity.SSR then
				nRareCount = nRareCount + 1
			end
		end
	end
	return nRareCount
end
function EquipmentRollCtrl:FadeIn()
	self.animator = self.gameObject.transform:GetComponent("Animator")
	self.animator:Play("EquipmentSelectPanel_in1")
end
function EquipmentRollCtrl:Awake()
	local tbParam = self:GetPanelParam()
	if type(tbParam) == "table" then
		self.nCharId = tbParam[1]
		self.nSlotId = tbParam[2]
		self.nSelectGemIndex = tbParam[3]
	end
end
function EquipmentRollCtrl:OnEnable()
	self:Refresh()
end
function EquipmentRollCtrl:OnDisable()
end
function EquipmentRollCtrl:OnDestroy()
end
function EquipmentRollCtrl:OnBtnClick_Switch(btn, nIndex)
	local bLock = nIndex == 1
	local callback = function()
		self:RefreshLock()
	end
	PlayerData.Equipment:SendCharGemUpdateGemLockStatusReq(self.nCharId, self.nSlotId, self.nSelectGemIndex, bLock, callback)
end
function EquipmentRollCtrl:OnBtnClick_Unlock(btn, nIndex)
	self.tbLockAttr[nIndex] = false
	self:RefreshAttrLock(nIndex)
	local nLockAttr = self:GetAttrLockCount()
	self:RefreshCoin()
	NovaAPI.SetTMPText(self._mapNode.txtLockLimitCount, orderedFormat(ConfigTable.GetUIText("Equipment_Roll_LockAttrCount"), nLockAttr, self.mapSlotCfg.LockableNum))
end
function EquipmentRollCtrl:OnBtnClick_Lock(btn, nIndex)
	local nLockAttr = self:GetAttrLockCount()
	if nLockAttr >= self.mapSlotCfg.LockableNum then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Equipment_LockAttrMax"))
		return
	end
	self.tbLockAttr[nIndex] = true
	self:RefreshAttrLock(nIndex)
	self:RefreshCoin()
	NovaAPI.SetTMPText(self._mapNode.txtLockLimitCount, orderedFormat(ConfigTable.GetUIText("Equipment_Roll_LockAttrCount"), nLockAttr + 1, self.mapSlotCfg.LockableNum))
end
function EquipmentRollCtrl:OnBtnClick_Confirm(btn)
	local bEmpty = self.mapEquipment:CheckAlterEmpty()
	if bEmpty then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Equipment_ConfirmRoll_AlterEmpty"))
		return
	end
	if self.mapEquipment.bLock then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Equipment_ConfirmRoll_EquipmentLock"))
		return
	end
	local callback = function()
		self:RefreshAttr()
		self:RefreshAlterAttr()
		self:RefreshCoin()
		self:RefreshConfirm()
		self.animator:Play("EquipmentSelectPanel_in", 0, 0)
	end
	local sRoman = ConfigTable.GetUIText("RomanNumeral_" .. self.nSelectGemIndex)
	local sSuf = orderedFormat(ConfigTable.GetUIText("Equipment_NameIndexSuffix"), sRoman)
	local sName = self.mapGemCfg.Title .. sSuf
	self._mapNode.Replace:Open(sName, self.mapEquipment, self.nCharId, self.nSlotId, self.nSelectGemIndex, callback)
end
function EquipmentRollCtrl:OnBtnClick_Roll(btn)
	if self.mapEquipment.bLock then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Equipment_Roll_EquipmentLock"))
		return
	end
	local roll = function()
		local bEnough = false
		local nHasRefresh = PlayerData.Item:GetItemCountByID(self.mapGemCfg.RefreshCostTid)
		local nLockAttr = self:GetAttrLockCount()
		local bUseLock = 0 < nLockAttr
		if bUseLock then
			local nHasLock = PlayerData.Item:GetItemCountByID(self.mapSlotCfg.LockItemTid)
			bEnough = nHasLock >= self.mapSlotCfg.LockItemQty * nLockAttr and nHasRefresh >= self.mapSlotCfg.RefreshCostQty
		else
			bEnough = nHasRefresh >= self.mapSlotCfg.RefreshCostQty
		end
		if not bEnough then
			EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Equipment_MatNotEnough_Roll"))
			return
		end
		local tbLockAttrId = {}
		for k, v in pairs(self.tbLockAttr) do
			if v == true then
				table.insert(tbLockAttrId, self.mapEquipment.tbAffix[k])
			end
		end
		local callback = function()
			self:RefreshAlterAttr(true)
			self:RefreshCoin()
			self:RefreshConfirm()
			WwiseAudioMgr:PostEvent("ui_charInfo_equipment_reforge_ani")
		end
		PlayerData.Equipment:SendCharGemRefreshReq(self.nCharId, self.nSlotId, self.nSelectGemIndex, tbLockAttrId, callback)
	end
	local warning = function()
		local isSelectAgain = false
		local confirmCallback = function()
			PlayerData.Equipment:SetRollWarning(not isSelectAgain)
			roll()
		end
		local againCallback = function(isSelect)
			isSelectAgain = isSelect
		end
		local msg = {
			nType = AllEnum.MessageBox.Confirm,
			sContent = ConfigTable.GetUIText("Equipment_RollWarning_HighQuality"),
			callbackConfirm = confirmCallback,
			callbackAgain = againCallback,
			sAgain = ConfigTable.GetUIText("MessageBox_LoginWarning")
		}
		EventManager.Hit(EventId.OpenMessageBox, msg)
	end
	local bWarn = PlayerData.Equipment:GetRollWarning()
	if self.mapEquipment.tbAlterAffix and bWarn then
		local nRareCount = self:GetRareCount(self.mapEquipment.tbAffix)
		local nAlterRareCount = self:GetRareCount(self.mapEquipment.tbAlterAffix)
		local bLock = false
		for k, v in pairs(self.tbLockAttr) do
			if v == true then
				bLock = true
				break
			end
		end
		if not bLock and nAlterRareCount >= ConfigTable.GetConfigNumber("CharGemHighQualityNum") then
			warning()
		elseif bLock and nRareCount < nAlterRareCount then
			warning()
		else
			roll()
		end
	else
		roll()
	end
end
return EquipmentRollCtrl
