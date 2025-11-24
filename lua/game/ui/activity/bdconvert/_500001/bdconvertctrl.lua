local BdConvertCtrl = class("BdConvertCtrl", BaseCtrl)
local LocalSettingData = require("GameCore.Data.LocalSettingData")
local Actor2DManager = require("Game.Actor2D.Actor2DManager")
local barMinX = -378
local barMaxX = 0
BdConvertCtrl._mapNodeConfig = {
	TopBar = {
		sNodeName = "TopBarPanel",
		sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"
	},
	txt_quest = {
		sComponentName = "TMP_Text",
		sLanguageId = "BdConvert_QuestTitle"
	},
	redDotQuest = {},
	btn_quest = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Quest"
	},
	txt_mainProcess = {sComponentName = "TMP_Text"},
	imgMainBarFill = {
		sComponentName = "RectTransform"
	},
	Actor2D = {
		sNodeName = "----Actor2D----"
	},
	btn_starTower = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_GoStarTower"
	},
	anim = {
		sNodeName = "----SafeAreaRoot----",
		sComponentName = "Animator"
	},
	bg_anim = {sNodeName = "----BG----", sComponentName = "Animator"},
	imgBgLevelSelect = {
		sNodeName = "----Actor2D----",
		sComponentName = "RawImage"
	},
	trActor2D_PNG = {
		sNodeName = "----Actor2D_PNG----",
		sComponentName = "Transform"
	},
	cell = {},
	ListContent = {
		sComponentName = "RectTransform"
	},
	ListCanvasGroup = {
		sNodeName = "ListContent",
		sComponentName = "CanvasGroup"
	},
	txt_starTower = {
		sComponentName = "TMP_Text",
		sLanguageId = "BdConvert_GoToStarTower"
	}
}
BdConvertCtrl._mapEventConfig = {
	BdConvertQuestUpdate = "InitQuest",
	BdConvert_JumpToBuildPanel = "OnEvent_JumpTo",
	[EventId.UIBackConfirm] = "OnEvent_BackHome",
	[EventId.UIHomeConfirm] = "OnEvent_Home"
}
BdConvertCtrl._mapRedDotConfig = {
	[RedDotDefine.Activity_BdConvert_AllQuest] = {
		sNodeName = "redDotQuest"
	}
}
function BdConvertCtrl:Awake()
	local param = self:GetPanelParam()
	if type(param) == "table" then
		self.nActId = param[1]
	end
	self.actData = PlayerData.Activity:GetActivityDataById(self.nActId)
	self.bInAnim_In = false
end
function BdConvertCtrl:OnEnable()
	if self._panel.bPlayedAnim_In then
		EventManager.Hit(EventId.BlockInput, true)
		self._mapNode.anim:Play("BdConVertPanel_in_02")
		self._mapNode.bg_anim:Play("BdConvertPanel_Bg_out_02")
		self.bInAnim_In = true
		self:AddTimer(1, 0.7, function()
			self.bInAnim_In = false
			EventManager.Hit(EventId.BlockInput, false)
		end, true, true, true)
	else
		EventManager.Hit(EventId.BlockInput, true)
		self._mapNode.anim:Play("BdConVertPanel_in_01")
		self._mapNode.bg_anim:Play("BdConvertPanel_Bg_in_01")
		self.bInAnim_In = true
		self:AddTimer(1, 0.67, function()
			self.bInAnim_In = false
			EventManager.Hit(EventId.BlockInput, false)
		end, true, true, true)
	end
	self._panel.bPlayedAnim_In = true
	local bUseL2D = LocalSettingData.mapData.UseLive2D
	self._mapNode.imgBgLevelSelect.transform.localScale = bUseL2D == true and Vector3.one or Vector3.zero
	self._mapNode.trActor2D_PNG.localScale = bUseL2D == true and Vector3.zero or Vector3.one
	if bUseL2D == true then
		Actor2DManager.SetBoardNPC2D(self:GetPanelId(), self._mapNode.imgBgLevelSelect, 9102)
	else
		Actor2DManager.SetBoardNPC2D_PNG(self._mapNode.trActor2D_PNG, self:GetPanelId(), 9102)
	end
	local bResult = self.actData:CheckBuildsData()
	if bResult then
		self:UpdateOptionList()
	else
		EventManager.Hit(EventId.BlockInput, true)
		self.actData:RequestAllBuildData(function()
			if not self.bInAnim_In then
				EventManager.Hit(EventId.BlockInput, false)
			end
			self:UpdateOptionList()
		end)
	end
	self:InitQuest()
end
function BdConvertCtrl:OnDisable()
	Actor2DManager.UnsetBoardNPC2D()
	if self.GridIns ~= nil then
		for _, ctrl in pairs(self.GridIns) do
			self:UnbindCtrlByNode(ctrl)
		end
	end
	self.GridIns = {}
	if self.tbListCtrl ~= nil then
		for _, ctrl in pairs(self.tbListCtrl) do
			self:UnbindCtrlByNode(ctrl)
		end
	end
	self.tbListCtrl = {}
end
function BdConvertCtrl:UpdateOptionList()
	self.bdConfig = self.actData:GetBdConvertConfig()
	self.optionList = self.bdConfig.OptionList
	local sort = function(a, b)
		local contentA_Data = self.actData:GetBdDataBy(a)
		local contentB_Data = self.actData:GetBdDataBy(b)
		local bFinish_A = contentA_Data.nCurSub == contentA_Data.nMaxSub
		local bFinish_B = contentB_Data.nCurSub == contentB_Data.nMaxSub
		if bFinish_A and not bFinish_B then
			return false
		elseif not bFinish_A and bFinish_B then
			return true
		end
		return a < b
	end
	table.sort(self.optionList, sort)
	self.tbGridSize = {}
	for _, optionId in ipairs(self.optionList) do
		local contentCfg = ConfigTable.GetData("BdConvertContent", optionId)
		if contentCfg ~= nil then
			local height = 0
			if #contentCfg.ConvertConditionList >= 3 then
				height = 360
			else
				height = 310
			end
			table.insert(self.tbGridSize, height)
		end
	end
	delChildren(self._mapNode.ListContent.gameObject)
	NovaAPI.SetCanvasGroupAlpha(self._mapNode.ListCanvasGroup, 0)
	if self.tbListCtrl ~= nil then
		for _, ctrl in pairs(self.tbListCtrl) do
			self:UnbindCtrlByNode(ctrl)
		end
	end
	self.tbListCtrl = {}
	self.GridIns = {}
	for _, opId in ipairs(self.optionList) do
		local go = instantiate(self._mapNode.cell, self._mapNode.ListContent)
		local ctrl = self:BindCtrlByNode(go, "Game.UI.Activity.BdConvert._500001.BdConvertCellCtrl")
		ctrl:SetData(self.nActId, opId)
		table.insert(self.tbListCtrl, ctrl)
		go:SetActive(true)
	end
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		NovaAPI.SetCanvasGroupAlpha(self._mapNode.ListCanvasGroup, 1)
		CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self._mapNode.ListContent)
	end
	cs_coroutine.start(wait)
end
function BdConvertCtrl:InitQuest()
	local allCount = self.actData:GetAllQuestCount()
	local receivedCount = self.actData:GetAllReceivedCount()
	NovaAPI.SetTMPText(self._mapNode.txt_mainProcess, receivedCount .. "/" .. allCount)
	self._mapNode.imgMainBarFill.anchoredPosition = Vector2(barMinX + (barMaxX - barMinX) * (receivedCount / allCount), self._mapNode.imgMainBarFill.anchoredPosition.y)
end
function BdConvertCtrl:OnBtnClick_Quest()
	EventManager.Hit(EventId.OpenPanel, PanelId.BdConvertQuestPanel, self.nActId)
end
function BdConvertCtrl:OnBtnClick_GoStarTower()
	EventManager.Hit(EventId.OpenPanel, PanelId.LevelMenu, 2)
end
function BdConvertCtrl:OnEvent_JumpTo(nOptionId)
	self._mapNode.bg_anim:Play("BdConvertPanel_Bg_in_02")
	self._mapNode.anim:Play("BdConVertPanel_out_01")
	EventManager.Hit(EventId.TemporaryBlockInput, 0.17)
	self:AddTimer(1, 0.17, function()
		EventManager.Hit(EventId.OpenPanel, PanelId.BdConvertBuildPanel, self.nActId, nOptionId)
	end, true, true, true)
end
function BdConvertCtrl:OnEvent_BackHome(nPanelId)
	if nPanelId == PanelId.BdConvertPanel then
		self._mapNode.anim:Play("BdConVertPanel_out_02")
		self._mapNode.bg_anim:Play("BdConvertPanel_Bg_out_01")
		EventManager.Hit(EventId.TemporaryBlockInput, 0.23)
		self:AddTimer(1, 0.23, function()
			EventManager.Hit(EventId.ClosePanel, PanelId.BdConvertPanel)
		end, true, true, true)
	end
end
function BdConvertCtrl:OnEvent_Home(nPanelId)
	if nPanelId == PanelId.BdConvertPanel then
		PanelManager.Home()
	end
end
return BdConvertCtrl
