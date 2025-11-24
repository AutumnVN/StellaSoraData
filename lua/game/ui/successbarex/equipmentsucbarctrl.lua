local EquipmentSucBarCtrl = class("EquipmentSucBarCtrl", BaseCtrl)
EquipmentSucBarCtrl._mapNodeConfig = {
	aniBlur = {
		sNodeName = "t_fullscreen_blur_blue",
		sComponentName = "Animator"
	},
	btnClose = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	SuccessBar = {
		sCtrlName = "Game.UI.SuccessBarEx.SuccessBarCtrl"
	},
	rtProperty = {sComponentName = "Transform"},
	rtRandomProperty = {sComponentName = "Transform"},
	goProperty = {},
	goRandomProperty = {},
	txtNextLevel = {sComponentName = "TMP_Text"},
	txtLvCn = {
		sComponentName = "TMP_Text",
		sLanguageId = "Equipment_Upgrade_Suc_Level"
	},
	ani1 = {sNodeName = "rtTitle", sComponentName = "Animator"}
}
EquipmentSucBarCtrl._mapEventConfig = {}
function EquipmentSucBarCtrl:Open()
	self:RefreshContent()
	self._mapNode.SuccessBar.gameObject:SetActive(true)
	self._mapNode.SuccessBar:PlayAni(AllEnum.SuccessBar.Blue, self.tbAni)
	EventManager.Hit(EventId.TemporaryBlockInput, 0.8)
end
function EquipmentSucBarCtrl:RefreshContent()
	self.tbAni = {}
	local nLevel = self._panel.mapData.nLevel
	local mapAttrBefore = self._panel.mapData.mapAttrBefore
	local mapAttrAfter = self._panel.mapData.mapAttrAfter
	local tbUnlockRandomAttr = self._panel.mapData.tbUnlockAttr
	NovaAPI.SetTMPText(self._mapNode.txtNextLevel, nLevel)
	table.insert(self.tbAni, self._mapNode.ani1)
	delChildren(self._mapNode.rtProperty)
	for _, mapAttachAttr in pairs(AllEnum.AttachAttr) do
		local mapAttr = mapAttrBefore[mapAttachAttr.sKey]
		if nil ~= mapAttr and mapAttr.Value > 0 then
			local goItemObj = instantiate(self._mapNode.goProperty, self._mapNode.rtProperty)
			goItemObj:SetActive(true)
			local ctrlItem = self:BindCtrlByNode(goItemObj, "Game.UI.TemplateEx.TemplatePropertyCtrl")
			local bValueChanged = mapAttrAfter[mapAttachAttr.sKey].Value ~= mapAttr.Value
			if bValueChanged then
				ctrlItem:SetItemProperty(mapAttr.Key, mapAttr.Value, mapAttrAfter[mapAttachAttr.sKey].Value, true)
			else
				ctrlItem:SetItemProperty(mapAttr.Key, mapAttr.Value, nil, true)
			end
			table.insert(self.tbAni, goItemObj.transform:GetComponent("Animator"))
		end
	end
	for _, v in ipairs(tbUnlockRandomAttr) do
		local goItemObj = instantiate(self._mapNode.goRandomProperty, self._mapNode.rtRandomProperty)
		goItemObj:SetActive(true)
		local ctrlItem = self:BindCtrlByNode(goItemObj, "Game.UI.TemplateEx.TemplateRandomPropertyCtrl")
		ctrlItem:SetProperty(v.Tag, v.AttrId, v.Value)
		table.insert(self.tbAni, goItemObj.transform:GetComponent("Animator"))
	end
end
function EquipmentSucBarCtrl:Awake()
end
function EquipmentSucBarCtrl:OnEnable()
	self._mapNode.aniBlur.gameObject:SetActive(true)
	self:Open()
end
function EquipmentSucBarCtrl:OnDisable()
end
function EquipmentSucBarCtrl:OnDestroy()
end
function EquipmentSucBarCtrl:OnBtnClick_Close(btn)
	if self._panel.callback then
		self._panel.callback()
	end
	EventManager.Hit(EventId.ClosePanel, PanelId.EquipmentSucBar)
end
return EquipmentSucBarCtrl
