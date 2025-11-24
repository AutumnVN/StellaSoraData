local EquipmentAttrPreviewCtrl = class("EquipmentAttrPreviewCtrl", BaseCtrl)
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
EquipmentAttrPreviewCtrl._mapNodeConfig = {
	blur = {
		sNodeName = "t_fullscreen_blur_blue"
	},
	aniBlur = {
		sNodeName = "t_fullscreen_blur_blue",
		sComponentName = "Animator"
	},
	btnCloseBg = {
		sNodeName = "snapshot",
		sComponentName = "Button",
		callback = "OnBtnClick_Close"
	},
	txtWindowTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "Equipment_Title_AttrPreview"
	},
	window = {},
	aniWindow = {sNodeName = "window", sComponentName = "Animator"},
	btnClose = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	Content = {sComponentName = "Transform"},
	goAttr = {},
	ActionBar = {
		sCtrlName = "Game.UI.ActionBar.ActionBarCtrl"
	},
	btnShortcutClose = {
		sComponentName = "NaviButton",
		callback = "OnBtnClick_Close"
	}
}
EquipmentAttrPreviewCtrl._mapEventConfig = {}
function EquipmentAttrPreviewCtrl:Open()
	self._mapNode.blur:SetActive(true)
	self:PlayInAni()
	self:Refresh()
end
function EquipmentAttrPreviewCtrl:Refresh()
	local mapSlotData
	if self.tbEquipment == nil then
		self.tbEquipment, mapSlotData = PlayerData.Equipment:GetEquipedGem(self.nCharId)
	end
	for k, v in ipairs(self.tbEquipment) do
		local goItemObj = instantiate(self._mapNode.goAttr, self._mapNode.Content)
		goItemObj:SetActive(true)
		local txtName = goItemObj.transform:Find("t_common_04/imgBg/txtName"):GetComponent("TMP_Text")
		local sRoman = mapSlotData and ConfigTable.GetUIText("RomanNumeral_" .. mapSlotData[k].nGemIndex) or ""
		local sName = orderedFormat(ConfigTable.GetUIText("Equipment_AttrPreviewName_" .. k), v.sName, sRoman)
		NovaAPI.SetTMPText(txtName, sName)
		for i = 1, 4 do
			local goAttr = goItemObj.transform:Find("rtBg/goProperty" .. i).gameObject
			local ctrlAttr = self:BindCtrlByNode(goAttr, "Game.UI.TemplateEx.TemplateRandomPropertyCtrl")
			ctrlAttr:SetProperty(v.tbAffix[i], self.nCharId)
		end
	end
end
function EquipmentAttrPreviewCtrl:PlayInAni()
	self._mapNode.window:SetActive(true)
	self._mapNode.aniWindow:Play("t_window_04_t_in")
	EventManager.Hit(EventId.TemporaryBlockInput, 0.3)
end
function EquipmentAttrPreviewCtrl:PlayOutAni()
	self._mapNode.aniWindow:Play("t_window_04_t_out")
	self._mapNode.aniBlur:SetTrigger("tOut")
	self:AddTimer(1, 0.2, "Close", true, true, true)
	EventManager.Hit(EventId.TemporaryBlockInput, 0.2)
end
function EquipmentAttrPreviewCtrl:Close()
	self._mapNode.window:SetActive(false)
	EventManager.Hit(EventId.ClosePanel, PanelId.EquipmentAttrPreview)
end
function EquipmentAttrPreviewCtrl:Awake()
	self._mapNode.window:SetActive(false)
	local tbParam = self:GetPanelParam()
	if type(tbParam) == "table" then
		self.nCharId = tbParam[1]
		self.tbEquipment = tbParam[2]
	end
	self._mapNode.btnShortcutClose.gameObject:SetActive(GamepadUIManager.GetInputState())
	if GamepadUIManager.GetInputState() then
		local tbConfig = {
			{
				sAction = "Back",
				sLang = "ActionBar_Back"
			}
		}
		self._mapNode.ActionBar:InitActionBar(tbConfig)
	end
end
function EquipmentAttrPreviewCtrl:OnEnable()
	if GamepadUIManager.GetInputState() then
		GamepadUIManager.EnableGamepadUI("EquipmentAttrPreviewCtrl", self:GetGamepadUINode(), nil, true)
	end
	self:Open()
end
function EquipmentAttrPreviewCtrl:OnDisable()
	if GamepadUIManager.GetInputState() then
		GamepadUIManager.DisableGamepadUI("EquipmentAttrPreviewCtrl")
	end
end
function EquipmentAttrPreviewCtrl:OnDestroy()
end
function EquipmentAttrPreviewCtrl:OnBtnClick_Close()
	self:PlayOutAni()
end
return EquipmentAttrPreviewCtrl
