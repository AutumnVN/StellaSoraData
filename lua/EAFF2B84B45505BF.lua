local JointDrillContext = {}
JointDrillContext.Modes = {
	[GameEnum.JointDrillMode.JointDrill_Mode_1] = {
		sPlayerDataKey = "JointDrill_1",
		nFormationType = AllEnum.RegionBossFormationType.JointDrill,
		sCtrlNamespace = "Game.UI.JointDrill.JointDrill_1"
	},
	[GameEnum.JointDrillMode.JointDrill_Mode_2] = {
		sPlayerDataKey = "JointDrill_2",
		nFormationType = AllEnum.RegionBossFormationType.JointDrill_2,
		sCtrlNamespace = "Game.UI.JointDrill.JointDrill_2"
	}
}
JointDrillContext.PanelKeys = {
	"LevelSelect",
	"BuildList",
	"Result",
	"RankUp",
	"Quest",
	"Ranking",
	"RankDetail",
	"Raid"
}
JointDrillContext.Entries = {
	[510001] = {
		nJointDrillMode = GameEnum.JointDrillMode.JointDrill_Mode_1,
		tbPanelId = {
			LevelSelect = PanelId.JointDrillLevelSelect_510001,
			BuildList = PanelId.JointDrillBuildList_510001,
			Result = PanelId.JointDrillResult_510001,
			RankUp = PanelId.JointDrillRankUp_510001,
			Quest = PanelId.JointDrillQuest_510001,
			Ranking = PanelId.JointDrillRanking_510001,
			RankDetail = PanelId.JointDrillRankDetail_510001,
			Raid = PanelId.JointDrillRaid_510001
		}
	},
	[510003] = {
		nJointDrillMode = GameEnum.JointDrillMode.JointDrill_Mode_2,
		tbPanelId = {
			LevelSelect = PanelId.JointDrillLevelSelect_510003,
			BuildList = PanelId.JointDrillBuildList_510003,
			Result = PanelId.JointDrillResult_510003,
			RankUp = PanelId.JointDrillRankUp_510003,
			Quest = PanelId.JointDrillQuest_510003,
			Ranking = PanelId.JointDrillRanking_510003,
			RankDetail = PanelId.JointDrillRankDetail_510003,
			Raid = PanelId.JointDrillRaid_510003
		}
	},
	[510005] = {
		nJointDrillMode = GameEnum.JointDrillMode.JointDrill_Mode_2,
		tbPanelId = {
			LevelSelect = PanelId.JointDrillLevelSelect_510005,
			BuildList = PanelId.JointDrillBuildList_510005,
			Result = PanelId.JointDrillResult_510005,
			RankUp = PanelId.JointDrillRankUp_510005,
			Quest = PanelId.JointDrillQuest_510005,
			Ranking = PanelId.JointDrillRanking_510005,
			RankDetail = PanelId.JointDrillRankDetail_510005,
			Raid = PanelId.JointDrillRaid_510005
		}
	}
}
function JointDrillContext.Get(nActId)
	local entry = JointDrillContext.Entries[nActId]
	assert(entry, string.format("JointDrillContext.Get: unknown nActId=%s", tostring(nActId)))
	local modeInfo = JointDrillContext.Modes[entry.nJointDrillMode]
	assert(modeInfo, string.format("JointDrillContext.Get: nActId=%d declares unknown nJointDrillMode=%s", nActId, tostring(entry.nJointDrillMode)))
	return {
		nActId = nActId,
		nJointDrillMode = entry.nJointDrillMode,
		sPlayerDataKey = modeInfo.sPlayerDataKey,
		nFormationType = modeInfo.nFormationType,
		sCtrlNamespace = modeInfo.sCtrlNamespace,
		tbPanelId = entry.tbPanelId
	}
end
function JointDrillContext.GetPanelId(nActId, sPanelKey)
	local entry = JointDrillContext.Entries[nActId]
	assert(entry, string.format("JointDrillContext.GetPanelId: unknown nActId=%s", tostring(nActId)))
	local nPanelId = entry.tbPanelId[sPanelKey]
	assert(nPanelId, string.format("JointDrillContext.GetPanelId: nActId=%d has no tbPanelId.%s", nActId, tostring(sPanelKey)))
	return nPanelId
end
function JointDrillContext.GetMode(nJointDrillMode)
	local modeInfo = JointDrillContext.Modes[nJointDrillMode]
	assert(modeInfo, string.format("JointDrillContext.GetMode: unknown nJointDrillMode=%s", tostring(nJointDrillMode)))
	return modeInfo
end
function JointDrillContext.GetByMode(nJointDrillMode)
	for nActId, entry in pairs(JointDrillContext.Entries) do
		if entry.nJointDrillMode == nJointDrillMode then
			return JointDrillContext.Get(nActId)
		end
	end
	error(string.format("JointDrillContext.GetByMode: no entry with nJointDrillMode=%s", tostring(nJointDrillMode)))
end
return JointDrillContext
