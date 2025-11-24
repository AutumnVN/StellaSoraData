local JointDrillRoomInfo = class("JointDrillRoomInfo", BaseCtrl)
JointDrillRoomInfo._mapNodeConfig = {
	canvasGroup = {
		sNodeName = "----SafeAreaRoot----",
		sComponentName = "CanvasGroup"
	}
}
JointDrillRoomInfo._mapEventConfig = {
	InputEnable = "OnEvent_InputEnable"
}
function JointDrillRoomInfo:Awake()
end
function JointDrillRoomInfo:OnEnable()
end
function JointDrillRoomInfo:OnDisable()
end
function JointDrillRoomInfo:OnEvent_InputEnable(bEnable)
	NovaAPI.SetCanvasGroupAlpha(self._mapNode.canvasGroup, bEnable and 1 or 0)
end
return JointDrillRoomInfo
