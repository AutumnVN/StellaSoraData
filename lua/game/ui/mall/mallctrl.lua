local MallCtrl = class("MallCtrl", BaseCtrl)
MallCtrl._mapNodeConfig = {
	TopBar = {
		sNodeName = "TopBarPanel",
		sCtrlName = "Game.UI.TopBarEx.TopBarCtrl"
	},
	tog = {
		nCount = 5,
		sComponentName = "UIButton",
		callback = "OnBtnClick_ChangeSheet"
	},
	ctrlTog = {
		nCount = 5,
		sNodeName = "tog",
		sCtrlName = "Game.UI.TemplateEx.TemplateToggleCtrl"
	},
	Gem = {
		sNodeName = "---Gem---",
		sCtrlName = "Game.UI.Mall.MallGemCtrl"
	},
	Package = {
		sNodeName = "---Package---",
		sCtrlName = "Game.UI.Mall.MallPackageCtrl"
	},
	MonthlyCard = {
		sNodeName = "---MonthlyCard---",
		sCtrlName = "Game.UI.Mall.MallMonthlyCardCtrl"
	},
	Shop = {
		sNodeName = "---Shop---",
		sCtrlName = "Game.UI.Mall.MallShopCtrl"
	},
	Skin = {
		sNodeName = "---Skin---",
		sCtrlName = "Game.UI.Mall.MallSkinCtrl"
	},
	btnCharShard = {
		sNodeName = "btnCharShard",
		sComponentName = "UIButton",
		callback = "OnBtnClick_OpenCharShardPanel"
	},
	aniMonthlyCard = {
		sNodeName = "---MonthlyCard---",
		sComponentName = "Animator"
	},
	redDotTog = {nCount = 4}
}
MallCtrl._mapEventConfig = {
	OpenMallTog = "OnEvent_OpenMallTog",
	MallChangeTopCoin = "OnEvent_ChangeTopCoin"
}
function MallCtrl:RegisterRedDot()
	RedDotManager.RegisterNode(RedDotDefine.Mall_Free, nil, self._mapNode.redDotTog[2])
end
function MallCtrl:SwitchTog()
	self._mapNode.Gem.gameObject:SetActive(self._panel.nCurTog == AllEnum.MallToggle.Gem)
	self._mapNode.Package.gameObject:SetActive(self._panel.nCurTog == AllEnum.MallToggle.Package)
	self._mapNode.MonthlyCard.gameObject:SetActive(self._panel.nCurTog == AllEnum.MallToggle.MonthlyCard)
	self._mapNode.Shop.gameObject:SetActive(self._panel.nCurTog == AllEnum.MallToggle.Shop)
	self._mapNode.Skin.gameObject:SetActive(self._panel.nCurTog == AllEnum.MallToggle.Skin)
	if self._panel.nCurTog == AllEnum.MallToggle.Gem then
		self._mapNode.Gem:Refresh()
		self._mapNode.TopBar:CreateCoin({
			AllEnum.CoinItemId.Jade,
			AllEnum.CoinItemId.FREESTONE
		})
	elseif self._panel.nCurTog == AllEnum.MallToggle.Package then
		self._mapNode.Package:ResetTab(self.nTabParam)
		self._mapNode.Package:Refresh(true)
		self._mapNode.TopBar:CreateCoin({
			AllEnum.CoinItemId.FREESTONE
		})
	elseif self._panel.nCurTog == AllEnum.MallToggle.MonthlyCard then
		self._mapNode.MonthlyCard:Refresh()
		self._mapNode.TopBar:CreateCoin({
			AllEnum.CoinItemId.Jade,
			AllEnum.CoinItemId.FREESTONE
		})
	elseif self._panel.nCurTog == AllEnum.MallToggle.Shop then
		self._mapNode.Shop:ResetTab()
		self._mapNode.Shop:Refresh(true)
	elseif self._panel.nCurTog == AllEnum.MallToggle.Skin then
		self._mapNode.Skin:ResetTab()
		self._mapNode.Skin:Refresh(true)
	end
	self:RegisterRedDot()
end
function MallCtrl:PlayTogAni()
	if self._panel.nCurTog == AllEnum.MallToggle.MonthlyCard then
		self._mapNode.aniMonthlyCard:Play("MonthlyCard_in")
	end
end
function MallCtrl:SetDefaultTog()
	if self._panel.nCurTog == nil then
		self._panel.nCurTog = AllEnum.MallToggle.MonthlyCard
	end
	for i = 1, 5 do
		self._mapNode.ctrlTog[i]:SetDefault(i == self._panel.nCurTog)
	end
	self:SwitchTog()
end
function MallCtrl:RefreshTogText()
	self._mapNode.ctrlTog[1]:SetText(ConfigTable.GetUIText("Mall_Tog_MonthlyCard"))
	self._mapNode.ctrlTog[2]:SetText(ConfigTable.GetUIText("Mall_Tog_Package"))
	self._mapNode.ctrlTog[3]:SetText(ConfigTable.GetUIText("Mall_Tog_Gem"))
	self._mapNode.ctrlTog[4]:SetText(ConfigTable.GetUIText("Mall_Tog_Exchange"))
	self._mapNode.ctrlTog[5]:SetText(ConfigTable.GetUIText("Mall_Tog_Skin"))
end
function MallCtrl:FadeIn(bPlayFadeIn)
	EventManager.Hit(EventId.SetTransition)
	self:PlayTogAni()
end
function MallCtrl:Awake()
	self:RefreshTogText()
end
function MallCtrl:OnEnable()
	EventManager.Hit("MallCloseDetail")
	self:SetDefaultTog()
end
function MallCtrl:OnDisable()
end
function MallCtrl:OnDestroy()
end
function MallCtrl:OnBtnClick_ChangeSheet(btn, nIndex)
	if nIndex == self._panel.nCurTog then
		return
	end
	self._mapNode.ctrlTog[nIndex]:SetTrigger(true)
	self._mapNode.ctrlTog[self._panel.nCurTog]:SetTrigger(false)
	self._panel.nCurTog = nIndex
	self:SwitchTog()
	self:PlayTogAni()
end
function MallCtrl:OnBtnClick_OpenCharShardPanel(btn)
	EventManager.Hit(EventId.OpenPanel, PanelId.CharShardsConvert)
end
function MallCtrl:OnEvent_ChangeTopCoin(tbCoin)
	self._mapNode.TopBar:CreateCoin(tbCoin)
end
function MallCtrl:OnEvent_OpenMallTog(nTog)
	self:OnBtnClick_ChangeSheet(nil, nTog)
end
return MallCtrl
