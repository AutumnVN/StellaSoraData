local PenguinBaseCardCtrl = class("PenguinBaseCardCtrl", BaseCtrl)
local WwiseManger = CS.WwiseAudioManager.Instance
PenguinBaseCardCtrl._mapNodeConfig = {
	imgBg = {},
	imgIcon = {sComponentName = "Image"}
}
PenguinBaseCardCtrl._mapEventConfig = {}
function PenguinBaseCardCtrl:Refresh(nId, bOpen)
	self:RefreshIcon(bOpen)
	local mapCfg = ConfigTable.GetData("PenguinBaseCard", nId)
	if not mapCfg then
		return
	end
	self:SetSprite(self._mapNode.imgIcon, "UI/Play_PenguinCard/SpriteAtlas/Sprite/" .. mapCfg.Icon)
	self.nSuit = mapCfg.Suit1
end
function PenguinBaseCardCtrl:RefreshIcon(bOpen)
	self._mapNode.imgBg:SetActive(not bOpen)
	self._mapNode.imgIcon.gameObject:SetActive(bOpen)
end
function PenguinBaseCardCtrl:PlayFlipAni()
	self._mapNode.imgIcon.gameObject:SetActive(true)
	self.animator:Play("PengUinCard_Base_Turn", 0, 0)
	local nAnimTime = NovaAPI.GetAnimClipLength(self.animator, {
		"PengUinCard_Base_Turn"
	})
	self:AddTimer(1, nAnimTime, function()
		self._mapNode.imgBg:SetActive(false)
	end, true, true, true)
end
function PenguinBaseCardCtrl:PlayReplaceAni()
	self.animator:Play("PengUinCard_Base_Double", 0, 0)
end
function PenguinBaseCardCtrl:PlayTriggerAni(pos)
	if table.indexof(self._panel.mapLevel.tbHandRank, self.nSuit) == 0 then
		return
	end
	self.animator:Play("PengUinCard_Base_Open", 0, 0)
end
function PenguinBaseCardCtrl:PlayHideAni()
	self.animator:Play("PengUinCard_Base_Out", 0, 0)
end
function PenguinBaseCardCtrl:Awake()
	self.animator = self.gameObject:GetComponent("Animator")
end
function PenguinBaseCardCtrl:OnEnable()
end
function PenguinBaseCardCtrl:OnDisable()
end
return PenguinBaseCardCtrl
