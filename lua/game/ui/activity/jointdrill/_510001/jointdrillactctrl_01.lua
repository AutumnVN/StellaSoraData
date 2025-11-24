local JointDrillActCtrl_01 = class("JointDrillActCtrl_01", BaseCtrl)
JointDrillActCtrl_01._mapNodeConfig = {
	goCommon = {
		sNodeName = "---Common---"
	}
}
JointDrillActCtrl_01._mapEventConfig = {
	PlayJointDrillActAnim = "OnEvent_PlayAnim"
}
function JointDrillActCtrl_01:UnbindCtrl()
	if self.activityCtrl ~= nil then
		self:UnbindCtrlByNode(self.activityCtrl)
		self.activityCtrl = nil
	end
end
function JointDrillActCtrl_01:InitActData(actData)
	if self.activityCtrl == nil then
		self.activityCtrl = self:BindCtrlByNode(self._mapNode.goCommon, "Game.UI.Activity.JointDrill.JointDrillActCtrl")
	end
	self.actData = actData
	self.nActId = actData:GetActId()
	self.activityCtrl:InitActData(actData)
end
function JointDrillActCtrl_01:ClearActivity()
	self:UnbindCtrl()
end
function JointDrillActCtrl_01:OnEvent_PlayAnim(sAnim, callback)
	if self.animRoot ~= nil then
		local nAnimTime = NovaAPI.GetAnimClipLength(self.animRoot, {sAnim})
		self.animRoot:Play(sAnim, 0, 0)
		self:AddTimer(1, nAnimTime, function()
			if callback ~= nil then
				callback()
			end
		end, true, true, true)
	elseif callback ~= nil then
		callback()
	end
end
function JointDrillActCtrl_01:OnEnable()
	self.animRoot = self.gameObject:GetComponent("Animator")
end
function JointDrillActCtrl_01:OnDisable()
	self:UnbindCtrl()
end
return JointDrillActCtrl_01
