local RedDotNode = class("RedDotNode")
local RedDotType = AllEnum.RedDotType
function RedDotNode:ctor(sKey, parent)
	self.bManualRefresh = nil
	self.sNodeKey = sKey
	self.parentNode = parent
	self.tbChildNodeList = nil
	self.nRedDotCount = 0
	self.tbObjNode = nil
	self.tbTxtRedDotCount = nil
	self.nShowType = nil
end
function RedDotNode:RegisterNode(objGo, nType, bManualRefresh)
	if nil == objGo then
		traceback(string.format("\230\179\168\229\134\140\231\186\162\231\130\185\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129\228\188\160\229\133\165\231\154\132gameObject\228\184\186\231\169\186.  nodeKey = %s", self.sNodeKey))
		return
	end
	if nil == nType then
		nType = RedDotType.Single
	end
	self.nShowType = nType
	self.bManualRefresh = bManualRefresh
	if self.tbObjNode == nil then
		self.tbObjNode = {}
	end
	if type(objGo) == "table" then
		for _, v in ipairs(objGo) do
			local nInstanceId = v.gameObject:GetInstanceID()
			self.tbObjNode[nInstanceId] = v.gameObject
		end
	else
		local nInstanceId = objGo.gameObject:GetInstanceID()
		self.tbObjNode[nInstanceId] = objGo.gameObject
	end
	self.tbTxtRedDotCount = {}
	for _, v in pairs(self.tbObjNode) do
		if v:IsNull() ~= true then
			local trObj = v.gameObject:GetComponent("Transform")
			local trNode = trObj:Find("---RedDot---")
			if nil == trNode then
				printError("\231\186\162\231\130\185UI\231\187\147\230\158\132\228\184\141\230\160\135\229\135\134\239\188\129\239\188\129\239\188\129\232\175\183\230\163\128\230\159\165")
				return
			end
			if nType == RedDotType.Number then
				local trText = trNode:Find("txtRedDot")
				if nil ~= trText then
					local nInstanceId = trText:GetInstanceID()
					self.tbTxtRedDotCount[nInstanceId] = trText:GetComponent("TMP_Text")
				end
			end
		end
	end
	self:RefreshRedDotShow()
end
function RedDotNode:UnRegisterNode(objGo)
	if nil == objGo then
		self.tbObjNode = nil
		self.tbTxtRedDotCount = nil
	else
		if self.tbObjNode == nil then
			return
		end
		if type(objGo) == "table" then
			for _, v in ipairs(objGo) do
				local nInstanceId = v:GetInstanceID()
				self.tbObjNode[nInstanceId] = nil
			end
		else
			local nInstanceId = objGo:GetInstanceID()
			self.tbObjNode[nInstanceId] = nil
		end
	end
end
function RedDotNode:AddChildNode(sKey)
	if nil == self.tbChildNodeList then
		self.tbChildNodeList = {}
	end
	local node = RedDotNode.new(sKey, self)
	table.insert(self.tbChildNodeList, node)
	return node
end
function RedDotNode:GetChildNode(sKey)
	if nil ~= self.tbChildNodeList then
		for _, node in ipairs(self.tbChildNodeList) do
			if node:GetNodeKey() == sKey then
				return node
			end
		end
	end
end
function RedDotNode:SetValid(bValid)
	if self:GetValid() == bValid and (nil == self.tbChildNodeList or #self.tbChildNodeList <= 0) then
		return
	end
	if bValid then
		self.nRedDotCount = self.nRedDotCount + 1
	else
		self.nRedDotCount = self.nRedDotCount - 1
	end
	if not self.bManualRefresh then
		self:RefreshRedDotShow()
	end
	if nil ~= self.parentNode then
		self.parentNode:SetValid(bValid)
	end
end
function RedDotNode:SetCount(nCount)
	if self:GetCount() == nCount and (nil == self.tbChildNodeList or #self.tbChildNodeList <= 0) then
		return
	end
	self.nRedDotCount = nCount
	self:RefreshRedDotShow()
	if nil ~= self.parentNode then
		self.parentNode:SetCount(nCount)
	end
end
function RedDotNode:RefreshRedDotShow()
	if nil == self.tbObjNode or nil == next(self.tbObjNode) then
		return
	end
	for _, v in pairs(self.tbObjNode) do
		if v:IsNull() == true then
			traceback("\231\150\145\228\188\188\228\184\138\228\184\128\230\172\161\230\179\168\229\134\140\231\154\132\231\186\162\231\130\185\230\156\170\230\179\168\233\148\128\239\188\129\239\188\129\239\188\129\232\175\183\230\163\128\230\159\165 nodeKey = " .. self.sNodeKey)
		else
			v.gameObject:SetActive(self:GetValid())
		end
	end
	if self.nShowType == RedDotType.Number then
		for _, v in pairs(self.tbTxtRedDotCount) do
			NovaAPI.SetTMPText(v, self:GetCount())
		end
	end
end
function RedDotNode:GetNodeKey()
	return self.sNodeKey
end
function RedDotNode:GetValid()
	return self.nRedDotCount > 0
end
function RedDotNode:GetCount()
	return self.nRedDotCount
end
function RedDotNode:CheckLeafNode()
	return nil == self.tbChildNodeList or #self.tbChildNodeList == 0
end
function RedDotNode:PrintRedDot(bParent, bLeaf)
	if self.sNodeKey == "Root" then
		return
	end
	local sObj = ""
	local nCount = 0
	if self.tbObjNode ~= nil then
		for nInsId, v in pairs(self.tbObjNode) do
			nCount = nCount + 1
			sObj = sObj .. string.format("%s | %s", nInsId, v.gameObject:GetInstanceID())
			sObj = sObj .. "\n"
		end
		local sLog = string.format("<color=red>[RedDot]</color> \232\138\130\231\130\185key %s|\231\186\162\231\130\185state %s|\231\187\145\229\174\154gameObject\230\149\176\233\135\143 %s\n", self.sNodeKey, self.nRedDotCount, nCount)
		sLog = sLog .. sObj
		traceback(sLog)
	end
	if bParent then
		if nil ~= self.parentNode then
			self.parentNode:PrintRedDot(true)
		end
	elseif bLeaf and nil ~= self.tbChildNodeList then
		for _, v in ipairs(self.tbChildNodeList) do
			v:PrintRedDot(nil, true)
		end
	end
end
return RedDotNode
