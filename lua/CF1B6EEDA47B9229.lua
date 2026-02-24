local ThrowGiftSettleCtrl = class("ThrowGiftSettleCtrl", BaseCtrl)
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
ThrowGiftSettleCtrl._mapNodeConfig = {
	btnConfirm1 = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Confirm1"
	},
	btnConfirm2 = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Confirm2"
	},
	txtBtnClose = {
		sComponentName = "TMP_Text",
		sLanguageId = "ThrowGift_Settle_Close"
	},
	txtBtnConfirm = {sComponentName = "TMP_Text"},
	TMPSettleScoreTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "ThrowGift_Settle_ScoreTitle"
	},
	TMPSettleScore = {sComponentName = "TMP_Text"},
	TMPSettleGiftTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "ThrowGift_Settle_GiftCount"
	},
	TMPSettleGift = {sComponentName = "TMP_Text"},
	TMPPenguinTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "ThrowGift_Settle_RemainCount"
	},
	TMPPenguin = {sComponentName = "TMP_Text"},
	TMPVictoryTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "Activity_ThrowGifts_Win"
	},
	TMPFailTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "Activity_ThrowGifts_Fail"
	},
	imgPenguinBg = {}
}
ThrowGiftSettleCtrl._mapEventConfig = {}
ThrowGiftSettleCtrl._mapRedDotConfig = {}
function ThrowGiftSettleCtrl:Awake()
end
function ThrowGiftSettleCtrl:FadeIn()
end
function ThrowGiftSettleCtrl:FadeOut()
end
function ThrowGiftSettleCtrl:OnEnable()
	self.animator = self.gameObject:GetComponent("Animator")
	self.canvasGroup = self.gameObject:GetComponent("CanvasGroup")
end
function ThrowGiftSettleCtrl:OnDisable()
end
function ThrowGiftSettleCtrl:OnDestroy()
end
function ThrowGiftSettleCtrl:OnRelease()
end
function ThrowGiftSettleCtrl:ShowSettle(bWin, nScore, nGift, nPenguin, bShowPenguin, bNextUnlock, changeInfo, nLevelId)
	self.bWin = bWin
	NovaAPI.SetTMPText(self._mapNode.txtBtnConfirm, self.bWin and ConfigTable.GetUIText("ThrowGift_Settle_NextLevel") or ConfigTable.GetUIText("ThrowGift_Settle_Restart"))
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		NovaAPI.SetCanvasGroupAlpha(self.canvasGroup, 1)
	end
	cs_coroutine.start(wait)
	NovaAPI.SetCanvasGroupAlpha(self.canvasGroup, 0)
	self.gameObject:SetActive(true)
	NovaAPI.SetTMPText(self._mapNode.TMPSettleScore, nScore)
	NovaAPI.SetTMPText(self._mapNode.TMPSettleGift, nGift)
	NovaAPI.SetTMPText(self._mapNode.TMPPenguin, nPenguin)
	self._mapNode.imgPenguinBg:SetActive(bShowPenguin)
	local nAnimLength = 0
	if bWin then
		WwiseAudioMgr:PostEvent("Mode_Present_compelete")
		self.animator:Play("rtSettle_Victory")
		nAnimLength = NovaAPI.GetAnimClipLength(self.animator, {
			"rtSettle_Victory"
		})
		self._mapNode.btnConfirm2.gameObject:SetActive(bNextUnlock)
	else
		WwiseAudioMgr:PostEvent("Mode_Present_failed")
		self._mapNode.btnConfirm2.gameObject:SetActive(true)
		self.animator:Play("rtSettle_Fail")
		nAnimLength = NovaAPI.GetAnimClipLength(self.animator, {
			"rtSettle_Fail"
		})
	end
	EventManager.Hit(EventId.TemporaryBlockInput, nAnimLength)
	local timerCb = function()
		if changeInfo ~= nil and #changeInfo.Props > 0 then
			local mapLevelData = ConfigTable.GetData("ThrowGiftLevel", nLevelId)
			local i = 1
			local tbItem = {}
			while mapLevelData["FirstCompleteReward" .. i .. "Tid"] ~= nil do
				local nItemId = mapLevelData["FirstCompleteReward" .. i .. "Tid"]
				local nCount = mapLevelData["FirstCompleteReward" .. i .. "Qty"]
				table.insert(tbItem, {Tid = nItemId, Qty = nCount})
				i = i + 1
			end
			UTILS.OpenReceiveByDisplayItem(tbItem, changeInfo, nil)
		end
		EventManager.Hit(EventId.BlockInput, false)
	end
	self:AddTimer(1, nAnimLength, timerCb, true, true, true)
end
function ThrowGiftSettleCtrl:OnBtnClick_Confirm1()
	self.gameObject:SetActive(false)
	EventManager.Hit("ThrowGiftSettle_Exit")
end
function ThrowGiftSettleCtrl:OnBtnClick_Confirm2()
	self.gameObject:SetActive(false)
	if self.bWin then
		EventManager.Hit("ThrowGiftSettle_NextLevel")
	else
		EventManager.Hit("ThrowGiftSettle_Restart")
	end
end
return ThrowGiftSettleCtrl
