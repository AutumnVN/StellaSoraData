local MiningStoryCellCtrl = class("MiningStoryCellCtrl", BaseCtrl)
MiningStoryCellCtrl._mapNodeConfig = {
	img_Story = {sComponentName = "Image"},
	txt_Index = {sComponentName = "TMP_Text"},
	txt_Lock = {sComponentName = "TMP_Text"},
	go_LockMask = {},
	txt_Title = {sComponentName = "TMP_Text"},
	btn_GoAvg = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_PlayAvg"
	}
}
function MiningStoryCellCtrl:Init()
	self.nStoryId = 0
	self.config = nil
	self.bIsRead = false
	self.callback = nil
	self.nIndex = 0
end
function MiningStoryCellCtrl:Awake(...)
end
function MiningStoryCellCtrl:OnDisable()
end
function MiningStoryCellCtrl:SetData(storyId, nIndex, bIsLock, bIsRead)
	self:Init()
	self.bIsRead = bIsRead
	self.nIndex = nIndex
	self.nStoryId = storyId
	self.config = ConfigTable.GetData("MiningStoryConfig", storyId)
	self._mapNode.go_LockMask:SetActive(bIsLock)
	self._mapNode.txt_Lock.gameObjct:SetActive(bIsLock)
	if bIsLock then
		NovaAPI.SetTMPText(self._mapNode.txt_Lock, string.format(ConfigTable.GetUIText("Plot_Index"), self.config.UnlockLayer))
	else
		NovaAPI.SetTMPText(self._mapNode.txt_Index, string.format(ConfigTable.GetUIText("Plot_Index"), nIndex))
		NovaAPI.SetTMPText(self._mapNode.txt_Title, string.format(ConfigTable.GetUIText(self.config.Title)))
		self:SetPngSprite(self._mapNode.img_Story, self.config.PicPath)
	end
end
function MiningStoryCellCtrl:OnBtnClick_PlayAvg()
	local function callback(...)
		if not self.bIsRead and callback ~= nil then
			callback(self.gameObject, self.nIndex - 1, self.nStoryId)
		end
		EventManager.Hit(EventId.ClosePanel, PanelId.PureAvgStory)
	end
	local mapData = {
		nType = AllEnum.StoryAvgType.Plot,
		sAvgId = self.config.AvgId,
		nNodeId = nil,
		callback = callback
	}
	EventManager.Hit(EventId.OpenPanel, PanelId.PureAvgStory, mapData)
end
return MiningStoryCellCtrl
