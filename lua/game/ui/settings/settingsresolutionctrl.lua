local SettingsResolutionCtrl = class("SettingsResolutionCtrl", BaseCtrl)
SettingsResolutionCtrl._mapNodeConfig = {
	txtWindowTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "Settings_Display_ResolutionTitle"
	},
	btnClose = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Cancel"
	},
	btnCancel = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Cancel"
	},
	btnConfirm1 = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Confirm"
	},
	txtBtnConfirm1 = {
		sComponentName = "TMP_Text",
		sLanguageId = "MessageBox_Confirm"
	},
	txtBtnCancel = {
		sComponentName = "TMP_Text",
		sLanguageId = "MessageBox_Cancel"
	},
	txtOptionTitle = {nCount = 4, sComponentName = "TMP_Text"},
	btnChoose = {
		nCount = 4,
		sComponentName = "UIButton",
		callback = "OnBtnClick_Choose"
	},
	Checkmark = {nCount = 4, sComponentName = "Animator"},
	Option = {nCount = 4},
	line = {nCount = 4}
}
SettingsResolutionCtrl._mapEventConfig = {}
function SettingsResolutionCtrl:Open(nResolution, tbResolution)
	self.nIndex = nResolution
	self.tbResolution = tbResolution
	self:PlayInAni()
	self:Refresh()
end
function SettingsResolutionCtrl:Refresh()
	local nCount = #self.tbResolution
	if 4 <= nCount then
		self._mapNode.line[4]:SetActive(false)
	else
		self._mapNode.line[nCount]:SetActive(false)
	end
	for i = 1, 4 do
		local sText = self.tbResolution[i]
		if sText then
			self._mapNode.Option[i].gameObject:SetActive(true)
			NovaAPI.SetTMPText(self._mapNode.txtOptionTitle[i], sText)
		else
			self._mapNode.Option[i].gameObject:SetActive(false)
		end
	end
	for i = 1, 4 do
		if i == self.nIndex then
			self._mapNode.Checkmark[i]:Play("checkmark_in", -1, 1)
		else
			self._mapNode.Checkmark[i]:Play("checkmark_out", -1, 1)
		end
	end
end
function SettingsResolutionCtrl:PlayInAni()
	self.gameObject:SetActive(true)
	self.ani:Play("t_window_04_t_in")
	EventManager.Hit(EventId.TemporaryBlockInput, 0.3)
end
function SettingsResolutionCtrl:PlayOutAni()
	self.ani:Play("t_window_04_t_out")
	self:AddTimer(1, 0.2, "Close", true, true, true)
end
function SettingsResolutionCtrl:Close()
	self.gameObject:SetActive(false)
end
function SettingsResolutionCtrl:Awake()
	self.ani = self.gameObject.transform:GetComponent("Animator")
end
function SettingsResolutionCtrl:OnEnable()
end
function SettingsResolutionCtrl:OnDisable()
end
function SettingsResolutionCtrl:OnDestroy()
end
function SettingsResolutionCtrl:OnBtnClick_Cancel(btn)
	EventManager.Hit("SettingsClosePop")
end
function SettingsResolutionCtrl:OnBtnClick_Confirm(btn)
	EventManager.Hit("SettingsClosePop")
	EventManager.Hit("SettingsSetResolution", self.nIndex)
end
function SettingsResolutionCtrl:OnBtnClick_Choose(btn, index)
	if self.nIndex == index then
		return
	end
	self._mapNode.Checkmark[self.nIndex]:SetTrigger("PlayCheckmarkHide")
	self._mapNode.Checkmark[index]:SetTrigger("PlayCheckmarkShow")
	self.nIndex = index
end
return SettingsResolutionCtrl
