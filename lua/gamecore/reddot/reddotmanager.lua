local RedDotManager = {}
local RedDotNode = require("GameCore.RedDot.RedDotNode")
local stringSplit = string.split
local RapidJson = require("rapidjson")
local mapKeyList = {}
local rootNode, trUIRoot
local DEBUG_OPEN = false
function RedDotManager.Init()
	trUIRoot = GameObject.Find("---- UI ----").transform
	EventManager.Add("LuaEventName_UnRegisterRedDot", RedDotManager, RedDotManager.OnEvent_UnRegisterRedDot)
end
function RedDotManager.RegisterNode(sKey, param, objGo, nType, bManualRefresh, bRebind)
	local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
	if not bCheck then
		return
	end
	if objGo ~= nil then
		local tbParam = {}
		if param == nil then
			tbParam.sParam = "empty"
		elseif type(param) ~= "table" then
			tbParam.sParam = param
		else
			tbParam = param
		end
		local bindCS = function(obj)
			NovaAPI.UnRegisterRedDotNode(obj.gameObject)
			local trParent = obj.transform.parent
			obj.transform:SetParent(trUIRoot)
			obj.gameObject:SetActive(true)
			local paramJson = RapidJson.encode(tbParam)
			NovaAPI.AddRedDotNode(obj.gameObject, sKey, paramJson)
			obj.gameObject:SetActive(false)
			obj.transform:SetParent(trParent)
		end
		if type(objGo) == "table" then
			for _, v in ipairs(objGo) do
				bindCS(v.gameObject)
			end
		else
			bindCS(objGo.gameObject)
		end
	end
	local node = RedDotManager.GetNode(sNodeKey)
	if nil ~= node then
		if bRebind then
			node:UnRegisterNode()
		end
		node:RegisterNode(objGo, nType, bManualRefresh)
	end
end
function RedDotManager.UnRegisterNode(sKey, param, objGo)
	local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
	if not bCheck then
		return
	end
	if RedDotManager.CheckNodeExist(sNodeKey) then
		local node = RedDotManager.GetNode(sNodeKey)
		if nil ~= node then
			node:UnRegisterNode(objGo)
		end
	end
end
function RedDotManager.OnEvent_UnRegisterRedDot(_, sKey, paramJson, objGo)
	local tbParam = decodeJson(paramJson)
	local param
	if tbParam.sParam == nil then
		param = tbParam
	elseif tbParam.sParam == "empty" then
		param = nil
	elseif tbParam.sParam ~= nil then
		param = tbParam.sParam
	end
	local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
	if not bCheck then
		return
	end
	if RedDotManager.CheckNodeExist(sNodeKey) then
		local node = RedDotManager.GetNode(sNodeKey)
		if nil ~= node then
			node:UnRegisterNode(objGo)
		end
	end
end
function RedDotManager.SetValid(sKey, param, bValid)
	local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
	if not bCheck then
		return
	end
	local node = RedDotManager.GetNode(sNodeKey)
	if nil ~= node then
		if not node:CheckLeafNode() then
			return
		end
		node:SetValid(bValid)
	end
end
function RedDotManager.SetCount(sKey, param, nCount)
	local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
	if not bCheck then
		return
	end
	local node = RedDotManager.GetNode(sNodeKey)
	if nil ~= node then
		if not node:CheckLeafNode() then
			return
		end
		node:SetCount(nCount)
	end
end
function RedDotManager.GetValid(sKey, param)
	local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
	if not bCheck then
		return
	end
	local node = RedDotManager.GetNode(sNodeKey)
	if nil ~= node then
		return node:GetValid()
	end
	return false
end
function RedDotManager.RefreshRedDotShow(sKey, param)
	local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
	if not bCheck then
		return
	end
	if RedDotManager.CheckNodeExist(sNodeKey) then
		local node = RedDotManager.GetNode(sNodeKey)
		if nil ~= node then
			node:RefreshRedDotShow()
		end
	end
end
function RedDotManager.PrintRedDot(sKey, param, bParent, bLeaf)
	if not DEBUG_OPEN then
		return
	end
	local bCheck, sNodeKey = RedDotManager.GetNodeKey(sKey, param)
	if not bCheck then
		return
	end
	local node = RedDotManager.GetNode(sNodeKey)
	if nil ~= node then
		node:PrintRedDot(bParent, bLeaf)
	end
end
function RedDotManager.GetNodeKey(sKey, param)
	local sNodeKey = ""
	local bCheck = true
	if nil == sKey then
		bCheck = false
		traceback(string.format("\231\186\162\231\130\185\230\179\168\229\134\140\228\188\160\229\133\165\229\143\130\230\149\176\233\148\153\232\175\175\239\188\140\232\175\183\230\163\128\230\159\165\239\188\129\239\188\129!, key = %s, param = %s", sKey, param))
	else
		if nil == param then
			sNodeKey = sKey
		elseif type(param) ~= "table" then
			sNodeKey = string.gsub(sKey, "<param>", param, 1)
		else
			sNodeKey = sKey
			for _, v in ipairs(param) do
				sNodeKey = string.gsub(sNodeKey, "<param>", v, 1)
			end
		end
		sNodeKey = string.gsub(sNodeKey, "<param>", "")
		local tbSplit = stringSplit(sNodeKey, ".") or {}
		sNodeKey = ""
		local index = 1
		for _, v in ipairs(tbSplit) do
			if nil ~= v and "" ~= v then
				if index == 1 then
					sNodeKey = v
				else
					sNodeKey = sNodeKey .. "." .. v
				end
				index = index + 1
			end
		end
	end
	return bCheck, sNodeKey
end
function RedDotManager.GetNode(sNodeKey)
	if nil == rootNode then
		rootNode = RedDotNode.new(RedDotDefine.Root)
	end
	local curNode = rootNode
	local tbKeyList = RedDotManager.ParseKey(sNodeKey)
	for _, key in ipairs(tbKeyList) do
		local node = curNode:GetChildNode(key)
		if nil == node then
			node = curNode:AddChildNode(key)
		end
		curNode = node
	end
	return curNode
end
function RedDotManager.CheckNodeExist(sNodeKey)
	return nil ~= RedDotManager.GetKeyList(sNodeKey)
end
function RedDotManager.GetKeyList(sNodeKey)
	return mapKeyList[sNodeKey]
end
function RedDotManager.ParseKey(sNodeKey)
	local tbKeyList = RedDotManager.GetKeyList(sNodeKey)
	if nil == tbKeyList then
		tbKeyList = stringSplit(sNodeKey, ".") or {}
	end
	mapKeyList[sNodeKey] = tbKeyList
	return tbKeyList
end
return RedDotManager
