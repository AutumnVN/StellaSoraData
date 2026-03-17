local TrekkerVersusDuelHistoryGridCtrl = class("TrekkerVersusDuelHistoryGridCtrl", BaseCtrl)
TrekkerVersusDuelHistoryGridCtrl._mapNodeConfig = {
	TMPDesc = {sComponentName = "TMP_Text"},
	TMPIncomplete = {
		sComponentName = "TMP_Text",
		sLanguageId = "Quest_undone"
	},
	imgHeadStreamerGrid = {nCount = 2, sComponentName = "Image"},
	txtNameStreamerGrid = {nCount = 2, sComponentName = "TMP_Text"},
	txtHeatStreamerGrid = {nCount = 2, sComponentName = "TMP_Text"},
	txtDuelWinReward = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_DuelWinReward"
	},
	itemReward = {
		nCount = 3,
		sCtrlName = "Game.UI.TemplateEx.TemplateItemCtrl"
	},
	btnItemReward = {
		nCount = 3,
		sComponentName = "UIButton",
		sCallback = "OnBtnClick_ItemReward"
	},
	imgDuelEnd = {},
	txtDuelOnGoing = {
		sComponentName = "TMP_Text",
		sLanguageId = "TD_DuelOnGoing"
	},
	imgWin = {}
}
TrekkerVersusDuelHistoryGridCtrl._mapEventConfig = {}
TrekkerVersusDuelHistoryGridCtrl._mapRedDotConfig = {}
function TrekkerVersusDuelHistoryGridCtrl:Awake()
end
function TrekkerVersusDuelHistoryGridCtrl:FadeIn()
end
function TrekkerVersusDuelHistoryGridCtrl:FadeOut()
end
function TrekkerVersusDuelHistoryGridCtrl:OnEnable()
end
function TrekkerVersusDuelHistoryGridCtrl:OnDisable()
end
function TrekkerVersusDuelHistoryGridCtrl:OnDestroy()
end
function TrekkerVersusDuelHistoryGridCtrl:OnRelease()
end
function TrekkerVersusDuelHistoryGridCtrl:Refresh(mapDuelHistoryData, nIndex, bMain)
	self._mapNode.imgWin:SetActive(not bMain)
	self._mapNode.imgDuelEnd:SetActive(not bMain)
	self._mapNode.txtDuelOnGoing.gameObject:SetActive(bMain)
	self.mapDuelData = ConfigTable.GetData("TravelerDuelTarget", nIndex)
	local sHeatStr = ConfigTable.GetUIText("TD_HeatQuestTab") .. ":" or ""
	NovaAPI.SetTMPText(self._mapNode.txtHeatStreamerGrid[1], sHeatStr .. mapDuelHistoryData.SelfHotValue)
	NovaAPI.SetTMPText(self._mapNode.txtHeatStreamerGrid[2], sHeatStr .. mapDuelHistoryData.RivalHotValue)
end
function TrekkerVersusDuelHistoryGridCtrl:OnBtnClick_Item(btn, nIdx)
	local sFieldName1 = "ItemId" .. nIdx
	local sFieldName2 = "ItemQty" .. nIdx
	local nItemTid = self.mapDuelData[sFieldName1]
	local nCount = self.mapDuelData[sFieldName2]
	UTILS.ClickItemGridWithTips(nItemTid, btn.transform, true, true, false)
end
function TrekkerVersusDuelHistoryGridCtrl:OnBtnClick_JumpTo(btn)
	EventManager.Hit("TrekkerVersusAffixJump", self.cfgData.AffixJumpTo)
end
return TrekkerVersusDuelHistoryGridCtrl
