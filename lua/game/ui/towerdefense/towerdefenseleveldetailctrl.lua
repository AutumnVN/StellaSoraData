local TowerDefenseLevelDetailCtrl = class("TowerDefenseLevelDetailCtrl", BaseCtrl)
TowerDefenseLevelDetailCtrl._mapNodeConfig = {
	TopBar = {
		sNodeName = "TopBarPanel",
		sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"
	},
	TopBarAnimator = {sNodeName = "goBack", sComponentName = "Animator"},
	txt_monsterInfo = {
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_MonsterInfo"
	},
	txt_title_target = {
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_Title_Target"
	},
	txt_title_reward = {
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_Title_RewardInfo"
	},
	go_Monster = {
		sCtrlName = "Game.UI.TemplateEx.TemplateHeadCtrl",
		nCount = 5
	},
	go_QuestInfo = {nCount = 3},
	goEnemyInfo = {
		sCtrlName = "Game.UI.TowerDefense.TowerDefenseMonsterInfoCtrl"
	},
	btn_monsterInfo = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_MonsterInfo"
	},
	btn_rewardInfo = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_RewardInfo"
	},
	item = {
		sCtrlName = "Game.UI.TemplateEx.TemplateItemCtrl",
		nCount = 4
	},
	ItemBtn = {
		sComponentName = "UIButton",
		nCount = 4,
		callback = "OnBtnClick_Reward"
	},
	txt_item = {
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_Title_Item"
	},
	txt_char = {
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_Title_Char"
	},
	txt_charCount = {sComponentName = "TMP_Text"},
	txt_go1 = {
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_Go"
	},
	btn_go1 = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Go"
	},
	txt_team = {
		sComponentName = "TMP_Text",
		sLanguageId = "TowerDef_BuildTeam"
	},
	btn_Team = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_EditorTeam"
	},
	team_character = {nCount = 6},
	special_item = {},
	animator = {
		sNodeName = "----SafeAreaRoot_Detail---",
		sComponentName = "Animator"
	},
	teamCtrl = {
		sNodeName = "TowerDefenseTeamPanel",
		sCtrlName = "Game.UI.TowerDefense.TowerDefenseTeamCtrl"
	}
}
TowerDefenseLevelDetailCtrl._mapEventConfig = {
	TowerDefense_CharUpdate = "OnEvent_UpdateCharData",
	TowerDefense_ItemUpdate = "OnEvent_UpdateItemData",
	TowerDefenseTeamPanelConfirm = "OnEvent_Go",
	TowerDefenseTeamPanelClose = "OnEvent_UpdateTeamEditorPanelClose"
}
TowerDefenseLevelDetailCtrl._mapRedDotConfig = {}
function TowerDefenseLevelDetailCtrl:Awake()
	local param = self:GetPanelParam()
	if type(param) == "table" then
		self.nActId = param[1]
		self.nLevelId = param[2]
	end
	self.bInEditorPanel = false
	self.TowerDefenseData = PlayerData.Activity:GetActivityDataById(self.nActId)
	self._mapNode.teamCtrl.gameObject:SetActive(false)
	self:UpdateData()
end
function TowerDefenseLevelDetailCtrl:OnEnable()
	self:UpdateQuestInfo()
	self:UpdateItem()
end
function TowerDefenseLevelDetailCtrl:UpdateData()
	self.levelConfig = ConfigTable.GetData("TowerDefenseLevel", self.nLevelId)
	self:UpdateMonsterInfo()
	self:UpdateQuestInfo()
	self:UpdateItem()
	self:InitTeamData()
end
function TowerDefenseLevelDetailCtrl:UpdateQuestInfo()
	local levelData = self.TowerDefenseData:GetLevelData(self.nLevelId)
	local nStar = levelData.nStar
	for i = 1, 3 do
		local go_Info = self._mapNode.go_QuestInfo[i].transform:Find("txt_target")
		NovaAPI.SetTMPText(go_Info:GetComponent("TMP_Text"), self.levelConfig["Des" .. i])
		local go_Star = self._mapNode.go_QuestInfo[i].transform:Find("Star")
		go_Star.gameObject:SetActive(i <= nStar)
	end
end
function TowerDefenseLevelDetailCtrl:UpdateMonsterInfo()
	for i = 1, 5 do
		self._mapNode.go_Monster[i].gameObject:SetActive(false)
	end
	local groupId = self.levelConfig.MonsterPreview
	local tbMonsterGroup = ConfigTable.GetData("PreviewMonsterGroup", groupId)
	if tbMonsterGroup == nil then
		return
	end
	local tbMonsterConfig = tbMonsterGroup.MonsterIds
	local comp = function(a, b)
		local monsterA = ConfigTable.GetData("Monster", a)
		local monsterB = ConfigTable.GetData("Monster", b)
		if monsterA == nil or monsterB == nil then
			return
		end
		if monsterA.EpicLv ~= monsterB.EpicLv then
			return monsterA.EpicLv < monsterB.EpicLv
		else
			return a < b
		end
	end
	table.sort(tbMonsterConfig, comp)
	for i = 1, 5 do
		local go = self._mapNode.go_Monster[i]
		if i > #tbMonsterConfig then
			go.gameObject:SetActive(false)
		else
			go:SetMonsterHead(tbMonsterConfig[i])
		end
	end
end
function TowerDefenseLevelDetailCtrl:UpdateItem()
	self.tbReward = {}
	if self.levelConfig.Item1 ~= 0 then
		table.insert(self.tbReward, {
			nId = self.levelConfig.Item1,
			nCount = self.levelConfig.Qty1
		})
	end
	if self.levelConfig.Item2 ~= 0 then
		table.insert(self.tbReward, {
			nId = self.levelConfig.Item2,
			nCount = self.levelConfig.Qty2
		})
	end
	for i = 1, 4 do
		if i > #self.tbReward then
			self._mapNode.item[i].gameObject:SetActive(false)
		else
			local levelData = self.TowerDefenseData:GetLevelData(self.nLevelId)
			self._mapNode.item[i]:SetItem(self.tbReward[i].nId, nil, self.tbReward[i].nCount, nil, 0 < levelData.nStar, true)
			self._mapNode.item[i].gameObject:SetActive(true)
		end
	end
end
function TowerDefenseLevelDetailCtrl:InitTeamData()
	self.tbCharGuideId = {}
	self.nItemGuideId = 0
	local tempTeamData = self.TowerDefenseData:GetLevelTempTeamData(self.nLevelId)
	if tempTeamData ~= nil then
		if tempTeamData.tbCharGuideId ~= nil then
			self.tbCharGuideId = tempTeamData.tbCharGuideId
		end
		self.nItemGuideId = tempTeamData.itemGuideId
	end
	self:UpdateCharacter()
	self:UpdateSpecialItem_V1()
	local floorConfig = ConfigTable.GetData("TowerDefenseFloor", self.levelConfig.FloorId)
	if floorConfig == nil then
		return
	end
	self._mapNode.btn_Team.gameObject:SetActive(floorConfig.MemberNum ~= 0)
end
function TowerDefenseLevelDetailCtrl:UpdateCharacter()
	local floorConfig = ConfigTable.GetData("TowerDefenseFloor", self.levelConfig.FloorId)
	if floorConfig == nil then
		return
	end
	local teamCharacterCount = floorConfig.MemberNum
	if teamCharacterCount == 0 then
		self.tbCharGuideId = {}
		local foreach = function(data)
			if data.ActivityId == self.nActId and data.GuideType == GameEnum.TowerDefGuideType.Character and table.indexof(floorConfig.TeamGroup, data.ObjectId) > 0 then
				table.insert(self.tbCharGuideId, data.Id)
			end
		end
		ForEachTableLine(DataTable.TowerDefenseGuide, foreach)
	end
	for i = 1, 6 do
		local go_add = self._mapNode.team_character[i].transform:Find("img_add")
		local btn_add = self._mapNode.team_character[i]:GetComponent("UIButton")
		local go_none = self._mapNode.team_character[i].transform:Find("img_none")
		local go_icon = self._mapNode.team_character[i].transform:Find("img_icon")
		local txt_name = self._mapNode.team_character[i].transform:Find("img_icon/txt_name"):GetComponent("TMP_Text")
		go_add.gameObject:SetActive(false)
		go_none.gameObject:SetActive(false)
		go_icon.gameObject:SetActive(false)
		if teamCharacterCount == 0 then
			if i > #self.tbCharGuideId then
				go_none.gameObject:SetActive(true)
			else
				local guideConfig = ConfigTable.GetData("TowerDefenseGuide", self.tbCharGuideId[i])
				local characterConfig = ConfigTable.GetData("TowerDefenseCharacter", guideConfig.ObjectId)
				if characterConfig ~= nil then
					local icon_char = go_icon.transform:Find("icon_char")
					self:SetPngSprite(icon_char:GetComponent("Image"), characterConfig.Icon .. AllEnum.CharHeadIconSurfix.QM)
					NovaAPI.SetTMPText(txt_name, characterConfig.Name)
				end
				go_icon.gameObject:SetActive(true)
			end
			NovaAPI.SetTMPText(self._mapNode.txt_charCount, string.format("<color=#ffde6a>%d</color>/%d", #self.tbCharGuideId, #self.tbCharGuideId))
		else
			if teamCharacterCount < i then
				go_none.gameObject:SetActive(true)
			elseif i > #self.tbCharGuideId then
				go_add.gameObject:SetActive(true)
				btn_add.onClick:RemoveAllListeners()
				btn_add.onClick:AddListener(function()
					self:OnBtnClick_EditorTeam()
				end)
			else
				local guideConfig = ConfigTable.GetData("TowerDefenseGuide", self.tbCharGuideId[i])
				local characterConfig = ConfigTable.GetData("TowerDefenseCharacter", guideConfig.ObjectId)
				if characterConfig ~= nil then
					local icon_char = go_icon.transform:Find("icon_char")
					self:SetPngSprite(icon_char:GetComponent("Image"), characterConfig.Icon .. AllEnum.CharHeadIconSurfix.QM)
					NovaAPI.SetTMPText(txt_name, characterConfig.Name)
				end
				go_icon.gameObject:SetActive(true)
				btn_add.onClick:RemoveAllListeners()
				btn_add.onClick:AddListener(function()
					self:OnBtnClick_EditorTeam()
				end)
			end
			NovaAPI.SetTMPText(self._mapNode.txt_charCount, string.format("<color=#ffde6a>%d</color>/%d", #self.tbCharGuideId, teamCharacterCount))
		end
	end
end
function TowerDefenseLevelDetailCtrl:UpdateSpecialItem_V1()
	local floorConfig = ConfigTable.GetData("TowerDefenseFloor", self.levelConfig.FloorId)
	if floorConfig == nil then
		return
	end
	local go_add = self._mapNode.special_item.transform:Find("img_add")
	local go_icon = self._mapNode.special_item.transform:Find("img_icon")
	local go_none = self._mapNode.special_item.transform:Find("img_none")
	go_add.gameObject:SetActive(false)
	go_none.gameObject:SetActive(false)
	go_icon.gameObject:SetActive(false)
	if floorConfig.ItemID == 0 then
		go_none.gameObject:SetActive(true)
	else
		local foreach = function(data)
			if data.ActivityId == self.nActId and data.GuideType == GameEnum.TowerDefGuideType.Item and floorConfig.ItemID == data.ObjectId then
				self.nItemGuideId = data.Id
			end
		end
		ForEachTableLine(DataTable.TowerDefenseGuide, foreach)
		local guideConfig = ConfigTable.GetData("TowerDefenseGuide", self.nItemGuideId)
		local itemConfig = ConfigTable.GetData("TowerDefenseItem", guideConfig.ObjectId)
		if itemConfig ~= nil then
			self:SetPngSprite(go_icon:GetComponent("Image"), itemConfig.CardIcon)
		end
		go_icon.gameObject:SetActive(true)
	end
end
function TowerDefenseLevelDetailCtrl:UpdateSpecialItem()
	local floorConfig = ConfigTable.GetData("TowerDefenseFloor", self.levelConfig.FloorId)
	if floorConfig == nil then
		return
	end
	local teamCharacterCount = floorConfig.MemberNum
	if teamCharacterCount == 0 then
		self.nItemGuideId = 0
		local foreach = function(data)
			if data.ActivityId == self.nActId and data.GuideType == GameEnum.TowerDefGuideType.Item and floorConfig.ItemID == data.ObjectId then
				self.nItemGuideId = data.Id
			end
		end
		ForEachTableLine(DataTable.TowerDefenseGuide, foreach)
	end
	local go_add = self._mapNode.special_item.transform:Find("img_add")
	local go_icon = self._mapNode.special_item.transform:Find("img_icon")
	local go_none = self._mapNode.special_item.transform:Find("img_none")
	go_add.gameObject:SetActive(false)
	go_none.gameObject:SetActive(false)
	go_icon.gameObject:SetActive(false)
	if teamCharacterCount == 0 then
		if self.nItemGuideId == nil or self.nItemGuideId == 0 then
			go_none.gameObject:SetActive(true)
		else
			local guideConfig = ConfigTable.GetData("TowerDefenseGuide", self.nItemGuideId)
			local itemConfig = ConfigTable.GetData("TowerDefenseItem", guideConfig.ObjectId)
			if itemConfig ~= nil then
				self:SetPngSprite(go_icon:GetComponent("Image"), itemConfig.CardIcon)
			end
			go_icon.gameObject:SetActive(true)
		end
	elseif self.nItemGuideId == nil or self.nItemGuideId == 0 then
		go_add.gameObject:SetActive(true)
	else
		local guideConfig = ConfigTable.GetData("TowerDefenseGuide", self.nItemGuideId)
		local itemConfig = ConfigTable.GetData("TowerDefenseItem", guideConfig.ObjectId)
		if itemConfig ~= nil then
			self:SetPngSprite(go_icon:GetComponent("Image"), itemConfig.CardIcon)
		end
		go_icon.gameObject:SetActive(true)
	end
end
function TowerDefenseLevelDetailCtrl:GoToPlay(callback)
	local floorConfig = ConfigTable.GetData("TowerDefenseFloor", self.levelConfig.FloorId)
	if floorConfig == nil then
		return
	end
	if floorConfig.MemberNum ~= 0 and #self.tbCharGuideId < floorConfig.MemberNum then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("TowerDef_Team_Tips"))
		return
	end
	local tbChar = {}
	local itemId = 0
	if self.nItemGuideId ~= 0 then
		local itemGuidConfig = ConfigTable.GetData("TowerDefenseGuide", self.nItemGuideId)
		if itemGuidConfig ~= nil then
			itemId = itemGuidConfig.ObjectId
		end
	end
	for index, id in ipairs(self.tbCharGuideId) do
		local charGuidConfig = ConfigTable.GetData("TowerDefenseGuide", id)
		if charGuidConfig ~= nil then
			table.insert(tbChar, charGuidConfig.ObjectId)
		end
	end
	local sItem = tostring(itemId)
	local sChar = ""
	for index, value in ipairs(tbChar) do
		sChar = sChar .. tostring(value)
		if index ~= #tbChar then
			sChar = sChar .. ","
		end
	end
	local param = {}
	table.insert(param, sItem)
	table.insert(param, sChar)
	local cb = function()
		if callback ~= nil then
			callback()
		end
		self.TowerDefenseData.TowerDefenseLevelData:InitData(self.nLevelId, clone(tbChar), clone(itemId), self.nActId)
		CS.AdventureModuleHelper.EnterTowerDefenseLevel(self.levelConfig.FloorId, param)
		NovaAPI.EnterModule("AdventureModuleScene", true, 27)
		EventManager.Hit(EventId.OpenPanel, PanelId.TowerDefenseHUD)
	end
	self.TowerDefenseData:RequestEnterLevel(self.nLevelId, tbChar, itemId, cb)
	self.TowerDefenseData:SetLevelTeamData(self.nLevelId, self.tbCharGuideId, self.nItemGuideId)
end
function TowerDefenseLevelDetailCtrl:EnterTeamEditorPanel()
	self._mapNode.teamCtrl.gameObject:SetActive(true)
	self.bInEditorPanel = true
end
function TowerDefenseLevelDetailCtrl:CloseTeamEditorPanel()
	self._mapNode.teamCtrl.gameObject:SetActive(false)
	self.bInEditorPanel = false
end
function TowerDefenseLevelDetailCtrl:OnBtnClick_MonsterInfo()
	EventManager.Hit("OpenTowerDefenseMonsterInfo", self.levelConfig.Id)
end
function TowerDefenseLevelDetailCtrl:OnBtnClick_RewardInfo()
end
function TowerDefenseLevelDetailCtrl:OnBtnClick_Reward(btn, index)
	local itemData = self.tbReward[index]
	if itemData ~= nil then
		UTILS.ClickItemGridWithTips(itemData.nId, btn.transform, false, true, false)
	end
end
function TowerDefenseLevelDetailCtrl:OnBtnClick_Go()
	if self.levelConfig.Skip then
		local CancelCallback = function()
			local tbChar = {}
			local itemId = 0
			if self.nItemGuideId ~= 0 then
				local itemGuidConfig = ConfigTable.GetData("TowerDefenseGuide", self.nItemGuideId)
				if itemGuidConfig ~= nil then
					itemId = itemGuidConfig.ObjectId
				end
			end
			for index, id in ipairs(self.tbCharGuideId) do
				local charGuidConfig = ConfigTable.GetData("TowerDefenseGuide", id)
				if charGuidConfig ~= nil then
					table.insert(tbChar, charGuidConfig.ObjectId)
				end
			end
			local cb = function()
				self:UpdateQuestInfo()
				self:UpdateItem()
			end
			self.TowerDefenseData:SkipLevel(self.nLevelId, tbChar, itemId, cb)
		end
		local ConfirmCallback = function()
			self:GoToPlay()
		end
		local data = {
			nType = AllEnum.MessageBox.Confirm,
			sTitle = ConfigTable.GetUIText("TowerDef_SkipTitle"),
			sContent = ConfigTable.GetUIText("TowerDef_SkipTips"),
			sContentSub = orderedFormat(ConfigTable.GetUIText("TowerDef_SkipSubTips"), self.levelConfig.LevelName),
			sConfirm = ConfigTable.GetUIText("TowerDef_Skip_Go"),
			sCancel = ConfigTable.GetUIText("TowerDef_Skip"),
			callbackConfirmAfterClose = ConfirmCallback,
			callbackCancel = CancelCallback,
			bCloseNoHandler = true
		}
		EventManager.Hit(EventId.OpenMessageBox, data)
	else
		self:GoToPlay()
	end
end
function TowerDefenseLevelDetailCtrl:OnBtnClick_EditorTeam()
	if self.bInEditorPanel then
		return
	end
	EventManager.Hit(EventId.TemporaryBlockInput, 0.8)
	self._mapNode.animator:Play("TowerDefenseLevelDetailPanel_switch_in")
	self:EnterTeamEditorPanel()
	self._mapNode.TopBar.gameObject:SetActive(false)
	self._mapNode.teamCtrl:SetData(self.nActId, self.levelConfig.Id, self.tbCharGuideId, self.nItemGuideId)
end
function TowerDefenseLevelDetailCtrl:OnBtnClick_Close()
	EventManager.Hit(EventId.ClosePanel, PanelId.TowerDefenseLevelDetailPanel)
end
function TowerDefenseLevelDetailCtrl:OnEvent_UpdateCharData(tbCharGuideId)
	self.tbCharGuideId = tbCharGuideId
	self:UpdateCharacter()
end
function TowerDefenseLevelDetailCtrl:OnEvent_UpdateItemData(nItemGuideId)
	self.nItemGuideId = nItemGuideId
	self:UpdateSpecialItem()
end
function TowerDefenseLevelDetailCtrl:OnEvent_UpdateTeamEditorPanelClose()
	EventManager.Hit(EventId.TemporaryBlockInput, 0.8)
	self._mapNode.animator:Play("TowerDefenseLevelDetailPanel_switch_out")
	self:AddTimer(1, 0.8, function()
		self:CloseTeamEditorPanel()
	end, true, true, true)
	self._mapNode.TopBar.gameObject:SetActive(true)
end
function TowerDefenseLevelDetailCtrl:OnEvent_Go()
	local cb = function()
		local floorConfig = ConfigTable.GetData("TowerDefenseFloor", self.levelConfig.FloorId)
		if floorConfig == nil then
			return
		end
		if floorConfig.MemberNum ~= 0 and #self.tbCharGuideId < floorConfig.MemberNum then
			return
		end
		self:CloseTeamEditorPanel()
		self._mapNode.TopBar.gameObject:SetActive(true)
	end
	self:GoToPlay(cb)
end
return TowerDefenseLevelDetailCtrl
