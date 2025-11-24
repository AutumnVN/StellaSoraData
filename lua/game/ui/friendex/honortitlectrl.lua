local BaseCtrl = require("GameCore.UI.BaseCtrl")
local HonorTitleCtrl = class("HonorTitleCtrl", BaseCtrl)
HonorTitleCtrl._mapNodeConfig = {
	imgHonorTitle = {sComponentName = "Image"},
	imgStar = {nCount = 5, sComponentName = "Image"},
	imgStarSmall = {nCount = 5, sComponentName = "Image"},
	goStarBig = {},
	goStarSmall = {},
	Reddot = {}
}
HonorTitleCtrl._mapEventConfig = {}
local HonorTitleStarPath = {
	"zs_honor_level_0",
	"zs_honor_level_2",
	"zs_honor_level_1",
	"zs_honor_level_4",
	"zs_honor_level_3"
}
function HonorTitleCtrl:SetHonotTitle(honorTitleId, bBig, affinity_lv)
	local honorData = ConfigTable.GetData("Honor", honorTitleId)
	self:SetPngSprite(self._mapNode.imgHonorTitle, bBig and honorData.MainRes or honorData.SubRes)
	NovaAPI.SetImageNativeSize(self._mapNode.imgHonorTitle)
	if honorData.Type ~= GameEnum.honorType.Character then
		self._mapNode.goStarBig:SetActive(false)
		self._mapNode.goStarSmall:SetActive(false)
		return
	end
	local maxLevel = 1
	self.tbHonorTitle, maxLevel = PlayerData.Char:GetCharHonorTitleData(honorData.Params[1])
	if self.tbHonorTitle == nil then
		return
	end
	local level = affinity_lv
	self.curData = {}
	if maxLevel < level then
		self.curData = self.tbHonorTitle[maxLevel]
	else
		self.curData = self.tbHonorTitle[level]
	end
	if self.curData == nil then
		self._mapNode.goStarBig:SetActive(false)
		self._mapNode.goStarSmall:SetActive(false)
		return
	end
	self:SetPngSprite(self._mapNode.imgHonorTitle, bBig and self.curData.BigBgPath or self.curData.SmallBgPath)
	self._mapNode.goStarBig:SetActive(bBig)
	self._mapNode.goStarSmall:SetActive(not bBig)
	for i = 1, 5 do
		if self.curData.StarGroup[i] ~= nil then
			if bBig then
				self:SetAtlasSprite(self._mapNode.imgStar[i], "10_ico", HonorTitleStarPath[self.curData.StarGroup[i]])
			else
				self:SetAtlasSprite(self._mapNode.imgStarSmall[i], "10_ico", HonorTitleStarPath[self.curData.StarGroup[i]])
			end
		end
		if bBig then
			self._mapNode.imgStar[i].gameObject:SetActive(self.curData.StarGroup[i] ~= nil)
		else
			self._mapNode.imgStarSmall[i].gameObject:SetActive(self.curData.StarGroup[i] ~= nil)
		end
	end
end
function HonorTitleCtrl:RegisterRedDot(honorTitleId)
	self.honorId = honorTitleId
	RedDotManager.RegisterNode(RedDotDefine.Friend_Honor_Title_Item, honorTitleId, self._mapNode.Reddot, nil, nil, true)
end
return HonorTitleCtrl
