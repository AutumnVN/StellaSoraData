local JointDrillQuestCtrl = class("JointDrillQuestCtrl", BaseCtrl)
JointDrillQuestCtrl._mapNodeConfig = {
	goBlur = {
		sNodeName = "t_fullscreen_blur_01"
	},
	safeAreaRoot = {
		sNodeName = "----SafeAreaRoot----"
	},
	btnBgClose = {
		sComponentName = "Button",
		callback = "OnBtnClick_Close"
	},
	animWindow = {sNodeName = "goWindow", sComponentName = "Animator"},
	txtWindowTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "JointDrill_Rank_Score_Reward"
	},
	btnClose = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	txtScoreCn = {
		sComponentName = "TMP_Text",
		sLanguageId = "JointDrill_Rank_Week_Score_All"
	},
	txtWeekScore = {sComponentName = "TMP_Text"},
	questLSV = {
		sComponentName = "LoopScrollView"
	},
	btnReceive = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Receive"
	},
	txtBtnReceive = {
		sComponentName = "TMP_Text",
		sLanguageId = "JointDrill_Rank_Quest_Receive_All"
	}
}
JointDrillQuestCtrl._mapEventConfig = {}
JointDrillQuestCtrl._mapRedDotConfig = {}
function JointDrillQuestCtrl:Refresh()
	for goGrid, objCtrl in pairs(self.mapQuestGrid) do
		self:UnbindCtrlByNode(objCtrl)
		self.mapQuestGrid[goGrid] = nil
	end
	self.tbQuests = PlayerData.JointDrill:GetRewardQuestList()
	self._mapNode.questLSV:Init(#self.tbQuests, self, self.RefreshGrid)
	local nTotalScore = PlayerData.JointDrill:GetTotalRankScore()
	NovaAPI.SetTMPText(self._mapNode.txtWeekScore, FormatWithCommas(nTotalScore))
end
function JointDrillQuestCtrl:RefreshGrid(goGrid, gridIndex)
	local nIndex = gridIndex + 1
	if self.mapQuestGrid[goGrid] == nil then
		self.mapQuestGrid[goGrid] = self:BindCtrlByNode(goGrid, "Game.UI.JointDrill.JointDrillQuestItemCtrl")
	end
	local mapQuest = self.tbQuests[nIndex]
	self.mapQuestGrid[goGrid]:SetItem(mapQuest)
end
function JointDrillQuestCtrl:PlayCloseAni(callback)
	self._mapNode.animWindow:Play("t_window_04_t_out")
	EventManager.Hit(EventId.TemporaryBlockInput, 0.2)
	self:AddTimer(1, 0.2, "OnPanelClose", true, true, true, callback)
end
function JointDrillQuestCtrl:OnPanelClose(_, callback)
	EventManager.Hit(EventId.ClosePanel, PanelId.JointDrillQuest)
	if callback then
		callback()
	end
end
function JointDrillQuestCtrl:Awake()
	self.nActId = 0
	self.mapQuestGrid = {}
end
function JointDrillQuestCtrl:OnEnable()
	local tbParam = self:GetPanelParam()
	if tbParam ~= nil then
		self.nActId = tbParam[1]
	end
	self._mapNode.safeAreaRoot.gameObject:SetActive(false)
	self._mapNode.goBlur.gameObject:SetActive(true)
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		self._mapNode.safeAreaRoot.gameObject:SetActive(true)
		self._mapNode.animWindow:Play("t_window_04_t_in")
	end
	cs_coroutine.start(wait)
	self:Refresh()
end
function JointDrillQuestCtrl:OnDisable()
	for goGrid, objCtrl in pairs(self.mapQuestGrid) do
		self:UnbindCtrlByNode(objCtrl)
		self.mapQuestGrid[goGrid] = nil
	end
	self.mapQuestGrid = {}
end
function JointDrillQuestCtrl:OnDestroy()
end
function JointDrillQuestCtrl:OnBtnClick_Close()
	self:PlayCloseAni()
end
function JointDrillQuestCtrl:OnBtnClick_Receive()
	local bReceive = false
	for _, v in ipairs(self.tbQuests) do
		if v.Status == 1 then
			bReceive = true
			break
		end
	end
	if not bReceive then
		EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("JointDrill_Receive_Quest_Reward_Tip"))
		return
	end
	local callback = function()
		self:Refresh()
	end
	PlayerData.JointDrill:SendReceiveQuestReward(callback)
end
return JointDrillQuestCtrl
