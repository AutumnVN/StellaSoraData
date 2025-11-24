local ActivityAvgInfoExCtrl = class("ActivityAvgInfoExCtrl", BaseCtrl)
local AvgData = PlayerData.ActivityAvg
ActivityAvgInfoExCtrl._mapNodeConfig = {
	mainLineAvgLvName = {sComponentName = "TMP_Text"},
	mainLineAvgLvNum = {sComponentName = "TMP_Text"},
	mainLineAvgLvDes = {sComponentName = "TMP_Text"},
	mainLineBattleLvName = {sComponentName = "TMP_Text"},
	mainLineBattleLvNum = {sComponentName = "TMP_Text"},
	txtBattleStoryDesc = {sComponentName = "TMP_Text"},
	mainLineAvgBtnTex = {
		sComponentName = "TMP_Text",
		sLanguageId = "WorldMap_MainLine_Avg_Btn"
	},
	mainLineAvgBtn = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_OpenAvg"
	},
	btnClose = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	btnCancel = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Close"
	},
	animator = {sNodeName = "rtWindow", sComponentName = "Animator"},
	btnEnemy = {
		sNodeName = "btnEnemy",
		sComponentName = "UIButton",
		callback = "OnBtnClick_MonsterInfo"
	},
	imgBattleIcon = {},
	txtClueNotice = {},
	imgClueNotice = {},
	goBattleRoot = {},
	goAvgRoot = {},
	goRewardInfo = {},
	imgReward = {sComponentName = "Image"},
	txtRewardCount = {sComponentName = "TMP_Text"},
	txtAvgRewardTitle = {sComponentName = "TMP_Text", sLanguageId = "Level_Info"},
	txtCancelBtn = {
		sComponentName = "TMP_Text",
		sLanguageId = "MainLine_Select_Btn_Cancel"
	},
	txtReward = {
		sComponentName = "TMP_Text",
		sLanguageId = "STRanking_Reward_Btn"
	},
	txtBtnEnemy = {
		sComponentName = "TMP_Text",
		sLanguageId = "StarTower_Rank_Enemy_Info"
	}
}
ActivityAvgInfoExCtrl._mapEventConfig = {}
function ActivityAvgInfoExCtrl:Awake()
end
function ActivityAvgInfoExCtrl:FadeOut(callback)
	if type(callback) == "function" then
		callback()
	end
end
function ActivityAvgInfoExCtrl:OnEnable()
end
function ActivityAvgInfoExCtrl:OnDisable()
end
function ActivityAvgInfoExCtrl:OnDestroy()
end
function ActivityAvgInfoExCtrl:OnRelease()
end
function ActivityAvgInfoExCtrl:OpenLevelInfo(avgId, actId)
	self.avgId = avgId
	self.actId = actId
	local mapActivityAvg = ConfigTable.GetData("ActivityAvgLevel", avgId)
	if mapActivityAvg == nil then
		printError("nil mainlineData" .. avgId)
		return
	end
	NovaAPI.SetTMPText(self._mapNode.mainLineAvgLvNum, mapActivityAvg.Index)
	NovaAPI.SetTMPText(self._mapNode.mainLineAvgLvName, mapActivityAvg.Name)
	NovaAPI.SetTMPText(self._mapNode.mainLineAvgLvDes, mapActivityAvg.Desc)
	self._mapNode.goAvgRoot:SetActive(true)
	self._mapNode.goBattleRoot:SetActive(false)
	self._mapNode.txtClueNotice:SetActive(false)
	self._mapNode.imgClueNotice:SetActive(false)
	self._mapNode.goRewardInfo:SetActive(false)
	if not AvgData:IsActivityAvgReaded(self.actId, mapActivityAvg.Id) then
		local tbReward = decodeJson(mapActivityAvg.FirstCompleteRewardPreview)
		if 0 < #tbReward then
			self._mapNode.goRewardInfo:SetActive(true)
			self:SetPngSprite(self._mapNode.imgReward, ConfigTable.GetData_Item(tbReward[1][1]).Icon)
			NovaAPI.SetTMPText(self._mapNode.txtRewardCount, "\195\151" .. tbReward[1][2])
		end
	end
	self._mapNode.animator:Play("t_window_04_t_in")
end
function ActivityAvgInfoExCtrl:OnBtnClick_Close()
	self.gameObject:SetActive(false)
	EventManager.Hit("SelectMainlineBattle", false)
	EventManager.Hit("CloseActivityAvgInfo", false)
end
function ActivityAvgInfoExCtrl:OnBtnClick_MonsterInfo(btn)
end
function ActivityAvgInfoExCtrl:OnBtnClick_OpenAvg(btn)
	self.gameObject:SetActive(false)
	EventManager.Hit("SelectMainlineBattle", false)
	AvgData:EnterAvg(self.avgId, self.actId)
end
return ActivityAvgInfoExCtrl
