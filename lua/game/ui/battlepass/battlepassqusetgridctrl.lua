local BattlePassQusetGridCtrl = class("BattlePassQusetGridCtrl", BaseCtrl)
local LayoutRebuilder = CS.UnityEngine.UI.LayoutRebuilder
local totalLength = 755
local totalHeight = 37
local JumpUtil = require("Game.Common.Utils.JumpUtil")
BattlePassQusetGridCtrl._mapNodeConfig = {
	rtTitle = {
		sComponentName = "RectTransform"
	},
	TMPTitle = {sComponentName = "TMP_Text"},
	TMPUncomplete = {
		sComponentName = "TMP_Text",
		sLanguageId = "Quest_undone"
	},
	txtBtnReceive = {
		sComponentName = "TMP_Text",
		sLanguageId = "Quest_Receive"
	},
	txtBtnJump = {
		sComponentName = "TMP_Text",
		sLanguageId = "Quest_JumpTo"
	},
	rtBarFill = {
		sComponentName = "RectTransform"
	},
	TMPProcess = {sComponentName = "TMP_Text"},
	btnReceive = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Receive"
	},
	btnJump = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_JumpTo"
	},
	rtReward = {
		sCtrlName = "Game.UI.TemplateEx.TemplateItemCtrl"
	},
	imgComplete = {},
	imgCompleteMask = {},
	btnReward = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Reward"
	},
	TMPClose = {
		sComponentName = "TMP_Text",
		sLanguageId = "Quest_Closed"
	}
}
BattlePassQusetGridCtrl._mapEventConfig = {}
function BattlePassQusetGridCtrl:OnEnable()
	self.gameObject:SetActive(false)
	local waitOpen = function()
		self.gameObject:SetActive(true)
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		LayoutRebuilder.ForceRebuildLayoutImmediate(self._mapNode.rtTitle)
	end
	cs_coroutine.start(waitOpen)
end
function BattlePassQusetGridCtrl:Refresh(mapQuest, mapQuestCfgData, bEnable)
	if mapQuest == nil then
		self.gameObject:SetActive(false)
		return
	end
	if mapQuestCfgData == nil then
		printError("quest data missing:" .. mapQuest.nTid)
		self.gameObject:SetActive(false)
		return
	end
	self.mapQuestCfgData = mapQuestCfgData
	self.mapQuest = mapQuest
	NovaAPI.SetTMPText(self._mapNode.TMPTitle, mapQuestCfgData.Title)
	self.nRewardId = 22
	self._mapNode.rtReward:SetItem(self.nRewardId, nil, mapQuestCfgData.Exp, nil, nil, nil, nil, true)
	if not bEnable then
		NovaAPI.SetTMPText(self._mapNode.TMPProcess, "-/-")
	elseif mapQuest.nStatus ~= 2 then
		NovaAPI.SetTMPText(self._mapNode.TMPProcess, string.format("%d/%d", mapQuest.nCurProgress, mapQuest.nGoal))
	else
		NovaAPI.SetTMPText(self._mapNode.TMPProcess, ConfigTable.GetUIText("Quest_Complete"))
	end
	if not bEnable then
		self._mapNode.rtBarFill.sizeDelta = Vector2(0, totalHeight)
	else
		self._mapNode.rtBarFill.sizeDelta = Vector2(mapQuest.nCurProgress / mapQuest.nGoal * totalLength, totalHeight)
	end
	self._mapNode.imgComplete:SetActive(mapQuest.nStatus == 2 and bEnable)
	self._mapNode.imgCompleteMask:SetActive(mapQuest.nStatus == 2 or not bEnable)
	self._mapNode.TMPUncomplete.gameObject:SetActive(mapQuest.nStatus == 0 and mapQuestCfgData.JumpTo == 0 and bEnable)
	self._mapNode.btnJump.gameObject:SetActive(mapQuest.nStatus == 0 and mapQuestCfgData.JumpTo ~= 0 and bEnable)
	self._mapNode.btnReceive.gameObject:SetActive(mapQuest.nStatus == 1 and bEnable)
	self._mapNode.TMPClose.gameObject:SetActive(not bEnable)
	LayoutRebuilder.ForceRebuildLayoutImmediate(self._mapNode.rtTitle)
end
function BattlePassQusetGridCtrl:ShowItemDetail(id, rtIcon)
	UTILS.ClickItemGridWithTips(id, rtIcon.transform, true, false, false)
end
function BattlePassQusetGridCtrl:OnBtnClick_Receive()
	PlayerData.Quest:ReceiveBattlePassQuestData(self.mapQuest.nTid, nil)
end
function BattlePassQusetGridCtrl:OnBtnClick_JumpTo()
	local nJumptoId = self.mapQuestCfgData.JumpTo
	JumpUtil.JumpTo(nJumptoId)
end
function BattlePassQusetGridCtrl:OnBtnClick_Reward()
	EventManager.Hit("ShowQuestReward", self.gameObject)
	self:ShowItemDetail(self.nRewardId, self._mapNode.btnReward)
end
return BattlePassQusetGridCtrl
