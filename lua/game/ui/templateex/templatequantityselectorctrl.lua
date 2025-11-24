local TemplateQuantitySelectorCtrl = class("TemplateQuantitySelectorCtrl", BaseCtrl)
TemplateQuantitySelectorCtrl._mapNodeConfig = {
	btnReduce = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Reduce"
	},
	btnAdd = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Add"
	},
	btnMax = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Max"
	},
	btnMin = {
		sComponentName = "UIButton",
		callback = "OnBtnClick_Min"
	},
	btnGrayAdd = {
		nCount = 2,
		sComponentName = "UIButton",
		callback = "OnBtnClick_MaxGray"
	},
	btnGrayReduce = {
		nCount = 2,
		sComponentName = "UIButton",
		callback = "OnBtnClick_MinGray"
	},
	inputCount = {
		sComponentName = "TMP_InputField"
	},
	Placeholder = {sComponentName = "TMP_Text"}
}
TemplateQuantitySelectorCtrl._mapEventConfig = {}
function TemplateQuantitySelectorCtrl:Init(funcRefresh, nDefaultCount, nMax, bHideSide)
	self.callback = funcRefresh
	self.nMax = nMax
	self.nBuyCount = nDefaultCount
	self.bAble = nDefaultCount ~= 0
	self.bHideSide = bHideSide
	NovaAPI.SetTMPInputFieldInteractable(self._mapNode.inputCount, self.bAble)
	self:RefreshCount()
end
function TemplateQuantitySelectorCtrl:RefreshCount()
	NovaAPI.SetTMPInputFieldText(self._mapNode.inputCount, self.nBuyCount)
	NovaAPI.SetTMPInputFieldPlaceholderText(self._mapNode.inputCount, self.nBuyCount)
	self:RefreshAddButton(self.nBuyCount < self.nMax and self.bAble)
	self:RefreshReduceButton(self.nBuyCount > 1 and self.bAble)
end
function TemplateQuantitySelectorCtrl:RefreshAddButton(bAble)
	self._mapNode.btnGrayAdd[1].gameObject:SetActive(not bAble and not self.bHideSide)
	self._mapNode.btnGrayAdd[2].gameObject:SetActive(not bAble)
	self._mapNode.btnAdd.gameObject:SetActive(bAble)
	self._mapNode.btnMax.gameObject:SetActive(bAble and not self.bHideSide)
end
function TemplateQuantitySelectorCtrl:RefreshReduceButton(bAble)
	self._mapNode.btnGrayReduce[1].gameObject:SetActive(not bAble)
	self._mapNode.btnGrayReduce[2].gameObject:SetActive(not bAble and not self.bHideSide)
	self._mapNode.btnReduce.gameObject:SetActive(bAble)
	self._mapNode.btnMin.gameObject:SetActive(bAble and not self.bHideSide)
end
function TemplateQuantitySelectorCtrl:Awake()
end
function TemplateQuantitySelectorCtrl:OnEnable()
	self.handler = ui_handler(self, self.OnInputEndEdit, self._mapNode.inputCount)
	NovaAPI.AddTMPEndEditListener(self._mapNode.inputCount, self.handler)
end
function TemplateQuantitySelectorCtrl:OnDisable()
	NovaAPI.RemoveTMPEndEditListener(self._mapNode.inputCount, self.handler)
end
function TemplateQuantitySelectorCtrl:OnDestroy()
end
function TemplateQuantitySelectorCtrl:OnBtnClick_Add(btn)
	local nRemain = self.nMax - self.nBuyCount
	if nRemain <= 0 then
		return
	end
	if btn.Operate_Type == 0 then
		self.nBuyCount = self.nBuyCount + 1
	elseif btn.Operate_Type == 3 then
		local nAdd = 2 ^ btn.CurrentGear
		local nAfterRemain = nRemain - nAdd
		if nAfterRemain < 0 then
			nAdd = nRemain
		end
		self.nBuyCount = math.floor(self.nBuyCount + nAdd)
	end
	self:RefreshCount()
	self.callback(self.nBuyCount)
end
function TemplateQuantitySelectorCtrl:OnBtnClick_Reduce(btn)
	if self.nBuyCount <= 1 then
		return
	end
	if btn.Operate_Type == 0 then
		self.nBuyCount = self.nBuyCount - 1
	elseif btn.Operate_Type == 3 then
		self.nBuyCount = math.floor(self.nBuyCount - 2 ^ btn.CurrentGear)
	end
	if self.nBuyCount < 1 then
		self.nBuyCount = 1
	end
	self:RefreshCount()
	self.callback(self.nBuyCount)
end
function TemplateQuantitySelectorCtrl:OnBtnClick_Max()
	if self.nBuyCount == self.nMax then
		return
	end
	self.nBuyCount = self.nMax
	self:RefreshCount()
	self.callback(self.nBuyCount)
end
function TemplateQuantitySelectorCtrl:OnBtnClick_Min()
	if self.nBuyCount <= 1 then
		return
	end
	self.nBuyCount = 1
	self:RefreshCount()
	self.callback(self.nBuyCount)
end
function TemplateQuantitySelectorCtrl:OnInputEndEdit()
	local nValue = tonumber(NovaAPI.GetTMPInputFieldText(self._mapNode.inputCount))
	if not nValue then
		nValue = self.nBuyCount
	elseif nValue < 1 then
		nValue = 1
	elseif nValue > self.nMax then
		nValue = self.nMax
	end
	self.nBuyCount = nValue
	NovaAPI.SetTMPInputFieldText(self._mapNode.inputCount, nValue)
	NovaAPI.SetTMPInputFieldPlaceholderText(self._mapNode.inputCount, nValue)
	self:RefreshCount()
	self.callback(self.nBuyCount)
end
function TemplateQuantitySelectorCtrl:OnBtnClick_MinGray()
	EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("QuantitySelector_Min"))
end
function TemplateQuantitySelectorCtrl:OnBtnClick_MaxGray()
	EventManager.Hit(EventId.OpenMessageBox, ConfigTable.GetUIText("QuantitySelector_Max"))
end
return TemplateQuantitySelectorCtrl
