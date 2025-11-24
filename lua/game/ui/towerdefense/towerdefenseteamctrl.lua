local TowerDefenseTeamCtrl = class("TowerDefenseTeamCtrl", BaseCtrl)
TowerDefenseTeamCtrl._mapNodeConfig = {
	btnBack = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	btn_go = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Go"
	},
	txt_go = {
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_Go"
	},
	txt_sv_char_title = {
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_TeamEditor_Char"
	},
	character_loopSv = {
		sComponentName = "LoopScrollView"
	},
	txt_sv_item_title = {
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_TeamEditor_Item"
	},
	item_loopSv = {
		sComponentName = "LoopScrollView"
	},
	txt_guide = {
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_Guide"
	},
	btn_Guide = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Guide"
	},
	blur = {},
	guidPanel = {
		sNodeName = "TowerDefenseGuidePanel",
		sCtrlName = "Game.UI.TowerDefense.TowerDefenseGuideCtrl"
	}
}
TowerDefenseTeamCtrl._mapEventConfig = {
	CloseTowerDefenseGuidePanel = "OnEvent_CloseTowerDefenseGuidePanel"
}
TowerDefenseTeamCtrl._mapRedDotConfig = {}
function TowerDefenseTeamCtrl:Awake()
	self._mapNode.blur:SetActive(false)
	self._mapNode.guidPanel.gameObject:SetActive(false)
	self.tbGridCtrl = {}
end
function TowerDefenseTeamCtrl:OnDisable()
	for nInstanceId, objCtrl in pairs(self.tbGridCtrl) do
		self:UnbindCtrlByNode(objCtrl)
		self.tbGridCtrl[nInstanceId] = nil
	end
	self.tbGridCtrl = {}
end
function TowerDefenseTeamCtrl:SetData(nActId, nLevelId, tbChracter, nItemId)
	self.tbGridCtrl = {}
	self.nActId = nActId
	self.tbSelectedCharGuideIds = tbChracter
	self.nSelectedItemId = nItemId
	self.nLevelId = nLevelId
	self.TowerDefenseData = PlayerData.Activity:GetActivityDataById(self.nActId)
	self.levelConfig = ConfigTable.GetData("TowerDefenseLevel", self.nLevelId)
	local floorConfig = ConfigTable.GetData("TowerDefenseFloor", self.levelConfig.FloorId)
	self.nTeamMaxCharacter = floorConfig.MemberNum
	self.tbCharGuideIds = {}
	self.tbItemIds = {}
	local forEachFunction = function(config)
		if config.ActivityId == nActId and self.TowerDefenseData:IsLevelUnlock(config.LevelId) and self.TowerDefenseData:IsPreLevelPass(config.LevelId) then
			if config.GuideType == GameEnum.TowerDefGuideType.Character then
				table.insert(self.tbCharGuideIds, config.Id)
			elseif config.GuideType == GameEnum.TowerDefGuideType.Item then
				table.insert(self.tbItemIds, config.Id)
			end
		end
	end
	ForEachTableLine(DataTable.TowerDefenseGuide, forEachFunction)
	self._mapNode.character_loopSv:Init(#self.tbCharGuideIds, self, self.OnRefreshGrid_Character, self.OnCharacterGridBtnClick)
	self._mapNode.item_loopSv:Init(#self.tbItemIds, self, self.OnRefreshGrid_Item, self.OnItemGridBtnClick)
end
function TowerDefenseTeamCtrl:OnRefreshGrid_Character(goGrid, gridIndex)
	local nIndex = gridIndex + 1
	local nInstanceId = goGrid:GetInstanceID()
	if not self.tbGridCtrl[nInstanceId] then
		self.tbGridCtrl[nInstanceId] = self:BindCtrlByNode(goGrid, "Game.UI.TowerDefense.TowerDefenseTeamCharCtrl")
	end
	local charIndex = table.indexof(self.tbSelectedCharGuideIds, self.tbCharGuideIds[nIndex])
	self.tbGridCtrl[nInstanceId]:SetData(self.tbCharGuideIds[nIndex], charIndex)
end
function TowerDefenseTeamCtrl:OnRefreshGrid_Item(goGrid, gridIndex)
	local nIndex = gridIndex + 1
	local icon = goGrid.transform:Find("btn_grid/AnimRoot/img_icon")
	local guideConfig = ConfigTable.GetData("TowerDefenseGuide", self.tbItemIds[nIndex])
	if guideConfig == nil then
		return
	end
	local itemConfig = ConfigTable.GetData("TowerDefenseItem", guideConfig.ObjectId)
	if itemConfig == nil then
		return
	end
	if itemConfig.CardIcon ~= "" then
		self:SetPngSprite(icon.gameObject:GetComponent("Image"), itemConfig.CardIcon)
	end
	local selected = goGrid.transform:Find("btn_grid/AnimRoot/go_select")
	selected.gameObject:SetActive(self.nItemId == self.tbItemIds[nIndex])
	local go_selectMask = goGrid.transform:Find("btn_grid/AnimRoot/go_selectMask")
	go_selectMask.gameObject:SetActive(self.nItemId == self.tbItemIds[nIndex])
	local selected_tips = goGrid.transform:Find("btn_grid/AnimRoot/selected_tips")
	selected_tips.gameObject:SetActive(self.nItemId == self.tbItemIds[nIndex])
	local txt_selected = goGrid.transform:Find("btn_grid/AnimRoot/selected_tips/txt_selected")
	NovaAPI:SetTMPText(txt_selected:GetComponent("TMP_Text"), ConfigTable.GetUIText("TowerDef_TeamEditor_Selected"))
end
function TowerDefenseTeamCtrl:OnCharacterGridBtnClick(goGrid, gridIndex)
	local nIndex = gridIndex + 1
	local charIndex = table.indexof(self.tbSelectedCharGuideIds, self.tbCharGuideIds[nIndex])
	if 0 < charIndex then
		table.remove(self.tbSelectedCharGuideIds, charIndex)
		EventManager.Hit("TowerDefense_CharUpdate", self.tbSelectedCharGuideIds)
	elseif #self.tbSelectedCharGuideIds >= self.nTeamMaxCharacter then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("TowerDef_TeamEditor_CharTip"))
	else
		table.insert(self.tbSelectedCharGuideIds, self.tbCharGuideIds[nIndex])
		EventManager.Hit("TowerDefense_CharUpdate", self.tbSelectedCharGuideIds)
	end
end
function TowerDefenseTeamCtrl:OnItemGridBtnClick(goGrid, gridIndex)
	local nIndex = gridIndex + 1
	local selectItemId = self.tbItemIds[nIndex]
	if self.nSelectedItemId == selectItemId then
		local selected = goGrid.transform:Find("btn_grid/AnimRoot/selected")
		selected.gameObject:SetActive(false)
		local go_selectMask = goGrid.transform:Find("btn_grid/AnimRoot/go_selectMask")
		go_selectMask.gameObject:SetActive(false)
		self.nSelectedItemId = 0
		EventManager.Hit("TowerDefense_ItemUpdate", self.nSelectedItemId)
	elseif self.nSelectedItemId ~= nil or self.nSelectedItemId ~= 0 then
		local selected = goGrid.transform:Find("btn_grid/AnimRoot/go_select")
		selected.gameObject:SetActive(true)
		local go_selectMask = goGrid.transform:Find("btn_grid/AnimRoot/go_selectMask")
		go_selectMask.gameObject:SetActive(true)
		self.nSelectedItemId = self.tbItemIds[nIndex]
		EventManager.Hit("TowerDefense_ItemUpdate", self.nSelectedItemId)
	else
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("TowerDef_TeamEditor_ItemTip"))
	end
end
function TowerDefenseTeamCtrl:OnBtnClick_Close()
	EventManager.Hit("TowerDefenseTeamPanelClose")
end
function TowerDefenseTeamCtrl:OnBtnClick_Go()
	EventManager.Hit("TowerDefenseTeamPanelConfirm")
end
function TowerDefenseTeamCtrl:OnBtnClick_Guide()
	self._mapNode.blur.gameObject:SetActive(true)
	self._mapNode.guidPanel.gameObject:SetActive(true)
	self._mapNode.guidPanel:SetData(self.nActId)
end
function TowerDefenseTeamCtrl:OnEvent_CloseTowerDefenseGuidePanel()
	self._mapNode.guidPanel.gameObject:SetActive(false)
	self._mapNode.blur.gameObject:SetActive(false)
end
return TowerDefenseTeamCtrl
