local StarTowerBuildDetailItemCtrl = class("StarTowerBuildDetailItemCtrl", BaseCtrl)
StarTowerBuildDetailItemCtrl._mapNodeConfig = {
	imgRareFrame = {sComponentName = "Image"},
	imgRareScore = {sComponentName = "Image"},
	txtScoreCn = {
		sComponentName = "TMP_Text",
		sLanguageId = "Build_Score"
	},
	txtScore = {sComponentName = "TMP_Text"},
	txtChar = {
		sComponentName = "TMP_Text",
		sLanguageId = "StarTower_Build_Char_Title"
	},
	btnLeader = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Leader"
	},
	btnSub = {
		nCount = 2,
		sComponentName = "UIButton",
		callback = "OnBtnClick_Sub"
	},
	imgCharIcon = {nCount = 3, sComponentName = "Image"},
	imgCharFrame = {nCount = 3, sComponentName = "Image"},
	txtPotentialCount = {nCount = 3, sComponentName = "TMP_Text"},
	txtBuildName = {sComponentName = "TMP_Text"},
	txtDisc = {
		sComponentName = "TMP_Text",
		sLanguageId = "StarTower_Build_MainDisc_Title"
	},
	txtLeaderCn = {
		sComponentName = "TMP_Text",
		sLanguageId = "StarTower_Build_Leader"
	},
	txtSubCn = {
		nCount = 2,
		sComponentName = "TMP_Text",
		sLanguageId = "StarTower_Build_Sub"
	},
	imgCharElement = {nCount = 3, sComponentName = "Image"},
	btnDiscItem = {
		nCount = 3,
		sComponentName = "UIButton",
		callback = "OnBtnClick_Disc"
	},
	goDiscItem = {
		nCount = 3,
		sCtrlName = "Game.UI.StarTower.Build.BuildSimpleDiscItem"
	},
	btnDiscDetail = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_DiscDetail"
	},
	btnAttr = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Attr"
	},
	txtAttr = {sComponentName = "TMP_Text"}
}
StarTowerBuildDetailItemCtrl._mapEventConfig = {}
StarTowerBuildDetailItemCtrl._mapRedDotConfig = {}
function StarTowerBuildDetailItemCtrl:Refresh(mapData)
	self.mapBuild = mapData
	self:RefreshInfo()
	self:RefreshChar()
	self:RefreshDisc()
end
function StarTowerBuildDetailItemCtrl:RefreshInfo()
	local sScore = "Icon/BuildRank/BuildRank_" .. self.mapBuild.mapRank.Id
	local sFrame = AllEnum.FrameType_New.BuildRankDB .. AllEnum.FrameColor_New[self.mapBuild.mapRank.Rarity]
	self:SetPngSprite(self._mapNode.imgRareScore, sScore)
	self:SetAtlasSprite(self._mapNode.imgRareFrame, "12_rare", sFrame)
	NovaAPI.SetTMPText(self._mapNode.txtScore, self.mapBuild.nScore)
	if self.mapBuild.sName == "" or self.mapBuild.sName == nil then
		NovaAPI.SetTMPText(self._mapNode.txtBuildName, ConfigTable.GetUIText("RoguelikeBuild_EmptyBuildName"))
	else
		NovaAPI.SetTMPText(self._mapNode.txtBuildName, self.mapBuild.sName)
	end
	NovaAPI.SetTMPText(self._mapNode.txtAttr, UTILS.ParseParamDesc(ConfigTable.GetUIText(self.mapBuild.mapRank.Desc), self.mapBuild.mapRank))
end
function StarTowerBuildDetailItemCtrl:RefreshChar()
	for i = 1, 3 do
		local nCharTid = self.mapBuild.tbChar[i].nTid
		local nCharSkinId = PlayerData.Char:GetCharSkinId(nCharTid)
		local mapCharSkin = ConfigTable.GetData_CharacterSkin(nCharSkinId)
		local mapCharCfg = ConfigTable.GetData_Character(nCharTid)
		local sFrame = AllEnum.FrameType_New.BoardFrame .. AllEnum.BoardFrameColor[mapCharCfg.Grade]
		self:SetPngSprite(self._mapNode.imgCharIcon[i], mapCharSkin.Icon .. AllEnum.CharHeadIconSurfix.XXL)
		self:SetAtlasSprite(self._mapNode.imgCharFrame[i], "12_rare", sFrame, true)
		NovaAPI.SetTMPText(self._mapNode.txtPotentialCount[i], self.mapBuild.tbChar[i].nPotentialCount)
		self:SetAtlasSprite(self._mapNode.imgCharElement[i], "12_rare", AllEnum.Char_Element[mapCharCfg.EET].icon)
	end
end
function StarTowerBuildDetailItemCtrl:RefreshDisc()
	local nIndex = 1
	for _, nId in ipairs(self.mapBuild.tbDisc) do
		if nil ~= self._mapNode.goDiscItem[nIndex] and nIndex <= 3 then
			self._mapNode.goDiscItem[nIndex]:Init(nId)
		end
		nIndex = nIndex + 1
	end
end
function StarTowerBuildDetailItemCtrl:SetName(sName)
	NovaAPI.SetTMPText(self._mapNode.txtBuildName, sName)
end
function StarTowerBuildDetailItemCtrl:Awake()
end
function StarTowerBuildDetailItemCtrl:FadeIn()
end
function StarTowerBuildDetailItemCtrl:FadeOut()
end
function StarTowerBuildDetailItemCtrl:OnEnable()
end
function StarTowerBuildDetailItemCtrl:OnDisable()
end
function StarTowerBuildDetailItemCtrl:OnDestroy()
end
function StarTowerBuildDetailItemCtrl:OnRelease()
end
function StarTowerBuildDetailItemCtrl:OnBtnClick_Attr()
	EventManager.Hit(EventId.OpenPanel, PanelId.BuildAttrPreview, self.mapBuild.mapRank.Id, self.mapBuild.nScore)
end
function StarTowerBuildDetailItemCtrl:OnBtnClick_Disc(btn, nIndex)
	local nIdx = 0
	local nDiscId = 0
	local tbAllDisc = {}
	for _, nId in ipairs(self.mapBuild.tbDisc) do
		nIdx = nIdx + 1
		if nIdx == nIndex then
			nDiscId = nId
		end
		table.insert(tbAllDisc, nId)
	end
	if nDiscId ~= 0 then
		EventManager.Hit(EventId.OpenPanel, PanelId.Disc, nDiscId, tbAllDisc)
	end
end
function StarTowerBuildDetailItemCtrl:OnBtnClick_Leader()
	local tbCharId = {}
	for _, v in ipairs(self.mapBuild.tbChar) do
		table.insert(tbCharId, v.nTid)
	end
	EventManager.Hit(EventId.OpenPanel, PanelId.CharBgPanel, PanelId.CharInfo, tbCharId[1], tbCharId, true)
end
function StarTowerBuildDetailItemCtrl:OnBtnClick_Sub(btn, nIndex)
	local tbCharId = {}
	for _, v in ipairs(self.mapBuild.tbChar) do
		table.insert(tbCharId, v.nTid)
	end
	EventManager.Hit(EventId.OpenPanel, PanelId.CharBgPanel, PanelId.CharInfo, tbCharId[nIndex + 1], tbCharId, true)
end
function StarTowerBuildDetailItemCtrl:OnBtnClick_DiscDetail()
	local tbDisc = {}
	local mapDiscData = {}
	for i = 1, 6 do
		tbDisc[i] = self.mapBuild.tbDisc[i] or 0
		if 0 ~= tbDisc[i] then
			mapDiscData[tbDisc[i]] = PlayerData.Disc:GetDiscById(tbDisc[i])
		end
	end
	EventManager.Hit(EventId.OpenPanel, PanelId.DiscSkill, tbDisc, self.mapBuild.tbNotes, mapDiscData)
end
return StarTowerBuildDetailItemCtrl
