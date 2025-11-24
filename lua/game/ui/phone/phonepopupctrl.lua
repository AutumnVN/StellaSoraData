local PhonePopUpCtrl = class("PhonePopUpCtrl", BaseCtrl)
PhonePopUpCtrl._mapNodeConfig = {
	imgBlurredBg = {sComponentName = "GameObject"},
	goContent = {},
	animRoot = {
		sNodeName = "----SafeAreaRoot----",
		sComponentName = "Animator"
	},
	animChatBg = {
		sNodeName = "imgChatIcon",
		sComponentName = "Animator"
	},
	goChat = {
		sCtrlName = "Game.UI.Phone.Chat.PhoneChatCtrl"
	},
	btnClose = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	}
}
PhonePopUpCtrl._mapEventConfig = {}
function PhonePopUpCtrl:Awake()
	local param = self:GetPanelParam()
	if type(param) == "table" then
		self.nChatId = param[1]
		self.bRestart = param[2]
		self.callback = param[3]
	end
end
function PhonePopUpCtrl:OnEnable()
	self._mapNode.goContent.gameObject:SetActive(false)
	self._mapNode.imgBlurredBg.gameObject:SetActive(true)
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		self._mapNode.goContent.gameObject:SetActive(true)
		self._mapNode.animChatBg.gameObject:SetActive(false)
		local nAnimLength = NovaAPI.GetAnimClipLength(self._mapNode.animRoot, {
			"PhonePopUpPanel_in"
		})
		local callback = function()
			self._mapNode.animChatBg.gameObject:SetActive(true)
			self._mapNode.animChatBg:Play("Phone_chaticon_in")
			local chatCfg = ConfigTable.GetData("Chat", self.nChatId)
			self.nAddressId = chatCfg.AddressBookId
			local addressData = PlayerData.Phone:GetAddressBookData(self.nAddressId)
			if nil ~= addressData then
				self._mapNode.goChat:SetChatContent(addressData, self.nChatId, self.bRestart)
			end
		end
		self:AddTimer(1, nAnimLength, callback, true, true, true)
		EventManager.Hit(EventId.TemporaryBlockInput, nAnimLength)
	end
	cs_coroutine.start(wait)
end
function PhonePopUpCtrl:OnDisable()
end
function PhonePopUpCtrl:OnDestroy()
	if nil ~= self.callback then
		self.callback()
	end
end
function PhonePopUpCtrl:OnBtnClick_Close()
	local nAnimLength = NovaAPI.GetAnimClipLength(self._mapNode.animRoot, {
		"PhonePopUpPanel_out"
	})
	self._mapNode.animRoot:Play("PhonePopUpPanel_out")
	self._mapNode.animChatBg:Play("Phone_chaticon_out")
	EventManager.Hit(EventId.TemporaryBlockInput, nAnimLength)
	self:AddTimer(1, nAnimLength, function()
		EventManager.Hit(EventId.ClosePanel, PanelId.PhonePopUp)
	end, true, true, true, true)
end
return PhonePopUpCtrl
