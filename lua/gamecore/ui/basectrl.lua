local ConfigData = require("GameCore.Data.ConfigData")
local TimerManager = require("GameCore.Timer.TimerManager")
local GameResourceLoader = require("Game.Common.Resource.GameResourceLoader")
local ResType = GameResourceLoader.ResType
local AdventureModuleHelper = CS.AdventureModuleHelper
local BaseCtrl = class("BaseCtrl")
local sRootPath = Settings.AB_ROOT_PATH
local bDebugLog = false
local typeof = typeof
function BaseCtrl:ctor(goPrefabInstance, objPanel)
	self._panel = objPanel
	self._tbTimer = {}
	self._mapPrefab = {}
	self._mapLoadAssets = {}
	self._mapHandler = {}
	self._mapNode = {}
	self:ParsePrefab(goPrefabInstance)
	if type(self.Awake) == "function" then
		self:Awake()
	end
	self._autoRemoveUnusedTimer = nil
end
function BaseCtrl:ParsePrefab(goPrefabInstance)
	if goPrefabInstance ~= nil and goPrefabInstance:IsNull() == false then
		self.gameObject = goPrefabInstance
	end
	self:_ParseNode(self._mapNodeConfig)
end
function BaseCtrl:_PreExit(callback, bPlayFadeOut)
	self:_UnbindComponentCallback(self._mapNodeConfig)
	self:_UnbindEventCallback(self._mapEventConfig)
	self:_RemoveAllTimer()
	if type(self.OnPreExit) == "function" then
		self:OnPreExit()
	end
	local func_DoCallback = function()
		if type(callback) == "function" then
			callback()
		end
	end
	if bPlayFadeOut == true and type(self.FadeOut) == "function" then
		local nDelayTime = self:FadeOut()
		if type(nDelayTime) == "number" and 0 < nDelayTime then
			local func_timer = function(timer)
				func_DoCallback()
			end
			TimerManager.Add(1, nDelayTime, self, func_timer, true, true)
		else
			func_DoCallback()
		end
	else
		func_DoCallback()
	end
end
function BaseCtrl:_Exit()
	if type(self.OnDisable) == "function" then
		self:OnDisable()
	end
	if type(self._mapNode) == "table" then
		for sKey, obj in pairs(self._mapNode) do
			if type(obj) ~= "table" then
				self._mapNode[sKey] = 0
			elseif type(obj.__cname) == "string" then
			else
				for i, _obj in ipairs(obj) do
					if type(_obj) ~= "table" then
						self._mapNode[sKey][i] = 0
					else
					end
				end
			end
		end
	end
	self:_DebugLogDataCount("OnDisable")
end
function BaseCtrl:_Enter(bPlayFadeIn)
	self:_BindComponentCallback(self._mapNodeConfig)
	self:_BindEventCallback(self._mapEventConfig)
	self:_RegisterRedDot()
	if type(self.OnEnable) == "function" then
		self:OnEnable()
	end
	if type(self.FadeIn) == "function" then
		self:FadeIn(bPlayFadeIn)
		self._panel._nFadeInType = self._panel._nFADEINTYPE
	end
	self:_DebugLogDataCount("OnEnable")
end
function BaseCtrl:_Destroy()
	if type(self.OnDestroy) == "function" then
		self:OnDestroy()
	end
	for k, v in pairs(self._mapPrefab) do
		self:DestroyPrefabInstance(k)
	end
	for k, v in pairs(self._mapLoadAssets) do
		self:UnLoadAsset(k)
	end
	self._panel = nil
	self._tbTimer = nil
	self._mapPrefab = nil
	self._mapLoadAssets = nil
	self._mapHandler = nil
	self._mapNode = nil
end
function BaseCtrl:_Release()
	if self.gameObject ~= nil and self.gameObject:IsNull() == false and type(self.OnRelease) == "function" then
		self:OnRelease()
	end
end
function BaseCtrl:_ParseNode(mapNodeConfig)
	if self.gameObject ~= nil and type(mapNodeConfig) == "table" then
		local trPrefabRoot = self.gameObject.transform
		local mapNode = {}
		local function func_MarkAllNode(trRoot)
			local nChildCount = trRoot.childCount - 1
			for i = 0, nChildCount do
				local trChild = trRoot:GetChild(i)
				mapNode[trChild.name] = trChild.gameObject
				if trChild.childCount > 0 then
					func_MarkAllNode(trChild)
				end
			end
		end
		func_MarkAllNode(trPrefabRoot)
		for sKey, mapConfig in pairs(mapNodeConfig) do
			local sNodeName = mapConfig.sNodeName
			local nCount = mapConfig.nCount
			local sComponentName = mapConfig.sComponentName
			local sCtrlName = mapConfig.sCtrlName
			local sLanguageId = mapConfig.sLanguageId
			if type(sNodeName) ~= "string" then
				sNodeName = tostring(sKey)
			end
			local tbNodeName = {}
			if type(nCount) == "number" then
				if type(self._mapNode[sKey]) ~= "table" then
					self._mapNode[sKey] = {}
				end
				for i = 1, nCount do
					table.insert(tbNodeName, sNodeName .. tostring(i))
				end
			else
				table.insert(tbNodeName, sNodeName)
			end
			for nIndex, sName in ipairs(tbNodeName) do
				local bComponentFound = true
				local objNode
				local goNode = mapNode[sName]
				if goNode ~= nil then
					if type(sCtrlName) == "string" then
						local objCtrl
						local nGoInstanceId = goNode:GetInstanceID()
						for _nObjCtrlIdx, _objCtrl in ipairs(self._panel._tbObjChildCtrl) do
							if _objCtrl._nGoInstanceId == nGoInstanceId then
								objCtrl = _objCtrl
								break
							end
						end
						if objCtrl == nil then
							local luaClass = require(sCtrlName)
							objCtrl = luaClass.new(goNode, self._panel)
							objCtrl._nGoInstanceId = nGoInstanceId
							table.insert(self._panel._tbObjChildCtrl, objCtrl)
						end
						objCtrl:ParsePrefab(goNode)
						objNode = objCtrl
					else
						if sComponentName == nil then
							sComponentName = "GameObject"
						end
						if sComponentName == "GameObject" then
							objNode = goNode
						elseif sComponentName == "Transform" then
							objNode = goNode.transform
						else
							local _sComponentName = sComponentName
							if sComponentName == "InputField_onEndEdit" then
								_sComponentName = "InputField"
							end
							bComponentFound, objNode = goNode:GetNodeComponent(_sComponentName)
							if objNode ~= nil and type(sLanguageId) == "string" then
								if _sComponentName == "Text" then
									if ConfigTable.GetUIText(sLanguageId) then
										NovaAPI.SetText(objNode, ConfigTable.GetUIText(sLanguageId))
									else
										printError("UIText\231\188\186\229\164\177\233\133\141\231\189\174:" .. sLanguageId)
									end
								elseif _sComponentName == "TMP_Text" then
									if ConfigTable.GetUIText(sLanguageId) then
										NovaAPI.SetTMPText(objNode, ConfigTable.GetUIText(sLanguageId))
									else
										printError("UIText\231\188\186\229\164\177\233\133\141\231\189\174:" .. sLanguageId)
									end
								end
							end
						end
					end
					if bComponentFound == true and objNode ~= nil then
						if type(nCount) == "number" then
							self._mapNode[sKey][nIndex] = objNode
						else
							self._mapNode[sKey] = objNode
						end
					else
						printError("\232\138\130\231\130\185\230\137\190\229\136\176\228\186\134\228\189\134\231\187\132\228\187\182\230\178\161\230\137\190\229\136\176\239\188\140\232\138\130\231\130\185\229\144\141\239\188\154" .. sName .. "\239\188\140\231\187\132\228\187\182\229\144\141\239\188\154" .. sComponentName .. "\239\188\140panel id\239\188\154" .. tostring(table.keyof(PanelId, self._panel._nPanelId)))
					end
				else
					printError("\231\149\140\233\157\162\233\162\132\232\174\190\228\189\147\228\184\173\233\133\141\231\189\174\231\154\132\232\138\130\231\130\185\230\178\161\230\137\190\229\136\176\239\188\140\233\162\132\232\174\190\228\189\147\229\144\141\229\173\151\239\188\154" .. trPrefabRoot.name .. "\239\188\140\232\138\130\231\130\185\229\144\141\229\173\151\239\188\154" .. sName)
				end
			end
		end
	end
end
function BaseCtrl:_BindComponentCallback(mapNodeConfig)
	if type(mapNodeConfig) ~= "table" then
		return
	end
	local func_DoBind = function(objComp, sCompName, cb, sNodeKey, nIndex)
		local sHandlerKey = sNodeKey
		if type(nIndex) == "number" then
			sHandlerKey = sNodeKey .. tostring(nIndex)
		end
		local func_Handler = function(...)
			local ui_func = ui_handler(self, cb, objComp, nIndex)
			ui_func(...)
			EventManager.Hit(EventId.UIOperate)
		end
		if sCompName == "Button" then
			objComp.onClick:AddListener(func_Handler)
		elseif sCompName == "ButtonEx" then
			objComp.onClick:AddListener(func_Handler)
		elseif sCompName == "UIButton" then
			objComp.onClick:AddListener(func_Handler)
		elseif sCompName == "NaviButton" then
			objComp.onClick:AddListener(func_Handler)
		elseif sCompName == "TMPHyperLink" then
			objComp.onClick:AddListener(func_Handler)
		elseif sCompName == "Toggle" then
			NovaAPI.AddToggleListener(objComp, func_Handler)
		elseif sCompName == "UIToggle" then
			NovaAPI.AddUIToggleListener(objComp, func_Handler)
		elseif sCompName == "ScrollRect" then
			NovaAPI.AddScrollRectListener(objComp, func_Handler)
		elseif sCompName == "Slider" then
			NovaAPI.AddSliderListener(objComp, func_Handler)
		elseif sCompName == "LoopScrollView" then
			objComp.onValueChanged:AddListener(func_Handler)
		elseif sCompName == "InputField" then
			NovaAPI.AddIPValueChangedListener(objComp, func_Handler)
		elseif sCompName == "InputField_onEndEdit" then
			objComp.onEndEdit:AddListener(func_Handler)
		elseif sCompName == "TMP_Dropdown" then
			objComp.onValueChanged:AddListener(func_Handler)
		elseif sCompName == "Dropdown" then
			NovaAPI.AddDropDownListener(objComp, func_Handler)
		elseif sCompName == "TMP_InputField" then
			objComp.onValueChanged:AddListener(func_Handler)
		elseif sCompName == "LoopScrollSnap" then
			objComp.onGridSelect:AddListener(func_Handler)
		elseif sCompName == "UIDrag" then
			objComp.onDragEvent:AddListener(func_Handler)
		else
			if sCompName == "UIZoom" then
				objComp.onZoom:AddListener(func_Handler)
			else
			end
		end
		if type(func_Handler) == "function" then
			self._mapHandler[sHandlerKey] = func_Handler
		end
	end
	for sKey, mapConfig in pairs(mapNodeConfig) do
		local sCallback = mapConfig.callback
		local sComponentName = mapConfig.sComponentName
		local nCount = mapConfig.nCount
		if type(sCallback) == "string" and type(sComponentName) == "string" then
			local funcCallback = self[sCallback]
			if type(funcCallback) == "function" then
				if type(self._mapNode[sKey]) == "table" and type(nCount) == "number" then
					for i = 1, nCount do
						func_DoBind(self._mapNode[sKey][i], sComponentName, funcCallback, sKey, i)
					end
				else
					func_DoBind(self._mapNode[sKey], sComponentName, funcCallback, sKey)
				end
			else
				printError("\230\178\161\230\156\137\230\137\190\229\136\176\231\187\132\228\187\182\231\154\132\229\155\158\232\176\131\229\135\189\230\149\176\239\188\140\232\138\130\231\130\185\229\144\141\229\173\151\239\188\154" .. sKey .. "\239\188\140\229\155\158\232\176\131\229\135\189\230\149\176\229\144\141\229\173\151\239\188\154" .. sCallback)
			end
		end
	end
end
function BaseCtrl:_UnbindComponentCallback(mapNodeConfig)
	if type(mapNodeConfig) ~= "table" then
		return
	end
	local func_DoUnbind = function(objComp, sCompName, sNodeKey, nIndex)
		local sHandlerKey = sNodeKey
		if type(nIndex) == "number" then
			sHandlerKey = sNodeKey .. tostring(nIndex)
		end
		local func_Handler = self._mapHandler[sHandlerKey]
		if objComp ~= nil and func_Handler ~= nil then
			if sCompName == "Button" then
				objComp.onClick:RemoveListener(func_Handler)
			elseif sCompName == "ButtonEx" then
				objComp.onClick:RemoveListener(func_Handler)
			elseif sCompName == "UIButton" then
				objComp.onClick:RemoveListener(func_Handler)
			elseif sCompName == "NaviButton" then
				objComp.onClick:RemoveListener(func_Handler)
			elseif sCompName == "TMPHyperLink" then
				objComp.onClick:RemoveListener(func_Handler)
			elseif sCompName == "Toggle" then
				NovaAPI.RemoveToggleListener(objComp, func_Handler)
			elseif sCompName == "UIToggle" then
				NovaAPI.RemoveUIToggleListener(objComp, func_Handler)
			elseif sCompName == "ScrollRect" then
				NovaAPI.RemoveScrollRectListener(objComp, func_Handler)
			elseif sCompName == "Slider" then
				NovaAPI.RemoveSliderListener(objComp, func_Handler)
			elseif sCompName == "LoopScrollView" then
				objComp.onValueChanged:RemoveListener(func_Handler)
			elseif sCompName == "InputField" then
				NovaAPI.RemoveIPValueChangedListener(objComp, func_Handler)
			elseif sCompName == "InputField_onEndEdit" then
				objComp.onEndEdit:RemoveListener(func_Handler)
			elseif sCompName == "TMP_Dropdown" then
				objComp.onValueChanged:RemoveListener(func_Handler)
			elseif sCompName == "Dropdown" then
				NovaAPI.RemoveDropDownListener(objComp, func_Handler)
			elseif sCompName == "TMP_InputField" then
				objComp.onValueChanged:RemoveListener(func_Handler)
			elseif sCompName == "LoopScrollSnap" then
				objComp.onGridSelect:RemoveListener(func_Handler)
			elseif sCompName == "UIDrag" then
				objComp.onDragEvent:RemoveListener(func_Handler)
			elseif sCompName == "UIZoom" then
				objComp.onZoom:RemoveListener(func_Handler)
			end
		end
		self._mapHandler[sHandlerKey] = nil
		func_Handler = nil
	end
	for sKey, mapConfig in pairs(mapNodeConfig) do
		local sCallback = mapConfig.callback
		local sComponentName = mapConfig.sComponentName
		local nCount = mapConfig.nCount
		if type(sCallback) == "string" and type(sComponentName) == "string" then
			local funcCallback = self[sCallback]
			if type(funcCallback) == "function" then
				if type(self._mapNode[sKey]) == "table" and type(nCount) == "number" then
					for i = 1, nCount do
						func_DoUnbind(self._mapNode[sKey][i], sComponentName, sKey, i)
					end
				else
					func_DoUnbind(self._mapNode[sKey], sComponentName, sKey)
				end
			else
				printError("\230\178\161\230\156\137\230\137\190\229\136\176\231\187\132\228\187\182\231\154\132\229\155\158\232\176\131\229\135\189\230\149\176\239\188\140\232\138\130\231\130\185\229\144\141\229\173\151\239\188\154" .. sKey .. "\239\188\140\229\155\158\232\176\131\229\135\189\230\149\176\229\144\141\229\173\151\239\188\154" .. sCallback)
			end
		end
	end
end
function BaseCtrl:_BindEventCallback(mapEventConfig)
	if type(mapEventConfig) ~= "table" then
		return
	end
	for nEventId, sCallbackName in pairs(mapEventConfig) do
		local callback = self[sCallbackName]
		if type(callback) == "function" then
			EventManager.Add(nEventId, self, callback)
		end
	end
end
function BaseCtrl:_UnbindEventCallback(mapEventConfig)
	if type(mapEventConfig) ~= "table" then
		return
	end
	for nEventId, sCallbackName in pairs(mapEventConfig) do
		local callback = self[sCallbackName]
		if type(callback) == "function" then
			EventManager.Remove(nEventId, self, callback)
		end
	end
end
function BaseCtrl:_RemoveAllTimer()
	local n = #self._tbTimer
	for i = n, 1, -1 do
		TimerManager.Remove(self._tbTimer[i], false)
		table.remove(self._tbTimer, i)
	end
	if table.nums(self._tbTimer) > 0 then
		self._tbTimer = {}
	end
	if self._autoRemoveUnusedTimer ~= nil then
		self._autoRemoveUnusedTimer:Cancel()
		self._autoRemoveUnusedTimer = nil
	end
end
function BaseCtrl:_DebugLogDataCount(sTitle)
	if bDebugLog == false then
		return
	end
	local sCtrlName = self.__cname
	local sGoName = self.gameObject.name
	local nTimerCnt = table.nums(self._tbTimer)
	local nPrefabInsCnt = table.nums(self._mapPrefab)
	local nHandlerCnt = table.nums(self._mapHandler)
	local nNodeCnt = table.nums(self._mapNode)
	local sDebugLog = string.format("[%s.%s] \233\162\132\232\174\190\228\189\147\239\188\154%s\239\188\140\232\174\161\230\151\182\229\153\168\230\149\176\233\135\143\239\188\154%d\239\188\140\232\135\170\231\144\134\233\162\132\232\174\190\228\189\147\229\174\158\228\190\139\230\149\176\233\135\143\239\188\154%d\239\188\140\229\155\158\232\176\131\230\149\176\233\135\143\239\188\154%d\239\188\140\232\138\130\231\130\185\230\149\176\233\135\143\239\188\154%d\227\128\130", sCtrlName, sTitle, sGoName, nTimerCnt, nPrefabInsCnt, nHandlerCnt, nNodeCnt)
	printLog(sDebugLog)
end
function BaseCtrl:_RegisterRedDot()
	if nil ~= self._mapRedDotConfig then
		for key, cfg in pairs(self._mapRedDotConfig) do
			local sNodeName = cfg.sNodeName
			local nNodeIndex = cfg.nNodeIndex
			local objNode
			if nil == nNodeIndex then
				objNode = self._mapNode[sNodeName]
			elseif nil ~= self._mapNode[sNodeName] then
				objNode = self._mapNode[sNodeName][nNodeIndex]
			end
			if nil == objNode then
				printError(string.format("\231\187\145\229\174\154\231\186\162\231\130\185\229\164\177\232\180\165\239\188\129\239\188\129\239\188\129 \230\137\190\228\184\141\229\136\176\231\186\162\231\130\185\232\138\130\231\130\185.key = %s, nodeName = %s", key, sNodeName))
			else
				RedDotManager.RegisterNode(key, cfg.param, objNode.gameObject)
			end
		end
	end
end
function BaseCtrl:GetPanelId()
	return self._panel._nPanelId
end
function BaseCtrl:GetPanelParam()
	return self._panel:GetPanelParam()
end
local bActive_AutoFit = true
function BaseCtrl:GetAtlasSprite(sAtlasPath, sSpriteName)
	if string.find(sAtlasPath, "/CommonEx/") ~= nil or string.find(sAtlasPath, "/Common/") ~= nil then
		printError("\230\150\176\231\137\136UI\229\156\168\230\141\162\232\191\135\229\155\190\233\155\134\229\129\154\230\179\149\229\144\142\239\188\140\228\187\142\229\155\190\233\155\134\228\184\173\229\143\150Sprite\230\151\182\228\184\141\229\186\148\229\135\186\231\142\176/CommonEx/\231\155\174\229\189\149 \230\136\150 /Common/ \231\155\174\229\189\149\227\128\130" .. sAtlasPath .. "," .. sSpriteName)
		printError("panel id:" .. self._panel._nPanelId .. "\239\188\140ctrl name:" .. self.__cname)
		return nil
	end
	local sFullPath = string.format("%sUI/CommonEx/atlas_png/%s/%s.png", sRootPath, sAtlasPath, sSpriteName)
	return GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(Sprite))
end
function BaseCtrl:GetPngSprite(sPath, sSurfix, imgObj)
	if type(sPath) == "number" then
		printError("\232\176\131\231\148\168\230\142\165\229\143\163\229\164\132\233\156\128\230\155\180\230\150\176\239\188\140panel id:" .. self._panel._nPanelId .. "\239\188\140ctrl name:" .. self.__cname)
		return nil
	end
	if type(sPath) == "string" and sPath ~= "" and type(sSurfix) == "string" and sSurfix ~= "" then
		if bActive_AutoFit == true then
			sPath = self:_AutoFitIcon(imgObj, sPath, sSurfix)
		else
			sPath = sPath .. sSurfix
		end
	end
	if string.find(sPath, "Icon/") == nil and string.find(sPath, "Image/") == nil and string.find(sPath, "ImageAvg/") == nil and string.find(sPath, "big_sprites/") == nil then
		printError("\233\133\141\231\189\174\232\161\168\228\184\173 Icon \232\181\132\230\186\144\229\173\151\230\174\181\229\134\133\229\174\185\229\161\171\229\134\153\233\148\153\232\175\175\239\188\140\229\186\148\229\161\171\232\183\175\229\190\132\239\188\140\229\166\130\239\188\154Icon/Item/item_1\239\188\140panel id:" .. self._panel._nPanelId .. "\239\188\140ctrl name:" .. self.__cname)
		return nil
	else
		local sp = GameResourceLoader.LoadAsset(ResType.Any, sRootPath .. sPath .. ".png", typeof(Sprite))
		if sp == nil then
			printError(string.format("\230\156\170\230\137\190\229\136\176 icon \232\181\132\230\186\144\239\188\154%s\239\188\140panel id\239\188\154%s\239\188\140ctrl name\239\188\154%s", sPath, tostring(self._panel._nPanelId), tostring(self.__cname)))
		end
		return sp
	end
end
function BaseCtrl:GetSprite_FrameColor(nRarity, sFrameType, bBigSprites)
	local sPngName = sFrameType .. AllEnum.FrameColor_New[nRarity]
	if bBigSprites then
		return self:GetPngSprite("UI/big_sprites/" .. sPngName)
	else
		return self:GetAtlasSprite("12_rare", sPngName)
	end
end
function BaseCtrl:GetSprite_Coin(nCoinItemId)
	local mapItem = ConfigTable.GetData_Item(nCoinItemId)
	if mapItem == nil then
		return nil
	elseif mapItem.Icon2 == nil or mapItem.Icon2 == "" then
		return nil
	else
		return self:GetPngSprite(mapItem.Icon2)
	end
end
function BaseCtrl:GetAvgCharHeadIcon(sSpeakerId, sFace)
	if sFace == nil then
		sFace = "002"
	end
	if sSpeakerId == nil or sSpeakerId == "" or sSpeakerId == "avg0_1" or sSpeakerId == "0" then
		sSpeakerId = AdjustMainRoleAvgCharId()
	end
	local sIconPath = string.format("Icon/AvgHead/%s/%s_%s", sSpeakerId, sSpeakerId, sFace)
	return self:GetPngSprite(sIconPath)
end
function BaseCtrl:SetSprite(imgObj, sPath)
	local sFullPath = sRootPath .. sPath .. ".png"
	local bSuc = NovaAPI.SetImageSprite(imgObj, sFullPath)
	if not bSuc then
		traceback(string.format("Sprite\232\174\190\231\189\174\229\164\177\232\180\165\239\188\154%s\239\188\140panel id\239\188\154%s\239\188\140ctrl name\239\188\154%s", sFullPath, tostring(self._panel._nPanelId), tostring(self.__cname)))
	end
	return bSuc
end
function BaseCtrl:SetAtlasSprite(imgObj, sAtlasPath, sSpriteName)
	if string.find(sAtlasPath, "/CommonEx/") ~= nil or string.find(sAtlasPath, "/Common/") ~= nil then
		printError("\230\150\176\231\137\136UI\229\156\168\230\141\162\232\191\135\229\155\190\233\155\134\229\129\154\230\179\149\229\144\142\239\188\140\228\187\142\229\155\190\233\155\134\228\184\173\229\143\150Sprite\230\151\182\228\184\141\229\186\148\229\135\186\231\142\176/CommonEx/\231\155\174\229\189\149 \230\136\150 /Common/ \231\155\174\229\189\149\227\128\130" .. sAtlasPath .. "," .. sSpriteName)
		printError("panel id:" .. self._panel._nPanelId .. "\239\188\140ctrl name:" .. self.__cname)
		return false
	end
	local sFullPath = string.format("%sUI/CommonEx/atlas_png/%s/%s.png", sRootPath, sAtlasPath, sSpriteName)
	local bSuc = NovaAPI.SetImageSprite(imgObj, sFullPath)
	if not bSuc then
		traceback(string.format("icon\232\174\190\231\189\174\229\164\177\232\180\165\239\188\154%s\239\188\140panel id\239\188\154%s\239\188\140ctrl name\239\188\154%s", sFullPath, tostring(self._panel._nPanelId), tostring(self.__cname)))
	end
	return bSuc
end
function BaseCtrl:SetActivityAtlasSprite(imgObj, sActivityPath, sSpriteName)
	local sFullPath = string.format("%sUI_Activity/%s/SpriteAtlas/%s.png", sRootPath, sActivityPath, sSpriteName)
	local bSuc = NovaAPI.SetImageSprite(imgObj, sFullPath)
	if not bSuc then
		traceback(string.format("icon\232\174\190\231\189\174\229\164\177\232\180\165\239\188\154%s\239\188\140panel id\239\188\154%s\239\188\140ctrl name\239\188\154%s", sFullPath, tostring(self._panel._nPanelId), tostring(self.__cname)))
	end
	return bSuc
end
function BaseCtrl:SetActivityAtlasSprite_New(imgObj, sActivityPath, sSpriteName)
	local sFullPath = string.format("%sUI_Activity/%s/%s.png", sRootPath, sActivityPath, sSpriteName)
	local bSuc = NovaAPI.SetImageSprite(imgObj, sFullPath)
	if not bSuc then
		traceback(string.format("icon\232\174\190\231\189\174\229\164\177\232\180\165\239\188\154%s\239\188\140panel id\239\188\154%s\239\188\140ctrl name\239\188\154%s", sFullPath, tostring(self._panel._nPanelId), tostring(self.__cname)))
	end
	return bSuc
end
function BaseCtrl:_AutoFitIcon(imgObj, sPath, sSurfix)
	local mapAutoFix = AllEnum.CharHeadIconSurfixAutoFit[sSurfix]
	if mapAutoFix == nil then
		return sPath .. sSurfix
	end
	local nGlobalScale = 0
	local v3GlobalScale = imgObj.transform.lossyScale
	if v3GlobalScale.x < v3GlobalScale.y then
		nGlobalScale = v3GlobalScale.x
	else
		nGlobalScale = v3GlobalScale.y
	end
	nGlobalScale = nGlobalScale / Settings.CANVAS_SCALE
	if nGlobalScale <= 0 then
		nGlobalScale = 1
	end
	local rectTransform = imgObj.gameObject:GetComponent("RectTransform")
	local nTargetWidth = rectTransform.rect.width * nGlobalScale
	local nTargetHeight = rectTransform.rect.height * nGlobalScale
	local sAutoFit, nRange
	for k, v in pairs(mapAutoFix) do
		local nMultiple_W = math.abs(nTargetWidth - v.w) / v.w
		local nMultiple_H = math.abs(nTargetHeight - v.h) / v.h
		local nMultiple = nMultiple_W >= nMultiple_H and nMultiple_W or nMultiple_H
		if nRange == nil then
			nRange = nMultiple
			sAutoFit = k
		elseif nMultiple < nRange then
			nRange = nMultiple
			sAutoFit = k
		end
	end
	if sAutoFit == nil then
		if NovaAPI.IsEditorPlatform() == true then
			printLog("\227\128\144\230\138\189\229\141\161\232\167\146\232\137\178\229\164\180\229\131\143 icon \232\135\170\233\128\130\229\186\148\227\128\145\230\156\170\232\135\170\233\128\130\229\186\148")
		end
		return sPath .. sSurfix
	else
		if NovaAPI.IsEditorPlatform() == true then
			printLog(string.format("\227\128\144\230\138\189\229\141\161\232\167\146\232\137\178\229\164\180\229\131\143 icon \232\135\170\233\128\130\229\186\148\227\128\145\229\133\168\229\177\128\231\188\169\230\148\190\239\188\154x%f\239\188\140y%f\239\188\140\230\156\128\231\187\136\229\143\150%f\239\188\140\229\186\148\231\148\168\229\164\132\231\174\151\228\184\138\229\133\168\229\177\128\231\188\169\230\148\190\229\144\142\231\154\132\229\176\186\229\175\184\239\188\154w%f\239\188\140h%f\239\188\140\232\135\170\233\128\130\229\186\148\232\135\179\229\144\142\231\188\128\239\188\154%s\239\188\140\229\174\189%f\239\188\140\233\171\152%f\227\128\130", v3GlobalScale.x, v3GlobalScale.y, nGlobalScale, nTargetWidth, nTargetHeight, sAutoFit, mapAutoFix[sAutoFit].w, mapAutoFix[sAutoFit].h))
		end
		local _sPath = sPath .. sAutoFit
		local bExist = GameResourceLoader.ExistsAsset(sRootPath .. _sPath .. ".png")
		if bExist == false then
			if NovaAPI.IsEditorPlatform() == true then
				printError(string.format("\230\138\189\229\141\161\232\167\146\232\137\178\229\164\180\229\131\143 icon \232\135\170\233\128\130\229\186\148\229\164\177\232\180\165\239\188\140\232\181\132\230\186\144\231\188\186\229\164\177\227\128\130%s \229\176\134 %s \232\135\170\233\128\130\229\186\148\232\176\131\230\149\180\228\184\186 %s", sPath, sSurfix, sAutoFit))
			end
			_sPath = sPath .. sSurfix
			NovaAPI.SetImageColor(imgObj, Color.cyan)
		else
			NovaAPI.SetImageColor(imgObj, Color.white)
		end
		return _sPath
	end
end
function BaseCtrl:SetPngSprite(imgObj, sPath, sSurfix)
	if type(sPath) == "number" then
		traceback("\232\176\131\231\148\168\230\142\165\229\143\163\229\164\132\233\156\128\230\155\180\230\150\176\239\188\140panel id:" .. self._panel._nPanelId .. "\239\188\140ctrl name:" .. self.__cname)
		NovaAPI.SetImageSpriteAsset(imgObj, nil)
		return false
	end
	if type(sPath) == "string" and sPath ~= "" and type(sSurfix) == "string" and sSurfix ~= "" then
		if bActive_AutoFit == true then
			sPath = self:_AutoFitIcon(imgObj, sPath, sSurfix)
		else
			sPath = sPath .. sSurfix
		end
	end
	if string.find(sPath, "Icon/") == nil and string.find(sPath, "Image/") == nil and string.find(sPath, "ImageAvg/") == nil and string.find(sPath, "big_sprites/") == nil and string.find(sPath, "Disc/") == nil and string.find(sPath, "Play_") == nil and string.find(sPath, "UI_Activity") == nil then
		traceback("\233\133\141\231\189\174\232\161\168\228\184\173 Icon \232\181\132\230\186\144\229\173\151\230\174\181\229\134\133\229\174\185\229\161\171\229\134\153\233\148\153\232\175\175\239\188\140\229\186\148\229\161\171\232\183\175\229\190\132\239\188\140\229\166\130\239\188\154Icon/Item/item_1\239\188\140panel id:" .. self._panel._nPanelId .. "\239\188\140ctrl name:" .. self.__cname)
		NovaAPI.SetImageSpriteAsset(imgObj, nil)
		return false
	else
		local sFullPath = sRootPath .. sPath .. ".png"
		local bSuc = NovaAPI.SetImageSprite(imgObj, sFullPath)
		if not bSuc then
			traceback(string.format("icon\232\174\190\231\189\174\229\164\177\232\180\165\239\188\154%s\239\188\140panel id\239\188\154%s\239\188\140ctrl name\239\188\154%s", sFullPath, tostring(self._panel._nPanelId), tostring(self.__cname)))
		end
		return bSuc
	end
end
function BaseCtrl:SetSprite_FrameColor(imgObj, nRarity, sFrameType, bBigSprites)
	local sPngName = sFrameType .. AllEnum.FrameColor_New[nRarity]
	if bBigSprites then
		return self:SetPngSprite(imgObj, "UI/big_sprites/" .. sPngName)
	else
		return self:SetAtlasSprite(imgObj, "12_rare", sPngName)
	end
end
function BaseCtrl:SetSprite_Coin(imgObj, nCoinItemId)
	local mapItem = ConfigTable.GetData_Item(nCoinItemId)
	if mapItem == nil then
		return false
	elseif mapItem.Icon2 == nil or mapItem.Icon2 == "" then
		return false
	else
		return self:SetPngSprite(imgObj, mapItem.Icon2)
	end
end
function BaseCtrl:SetAvgCharHeadIcon(imgObj, sSpeakerId, sFace)
	if sFace == nil then
		sFace = "002"
	end
	if sSpeakerId == nil or sSpeakerId == "" or sSpeakerId == "avg0_1" or sSpeakerId == "0" then
		sSpeakerId = AdjustMainRoleAvgCharId()
	end
	local sIconPath = string.format("Icon/AvgHead/%s/%s_%s", sSpeakerId, sSpeakerId, sFace)
	return self:SetPngSprite(imgObj, sIconPath)
end
function BaseCtrl:GetAvgStageEffect(sName, sType)
	if sName == nil then
		return nil
	end
	local sFullPath = string.format("%sImageAvg/AvgStageEffect/%s.png", sRootPath, sName)
	return GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(Texture))
end
function BaseCtrl:GetAvgPortrait(sAvgCharId, sPose, sFace)
	local sPathBody = string.format("%sActor2D/CharacterAvg/%s/atlas_png/%s/%s_%s_001.png", sRootPath, sAvgCharId, sPose, sAvgCharId, sPose)
	local sPathFace = string.format("%sActor2D/CharacterAvg/%s/atlas_png/%s/%s_%s_%s.png", sRootPath, sAvgCharId, sPose, sAvgCharId, sPose, sFace)
	local sPathBlackBody = string.format("%sActor2D/CharacterAvg/%s/%s_%s_001x.png", sRootPath, sAvgCharId, sAvgCharId, sPose)
	local spBody = GameResourceLoader.LoadAsset(ResType.Any, sPathBody, typeof(Sprite))
	local spFace
	if GameResourceLoader.ExistsAsset(sPathFace) == true then
		spFace = GameResourceLoader.LoadAsset(ResType.Any, sPathFace, typeof(Sprite))
	end
	local spBlackBody = spBody
	if GameResourceLoader.ExistsAsset(sPathBlackBody) == true then
		spBlackBody = GameResourceLoader.LoadAsset(ResType.Any, sPathBlackBody, typeof(Sprite))
	end
	local sFullPath = string.format("%sActor2D/CharacterAvg/%s/%s.asset", sRootPath, sAvgCharId, sAvgCharId)
	local objOffset = GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(CS.Actor2DOffsetData))
	local nX, nY = 0, 0
	if objOffset == nil then
		printError(sFullPath)
		return
	end
	local s, x, y = objOffset:GetOffsetData(PanelId.AvgST, indexOfPose(sPose), true, nX, nY)
	local v3OffsetPos = Vector3(x, y, 0)
	local v3OffsetScale = Vector3(s, s, 1)
	return spBody, spFace, v3OffsetPos, v3OffsetScale, spBlackBody
end
function BaseCtrl:GetAvgPortraitEmojiOffsetData(sAvgCharId, sPose, nEmojiIndex)
	local sFullPath = string.format("%sActor2D/CharacterAvg/%s/%s.asset", sRootPath, sAvgCharId, sAvgCharId)
	local objOffset = GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(CS.Actor2DOffsetData))
	local nX, nY = 0, 0
	local s, x, y = objOffset:GetEmojiData(PanelId.AvgST, indexOfPose(sPose), nEmojiIndex, nX, nY)
	local v3OffsetPos = Vector3(x, y, 0)
	local v3OffsetScale = Vector3(s, math.abs(s), 1)
	return v3OffsetPos, v3OffsetScale
end
function BaseCtrl:GetAvgHeadFrameOffsetData(sAvgCharId, sPose, nFrameIndex)
	local sFullPath = string.format("%sActor2D/CharacterAvg/%s/%s.asset", sRootPath, sAvgCharId, sAvgCharId)
	local objOffset = GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(CS.Actor2DOffsetData))
	if nFrameIndex == 2 then
		nFrameIndex = 3
	end
	local nX, nY = 0, 0
	local s, x, y = objOffset:Get_AvgCharHeadFrameData(PanelId.AvgST, indexOfPose(sPose), nFrameIndex, nX, nY)
	return x, y, s
end
function BaseCtrl:OnEvent_AvgSpeedUp_Timer(nRate)
	local n = #self._tbTimer
	for i = n, 1, -1 do
		local timer = self._tbTimer[i]
		if timer ~= nil then
			timer:SetSpeed(nRate)
		end
	end
end
function BaseCtrl:SetAvgCharHeadIconByPrefab(img, sPrefabPath)
	local sFullPath = sRootPath .. sPrefabPath
	local prefab = GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(GameObject), "UI", self._panel._nPanelId)
	NovaAPI.SetImageSpriteWithPrefab(img, prefab)
end
function BaseCtrl:AddTimer(nTargetCount, nInterval, sCallbackName, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
	local callback
	if type(sCallbackName) == "function" then
		callback = sCallbackName
	else
		callback = self[sCallbackName]
	end
	if type(callback) == "function" then
		local timer = TimerManager.Add(nTargetCount, nInterval, self, callback, bAutoRun, bDestroyWhenComplete, nScaleType, tbParam)
		if timer ~= nil then
			if self:GetPanelId() == PanelId.AvgST and type(self._panel.nSpeedRate) == "number" then
				timer:SetSpeed(self._panel.nSpeedRate)
			end
			table.insert(self._tbTimer, timer)
		end
		return timer
	else
		return nil
	end
end
function BaseCtrl:_autoRemoveTimer(timer)
	local n = #self._tbTimer
	for i = n, 1, -1 do
		local timer = self._tbTimer[i]
		if timer ~= nil and timer:IsUnused() == true then
			table.remove(self._tbTimer, i)
		end
	end
end
function BaseCtrl:CreatePrefabInstance(sPrefabPath, trParent)
	local sFullPath = sRootPath .. sPrefabPath
	local prefab = GameResourceLoader.LoadAsset(ResType.Any, sFullPath, typeof(Object), "UI", self._panel._nPanelId)
	if trParent == nil then
		trParent = self.gameObject.transform
	end
	local goPrefabIns = instantiate(prefab, trParent)
	goPrefabIns.name = sPrefabPath
	self._mapPrefab[sPrefabPath] = goPrefabIns
	return goPrefabIns
end
function BaseCtrl:DestroyPrefabInstance(sPrefabPath)
	local goIns = self._mapPrefab[sPrefabPath]
	if goIns ~= nil then
		destroy(goIns)
		self._mapPrefab[sPrefabPath] = nil
	end
end
function BaseCtrl:LoadAsset(sPrefabPath, assetType)
	local sFullPath = sRootPath .. sPrefabPath
	if assetType == nil then
		assetType = typeof(Object)
	end
	local prefab = GameResourceLoader.LoadAsset(ResType.Any, sFullPath, assetType, "UI", self._panel._nPanelId)
	if prefab ~= nil then
		self._mapLoadAssets[sPrefabPath] = prefab
	end
	return prefab
end
function BaseCtrl:LoadAssetAsync(sPrefabPath, assetType, callback)
	local sFullPath = sRootPath .. sPrefabPath
	if assetType == nil then
		assetType = typeof(Object)
	end
	local callBack = function(obj)
		if obj ~= nil then
			if obj ~= nil then
				self._mapLoadAssets[sPrefabPath] = obj
			end
			if callback ~= nil then
				callback(obj)
			end
		end
	end
	GameResourceLoader.LoadAssetAsync(ResType.Any, sFullPath, assetType, "UI", self._panel._nPanelId, callBack)
end
function BaseCtrl:UnLoadAsset(sPrefabPath)
	local prefab = self._mapLoadAssets[sPrefabPath]
	if prefab ~= nil then
		prefab = nil
		self._mapLoadAssets[sPrefabPath] = nil
	end
end
function BaseCtrl:SpawnPrefabInstance(prefab, sLuaClassName, sPoolName, parent)
	local goPrefabIns = AdventureModuleHelper.SpawnPrefabInstance(prefab, sPoolName, parent)
	local luaClassName = require(sLuaClassName)
	local objCtrl = luaClassName.new(goPrefabIns, self._panel)
	objCtrl:_Enter()
	return objCtrl
end
function BaseCtrl:DespawnPrefabInstance(objCtrl, sPoolName)
	if objCtrl ~= nil then
		objCtrl:_PreExit()
		objCtrl:_Exit()
		objCtrl:_Destroy()
		AdventureModuleHelper.DespawnPrefabInstance(objCtrl.gameObject, sPoolName)
	end
end
function BaseCtrl:BindCtrlByNode(goNode, sCtrlName)
	local objCtrl
	local luaClass = require(sCtrlName)
	if luaClass == nil then
		printError("Ctrl Lua not found, path:" .. sCtrlName)
	else
		objCtrl = luaClass.new(goNode, self._panel)
		table.insert(self._panel._tbObjDyncChildCtrl, objCtrl)
		objCtrl:_Enter()
	end
	return objCtrl
end
function BaseCtrl:UnbindCtrlByNode(objCtrl)
	objCtrl:_PreExit()
	objCtrl:_Exit()
	objCtrl:_Destroy()
	objCtrl.gameObject = nil
	table.remove(self._panel._tbObjDyncChildCtrl, table.indexof(self._panel._tbObjDyncChildCtrl, objCtrl))
end
function BaseCtrl:SetAnimationCallback(animatior, sCallbackName)
	local wait = function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		local time = animatior:GetCurrentAnimatorStateInfo(0).length
		self:AddTimer(1, time, sCallbackName, true, true, true)
	end
	cs_coroutine.start(wait)
end
function BaseCtrl:ParseHitDamageDesc(nHitDamageId, nLevel)
	local sDesc = ""
	local mapDamage = ConfigTable.GetData_HitDamage(nHitDamageId)
	if not mapDamage then
		printError("\232\175\165 hit damage id \230\137\190\228\184\141\229\136\176\230\149\176\230\141\174:" .. nHitDamageId)
		sDesc = string.format("<color=#FF0000>%d</color>", nHitDamageId)
		return sDesc
	end
	local nPercent = mapDamage.SkillPercentAmend[nLevel]
	local nAbs = mapDamage.SkillAbsAmend[nLevel]
	if not nPercent or not nAbs then
		printError(string.format("\232\175\165\230\138\128\232\131\189\231\173\137\231\186\167\229\156\168 HitDamage \232\161\168\228\184\173\230\137\190\228\184\141\229\136\176\230\149\176\230\141\174, hit damage id:%d, level:%d", nHitDamageId, nLevel))
		sDesc = string.format("<color=#FF0000>%d</color>", nHitDamageId)
		return sDesc
	end
	nPercent = nPercent * ConfigData.IntFloatPrecision
	nPercent = FormatNum(nPercent)
	nAbs = FormatNum(nAbs)
	local sPercent = nPercent == 0 and "" or tostring(nPercent) .. "%%"
	local sAbs = nAbs == 0 and "" or tostring(nAbs)
	if nPercent ~= 0 and nAbs ~= 0 then
		sDesc = sPercent .. "+" .. sAbs
	else
		sDesc = sPercent .. sAbs
	end
	return sDesc
end
function BaseCtrl:ThousandsNumber(number)
	local formatted = tostring(number)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(.*-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end
	return formatted
end
function BaseCtrl:GetGamepadUINode()
	local tbNode = {}
	if self.gameObject == nil or type(self._mapNodeConfig) ~= "table" then
		return tbNode
	end
	local add = function(sKey, mapConfig, sComponentName)
		if mapConfig.sComponentName == sComponentName then
			local nCount = mapConfig.nCount
			if type(nCount) == "number" then
				for i = 1, nCount do
					local mapNode = self._mapNode[sKey][i]
					if mapNode then
						table.insert(tbNode, {
							mapNode = mapNode,
							sComponentName = sComponentName,
							sAction = mapConfig.sAction
						})
					end
				end
			else
				local mapNode = self._mapNode[sKey]
				if mapNode then
					table.insert(tbNode, {
						mapNode = mapNode,
						sComponentName = sComponentName,
						sAction = mapConfig.sAction
					})
				end
			end
		end
	end
	for sKey, mapConfig in pairs(self._mapNodeConfig) do
		add(sKey, mapConfig, "NaviButton")
		add(sKey, mapConfig, "GamepadScroll")
	end
	return tbNode
end
return BaseCtrl
