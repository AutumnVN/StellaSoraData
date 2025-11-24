local DepotDiscSubSkillItem = class("DepotDiscSubSkillItem", BaseCtrl)
DepotDiscSubSkillItem._mapNodeConfig = {
	btnItem = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Item"
	},
	imgIconBg = {sComponentName = "Image"},
	imgSkillIcon = {sComponentName = "Image"},
	txtSkillName = {sComponentName = "TMP_Text"},
	txtLevel = {sComponentName = "TMP_Text"},
	txtActivated = {
		sComponentName = "TMP_Text",
		sLanguageId = "StarTower_Build_DiscSkill_MaxLevel"
	},
	imgChoose = {},
	canvasChoose = {sNodeName = "imgChoose", sComponentName = "Canvas"},
	goNoteList = {},
	goNote = {nCount = 3, sComponentName = "Image"},
	txtHas = {nCount = 3, sComponentName = "TMP_Text"}
}
DepotDiscSubSkillItem._mapEventConfig = {
	SelectDepotDiscSkill = "OnEvent_SelectDepotDiscSkill"
}
function DepotDiscSubSkillItem:SetItem(nSkillId, nDiscId, mapNote, nOrderInLayer)
	if nSkillId == nil then
		self._mapNode.btnItem.gameObject:SetActive(false)
		return
	end
	self._mapNode.btnItem.gameObject:SetActive(true)
	self.nSkillId = nSkillId
	self.nDiscId = nDiscId
	local subSkillCfg = ConfigTable.GetData("SecondarySkill", nSkillId)
	if subSkillCfg == nil then
		return
	end
	local tbGroup = CacheTable.GetData("_SecondarySkill", subSkillCfg.GroupId)
	local maxLevel = #tbGroup
	self:SetPngSprite(self._mapNode.imgIconBg, subSkillCfg.IconBg)
	self:SetPngSprite(self._mapNode.imgSkillIcon, subSkillCfg.Icon)
	NovaAPI.SetTMPText(self._mapNode.txtSkillName, subSkillCfg.Name)
	NovaAPI.SetTMPText(self._mapNode.txtLevel, ConfigTable.GetUIText("Skill_Level") .. subSkillCfg.Level)
	local bAvtive = self:CheckSkillActive(subSkillCfg, mapNote)
	if not bAvtive then
		NovaAPI.SetTMPText(self._mapNode.txtLevel, ConfigTable.GetUIText("StarTower_Depot_DiscSkill_NotActivated"))
	end
	local nNoteIndex = 1
	local bMax = maxLevel <= subSkillCfg.Level
	if not bMax then
		local nNextSkillId = bAvtive and nSkillId + 1 or nSkillId
		local nextSubSkillCfg = ConfigTable.GetData("SecondarySkill", nNextSkillId)
		if nextSubSkillCfg == nil then
			self._mapNode.goNoteList:SetActive(false)
			self._mapNode.txtActivated.gameObject:SetActive(true)
			return
		end
		local tbActiveNote = decodeJson(nextSubSkillCfg.NeedSubNoteSkills)
		for k, v in pairs(tbActiveNote) do
			local nNoteId = tonumber(k)
			local nNoteMax = tonumber(v)
			local nNoteHas = mapNote[nNoteId] or 0
			local noteCfg = ConfigTable.GetData("SubNoteSkill", nNoteId)
			if noteCfg ~= nil then
				self._mapNode.goNote[nNoteIndex].gameObject:SetActive(true)
				self:SetPngSprite(self._mapNode.goNote[nNoteIndex], noteCfg.Icon .. AllEnum.DiscSkillIconSurfix.Small)
				local sHasStr = ""
				if nNoteMax <= nNoteHas then
					sHasStr = "<color=#0ABEC5>" .. nNoteHas .. "</color>"
				else
					sHasStr = "<color=#5E89B4>" .. nNoteHas .. "</color>"
					bMax = false
				end
				NovaAPI.SetTMPText(self._mapNode.txtHas[nNoteIndex], sHasStr .. "<color=#264278>/" .. nNoteMax .. "</color>")
			end
			nNoteIndex = nNoteIndex + 1
		end
	end
	self._mapNode.goNoteList:SetActive(not bMax)
	self._mapNode.txtActivated.gameObject:SetActive(bMax)
	if nil ~= nOrderInLayer then
		NovaAPI.SetCanvasSortingOrder(self._mapNode.canvasChoose, nOrderInLayer)
	end
end
function DepotDiscSubSkillItem:CheckSkillActive(subSkillCfg, mapNote)
	if subSkillCfg.Level == 1 then
		local tbActiveNote = decodeJson(subSkillCfg.NeedSubNoteSkills)
		for k, v in pairs(tbActiveNote) do
			local nNoteId = tonumber(k)
			local nNoteMax = tonumber(v)
			local nNoteHas = mapNote[nNoteId] or 0
			local noteCfg = ConfigTable.GetData("SubNoteSkill", nNoteId)
			if noteCfg ~= nil and nNoteMax > nNoteHas then
				return false
			end
		end
	end
	return true
end
function DepotDiscSubSkillItem:OnBtnClick_Item()
	EventManager.Hit("SelectDepotDiscSkill", self.nDiscId, nil, self.nSkillId)
end
function DepotDiscSubSkillItem:OnEvent_SelectDepotDiscSkill(nDiscId, nMainSkillId, nSubSkillId, _)
	self._mapNode.imgChoose:SetActive(self.nSkillId == nSubSkillId)
end
function DepotDiscSubSkillItem:OnEnable()
	for i, v in ipairs(self._mapNode.goNote) do
		self._mapNode.goNote[i].gameObject:SetActive(false)
	end
end
return DepotDiscSubSkillItem
