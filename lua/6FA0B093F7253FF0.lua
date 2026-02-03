local ThrowGiftItemSelectCtrl = class("ThrowGiftItemSelectCtrl", BaseCtrl)
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
ThrowGiftItemSelectCtrl._mapNodeConfig = {
	btnItemSelect = {
		nCount = 2,
		sComponentName = "UIButton",
		callback = "OnBtnClick_Item"
	},
	btnItemSelectCtrl = {
		sNodeName = "btnItemSelect",
		nCount = 2,
		sCtrlName = "Game.UI.Activity.ThrowGifts.ItemSelect.ThrowGiftItemSelectGridCtrl"
	},
	rtPos = {nCount = 2}
}
ThrowGiftItemSelectCtrl._mapEventConfig = {
	ThrowGiftItemSelectConfirmClick = "OnEvent_ThrowGiftItemSelectConfirmClick"
}
ThrowGiftItemSelectCtrl._mapRedDotConfig = {}
function ThrowGiftItemSelectCtrl:Awake()
end
function ThrowGiftItemSelectCtrl:FadeIn()
end
function ThrowGiftItemSelectCtrl:FadeOut()
end
function ThrowGiftItemSelectCtrl:OnEnable()
	self.bSelected = false
	self.curIdx = 0
	self.tbOriginPos = {}
	self.tbOriginPos[1] = self._mapNode.btnItemSelectCtrl[1].gameObject.transform.position
	self.tbOriginPos[2] = self._mapNode.btnItemSelectCtrl[2].gameObject.transform.position
end
function ThrowGiftItemSelectCtrl:OnDisable()
end
function ThrowGiftItemSelectCtrl:OnDestroy()
end
function ThrowGiftItemSelectCtrl:OnRelease()
end
function ThrowGiftItemSelectCtrl:OpenPanel(tbItem, callback, curIdx)
	self.curPosIdx = curIdx
	self.gameObject:SetActive(true)
	self.callback = callback
	self.bSelected = false
	self.curIdx = 0
	self._mapNode.btnItemSelectCtrl[1]:Refresh(tbItem[1])
	self._mapNode.btnItemSelectCtrl[2]:Refresh(tbItem[2])
	self._mapNode.btnItemSelectCtrl[1]:SetSelect(false)
	self._mapNode.btnItemSelectCtrl[2]:SetSelect(false)
	self._mapNode.btnItemSelectCtrl[1].gameObject.transform.position = self.tbOriginPos[1]
	self._mapNode.btnItemSelectCtrl[2].gameObject.transform.position = self.tbOriginPos[2]
	self._mapNode.btnItemSelectCtrl[1].gameObject.transform.localEulerAngles = Vector3(0, 0, 0)
	self._mapNode.btnItemSelectCtrl[2].gameObject.transform.localEulerAngles = Vector3(0, 0, 0)
	WwiseAudioMgr:PostEvent("Mode_Present_intensify")
end
function ThrowGiftItemSelectCtrl:OnBtnClick_Item(btn, nIdx)
	WwiseAudioMgr:PostEvent("Mode_Present_intensify_choose")
	if self.bSelected then
		return
	end
	if self.curIdx == nIdx then
		return
	end
	self._mapNode.btnItemSelectCtrl[1]:SetSelect(nIdx == 1)
	self._mapNode.btnItemSelectCtrl[2]:SetSelect(nIdx == 2)
	self.curIdx = nIdx
end
function ThrowGiftItemSelectCtrl:OnEvent_ThrowGiftItemSelectConfirmClick()
	if self.bSelected then
		return
	end
	if self.curIdx == 0 then
		return
	end
	self.bSelected = true
	self._mapNode.btnItemSelectCtrl[self.curIdx]:PlaySelectAnim()
	WwiseAudioMgr:PostEvent("Mode_Present_intensify_ok")
	local endPos = self._mapNode.rtPos[self.curPosIdx].transform.position
	local beginPos = self._mapNode.btnItemSelectCtrl[self.curIdx].gameObject.transform.position
	local controlPos = Vector3(3, 5, 0)
	local wait = function()
		local totalMoveTime = 0.3
		local moveTime = 0
		local normalizedTime = 0
		while normalizedTime < 1 do
			moveTime = moveTime + CS.UnityEngine.Time.unscaledDeltaTime
			normalizedTime = moveTime / totalMoveTime
			normalizedTime = normalizedTime <= 1 and normalizedTime or 1
			local x, y, z = UTILS.GetBezierPointByT(beginPos, controlPos, endPos, normalizedTime)
			local angleZ = 100 * normalizedTime * 2
			self._mapNode.btnItemSelectCtrl[self.curIdx].gameObject.transform.localEulerAngles = Vector3(0, 0, angleZ)
			self._mapNode.btnItemSelectCtrl[self.curIdx].gameObject.transform.position = Vector3(x, y, z)
			coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		end
		if self.callback ~= nil and type(self.callback) == "function" then
			self.callback(self.curIdx)
		end
		self.gameObject:SetActive(false)
	end
	cs_coroutine.start(wait)
end
return ThrowGiftItemSelectCtrl
