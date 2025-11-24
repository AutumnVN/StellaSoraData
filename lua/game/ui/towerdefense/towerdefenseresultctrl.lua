local TowerDefenseResultCtrl = class("TowerDefenseResultCtrl", BaseCtrl)
local WwiseManger = CS.WwiseAudioManager.Instance
TowerDefenseResultCtrl._mapNodeConfig = {
	txt_level = {sComponentName = "TMP_Text"},
	db_target = {nCount = 3},
	ButtonClose = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	imgBlurredBg = {},
	Mask = {
		sComponentName = "CanvasGroup"
	}
}
TowerDefenseResultCtrl._mapEventConfig = {}
TowerDefenseResultCtrl._mapRedDotConfig = {}
function TowerDefenseResultCtrl:Awake()
	local param = self:GetPanelParam()
	if type(param) == "table" then
		self.bResult = param[1]
		self.sLevelName = param[2]
		self.tbTarget = param[3]
		self.callback = param[4]
		self.msgData = param[5]
	end
	self:SetContent()
	self.bProcessingClose = false
end
function TowerDefenseResultCtrl:SetContent()
	EventManager.Hit(EventId.TemporaryBlockInput, 1)
	WwiseManger:PostEvent("ui_loading_combatSFX_mute", nil, false)
	WwiseManger:PlaySound("ui_roguelike_victory")
	for _, target in pairs(self._mapNode.db_target) do
		target:SetActive(false)
	end
	NovaAPI.SetTMPText(self._mapNode.txt_level, self.sLevelName)
	for i = 1, math.min(#self.tbTarget, #self._mapNode.db_target) do
		local target = self._mapNode.db_target[i]
		local star = target.transform:Find("star_get")
		local txt_target = target.transform:Find("txt_target")
		star.gameObject:SetActive(self.tbTarget[i].bResult)
		NovaAPI.SetTMPText(txt_target:GetComponent("TMP_Text"), self.tbTarget[i].sTargetDes)
		target:SetActive(true)
	end
	self:AddTimer(1, 0.5, function()
		local mapReward = PlayerData.Item:ProcessRewardChangeInfo(self.msgData)
		local tbItem = {}
		for _, v in ipairs(mapReward.tbReward) do
			local item = {
				Tid = v.id,
				Qty = v.count,
				rewardType = AllEnum.RewardType.First
			}
			table.insert(tbItem, item)
		end
		UTILS.OpenReceiveByDisplayItem(tbItem, self.msgData)
	end, true, true, true)
end
function TowerDefenseResultCtrl:OnBtnClick_Close()
	if self.bProcessingClose then
		return
	end
	self.bProcessingClose = true
	if self.callback ~= nil then
		self.callback()
	end
	if NovaAPI.GetCurrentModuleName() == "MainMenuModuleScene" then
		CS.AdventureModuleHelper.LevelStateChanged(true, 0, false)
		EventManager.Hit(EventId.CloesCurPanel)
		PlayerData.Base:OnBackToMainMenuModule()
	else
		EventManager.Hit(EventId.ClosePanel, PanelId.TowerDefensePanel)
		NovaAPI.SetCanvasGroupAlpha(self._mapNode.Mask, 0)
		self._mapNode.Mask.gameObject:SetActive(true)
		EventManager.Hit(EventId.TemporaryBlockInput, 0.5)
		local sequence = DOTween.Sequence()
		sequence:Append(self._mapNode.Mask:DOFade(1, 0.5):SetUpdate(true))
		sequence:AppendCallback(function()
			CS.AdventureModuleHelper.LevelStateChanged(true, 0, false)
		end)
		sequence:SetUpdate(true)
	end
end
return TowerDefenseResultCtrl
