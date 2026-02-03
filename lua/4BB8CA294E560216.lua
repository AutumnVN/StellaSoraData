local BreakOutResultCtrl = class("BreakOutResultCtrl", BaseCtrl)
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
local GamepadUIManager = require("GameCore.Module.GamepadUIManager")
BreakOutResultCtrl._mapNodeConfig = {
	imgBlurredBg = {},
	ButtonClose = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	FailRoot = {},
	LeveName_Fail = {},
	SucceedRoot = {},
	LeveName_Succeed = {},
	btn_Exit = {
		sNodeName = "btn_Exit",
		sComponentName = "NaviButton",
		callback = "OnBtnClick_Close",
		sAction = "Giveup"
	},
	txt_Exit = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "BreakOut_Result_Exit"
	},
	btn_Restart = {
		sNodeName = "btn_Restart",
		sComponentName = "NaviButton",
		callback = "BreakOut_Button_Restart",
		sAction = "Retry"
	},
	txt_Restart = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "BreakOut_Result_Restart"
	},
	safeAreaRoot = {
		sNodeName = "----SafeAreaRoot----"
	}
}
BreakOutResultCtrl._mapEventConfig = {OpenBreakOutResultPanel = "Open", CloseBreakOutResultPanel = "Close"}
BreakOutResultCtrl._mapRedDotConfig = {}
function BreakOutResultCtrl:Awake()
	self._mapNode.safeAreaRoot:SetActive(false)
	self._mapNode.imgBlurredBg.gameObject:SetActive(false)
	self.tbGamepadUINode = self:GetGamepadUINode()
end
function BreakOutResultCtrl:SetContent()
	EventManager.Hit(EventId.TemporaryBlockInput, 1)
	if self.bResult then
		WwiseAudioMgr:PostEvent("mode_breakout_ui_victory")
		local sTitle = self._mapNode.LeveName_Succeed.transform:Find("txt_title"):GetComponent("TMP_Text")
		NovaAPI.SetTMPText(sTitle, self.sLevelName)
		self:AddTimer(1, 1, function()
			local mapReward = PlayerData.Item:ProcessRewardChangeInfo(self.mapChangeInfo)
			local tbItem = {}
			for _, v in ipairs(mapReward.tbReward) do
				local item = {
					Tid = v.id,
					Qty = v.count,
					rewardType = AllEnum.RewardType.First
				}
				table.insert(tbItem, item)
			end
			UTILS.OpenReceiveByDisplayItem(tbItem, self.mapChangeInfo)
		end, true, true, true)
	else
		WwiseAudioMgr:PostEvent("mode_breakout_ui_lose")
		local sTitle = self._mapNode.LeveName_Fail.transform:Find("txt_title"):GetComponent("TMP_Text")
		NovaAPI.SetTMPText(sTitle, self.sLevelName)
	end
end
function BreakOutResultCtrl:OnBtnClick_Close()
	if self.bProcessingClose then
		return
	end
	self.bProcessingClose = true
	if self.callback ~= nil then
		self.callback()
	end
	if NovaAPI.GetCurrentModuleName() == "MainMenuModuleScene" then
		EventManager.Hit(EventId.CloesCurPanel)
		PlayerData.Base:OnBackToMainMenuModule()
	else
		CS.AdventureModuleHelper.LevelStateChanged(true, 0, false)
	end
end
function BreakOutResultCtrl:BreakOut_Button_Restart()
	EventManager.Hit("Close_BattlePause")
	self:Close()
	EventManager.Hit("SetPlayFinishState", false)
	EventManager.Hit("SetBreakOutPlaySkill_Visible", true)
	EventManager.Hit("SetBreakOutPlaySkill_Visible", false)
	NovaAPI.DispatchEventWithData("BreakOut_InRestart", nil, {true})
	EventManager.Hit("BreakOut_Complete", false)
	CS.AdventureModuleHelper.LevelStateChanged(false)
	EventManager.Hit("ResetBossHUD")
end
function BreakOutResultCtrl:Open(bResult, sLevelName, callback, mapChangeInfo)
	PanelManager.InputDisable()
	GamepadUIManager.AddGamepadUINode("BreakOutPlayCtrl", self.tbGamepadUINode)
	EventManager.Hit("SetBreakOutPlaySkill_Visible", false)
	EventManager.Hit("OnEvent_ClearState")
	self.bResult = bResult
	self.sLevelName = sLevelName
	self.callback = callback
	self.mapChangeInfo = mapChangeInfo
	self._mapNode.SucceedRoot:SetActive(self.bResult)
	self._mapNode.FailRoot:SetActive(not self.bResult)
	self._mapNode.ButtonClose.gameObject:SetActive(self.bResult)
	self:SetContent()
	self.bProcessingClose = false
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		self._mapNode.safeAreaRoot:SetActive(true)
	end
	cs_coroutine.start(wait)
	self._mapNode.imgBlurredBg.gameObject:SetActive(true)
end
function BreakOutResultCtrl:Close()
	self._mapNode.safeAreaRoot:SetActive(false)
	PanelManager.InputEnable()
	self._mapNode.imgBlurredBg.gameObject:SetActive(false)
	GamepadUIManager.DisableGamepadUI("BreakOutResultCtrl")
end
return BreakOutResultCtrl
