local MonthlyCardCtrl = class("MonthlyCardCtrl", BaseCtrl)
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
local BoxBornTime = 0.9
local InTime = 0.7
local OutTime = 0.5
MonthlyCardCtrl._mapNodeConfig = {
	blur = {
		sNodeName = "t_fullscreen_blur_blue"
	},
	btnBlur = {
		sNodeName = "snapshot",
		sComponentName = "Button",
		callback = "OnBtnClick_Close"
	},
	aniRoot = {
		sNodeName = "----SafeAreaRoot----",
		sComponentName = "Animator"
	},
	txtTime = {sComponentName = "TMP_Text"},
	txtClick = {
		sComponentName = "TMP_Text",
		sLanguageId = "MonthlyCard_Click"
	},
	Model = {
		sCtrlName = "Game.UI.MonthlyCard.MonthlyCardModelCtrl"
	},
	imgTitle = {}
}
MonthlyCardCtrl._mapEventConfig = {}
function MonthlyCardCtrl:Refresh()
	EventManager.Hit(EventId.TemporaryBlockInput, BoxBornTime + InTime)
	NovaAPI.SetTMPText(self._mapNode.txtTime, orderedFormat(ConfigTable.GetUIText("MonthlyCard_RemainDay"), self.nRemaining))
	self._mapNode.txtTime.gameObject:SetActive(false)
	self._mapNode.txtClick.gameObject:SetActive(false)
	self._mapNode.imgTitle.gameObject:SetActive(false)
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		self._mapNode.Model:ShowRawImage()
		WwiseAudioMgr:PlaySound("ui_mall_monthlyCard_appear")
		self:PlayInAnim()
	end
	cs_coroutine.start(wait)
end
function MonthlyCardCtrl:PlayInAnim()
	local func_in = function()
		self._mapNode.txtTime.gameObject:SetActive(true)
		self._mapNode.txtClick.gameObject:SetActive(true)
		self._mapNode.imgTitle.gameObject:SetActive(true)
		self._mapNode.aniRoot:SetTrigger("tIn")
	end
	self:AddTimer(1, 0.9, func_in, true, true, true)
end
function MonthlyCardCtrl:PlayOutAnim()
	self._mapNode.Model:PlayOpenAnim()
	self._mapNode.aniRoot:SetTrigger("tOut")
	EventManager.Hit(EventId.TemporaryBlockInput, OutTime)
end
function MonthlyCardCtrl:Awake()
	local tbParam = self:GetPanelParam()
	if type(tbParam) == "table" then
		self.mapReward = tbParam[1].mapReward
		self.nRemaining = tbParam[1].nRemaining
		self.callback = tbParam[2]
	end
end
function MonthlyCardCtrl:OnEnable()
	self._mapNode.blur:SetActive(true)
	self:Refresh()
end
function MonthlyCardCtrl:OnDisable()
end
function MonthlyCardCtrl:OnDestroy()
end
function MonthlyCardCtrl:OnBtnClick_Close(btn)
	local func_close_receive = function()
		EventManager.Hit(EventId.ClosePanel, PanelId.MonthlyCard)
		local wait = function()
			coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
			if self.callback then
				self.callback()
			end
		end
		cs_coroutine.start(wait)
	end
	WwiseAudioMgr:PlaySound("ui_mall_monthlyCard_open")
	self:PlayOutAnim()
	self:AddTimer(1, OutTime, function()
		UTILS.OpenReceiveByReward(self.mapReward, func_close_receive)
	end, true, true, true)
end
return MonthlyCardCtrl
