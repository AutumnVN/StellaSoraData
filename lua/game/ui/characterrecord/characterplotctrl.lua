local BaseCtrl = require("GameCore.UI.BaseCtrl")
local CharacterPlotCtrl = class("CharacterPlotCtrl", BaseCtrl)
local LayoutRebuilder = CS.UnityEngine.UI.LayoutRebuilder
CharacterPlotCtrl._mapNodeConfig = {
	loopsv = {
		sNodeName = "sv",
		sComponentName = "LoopScrollView"
	}
}
CharacterPlotCtrl._mapEventConfig = {
	[EventId.CharRelatePanelAdvance] = "OnEvent_PanelAdvance",
	Enter_CharPlot = "OnEvent_Enter_CharPlot",
	[EventId.TransAnimOutClear] = "OnEvent_TransAnimOutClear",
	RefreshCharPlotContent = "OnEvent_RefreshCharPlotContent"
}
function CharacterPlotCtrl:Awake()
end
function CharacterPlotCtrl:OnEnable()
end
function CharacterPlotCtrl:OnDisable()
end
function CharacterPlotCtrl:OnDestroy()
end
function CharacterPlotCtrl:RegisterRedDot(plotId, redDot, bRebind)
	RedDotManager.RegisterNode(RedDotDefine.Role_AffinityPlotItem, {
		self.characterId,
		plotId
	}, redDot, nil, nil, bRebind)
end
function CharacterPlotCtrl:RefreshContent(nCharId)
	self.tbReward = {}
	self:RefreshPlotList(nCharId)
	PlayerData.Phone:TrySendAddressListReq()
end
function CharacterPlotCtrl:RefreshPlotList(nCharId)
	self.characterId = nCharId
	self.PlotData = PlayerData.Char:GetCharPlotDataById(self.characterId)
	table.sort(self.PlotData, function(a, b)
		return a.Id < b.Id
	end)
	if self._mapNode ~= nil then
		self._mapNode.loopsv:Init(#self.PlotData, self, self.RefreshPlotItem)
	end
end
function CharacterPlotCtrl:RefreshPlotItem(go)
	local index = tonumber(go.name) + 1
	local data = self.PlotData[index]
	if data == nil then
		go:SetActive(false)
		return
	end
	local txtLockStr = ""
	local bLock = false
	local favourLevel = 0
	local favourData = PlayerData.Char:GetAdvanceLevelTable(self.curCharId)
	favourLevel = favourData ~= nil and favourData.Level or 0
	bLock, txtLockStr = PlayerData.Char:IsPlotUnlock(data.Id, self.characterId)
	local goLock = go.transform:Find("btnGrid/Lock")
	local root = go.transform:Find("btnGrid/AnimRoot")
	goLock.gameObject:SetActive(bLock)
	root.gameObject:SetActive(not bLock)
	local rewardData = decodeJson(data.Rewards)
	local itemId, itemCount
	for id, count in pairs(rewardData) do
		itemId = tonumber(id)
		itemCount = tonumber(count)
	end
	if bLock then
		local txtLock = goLock.transform:Find("txtLock"):GetComponent("TMP_Text")
		NovaAPI.SetTMPText(txtLock, txtLockStr)
		local txtLockReward = goLock:Find("txtLockReward"):GetComponent("TMP_Text")
		NovaAPI.SetTMPText(txtLockReward, ConfigTable.GetUIText("CharacterRelation_Plot_Reward"))
		local goReward = goLock:Find("txtLockReward/goJade")
		if itemId ~= nil then
			local imgReward = goReward:Find("goJadeImg/imgJade"):GetComponent("Image")
			self:SetPngSprite(imgReward, ConfigTable.GetData_Item(itemId).Icon)
		end
		if itemCount ~= nil then
			local txtRewardCount = goReward:Find("txtCount"):GetComponent("TMP_Text")
			NovaAPI.SetTMPText(txtRewardCount, "\195\151" .. itemCount)
			LayoutRebuilder:ForceRebuildLayoutImmediate(txtRewardCount.transform)
			LayoutRebuilder:ForceRebuildLayoutImmediate(goReward)
		end
		local hasCG = nil ~= CacheTable.GetData("_CharacterCG", data.Id)
		local goFavorCg = goReward:Find("goFavorCg")
		goFavorCg.gameObject:SetActive(hasCG)
		local txtFavorCg = goFavorCg:Find("txtFavorCg"):GetComponent("TMP_Text")
		NovaAPI.SetTMPText(txtFavorCg, ConfigTable.GetUIText("CharacterRelation_CG_Reward"))
		return
	end
	local txtLevelIndex = root:Find("txtLevelIndex"):GetComponent("TMP_Text")
	local txtLevelName = root:Find("txtLevelName"):GetComponent("TMP_Text")
	local btnSelect = root:Find("btnSelect"):GetComponent("UIButton")
	local imgLevel = root:Find("goAvg/imgLevel"):GetComponent("Image")
	local goReward = root:Find("goJade")
	local redDot = root:Find("RedDot")
	NovaAPI.SetTMPText(txtLevelIndex, orderedFormat(ConfigTable.GetUIText("Plot_Index"), index))
	NovaAPI.SetTMPText(txtLevelName, data.Name)
	if data.PicSource ~= "" then
		self:SetPngSprite(imgLevel, data.PicSource)
	end
	btnSelect.onClick:AddListener(function()
		self.curSelectIndex = index
		self:OnBtnClick_Select()
	end)
	local bGetReward = PlayerData.Char:IsCharPlotFinish(self.characterId, data.Id)
	local hasCG = nil ~= CacheTable.GetData("_CharacterCG", data.Id)
	goReward.gameObject:SetActive(not bGetReward or hasCG)
	self.tbReward[index] = {nId = itemId, bReceive = bGetReward}
	if itemId ~= nil then
		local imgReward = goReward:Find("goJadeImg/imgJade"):GetComponent("Image")
		self:SetPngSprite(imgReward, ConfigTable.GetData_Item(itemId).Icon)
		imgReward.gameObject:SetActive(not bGetReward)
	end
	if itemCount ~= nil then
		local txtRewardCount = goReward:Find("txtCount"):GetComponent("TMP_Text")
		NovaAPI.SetTMPText(txtRewardCount, "\195\151" .. itemCount)
		txtRewardCount.gameObject:SetActive(not bGetReward)
		LayoutRebuilder:ForceRebuildLayoutImmediate(txtRewardCount.transform)
		LayoutRebuilder:ForceRebuildLayoutImmediate(goReward)
	end
	local goFavorCg = goReward:Find("goFavorCg")
	goFavorCg.gameObject:SetActive(hasCG)
	self:RegisterRedDot(data.Id, redDot, true)
end
function CharacterPlotCtrl:ShowReward()
	local mapPlot = self.PlotData[self.curSelectIndex]
	local mapMsgData = self.PlotRewardData
	local rewardFunc = function()
		local bHasReward = mapMsgData and mapMsgData.Props and #mapMsgData.Props > 0
		local tbItem = {}
		if bHasReward then
			local sRewardDisplay = mapPlot.Rewards
			local tbRewardDisplay = decodeJson(sRewardDisplay)
			for k, v in pairs(tbRewardDisplay) do
				table.insert(tbItem, {
					Tid = tonumber(k),
					Qty = v,
					rewardType = AllEnum.RewardType.First
				})
			end
			UTILS.OpenReceiveByDisplayItem(tbItem, mapMsgData)
		end
	end
	if nil ~= CacheTable.GetData("_CharacterCG", mapPlot.Id) then
		local tbRewardList = {}
		table.insert(tbRewardList, {
			nId = CacheTable.GetData("_CharacterCG", mapPlot.Id),
			nCharId = self.characterId,
			bNew = true,
			tbItemList = {},
			bCG = true,
			callBack = rewardFunc
		})
		EventManager.Hit(EventId.OpenPanel, PanelId.ReceiveSpecialReward, tbRewardList)
	else
		rewardFunc()
	end
	self.PlotRewardData = nil
end
function CharacterPlotCtrl:OnBtnClick_Select()
	local data = self.PlotData[self.curSelectIndex]
	EventManager.Hit(EventId.OpenPanel, PanelId.CharPlot, data, self.tbReward, self.curSelectIndex)
end
function CharacterPlotCtrl:OnBtnClick_EnterPlot()
	if self.PlotData == nil then
		return
	end
	local mapPlot = self.PlotData[self.curSelectIndex]
	if mapPlot.ConnectChatId ~= 0 and not PlayerData.Phone:CheckChatComplete(mapPlot.ConnectChatId) then
		EventManager.Hit(EventId.OpenPanel, PanelId.PhonePopUp, mapPlot.ConnectChatId, true)
		return
	end
	local bGetReward = PlayerData.Char:IsCharPlotFinish(self.characterId, mapPlot.Id)
	local finishCallback = function(nCharId)
		if not bGetReward then
			EventManager.Hit("RefreshCharPlotContent", nCharId)
		else
			EventManager.Hit(EventId.ClosePanel, PanelId.PureAvgStory)
		end
	end
	PlayerData.Char:EnterCharPlotAvg(self.characterId, mapPlot.Id, finishCallback, true)
end
function CharacterPlotCtrl:OnBtnClick_Reward(btn)
	if self.tbReward ~= nil then
		local nTid = self.tbReward.nId
		UTILS.ClickItemGridWithTips(nTid, btn.transform, false, true, false)
	end
end
function CharacterPlotCtrl:OnEvent_Enter_CharPlot(...)
	EventManager.Hit(EventId.ClosePanel, PanelId.CharPlot)
	self:OnBtnClick_EnterPlot()
end
function CharacterPlotCtrl:OnEvent_TransAnimOutClear(...)
end
function CharacterPlotCtrl:OnEvent_RefreshCharPlotContent(nCharId)
	self:RefreshContent(nCharId)
end
return CharacterPlotCtrl
