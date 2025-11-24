local SettingsNotificationCtrl = class("SettingsNotificationCtrl", BaseCtrl)
local UIGameSystemSetup = CS.UIGameSystemSetup
SettingsNotificationCtrl._mapNodeConfig = {
	txtPageTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "Settings_Notification"
	},
	txtForwardNews = {
		sComponentName = "TMP_Text",
		sLanguageId = "Settings_Notification_ForwardNews"
	},
	Energy = {
		sCtrlName = "Game.UI.Settings.OptionSwitchCtrl"
	},
	Dispatch = {
		sCtrlName = "Game.UI.Settings.OptionSwitchCtrl"
	}
}
SettingsNotificationCtrl._mapEventConfig = {}
function SettingsNotificationCtrl:RefreshText()
	self._mapNode.Energy:SetText(ConfigTable.GetUIText("Settings_Notification_Energy"))
	self._mapNode.Dispatch:SetText(ConfigTable.GetUIText("Settings_Notification_Dispatch"))
end
function SettingsNotificationCtrl:Init()
	if self.bInit then
		return
	end
	self.bInit = true
	self:LoadSetting()
end
function SettingsNotificationCtrl:Quit()
	if not self.bInit then
		return
	end
end
function SettingsNotificationCtrl:LoadSetting()
	self._mapNode.Energy:Init(function()
	end, true)
	self._mapNode.Dispatch:Init(function()
	end, true)
end
function SettingsNotificationCtrl:SaveSetting()
end
function SettingsNotificationCtrl:Awake()
	self.bInit = false
	self:RefreshText()
end
function SettingsNotificationCtrl:OnEnable()
end
function SettingsNotificationCtrl:OnDisable()
	if not self.bInit then
		return
	end
	self:SaveSetting()
end
function SettingsNotificationCtrl:OnDestroy()
end
return SettingsNotificationCtrl
