local MallMonthlyCardCtrl = class("MallMonthlyCardCtrl", BaseCtrl)
MallMonthlyCardCtrl._mapNodeConfig = {
	btnBuy = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Buy"
	},
	txtBtnBuy = {
		sComponentName = "TMP_Text",
		sLanguageId = "Mall_Btn_Buy"
	},
	btnRule = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Rule"
	},
	cgBg = {
		sNodeName = "imgMonthlyBg",
		sComponentName = "CanvasGroup"
	},
	txtRemainDay = {sComponentName = "TMP_Text"},
	imgItem = {nCount = 3},
	imgItemIcon = {nCount = 3, sComponentName = "Image"},
	txtItemCount = {nCount = 3, sComponentName = "TMP_Text"},
	txtPrice = {sComponentName = "TMP_Text"},
	txtName = {
		sComponentName = "TMP_Text",
		sLanguageId = "Mall_MonthlyCard_Name"
	},
	txtTip1 = {
		sComponentName = "TMP_Text",
		sLanguageId = "Mall_MonthlyCard_BuyImmediately"
	},
	txtTip2 = {
		sComponentName = "TMP_Text",
		sLanguageId = "Mall_MonthlyCard_Daily"
	},
	txtTip3 = {
		sComponentName = "TMP_Text",
		sLanguageId = "Mall_MonthlyCard_UseTip"
	},
	txtTip4 = {
		sComponentName = "TMP_Text",
		sLanguageId = "Mall_MonthlyCard_LimitTime"
	},
	txtTip6 = {
		sComponentName = "TMP_Text",
		sLanguageId = "Mall_MonthlyCard_RuleDetail"
	}
}
MallMonthlyCardCtrl._mapEventConfig = {
	MallOrderClear = "OnEvent_OrderClear"
}
function MallMonthlyCardCtrl:Refresh()
	if self._panel.nCurTog ~= AllEnum.MallToggle.MonthlyCard then
		return
	end
	NovaAPI.SetCanvasGroupAlpha(self._mapNode.cgBg, 0)
	local callback = function(mapData)
		self.sId = mapData.Id
		self.bReceived = mapData.Received
		self.nRemaining = mapData.Remaining
		self:RefreshList()
		NovaAPI.SetCanvasGroupAlpha(self._mapNode.cgBg, 1)
	end
	PlayerData.Mall:SendMallMonthlyCardListReq(callback)
end
function MallMonthlyCardCtrl:RefreshList()
	local mapCfg = ConfigTable.GetData("MallMonthlyCard", self.sId)
	local sState = self.bReceived and ConfigTable.GetUIText("Mall_MonthlyCard_Received") or ConfigTable.GetUIText("Mall_MonthlyCard_Unreceived")
	NovaAPI.SetTMPText(self._mapNode.txtRemainDay, orderedFormat(ConfigTable.GetUIText("Mall_MonthlyCard_RemainDay"), self.nRemaining, sState))
	self:SetPngSprite(self._mapNode.imgItemIcon[1], ConfigTable.GetData_Item(mapCfg.BaseItemId).Icon2)
	NovaAPI.SetTMPText(self._mapNode.txtItemCount[1], mapCfg.BaseItemQty)
	NovaAPI.SetTMPText(self._mapNode.txtPrice, tostring(mapCfg.ShowPrice))
	local mapMonthlyCard = ConfigTable.GetData("MonthlyCard", mapCfg.MonthlyCardId * 100 + 1)
	self._mapNode.imgItem[2].gameObject:SetActive(mapMonthlyCard.RewardId1 ~= 0)
	if mapMonthlyCard.RewardId1 ~= 0 then
		self:SetPngSprite(self._mapNode.imgItemIcon[2], ConfigTable.GetData_Item(mapMonthlyCard.RewardId1).Icon2)
		NovaAPI.SetTMPText(self._mapNode.txtItemCount[2], mapMonthlyCard.RewardNum1)
	end
	self._mapNode.imgItem[3].gameObject:SetActive(mapMonthlyCard.RewardId2 ~= 0)
	if mapMonthlyCard.RewardId2 ~= 0 then
		self:SetPngSprite(self._mapNode.imgItemIcon[3], ConfigTable.GetData_Item(mapMonthlyCard.RewardId2).Icon2)
		NovaAPI.SetTMPText(self._mapNode.txtItemCount[3], mapMonthlyCard.RewardNum2)
	end
end
function MallMonthlyCardCtrl:Awake()
end
function MallMonthlyCardCtrl:OnEnable()
end
function MallMonthlyCardCtrl:OnDisable()
end
function MallMonthlyCardCtrl:OnDestroy()
end
function MallMonthlyCardCtrl:OnBtnClick_Buy()
	local mapCfg = ConfigTable.GetData("MallMonthlyCard", self.sId)
	if self.nRemaining > mapCfg.MaxDays then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Mall_MaxDay"))
		return
	end
	PlayerData.Mall:BuyMonthlyCard(self.sId, mapCfg.StatisticalGroup)
end
function MallMonthlyCardCtrl:OnBtnClick_Rule()
	local msg = {
		nType = AllEnum.MessageBox.Desc,
		sContent = ConfigTable.GetUIText("Mall_MonthlyCard_RuleDesc")
	}
	EventManager.Hit(EventId.OpenMessageBox, msg)
end
function MallMonthlyCardCtrl:OnEvent_OrderClear()
	PopUpManager.OpenPopUpPanelByType(GameEnum.PopUpSeqType.MonthlyCard)
	self:Refresh()
end
return MallMonthlyCardCtrl
