local PenguinCardSlotCtrl = class("PenguinCardSlotCtrl", BaseCtrl)
local WwiseManger = CS.WwiseAudioManager.Instance
PenguinCardSlotCtrl._mapNodeConfig = {
	PenguinCardItem = {
		nCount = 6,
		sCtrlName = "Game.UI.Play_PenguinCard.PenguinCardItemCtrl"
	},
	goEmptySlot = {nCount = 6},
	imgSlotLock = {nCount = 6}
}
PenguinCardSlotCtrl._mapEventConfig = {
	PenguinCard_AddSlot = "OnEvent_AddSlot",
	PenguinCard_SelectPenguinCard = "OnEvent_SelectPenguinCard",
	PenguinCard_SalePenguinCard = "OnEvent_SalePenguinCard"
}
function PenguinCardSlotCtrl:Refresh()
	for i = 1, 6 do
		self:RefreshSlot(i)
	end
end
function PenguinCardSlotCtrl:RefreshSlot(nIndex)
	local mapCard = self._panel.mapLevel.tbPenguinCard[nIndex]
	self._mapNode.PenguinCardItem[nIndex].gameObject:SetActive(mapCard ~= 0)
	self._mapNode.goEmptySlot[nIndex]:SetActive(mapCard == 0)
	if mapCard == 0 then
		self._mapNode.imgSlotLock[nIndex]:SetActive(nIndex > self._panel.mapLevel.nSlotCount)
	else
		self._mapNode.PenguinCardItem[nIndex]:Refresh_Slot(mapCard)
	end
end
function PenguinCardSlotCtrl:Awake()
end
function PenguinCardSlotCtrl:OnEnable()
end
function PenguinCardSlotCtrl:OnDisable()
end
function PenguinCardSlotCtrl:OnEvent_AddSlot()
	self:RefreshSlot(self._panel.mapLevel.nSlotCount)
end
function PenguinCardSlotCtrl:OnEvent_SelectPenguinCard(nSlot, bUpgrade)
	self._mapNode.PenguinCardItem[nSlot].gameObject:SetActive(true)
	if bUpgrade then
		local callback = function()
			self._mapNode.PenguinCardItem[nSlot]:Refresh_Slot(self._panel.mapLevel.tbPenguinCard[nSlot])
		end
		self._mapNode.PenguinCardItem[nSlot]:PlayUpgradeAni(callback)
	else
		self._mapNode.PenguinCardItem[nSlot]:Refresh_Slot(self._panel.mapLevel.tbPenguinCard[nSlot])
		local callback = function()
			self._mapNode.goEmptySlot[nSlot]:SetActive(false)
		end
		self._mapNode.PenguinCardItem[nSlot]:PlaySelectAni(callback)
	end
end
function PenguinCardSlotCtrl:OnEvent_SalePenguinCard(nSlot)
	self._mapNode.goEmptySlot[nSlot]:SetActive(true)
	local callback = function()
		self._mapNode.PenguinCardItem[nSlot].gameObject:SetActive(false)
	end
	self._mapNode.PenguinCardItem[nSlot]:PlaySaleAni(callback)
end
return PenguinCardSlotCtrl
