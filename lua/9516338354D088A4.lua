local MiningStoryCtrl = class("MiningStoryCtrl", BaseCtrl)
MiningStoryCtrl._mapNodeConfig = {
	txt_Title = {sComponentName = "TMP_Text"},
	loosv = {
		sNodeName = "storyList",
		sComponentName = "LoopScrollView"
	},
	btn_Close = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_ClosePanel"
	}
}
MiningStoryCtrl._mapEventConfig = {
	MiningStoryFinish = "RefreshData"
}
function MiningStoryCtrl:Init()
	self.tbStoryList = {}
	self.tbGridCtrl = {}
	self.actData = nil
end
function MiningStoryCtrl:Awake(...)
	local param = self:GetPanelParam()
	if type(param) == "table" then
		self.nActId = param[1]
	end
	self:RefreshData()
end
function MiningStoryCtrl:OnDisable()
end
function MiningStoryCtrl:OnDestroy(...)
	if not self.tbGridCtrl then
		for k, v in pairs(self.tbGridCtrl) do
			self:UnBindCtrlByNode(v)
		end
	end
end
function MiningStoryCtrl:RefreshData(...)
	self:Init()
	self:GetData()
end
function MiningStoryCtrl:GetData()
	self.actData = PlayerData.Activity:GetActivityDataById(self.nActId)
	self.tbStoryList = self.actData:GetGroupStoryData()
	table.sort(self.tbStoryList, function(a, b)
		return a.id < b.id
	end)
	self._mapNode.loosv:SetAnim(0.1)
	self._mapNode.loosv:Init(#self.tbStoryList, self, self.OnGridRefresh)
end
function MiningStoryCtrl:OnGridRefresh(gridGo, gridIndex)
	local nIndex = gridIndex + 1
	local nInstanceId = gridGo:GetInstanceID()
	if not self.tbGridCtrl[nInstanceId] then
		self.tbGridCtrl[nInstanceId] = self:BindCtrlByNode(gridGo, "Game.UI.Play_Mining.400003.MiningStoryCellCtrl")
	end
	local data = self.tbStoryList[nIndex]
	self.tbGridCtrl[nInstanceId]:SetData(data.id, nIndex, data.bIsLock, data.bIsRead)
end
function MiningStoryCtrl:OnBtnClick_ClosePanel()
	EventManager.Hit(EventId.ClosePanel, PanelId.MiningGameStory_400002)
end
return MiningStoryCtrl
