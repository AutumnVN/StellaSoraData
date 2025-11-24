local MallPkgPopupCtrl = class("MallPkgPopupCtrl", BaseCtrl)
local JumpUtil = require("Game.Common.Utils.JumpUtil")
local ClientManager = CS.ClientManager.Instance
MallPkgPopupCtrl._mapNodeConfig = {
	goContent = {
		sNodeName = "---Common---"
	},
	btnGo = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Goto"
	},
	txtBtnGo = {
		sComponentName = "TMP_Text",
		sLanguageId = "Activity_PopUp_Goto_1"
	},
	btnClose = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	btnCloseBg = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	txtDate = {sComponentName = "TMP_Text"},
	txtTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "Mall_Package_PopupTitle"
	},
	ClickScreenToContinue = {
		sComponentName = "TMP_Text",
		sLanguageId = "Tips_Continue"
	}
}
MallPkgPopupCtrl._mapEventConfig = {}
function MallPkgPopupCtrl:ShowPopUp(id, callback, index)
	self.popUpIndex = index
	self.nCurId = id
	self.callback = callback
	self.mapCfg = ConfigTable.GetData("PopUp", self.nCurId)
	self.nOpenTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(self.mapCfg.StartTime)
	self.nEndTime = CS.ClientManager.Instance:ISO8601StrToTimeStamp(self.mapCfg.EndTime)
	self:RefreshDate()
	self.anim = self.gameObject:GetComponent("Animator")
	self:PlayOpenAnim()
end
function MallPkgPopupCtrl:PlayOpenAnim()
	if self.anim then
		self.anim:Play("open", 0, 0)
	end
end
function MallPkgPopupCtrl:RefreshDate()
	local nOpenMonth = tonumber(os.date("%m", self.nOpenTime))
	local nOpenDay = tonumber(os.date("%d", self.nOpenTime))
	local nEndMonth = tonumber(os.date("%m", self.nEndTime))
	local nEndDay = tonumber(os.date("%d", self.nEndTime))
	local strOpenDay = string.format("%02d", nOpenDay)
	local strEndDay = string.format("%02d", nEndDay)
	local dateStr = string.format("%s/%s ~ %s/%s", nOpenMonth, strOpenDay, nEndMonth, strEndDay)
	NovaAPI.SetTMPText(self._mapNode.txtDate, dateStr)
end
function MallPkgPopupCtrl:ClosePopUp(callback)
	if self.anim ~= nil then
		self.anim:Play("close", 0, 0)
		self:AddTimer(1, 0.1, function()
			if callback ~= nil then
				callback()
			end
		end, true, true, true)
		EventManager.Hit(EventId.TemporaryBlockInput, 0.1)
	elseif callback ~= nil then
		callback()
	end
end
function MallPkgPopupCtrl:OnBtnClick_Close()
	self:ClosePopUp(self.callback)
end
function MallPkgPopupCtrl:OnBtnClick_Goto()
	local callback = function()
		if nil ~= self.nCurId then
			PopUpManager.InterruptPopUp(self.popUpIndex)
			local endTime = self.nEndTime
			local curTime = ClientManager.serverTimeStamp
			local remainTime = endTime - curTime
			if remainTime <= 0 then
				EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("Mall_Package_Expired"))
				if self.callback ~= nil then
					self.callback()
				end
				return
			end
			EventManager.Hit(EventId.ClosePanel, PanelId.ActivityPopUp)
			JumpUtil.JumpTo(self.mapCfg.JumpToParams)
		end
	end
	self:ClosePopUp(callback)
end
return MallPkgPopupCtrl
