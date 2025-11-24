local BdConvertBuildCtrl = class("BdConvertBuildCtrl", BaseCtrl)
local LocalData = require("GameCore.Data.LocalData")
local newDayTime = UTILS.GetDayRefreshTimeOffset()
BdConvertBuildCtrl._mapNodeConfig = {
	TopBar = {
		sNodeName = "TopBarPanel",
		sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"
	},
	BuildListContent = {},
	BuildListContent_Empty = {},
	txt_empty = {
		sComponentName = "TMP_Text",
		sLanguageId = "BdConvert_BuildEmpty"
	},
	BuildList = {
		sComponentName = "LoopScrollView"
	},
	btn_sort_time = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_SortTime"
	},
	btn_sort_score = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_SortScore"
	},
	img_icon = {
		sNodeName = "img_icon_detail",
		sComponentName = "Image"
	},
	txt_title = {sComponentName = "TMP_Text"},
	txt_reward = {sComponentName = "TMP_Text"},
	sv = {},
	svItem = {
		sComponentName = "LoopScrollView"
	},
	txt_SubmitTips = {
		sComponentName = "TMP_Text",
		sLanguageId = "BdConvert_BuildTips"
	},
	txt_srot_timeTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "RoguelikeBuild_Manage_SortTime"
	},
	txt_srot_ScoreTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "RoguelikeBuild_Manage_SortScore"
	},
	txt_Allselect = {sComponentName = "TMP_Text"},
	btn_submit = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Submit"
	},
	txt_submit = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "BdConvert_Submit"
	},
	btn_submit_none = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Submit"
	},
	BdConvertFinishPanel = {
		sCtrlName = "Game.UI.Activity.BdConvert._500001.BdConvertFinishCtrl"
	},
	bg_anim = {sNodeName = "----BG----", sComponentName = "Animator"},
	anim = {
		sNodeName = "SafeAreaRoot",
		sComponentName = "Animator"
	},
	txt_detailTips = {
		sComponentName = "TMP_Text",
		sLanguageId = "BdConvert_DesTips"
	}
}
BdConvertBuildCtrl._mapEventConfig = {
	BdConvert_ShowReward = "OnEvent_ShowReward",
	BdConvert_FinishPanelClose = "OnEvent_CloseReward",
	[EventId.UIBackConfirm] = "OnEvent_BackHome",
	[EventId.UIHomeConfirm] = "OnEvent_Home"
}
BdConvertBuildCtrl._mapRedDotConfig = {}
local SortType = {Time = 1, Score = 2}
local SortOrder = {Descending = true, Ascending = false}
local BtnTextColor = {
	[true] = Color(0.3288888888888889, 0.43555555555555553, 0.5422222222222223, 1),
	[false] = Color(0.7288888888888889, 0.8, 0.8711111111111111, 1)
}
function BdConvertBuildCtrl:Awake()
	self._mapNode.BdConvertFinishPanel.gameObject:SetActive(false)
	local param = self:GetPanelParam()
	if type(param) == "table" then
		self.nActId = param[1]
		self.nOptionId = param[2]
	end
	self.actData = PlayerData.Activity:GetActivityDataById(self.nActId)
	self.nSortype = SortType.Score
	self.nSortOrder = SortOrder.Ascending
	self.tbSelected = {}
end
function BdConvertBuildCtrl:OnEnable()
	EventManager.Hit(EventId.TemporaryBlockInput, 0.6)
	self.tbItemIns = {}
	self.mapListItemCtrl = {}
	self:InitSort()
	self:InitData()
end
function BdConvertBuildCtrl:OnDisable()
	if self.tbItemIns ~= nil then
		for _, ctrl in pairs(self.tbItemIns) do
			self:UnbindCtrlByNode(ctrl)
		end
	end
	if self.mapListItemCtrl ~= nil then
		for _, ctrl in pairs(self.mapListItemCtrl) do
			self:UnbindCtrlByNode(ctrl)
		end
	end
end
function BdConvertBuildCtrl:OnDestroy()
end
function BdConvertBuildCtrl:InitData()
	self._tbAllBuild = self.actData:GetAllBuildByOpId(self.nOptionId)
	self.bdCfg = self.actData:GetBdConvertConfig()
	self.contentCfg = ConfigTable.GetData("BdConvertContent", self.nOptionId)
	self.data = self.actData:GetBdDataBy(self.nOptionId)
	if self.data == nil then
		return
	end
	if self.contentCfg.Icon ~= "" then
		self:SetPngSprite(self._mapNode.img_icon, self.contentCfg.Icon)
	end
	self.tbItem = {}
	local tbReward = decodeJson(self.contentCfg.BasicReward)
	local tbTemp = {}
	for key, value in pairs(tbReward) do
		tbTemp[tonumber(key)] = tonumber(value)
	end
	for _, rewardId in ipairs(self.contentCfg.BasicRewardPreview) do
		table.insert(self.tbItem, {
			itemId = rewardId,
			itemCount = tbTemp[rewardId]
		})
	end
	self._mapNode.svItem:Init(#self.tbItem, self, self.OnRewardItemGridRefresh, self.OnGridBtnClick)
	NovaAPI.SetTMPText(self._mapNode.txt_title, self.contentCfg.Des)
	NovaAPI.SetTMPText(self._mapNode.txt_reward, ConfigTable.GetUIText("BdConvert_RewardTitle") .. " " .. self.data.nCurSub .. "/" .. self.data.nMaxSub)
	local tbTarget = {}
	for i = 1, 5 do
		local target = self._mapNode.sv.transform:Find("Viewport/Content/target" .. i)
		target.gameObject:SetActive(false)
		table.insert(tbTarget, target)
	end
	for index, optionId in ipairs(self.contentCfg.ConvertConditionList) do
		local txt_target = tbTarget[index]:Find("txt_target"):GetComponent("TMP_Text")
		local targetCfg = ConfigTable.GetData("BdConvertCondition", optionId)
		if targetCfg ~= nil then
			NovaAPI.SetTMPText(txt_target, targetCfg.RequestDes)
			tbTarget[index].gameObject:SetActive(true)
		end
	end
	CS.UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self._mapNode.sv.transform:Find("Viewport/Content"):GetComponent("RectTransform"))
	self:RefreshList()
end
function BdConvertBuildCtrl:OnTargetGridRefresh(goGrid, nIndex)
	local nDataIndex = nIndex + 1
	local txt_target = goGrid.transform:Find("txt_target"):GetComponent("TMP_Text")
	local targetId = self.contentCfg.ConvertConditionList[nDataIndex]
	local targetCfg = ConfigTable.GetData("BdConvertCondition", targetId)
	if targetCfg == nil then
		return
	end
	NovaAPI.SetTMPText(txt_target, targetCfg.RequestDes)
end
function BdConvertBuildCtrl:OnRewardItemGridRefresh(goGrid, nIndex)
	local nDataIndex = nIndex + 1
	local itemId = self.tbItem[nDataIndex].itemId
	local goItem = goGrid.transform:Find("btnGrid/AnimRoot/tcItem").gameObject
	local instanceId = goItem:GetInstanceID()
	if self.tbItemIns[instanceId] == nil then
		self.tbItemIns[instanceId] = self:BindCtrlByNode(goItem, "Game.UI.TemplateEx.TemplateItemCtrl")
	end
	local bGet = self.data.nCurSub == self.data.nMaxSub
	self.tbItemIns[instanceId]:SetItem(itemId, nil, self.tbItem[nDataIndex].itemCount, nil, bGet)
end
function BdConvertBuildCtrl:OnGridBtnClick(goGrid, nIndex)
	local nDataIndex = nIndex + 1
	local itemId = self.tbItem[nDataIndex].itemId
	UTILS.ClickItemGridWithTips(itemId, goGrid.transform, true, false, false)
end
function BdConvertBuildCtrl:InitSort()
	NovaAPI.SetTMPColor(self._mapNode.txt_srot_timeTitle, BtnTextColor[self.nSortype == SortType.Time])
	NovaAPI.SetTMPColor(self._mapNode.txt_srot_ScoreTitle, BtnTextColor[self.nSortype == SortType.Score])
	self._mapNode.btn_sort_score.transform:Find("AnimRoot/btn_AsceIcon"):GetComponent("Button").interactable = self.nSortype == SortType.Score and self.nSortOrder == SortOrder.Ascending
	self._mapNode.btn_sort_score.transform:Find("AnimRoot/btn_DescIcon"):GetComponent("Button").interactable = self.nSortype == SortType.Score and self.nSortOrder == SortOrder.Descending
	self._mapNode.btn_sort_time.transform:Find("AnimRoot/btn_AsceIcon"):GetComponent("Button").interactable = self.nSortype == SortType.Time and self.nSortOrder == SortOrder.Ascending
	self._mapNode.btn_sort_time.transform:Find("AnimRoot/btn_DescIcon"):GetComponent("Button").interactable = self.nSortype == SortType.Time and self.nSortOrder == SortOrder.Descending
end
function BdConvertBuildCtrl:OnBtnClick_AAA()
end
function BdConvertBuildCtrl:OnEvent_AAA()
end
function BdConvertBuildCtrl:RefreshList()
	self._tbAllBuild = self.actData:GetAllBuildByOpId(self.nOptionId)
	if #self._tbAllBuild == 0 then
		self._mapNode.BuildListContent:SetActive(false)
		self._mapNode.BuildListContent_Empty:SetActive(true)
		self._mapNode.btn_submit_none.gameObject:SetActive(true)
		self._mapNode.btn_submit.gameObject:SetActive(false)
		NovaAPI.SetTMPText(self._mapNode.txt_Empty, ConfigTable.GetUIText("RoguelikeBuild_Manage_EmptyList"))
		self:RerfeshSelected()
		return
	else
		self._mapNode.BuildListContent:SetActive(true)
		self._mapNode.btn_submit_none.gameObject:SetActive(false)
		self._mapNode.btn_submit.gameObject:SetActive(true)
	end
	self:SortBuildData()
	self._mapNode.BuildList:Init(#self._tbAllBuild, self, self.RefreshBuildGrid, self.OnBtnCal)
	self:RerfeshSelected()
end
function BdConvertBuildCtrl:RefreshBuildGrid(goGrid, gridIndex)
	local nIndex = gridIndex + 1
	local mapData = self._tbAllBuild[nIndex]
	if self.mapListItemCtrl[goGrid] == nil then
		self.mapListItemCtrl[goGrid] = self:BindCtrlByNode(goGrid, "Game.UI.Activity.BdConvert._500001.BdConvertBuildItemCtrl")
		self.mapListItemCtrl[goGrid]:Init(self)
	end
	self.mapListItemCtrl[goGrid]:RefreshGrid(mapData)
	local index = table.indexof(self.tbSelected, mapData)
	if 0 < index then
		self:RerfeshSelected()
	end
end
function BdConvertBuildCtrl:RerfeshSelected()
	EventManager.Hit("BdConvert_BuildCancleSelect")
	for index, data in ipairs(self.tbSelected) do
		EventManager.Hit("BdConvert_BuildRefreshIndex", data, index)
	end
	local str = string.format("<color=#0abec5>%s</color>/%s", #self.tbSelected, self.data.nMaxSub - self.data.nCurSub)
	NovaAPI.SetTMPText(self._mapNode.txt_Allselect, ConfigTable.GetUIText("BdConvert_Selected") .. " " .. str)
end
function BdConvertBuildCtrl:ClearSelectedData()
	self.tbSelected = {}
	self:RerfeshSelected()
end
function BdConvertBuildCtrl:SortBuildData()
	if self.nSortype == SortType.Time then
		local sortByTime = function(a, b)
			if self.nSortOrder == SortOrder.Descending then
				return a.nBuildId > b.nBuildId
			else
				return a.nBuildId < b.nBuildId
			end
		end
		table.sort(self._tbAllBuild, sortByTime)
	else
		local sortByScore = function(a, b)
			if self.nSortOrder == SortOrder.Descending then
				if a.nScore ~= b.nScore then
					return a.nScore > b.nScore
				else
					return a.nBuildId > b.nBuildId
				end
			elseif a.nScore ~= b.nScore then
				return a.nScore < b.nScore
			else
				return a.nBuildId > b.nBuildId
			end
		end
		table.sort(self._tbAllBuild, sortByScore)
	end
end
function BdConvertBuildCtrl:OnBtnClick_SortTime(btn)
	if self.nSortype == SortType.Time then
		self.nSortOrder = not self.nSortOrder
		self._mapNode.btn_sort_time.transform:Find("AnimRoot/btn_AsceIcon"):GetComponent("Button").interactable = self.nSortOrder == SortOrder.Ascending
		self._mapNode.btn_sort_time.transform:Find("AnimRoot/btn_DescIcon"):GetComponent("Button").interactable = self.nSortOrder == SortOrder.Descending
	else
		self.nSortype = SortType.Time
		self.nSortOrder = SortOrder.Descending
		self._mapNode.btn_sort_time.transform:Find("AnimRoot/btn_AsceIcon"):GetComponent("Button").interactable = false
		self._mapNode.btn_sort_time.transform:Find("AnimRoot/btn_DescIcon"):GetComponent("Button").interactable = true
		self._mapNode.btn_sort_score.transform:Find("AnimRoot/btn_AsceIcon"):GetComponent("Button").interactable = false
		self._mapNode.btn_sort_score.transform:Find("AnimRoot/btn_DescIcon"):GetComponent("Button").interactable = false
		NovaAPI.SetTMPColor(self._mapNode.txt_srot_timeTitle, BtnTextColor[self.nSortype == SortType.Time])
		NovaAPI.SetTMPColor(self._mapNode.txt_srot_ScoreTitle, BtnTextColor[self.nSortype == SortType.Score])
	end
	self:RefreshList()
end
function BdConvertBuildCtrl:OnBtnClick_SortScore(btn)
	if self.nSortype == SortType.Score then
		self.nSortOrder = not self.nSortOrder
		self._mapNode.btn_sort_score.transform:Find("AnimRoot/btn_AsceIcon"):GetComponent("Button").interactable = self.nSortOrder == SortOrder.Ascending
		self._mapNode.btn_sort_score.transform:Find("AnimRoot/btn_DescIcon"):GetComponent("Button").interactable = self.nSortOrder == SortOrder.Descending
	else
		self.nSortype = SortType.Score
		self.nSortOrder = SortOrder.Descending
		self._mapNode.btn_sort_score.transform:Find("AnimRoot/btn_AsceIcon"):GetComponent("Button").interactable = false
		self._mapNode.btn_sort_score.transform:Find("AnimRoot/btn_DescIcon"):GetComponent("Button").interactable = true
		self._mapNode.btn_sort_time.transform:Find("AnimRoot/btn_AsceIcon"):GetComponent("Button").interactable = false
		self._mapNode.btn_sort_time.transform:Find("AnimRoot/btn_DescIcon"):GetComponent("Button").interactable = false
		NovaAPI.SetTMPColor(self._mapNode.txt_srot_timeTitle, BtnTextColor[self.nSortype == SortType.Time])
		NovaAPI.SetTMPColor(self._mapNode.txt_srot_ScoreTitle, BtnTextColor[self.nSortype == SortType.Score])
	end
	self:RefreshList()
end
function BdConvertBuildCtrl:OnBtnClickGrid(nIdx, itemCtrl)
	local mapBuild = self._tbAllBuild[nIdx]
	if mapBuild.bLock then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("BdConvert_LockTips"))
		return
	end
	local index = table.indexof(self.tbSelected, itemCtrl._mapData)
	if index ~= nil and 0 < index then
		table.remove(self.tbSelected, index)
		self:RerfeshSelected()
		return
	end
	if #self.tbSelected >= self.data.nMaxSub - self.data.nCurSub then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("BdConvert_SelectedMaxTips"))
		return
	end
	table.insert(self.tbSelected, mapBuild)
	self:RerfeshSelected()
end
function BdConvertBuildCtrl:OpenBuildDes(nIdx, itemCtrl)
	local mapBuild = self._tbAllBuild[nIdx]
	EventManager.Hit(EventId.OpenPanel, PanelId.BdConvertBuildDetail, mapBuild, self.actData)
end
function BdConvertBuildCtrl:OnBuildGridLock(nIdx, itemCtrl)
	local mapBuild = self._tbAllBuild[nIdx]
	local callback = function()
		itemCtrl:SetLockState(mapBuild.bLock)
		self:RerfeshSelected()
	end
	self.actData:ChangeBuildLock(mapBuild.nBuildId, not mapBuild.bLock, callback)
end
function BdConvertBuildCtrl:OnBtnClick_Submit()
	if #self.tbSelected == 0 then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("BdConvert_SubmitNoneTips"))
		return
	end
	local bHasHighLevelBuild = false
	for _, mapBuild in ipairs(self.tbSelected) do
		if mapBuild.mapRank.Level >= self.contentCfg.DoubleCheckMinLevel then
			bHasHighLevelBuild = true
			break
		end
	end
	local tbBuildId = {}
	for _, buildData in ipairs(self.tbSelected) do
		table.insert(tbBuildId, buildData.nBuildId)
	end
	if bHasHighLevelBuild then
		local TipsTime = LocalData.GetPlayerLocalData("BdConvert_BuildTips_Time")
		local _tipDay = 0
		if TipsTime ~= nil then
			_tipDay = tonumber(TipsTime)
		end
		local curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
		local fixedTimeStamp = curTimeStamp + newDayTime * 3600
		local nYear = tonumber(os.date("!%Y", fixedTimeStamp))
		local nMonth = tonumber(os.date("!%m", fixedTimeStamp))
		local nDay = tonumber(os.date("!%d", fixedTimeStamp))
		local nowD = nYear * 366 + nMonth * 31 + nDay
		if nowD == _tipDay then
			self.actData:RequestSubmitBuild(self.nOptionId, tbBuildId)
			self:ClearSelectedData()
		else
			local isSelectAgain = false
			local confirmCallback = function()
				if isSelectAgain then
					local _curTimeStamp = CS.ClientManager.Instance.serverTimeStampWithTimeZone
					local _fixedTimeStamp = _curTimeStamp + newDayTime * 3600
					local _nYear = tonumber(os.date("!%Y", _fixedTimeStamp))
					local _nMonth = tonumber(os.date("!%m", _fixedTimeStamp))
					local _nDay = tonumber(os.date("!%d", _fixedTimeStamp))
					local _nowD = _nYear * 366 + _nMonth * 31 + _nDay
					LocalData.SetPlayerLocalData("BdConvert_BuildTips_Time", tostring(_nowD))
				end
				self:ClearSelectedData()
				self.actData:RequestSubmitBuild(self.nOptionId, tbBuildId)
			end
			local againCallback = function(isSelect)
				isSelectAgain = isSelect
			end
			local msg = {
				nType = AllEnum.MessageBox.Confirm,
				sContent = ConfigTable.GetUIText("BdConvert_CheckTips"),
				callbackConfirmAfterClose = confirmCallback,
				callbackAgain = againCallback
			}
			EventManager.Hit(EventId.OpenMessageBox, msg)
		end
	else
		self.actData:RequestSubmitBuild(self.nOptionId, tbBuildId)
		self:ClearSelectedData()
	end
end
function BdConvertBuildCtrl:OnEvent_ShowReward(tbItem, icon)
	if tbItem == nil or #tbItem == 0 then
		return
	end
	local tbItemData = {}
	for _, itemData in ipairs(tbItem) do
		table.insert(tbItemData, {
			id = itemData.Tid,
			count = itemData.Qty
		})
	end
	local callback = function()
		self:InitData()
		if self.data.nCurSub == self.data.nMaxSub then
			self:OnEvent_BackHome(PanelId.BdConvertBuildPanel)
		end
	end
	self._mapNode.BdConvertFinishPanel.gameObject:SetActive(true)
	self._mapNode.BdConvertFinishPanel:ShowReward(tbItemData, icon, callback)
end
function BdConvertBuildCtrl:OnEvent_CloseReward()
	self._mapNode.BdConvertFinishPanel.gameObject:SetActive(false)
end
function BdConvertBuildCtrl:OnEvent_BackHome(nPanelId)
	if nPanelId == PanelId.BdConvertBuildPanel then
		self._mapNode.anim:Play("BdConvertBuildPanel_out")
		self._mapNode.bg_anim:Play("BdConvertBuildPanel_Bg_out")
		EventManager.Hit(EventId.TemporaryBlockInput, 0.2)
		self:AddTimer(1, 0.2, function()
			EventManager.Hit(EventId.ClosePanel, PanelId.BdConvertBuildPanel)
		end, true, true, true)
	end
end
function BdConvertBuildCtrl:OnEvent_Home(nPanelId)
	if nPanelId == PanelId.BdConvertBuildPanel then
		PanelManager.Home()
	end
end
return BdConvertBuildCtrl
