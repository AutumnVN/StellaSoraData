local MiningQuestCellCtrl = class("MiningQuestCellCtrl", BaseCtrl)
local JumpUtil = require("Game.Common.Utils.JumpUtil")
local totalLength = 520
local totalHeight = 37
MiningQuestCellCtrl._mapNodeConfig = {
	txtTitle = {sComponentName = "TMP_Text"},
	btn_Receive = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Receive"
	},
	txt_Receive = {
		sComponentName = "TMP_Text",
		"Mining_Quest_Receive"
	},
	btn_JumpTo = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_JumpTo"
	},
	txt_JumoTo = {
		sComponentName = "TMP_Text",
		"Mining_Quest_Jump"
	},
	go_UnComplete = {},
	go_Received = {},
	go_ReceivedMask = {},
	rtBarFill = {
		sComponentName = "RectTransform"
	},
	btnReward = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Reward"
	},
	rtReward = {
		sCtrlName = "Game.UI.TemplateEx.TemplateItemCtrl"
	}
}
function MiningQuestCellCtrl:Init()
end
function MiningQuestCellCtrl:Awake(...)
end
function MiningQuestCellCtrl:OnDisable()
end
function MiningQuestCellCtrl:SetData(nActId, questData)
	self.questData = questData
	self.tbConfig = ConfigTable.GetData("MiningQuestConfig", self.questData.nId)
	NovaAPI.SetText(self._mapNode.txtTitle, ConfigTable.GetUIText(self.tbConfig.QuestDes))
end
function MiningQuestCellCtrl:UpdateCellStatus()
	self._mapNode.btn_Receive:SetActive(false)
	self._mapNode.btn_JumpTo:SetActive(false)
	self._mapNode.go_UnComplete:SetActive(false)
	self._mapNode.go_Received:SetActive(false)
	self._mapNode.go_ReceivedMask:SetActive(false)
	if self.questData.nStatus == AllEnum.ActQuestStatus.Complete then
		self._mapNode.btn_Receive:SetActive(true)
		self._mapNode.rtBarFill.sizeDelta = Vector2(totalLength, totalHeight)
	elseif self.questData.nStatus == AllEnum.ActQuestStatus.UnComplete then
		self._mapNode.rtBarFill.sizeDelta = Vector2(self.questData.progress.Cur / self.questData.progress.Max * totalLength, totalHeight)
		if self.tbConfig.JumpTo ~= nil or next(self.tbConfig.JumpTo) ~= nil then
			self._mapNode.btn_JumpTo:SetActive(true)
		else
			self._mapNode.go_UnComplete:SetActive(true)
		end
	else
		self._mapNode.go_Received:SetActive(true)
		self._mapNode.go_ReceivedMask:SetActive(true)
		self._mapNode.rtBarFill.sizeDelta = Vector2(totalLength, totalHeight)
	end
end
function MiningQuestCellCtrl:OnBtnClick_Receive()
	PlayerData.Activity:SendReceivePerQuest(self.nActId, self.nQuestId, nil)
end
function MiningQuestCellCtrl:OnBtnClick_JumpTo()
	if nil ~= self.nJumpTo and 0 ~= self.nJumpTo then
		JumpUtil.JumpTo(self.nJumpTo)
	end
end
function MiningQuestCellCtrl:OnBtnClick_Reward(btn)
	if nil ~= self.rewardId then
		UTILS.ClickItemGridWithTips(self.rewardId, btn.transform, true, true, true)
	end
end
return MiningQuestCellCtrl
