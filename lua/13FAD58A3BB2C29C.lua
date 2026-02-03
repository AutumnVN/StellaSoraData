local PenguinCardSelectCtrl = class("PenguinCardSelectCtrl", BaseCtrl)
PenguinCardSelectCtrl._mapNodeConfig = {
	TopBar = {
		sNodeName = "TopBarPanel",
		sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"
	},
	btnQuest = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Quest"
	},
	txtQuest = {
		sComponentName = "TMP_Text",
		sLanguageId = "PenguinCard_Btn_Quest"
	},
	reddotQuest = {},
	sv = {sComponentName = "ScrollRect"},
	sc = {
		sNodeName = "sv",
		sComponentName = "UIScrollToClick"
	},
	LevelContent = {sComponentName = "Transform"},
	goHardLevel = {},
	goNormalLevel = {}
}
PenguinCardSelectCtrl._mapEventConfig = {
	PenguinCard_ClickLevel = "OnEvent_Click"
}
PenguinCardSelectCtrl._mapRedDotConfig = {
	[RedDotDefine.Activity_PenguinCard_AllQuest] = {
		sNodeName = "reddotQuest"
	}
}
function PenguinCardSelectCtrl:Refresh()
	self.goFirstLock = nil
	self.tbLevel = self.actData:GetLevelList()
	delChildren(self._mapNode.LevelContent)
	for k, nLevelId in ipairs(self.tbLevel) do
		local mapCfg = ConfigTable.GetData("ActivityPenguinCardLevel", nLevelId)
		if mapCfg then
			if mapCfg.ScoreLevel then
				self:RefreshHard(k, nLevelId)
			else
				self:RefreshNormal(k, nLevelId)
			end
		end
	end
	if self._panel.nPos then
		NovaAPI.SetHorizontalNormalizedPosition(self._mapNode.sv, self._panel.nPos)
	elseif self.goFirstLock then
		local wait = function()
			coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
			self._mapNode.sc:ScrollToClick(self.goFirstLock, 0.01)
			self.goFirstLock = nil
		end
		cs_coroutine.start(wait)
	else
		NovaAPI.SetHorizontalNormalizedPosition(self._mapNode.sv, 1)
	end
	EventManager.Hit("Guide_PassiveCheck_Msg", "Guide_PenguinCard_304")
end
function PenguinCardSelectCtrl:RefreshHard(nIndex, nLevelId)
	local goObj = instantiate(self._mapNode.goHardLevel, self._mapNode.LevelContent)
	local ctrlObj = self:BindCtrlByNode(goObj, "Game.UI.Play_PenguinCard.PenguinCardLevelGridCtrl")
	self.tbGridCtrl[nIndex] = ctrlObj
	goObj:SetActive(true)
	ctrlObj:RefreshHard(self.actData, nLevelId)
	local bLock = ctrlObj:GetLock()
	if bLock and not self.goFirstLock then
		self.goFirstLock = goObj
	end
end
function PenguinCardSelectCtrl:RefreshNormal(nIndex, nLevelId)
	local goObj = instantiate(self._mapNode.goNormalLevel, self._mapNode.LevelContent)
	local ctrlObj = self:BindCtrlByNode(goObj, "Game.UI.Play_PenguinCard.PenguinCardLevelGridCtrl")
	self.tbGridCtrl[nIndex] = ctrlObj
	goObj:SetActive(true)
	ctrlObj:RefreshNormal(self.actData, nIndex, nLevelId)
	local bLock = ctrlObj:GetLock()
	if bLock and not self.goFirstLock then
		self.goFirstLock = goObj
	end
end
function PenguinCardSelectCtrl:Awake()
	local param = self:GetPanelParam()
	if type(param) == "table" then
		self.nActId = param[1]
	end
	self.actData = PlayerData.Activity:GetActivityDataById(self.nActId)
	self.tbGridCtrl = {}
end
function PenguinCardSelectCtrl:OnEnable()
	self:Refresh()
end
function PenguinCardSelectCtrl:OnDisable()
	for k, v in pairs(self.tbGridCtrl) do
		self:UnbindCtrlByNode(v)
		self.tbGridCtrl[k] = nil
	end
	self.tbGridCtrl = {}
	self._panel.nPos = NovaAPI.GetHorizontalNormalizedPosition(self._mapNode.sv)
	self.actData:SkipLevelRedDot()
end
function PenguinCardSelectCtrl:OnDestroy()
end
function PenguinCardSelectCtrl:OnBtnClick_Quest()
	EventManager.Hit(EventId.OpenPanel, PanelId.PenguinCardQuest, self.nActId)
end
function PenguinCardSelectCtrl:OnEvent_Click(go, callback)
	self:AddTimer(1, 0.1, callback, true, true, true)
	EventManager.Hit(EventId.TemporaryBlockInput, 0.1)
	self._mapNode.sc:ScrollToClick(go)
end
return PenguinCardSelectCtrl
