local BaseCtrl = require("GameCore.UI.BaseCtrl")
local CharFavourExpUpCtrl = class("CharFavourExpUpCtrl", BaseCtrl)
CharFavourExpUpCtrl._mapNodeConfig = {
	loopExpUpRoot = {
		sNodeName = "ExpUpRoot",
		sComponentName = "LoopScrollView"
	}
}
CharFavourExpUpCtrl._mapEventConfig = {}
function CharFavourExpUpCtrl:Awake()
	local tbParam = self:GetPanelParam()
	self.charData = tbParam[1]
end
function CharFavourExpUpCtrl:OnEnable()
	self.tbLevelUpList = {}
	self:OnRefresh()
end
function CharFavourExpUpCtrl:OnRefresh()
	local count = #self.charData
	for i = count, 1, -1 do
		local affinityLevel = PlayerData.Char:GetIsNeedShowAffinityLevelUp(self.charData[i])
		if affinityLevel < 0 and not PlayerData.Char:GetIsAffinityExpUp(self.charData[i]) then
			table.remove(self.charData, i)
		end
	end
	self._mapNode.loopExpUpRoot:Init(#self.charData, self, self.OnRefreshGrid)
	self:AddTimer(1, 0.1, "OpenLevelUpPanel", true, true, true)
end
function CharFavourExpUpCtrl:OnRefreshGrid(goGrid, gridIndex)
	local index = gridIndex + 1
	local data = self.charData[index]
	local rootTrans = goGrid.transform:Find("Root")
	local animRoot = rootTrans:GetComponent("Animator")
	local imgHead = rootTrans:Find("imgHead"):GetComponent("Image")
	local txtFavourLevel = rootTrans:Find("imgHead/txtFavourLevel"):GetComponent("TMP_Text")
	local txtName = rootTrans:Find("txtName"):GetComponent("TMP_Text")
	local imgHeart = rootTrans:Find("imgHead/imgHeart"):GetComponent("Image")
	local nSkinId = PlayerData.Char:GetCharSkinId(data)
	local mapCfgData_Skin = ConfigTable.GetData_CharacterSkin(nSkinId)
	self:SetPngSprite(imgHead, mapCfgData_Skin.Icon .. AllEnum.CharHeadIconSurfix.L)
	local mapData = PlayerData.Char:GetCharAffinityData(data)
	local level = 0
	local exp = 0
	if mapData ~= nil then
		level = mapData.Level
		exp = mapData.Exp
	end
	NovaAPI.SetTMPText(txtFavourLevel, level)
	local mapCharCfg = ConfigTable.GetData_Character(data)
	NovaAPI.SetTMPText(txtName, mapCharCfg.Name)
	local mapAffinity = {}
	local templateId = ConfigTable.GetData("CharAffinityTemplate", data).TemplateId
	local forEachAffinityLevel = function(mapData)
		if mapData.TemplateId == templateId and mapData.AffinityLevel == level then
			mapAffinity = mapData
		end
	end
	ForEachTableLine(DataTable.AffinityLevel, forEachAffinityLevel)
	if mapAffinity.AffinityLevelIcon ~= "" then
		self:SetPngSprite(imgHeart, mapAffinity.AffinityLevelIcon)
	end
	local affinityLevel, affinityExp = PlayerData.Char:GetIsNeedShowAffinityLevelUp(data)
	if 0 <= affinityLevel then
		table.insert(self.tbLevelUpList, {
			charID = data,
			curLevel = level,
			lastLevel = affinityLevel,
			curExp = exp,
			lastExp = affinityExp
		})
	end
	self:AddTimer(1, 0.8, function()
		animRoot:SetTrigger("out")
	end, true, true, true)
end
function CharFavourExpUpCtrl:OpenLevelUpPanel()
	if #self.tbLevelUpList <= 0 then
		return
	end
	EventManager.Hit(EventId.OpenPanel, PanelId.CharFavourLevelUp, self.tbLevelUpList)
end
return CharFavourExpUpCtrl
