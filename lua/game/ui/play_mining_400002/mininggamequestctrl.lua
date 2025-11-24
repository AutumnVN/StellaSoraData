local MiningGameQuestCtrl = class("MiningGameQuestCtrl", BaseCtrl)
local totalLength = 520
local totalHeight = 37
MiningGameQuestCtrl._mapNodeConfig = {
	loopSv = {
		sNodeName = "questList",
		sComponentName = "LoopScrollView"
	},
	rtBarFill = {
		sComponentName = "RectTransform"
	},
	btn_AllReceive = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_AllReceive"
	},
	txt_AllReceive = {
		ComponentName = "TMP_Text",
		"Mining_Quest_AllReceive"
	}
}
MiningGameQuestCtrl._mapEventConfig = {
	MiningQuestUpdate = "InitQuestData"
}
function MiningGameQuestCtrl:Awake(...)
	local param = self:GetPanelParam()
	if type(param) == "table" then
		self.nActId = param[1]
	end
	self:InitData()
end
function MiningGameQuestCtrl:OnDisable()
	for nInstanceId, objCtrl in pairs(self.tbGridCtrl) do
		self:UnbindCtrlByNode(objCtrl)
		self.tbGridCtrl[nInstanceId] = nil
	end
	self.tbGridCtrl = {}
end
function MiningGameQuestCtrl:InitData()
	self.actData = PlayerData.Activity:GetActivityDataById(self.nActId)
	self.tbQuestList = {}
	self.tbGridCtrl = {}
end
function MiningGameQuestCtrl:InitQuestData()
	self.tbQuestList = self.actData:GetAllQuestData()
	table.sort(self.tbQuestList, function(a, b)
		if a.nStatus == b.nStatus then
			return a.Id < b.Id
		end
		return a.nStatus < b.nStatus
	end)
	if nil ~= self.tbQuestList then
		for nInstanceId, objCtrl in pairs(self.tbGridCtrl) do
			self:UnbindCtrlByNode(objCtrl)
			self.tbGridCtrl[nInstanceId] = nil
		end
		self._mapNode.loopSv:SetAnim(0.1)
		self._mapNode.loopSv:Init(#self.tbQuestList, self, self.OnGridRefresh)
		EventManager.Hit(EventId.TemporaryBlockInput, 0.5)
	end
	self._mapNode.rtBarFill.sizeDelta = Vector2(self.actData:GetCompleteCount() / #self.tbQuestList * totalLength, totalHeight)
end
function MiningGameQuestCtrl:OnGridRefresh(goGrid, gridIndex)
	local nIndex = gridIndex + 1
	local nInstanceId = goGrid:GetInstanceID()
	if not self.tbGridCtrl[nInstanceId] then
		self.tbGridCtrl[nInstanceId] = self:BindCtrlByNode(goGrid, "Game.UI.Play_Mining_400002.MiningQuestCellCtrl")
	end
	self.tbGridCtrl[nInstanceId]:SetData(self.nActId, self.tbQuestList[nIndex])
end
function MiningGameQuestCtrl:OnBtnClick_AllReceive()
	PlayerData.Activity:SendReceivePerQuest(self.nActId, 0, nil)
end
return MiningGameQuestCtrl
