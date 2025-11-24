local JointDrillTeamItemCtrl = class("JointDrillTeamItemCtrl", BaseCtrl)
JointDrillTeamItemCtrl._mapNodeConfig = {
	goCharItem = {nCount = 3},
	imgItemIcon = {nCount = 3, sComponentName = "Image"},
	imgItemRare = {nCount = 3, sComponentName = "Image"},
	txtRank = {nCount = 3, sComponentName = "TMP_Text"},
	imgScoreIcon = {sComponentName = "Image"},
	txtBuildTitle = {
		sComponentName = "TMP_Text",
		sLanguageId = "JointDrill_Rank_Build_Score"
	},
	txtTeam = {sComponentName = "TMP_Text"},
	txtLeaderCn = {
		sComponentName = "TMP_Text",
		sLanguageId = "Build_Leader"
	},
	txtSubCn = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "Build_Sub"
	}
}
JointDrillTeamItemCtrl._mapEventConfig = {}
JointDrillTeamItemCtrl._mapRedDotConfig = {}
function JointDrillTeamItemCtrl:GetBuildRank(nScore)
	local curIdx = -1
	local forEachReward = function(mapData)
		if nScore >= mapData.MinGrade and curIdx < mapData.Id then
			curIdx = mapData.Id
		end
	end
	ForEachTableLine(DataTable.StarTowerBuildRank, forEachReward)
	if curIdx < 0 then
		curIdx = 1
	end
	return curIdx
end
function JointDrillTeamItemCtrl:RefreshItem(mapTeam, nIndex)
	local sIndex = ConfigTable.GetUIText("JointDrill_Battle_Time_" .. nIndex)
	NovaAPI.SetTMPText(self._mapNode.txtTeam, orderedFormat(ConfigTable.GetUIText("JointDrill_Rank_Build_Count"), sIndex))
	for i = 1, 3 do
		local nCharId = mapTeam.Chars[i].Id
		local mapChar = ConfigTable.GetData_Character(nCharId)
		if mapChar ~= nil then
			NovaAPI.SetTMPText(self._mapNode.txtRank[i], mapTeam.Chars[i].Level)
			local nCharSkinId = mapChar.DefaultSkinId
			local mapCharSkin = ConfigTable.GetData_CharacterSkin(nCharSkinId)
			self:SetPngSprite(self._mapNode.imgItemIcon[i], mapCharSkin.Icon .. AllEnum.CharHeadIconSurfix.XXL)
			local nRarity = mapChar.Grade
			local sFrame = AllEnum.FrameType_New.BoardFrame .. AllEnum.BoardFrameColor[nRarity]
			self:SetAtlasSprite(self._mapNode.imgItemRare[i], "12_rare", sFrame, true)
		end
	end
	local nScore = self:GetBuildRank(mapTeam.BuildScore)
	self:SetPngSprite(self._mapNode.imgScoreIcon, "Icon/BuildRank/BuildRank_" .. nScore)
end
function JointDrillTeamItemCtrl:Awake()
end
function JointDrillTeamItemCtrl:OnEnable()
end
function JointDrillTeamItemCtrl:OnDisable()
end
function JointDrillTeamItemCtrl:OnDestroy()
end
return JointDrillTeamItemCtrl
