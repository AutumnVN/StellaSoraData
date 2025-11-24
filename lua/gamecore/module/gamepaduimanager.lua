local GamepadUIManager = {}
local InputManager = CS.InputManager
local ClientManager = CS.ClientManager.Instance
local sRootPath = Settings.AB_ROOT_PATH
local nCurUIType = AllEnum.GamepadUIType.Other
local sCurUIName
local tbHistory = {}
local mapGamepadUI = {}
local mapMouseConfig = {}
local bEnableInput = false
local bBlockUI = false
local bFirstInputEnable = false
local SetGamepadIcon = function(img, sAction)
	local sIcon
	if nCurUIType == AllEnum.GamepadUIType.PS then
		sIcon = ConfigTable.GetField("GamepadAction", sAction, "PlayStationIcon")
	elseif nCurUIType == AllEnum.GamepadUIType.Xbox then
		sIcon = ConfigTable.GetField("GamepadAction", sAction, "XboxIcon")
	elseif nCurUIType == AllEnum.GamepadUIType.Keyboard or nCurUIType == AllEnum.GamepadUIType.Mouse then
		sIcon = ConfigTable.GetField("GamepadAction", sAction, "KeyboardIcon")
	end
	if sIcon == "" then
		img.gameObject:SetActive(false)
		return
	end
	img.gameObject:SetActive(true)
	sIcon = sRootPath .. sIcon .. ".png"
	NovaAPI.SetImageSprite(img, sIcon)
	NovaAPI.SetImageNativeSize(img)
end
local RefreshCurTypeUINode = function(v)
	if not v.sAction then
		return
	end
	if v.sComponentName == "NaviButton" then
		if v.mapNode:IsNull() then
			return
		end
		local trRoot = v.mapNode.gameObject:GetComponent("Transform"):Find("AnimRoot")
		if trRoot then
			local Other = trRoot:Find("Other")
			if not Other then
				return
			end
			local General = trRoot:Find("General")
			local Xbox = trRoot:Find("Xbox")
			local PS = trRoot:Find("PS")
			local Keyboard = trRoot:Find("Keyboard")
			if General then
				if Xbox then
					Xbox.gameObject:SetActive(false)
				end
				if PS then
					PS.gameObject:SetActive(false)
				end
				if Keyboard then
					Keyboard.gameObject:SetActive(false)
				end
				General.gameObject:SetActive(nCurUIType ~= AllEnum.GamepadUIType.Other)
				Other.gameObject:SetActive(nCurUIType == AllEnum.GamepadUIType.Other)
				if nCurUIType ~= AllEnum.GamepadUIType.Other then
					local icon = General:Find("imgAction")
					if icon then
						SetGamepadIcon(icon:GetComponent("Image"), v.sAction)
					end
				end
			elseif not General and Xbox and PS and Keyboard then
				Xbox.gameObject:SetActive(nCurUIType == AllEnum.GamepadUIType.Xbox)
				PS.gameObject:SetActive(nCurUIType == AllEnum.GamepadUIType.PS)
				Keyboard.gameObject:SetActive(nCurUIType == AllEnum.GamepadUIType.Keyboard or nCurUIType == AllEnum.GamepadUIType.Mouse)
				Other.gameObject:SetActive(nCurUIType == AllEnum.GamepadUIType.Other)
				local icon
				if nCurUIType == AllEnum.GamepadUIType.Xbox then
					icon = Xbox:Find("imgAction")
				elseif nCurUIType == AllEnum.GamepadUIType.PS then
					icon = PS:Find("imgAction")
				elseif nCurUIType == AllEnum.GamepadUIType.Keyboard or nCurUIType == AllEnum.GamepadUIType.Mouse then
					icon = Keyboard:Find("imgAction")
				end
				if icon then
					SetGamepadIcon(icon:GetComponent("Image"), v.sAction)
				end
			end
		end
	elseif v.sComponentName == "GamepadScroll" then
		if v.mapNode:IsNull() then
			return
		end
		local trRoot = v.mapNode.gameObject:GetComponent("Transform"):Find("Scrollbar")
		if trRoot then
			local icon = trRoot:Find("imgAction")
			if icon then
				icon.gameObject:SetActive(nCurUIType ~= AllEnum.GamepadUIType.Other)
				if nCurUIType ~= AllEnum.GamepadUIType.Other then
					SetGamepadIcon(icon:GetComponent("Image"), v.sAction)
				end
			end
		end
	end
end
local RefreshCurTypeUI = function()
	if not sCurUIName then
		return
	end
	local tbNode = mapGamepadUI[sCurUIName]
	if (tbNode == nil or next(tbNode) == nil) and mapMouseConfig[sCurUIName] == nil then
		printWarn("GamepadUIManager\239\188\154\229\189\147\229\137\141UI\229\134\133\232\138\130\231\130\185\229\136\183\230\150\176\229\164\177\232\180\165\239\188\140\229\143\175\232\131\189\232\175\165UI\228\187\142\230\157\165\230\178\161\230\156\137\230\137\147\229\188\128\232\191\135\239\188\154" .. sCurUIName)
		return
	end
	for _, v in pairs(tbNode) do
		RefreshCurTypeUINode(v)
	end
end
local ChangeUIType = function(nAfterType)
	if nAfterType == nCurUIType then
		return
	end
	local nBeforeType = nCurUIType
	nCurUIType = nAfterType
	EventManager.Hit("GamepadUIChange", sCurUIName, nBeforeType, nAfterType)
	RefreshCurTypeUI()
end
local GetUITypeByGamepad = function()
	local nType = InputManager.Instance:CheckGamepadType()
	local nAfterType = AllEnum.GamepadUIType.Other
	if nType == InputManager.GamepadType.PS then
		nAfterType = AllEnum.GamepadUIType.PS
	elseif nType == InputManager.GamepadType.XBox or nType == InputManager.GamepadType.Switch or nType == InputManager.GamepadType.Other then
		nAfterType = AllEnum.GamepadUIType.Xbox
	elseif nType == InputManager.GamepadType.None then
		nAfterType = AllEnum.GamepadUIType.Other
	end
	return nAfterType
end
local OnEvent_LastInputDeviceChange = function(_, nType)
	local bMobile = NovaAPI.IsMobilePlatform()
	local bTable = ClientManager.isTabletDevice
	local nAfterType = AllEnum.GamepadUIType.Other
	if nType == InputManager.InputDeviceType.PSGamepad then
		nAfterType = AllEnum.GamepadUIType.PS
	elseif nType == InputManager.InputDeviceType.XBoxGamepad then
		nAfterType = AllEnum.GamepadUIType.Xbox
	elseif nType == InputManager.InputDeviceType.Keyboard and (not bMobile or bTable) then
		nAfterType = AllEnum.GamepadUIType.Keyboard
	elseif nType == InputManager.InputDeviceType.Mouse and (not bMobile or bTable) then
		nAfterType = AllEnum.GamepadUIType.Mouse
	elseif nType == InputManager.InputDeviceType.Other then
		nAfterType = GetUITypeByGamepad()
	elseif nType == InputManager.InputDeviceType.None then
		nAfterType = AllEnum.GamepadUIType.Other
	end
	ChangeUIType(nAfterType)
end
local GetUITypeByInputDevice = function()
	local bMobile = NovaAPI.IsMobilePlatform()
	local nType = InputManager.Instance:CheckInputDeviceType()
	local nAfterType = AllEnum.GamepadUIType.Other
	if nType == InputManager.InputDeviceType.PSGamepad then
		nAfterType = AllEnum.GamepadUIType.PS
	elseif nType == InputManager.InputDeviceType.XBoxGamepad then
		nAfterType = AllEnum.GamepadUIType.Xbox
	elseif nType == InputManager.InputDeviceType.Keyboard and not bMobile then
		nAfterType = AllEnum.GamepadUIType.Keyboard
	elseif nType == InputManager.InputDeviceType.Mouse and not bMobile then
		nAfterType = AllEnum.GamepadUIType.Mouse
	elseif nType == InputManager.InputDeviceType.Other then
		nAfterType = GetUITypeByGamepad()
	elseif nType == InputManager.InputDeviceType.None then
		nAfterType = AllEnum.GamepadUIType.Other
	end
	return nAfterType
end
local OnEvent_OnDeviceChange = function(_, changeType)
	if changeType.value__ == 0 or changeType.value__ == 1 then
		local nAfterType = GetUITypeByInputDevice()
		ChangeUIType(nAfterType)
	end
end
local OnEvent_BlockGamepadUI = function(_, bBlock)
	bBlockUI = bBlock
	if not sCurUIName then
		return
	end
	local tbNode = mapGamepadUI[sCurUIName]
	if tbNode == nil or next(tbNode) == nil then
		return
	end
	for _, v in pairs(tbNode) do
		if v.mapNode:IsNull() == false then
			if bFirstInputEnable then
				NovaAPI.SetComponentEnable(v.mapNode, not bBlock)
			else
				NovaAPI.SetComponentEnable(v.mapNode, false)
			end
		else
			printWarn("GamepadUIManager\239\188\154\229\189\147\229\137\141UI\229\174\158\228\190\139\229\183\178\233\148\128\230\175\129\239\188\140\230\151\160\233\156\128\229\177\143\232\148\189\239\188\154" .. sCurUIName)
			return
		end
	end
end
local EnableNode = function(sCtrlName)
	if not sCtrlName then
		printWarn("GamepadUIManager\239\188\154\229\189\147\229\137\141UI\229\134\133\232\138\130\231\130\185\230\137\147\229\188\128\229\164\177\232\180\165\239\188\140CtrlName\228\184\186\231\169\186")
		return
	end
	if NovaAPI.IsEditorPlatform() then
		printLog("GamepadUIManager\239\188\154Enable UI " .. sCtrlName)
	end
	local tbNode = mapGamepadUI[sCtrlName]
	if (tbNode == nil or next(tbNode) == nil) and mapMouseConfig[sCurUIName] == nil then
		printWarn("GamepadUIManager\239\188\154\229\189\147\229\137\141UI\229\134\133\232\138\130\231\130\185\230\137\147\229\188\128\229\164\177\232\180\165\239\188\140\229\143\175\232\131\189\232\175\165UI\228\187\142\230\157\165\230\178\161\230\156\137\230\137\147\229\188\128\232\191\135\239\188\154" .. sCtrlName)
		return
	end
	for _, v in pairs(tbNode) do
		if v.mapNode:IsNull() then
			printError("GamepadUIManager\239\188\154\229\189\147\229\137\141UI\229\134\133\232\138\130\231\130\185\230\137\147\229\188\128\229\164\177\232\180\165\239\188\140UI\229\174\158\228\190\139\229\183\178\233\148\128\230\175\129\239\188\154" .. sCtrlName)
			return
		end
		if not bBlockUI and bFirstInputEnable then
			if v.mapNode.enabled == true then
				NovaAPI.SetComponentEnable(v.mapNode, false)
			end
			NovaAPI.SetComponentEnable(v.mapNode, true)
		else
			NovaAPI.SetComponentEnable(v.mapNode, false)
		end
	end
end
local DisableNode = function(sCtrlName)
	if not sCtrlName then
		printWarn("GamepadUIManager\239\188\154\229\189\147\229\137\141UI\229\134\133\232\138\130\231\130\185\229\133\179\233\151\173\229\164\177\232\180\165\239\188\140CtrlName\228\184\186\231\169\186")
		return
	end
	if NovaAPI.IsEditorPlatform() then
		printLog("GamepadUIManager\239\188\154Disable UI " .. sCtrlName)
	end
	local tbNode = mapGamepadUI[sCtrlName]
	if (tbNode == nil or next(tbNode) == nil) and mapMouseConfig[sCurUIName] == nil then
		printWarn("GamepadUIManager\239\188\154\229\189\147\229\137\141UI\229\134\133\232\138\130\231\130\185\229\133\179\233\151\173\229\164\177\232\180\165\239\188\140\229\143\175\232\131\189\232\175\165UI\228\187\142\230\157\165\230\178\161\230\156\137\230\137\147\229\188\128\232\191\135\239\188\154" .. sCtrlName)
		return
	end
	for _, v in pairs(tbNode) do
		if v.mapNode:IsNull() then
			printError("GamepadUIManager\239\188\154\229\189\147\229\137\141UI\229\134\133\232\138\130\231\130\185\229\133\179\233\151\173\229\164\177\232\180\165\239\188\140UI\229\174\158\228\190\139\229\183\178\233\148\128\230\175\129\239\188\154" .. sCtrlName)
			return
		end
		NovaAPI.SetComponentEnable(v.mapNode, false)
	end
end
local OnEvent_FirstInputEnable = function()
	bFirstInputEnable = true
	if sCurUIName then
		EnableNode(sCurUIName)
	end
end
local OnEvent_OpenBuiltinAlert = function(_, bOpen, _okBtn, _confirmBtn, _cancelBtn)
	if not bEnableInput then
		NovaAPI.SetNaviButtonAction(_okBtn, false)
		NovaAPI.SetNaviButtonAction(_confirmBtn, false)
		NovaAPI.SetNaviButtonAction(_cancelBtn, false)
		return
	end
	if bOpen then
		local tbGamepadUINode = {
			[1] = {
				mapNode = _okBtn,
				sComponentName = "NaviButton",
				sAction = "buttonSouth"
			},
			[2] = {
				mapNode = _confirmBtn,
				sComponentName = "NaviButton",
				sAction = "buttonSouth"
			},
			[3] = {
				mapNode = _cancelBtn,
				sComponentName = "NaviButton",
				sAction = "buttonEast"
			}
		}
		GamepadUIManager.EnableGamepadUI("BuiltinUI", tbGamepadUINode)
		NovaAPI.SetNaviButtonAction(_okBtn, true)
		NovaAPI.SetNaviButtonAction(_confirmBtn, true)
		NovaAPI.SetNaviButtonAction(_cancelBtn, true)
	else
		GamepadUIManager.DisableGamepadUI("BuiltinUI")
	end
end
local function Uninit(_)
	EventManager.Remove("LuaEventName_OnDeviceChange", GamepadUIManager, OnEvent_OnDeviceChange)
	EventManager.Remove("LuaEventName_LastInputDeviceChange", GamepadUIManager, OnEvent_LastInputDeviceChange)
	EventManager.Remove("__BlockGamepadUI", GamepadUIManager, OnEvent_BlockGamepadUI)
	EventManager.Remove("FirstInputEnable", GamepadUIManager, OnEvent_FirstInputEnable)
	EventManager.Remove("__OpenBuiltinAlert", GamepadUIManager, OnEvent_OpenBuiltinAlert)
	EventManager.Remove(EventId.CSLuaManagerShutdown, GamepadUIManager, Uninit)
end
function GamepadUIManager.Init()
	nCurUIType = GetUITypeByInputDevice()
	EventManager.Add("LuaEventName_OnDeviceChange", GamepadUIManager, OnEvent_OnDeviceChange)
	EventManager.Add("LuaEventName_LastInputDeviceChange", GamepadUIManager, OnEvent_LastInputDeviceChange)
	EventManager.Add("__BlockGamepadUI", GamepadUIManager, OnEvent_BlockGamepadUI)
	EventManager.Add("FirstInputEnable", GamepadUIManager, OnEvent_FirstInputEnable)
	EventManager.Add("__OpenBuiltinAlert", GamepadUIManager, OnEvent_OpenBuiltinAlert)
	EventManager.Add(EventId.CSLuaManagerShutdown, GamepadUIManager, Uninit)
end
function GamepadUIManager.EnableGamepadUI(sCtrlName, tbNode, goDefaultSelected, bEnableVirtualMouse, bBlockCursor)
	if sCurUIName == sCtrlName then
		printWarn("GamepadUIManager\239\188\154\233\135\141\229\164\141\230\137\147\229\188\128Gamepad UI\239\188\154" .. sCtrlName)
		return
	end
	NovaAPI.ClearSelectedUI()
	if goDefaultSelected then
		NovaAPI.SetSelectedUI(goDefaultSelected)
	end
	InputManager.Instance.IsVirtualMouseEnabled = bEnableVirtualMouse == true
	InputManager.Instance.IsBlockCursor = bBlockCursor == true
	local bSwitch = false
	if sCurUIName then
		DisableNode(sCurUIName)
		bSwitch = true
	end
	sCurUIName = sCtrlName
	mapGamepadUI[sCurUIName] = clone(tbNode)
	if not mapMouseConfig[sCurUIName] then
		mapMouseConfig[sCurUIName] = {}
	end
	mapMouseConfig[sCurUIName].VirtualMouse = bEnableVirtualMouse == true
	mapMouseConfig[sCurUIName].BlockCursor = bBlockCursor == true
	table.insert(tbHistory, sCurUIName)
	RefreshCurTypeUI()
	if bSwitch then
		local wait = function()
			coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
			EnableNode(sCurUIName)
		end
		cs_coroutine.start(wait)
	else
		EnableNode(sCurUIName)
	end
end
function GamepadUIManager.DisableGamepadUI(sCtrlName)
	local nIndex = table.indexof(tbHistory, sCtrlName)
	if nIndex == 0 then
		return
	end
	if sCurUIName == sCtrlName then
		DisableNode(sCtrlName)
		mapGamepadUI[sCtrlName] = nil
		mapMouseConfig[sCtrlName] = nil
		table.remove(tbHistory, nIndex)
		sCurUIName = nil
		if next(tbHistory) ~= nil then
			sCurUIName = tbHistory[#tbHistory]
			InputManager.Instance.IsVirtualMouseEnabled = mapMouseConfig[sCurUIName].VirtualMouse
			InputManager.Instance.IsBlockCursor = mapMouseConfig[sCurUIName].BlockCursor
			RefreshCurTypeUI()
			local wait = function()
				coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
				if sCurUIName then
					EnableNode(sCurUIName)
					EventManager.Hit("GamepadUIReopen", sCurUIName)
				else
					printWarn("GamepadUIManager\239\188\154\229\133\179\233\151\173\229\142\134\229\143\178\230\156\170\230\137\190\229\136\176\229\175\185\229\186\148ctrl")
				end
			end
			cs_coroutine.start(wait)
		end
	else
		mapGamepadUI[sCtrlName] = nil
		mapMouseConfig[sCtrlName] = nil
		table.remove(tbHistory, nIndex)
	end
end
function GamepadUIManager.AddGamepadUINode(sCtrlName, tbNode)
	if not mapGamepadUI or not mapGamepadUI[sCtrlName] then
		printWarn("GamepadUIManager\239\188\154\229\189\147\229\137\141ui\228\184\141\229\173\152\229\156\168\239\188\140\230\183\187\229\138\160\232\138\130\231\130\185\229\164\177\232\180\165Gamepad UI\239\188\154" .. sCtrlName)
		return
	end
	for _, v in pairs(tbNode) do
		table.insert(mapGamepadUI[sCtrlName], v)
	end
	if sCurUIName == sCtrlName then
		EnableNode(sCtrlName)
		for _, v in pairs(tbNode) do
			RefreshCurTypeUINode(v)
		end
	else
		DisableNode(sCtrlName)
	end
end
function GamepadUIManager.SetSelectedUI(goSelected)
	NovaAPI.SetSelectedUI(goSelected)
end
function GamepadUIManager.ClearSelectedUI()
	NovaAPI.ClearSelectedUI()
end
function GamepadUIManager.SetNavigation(tbUIObj, bHorizontal, bLoop)
	if bHorizontal == nil then
		bHorizontal = true
	end
	if bLoop == nil then
		bLoop = true
	end
	NovaAPI.SetGamepadUINavigation(tbUIObj, bHorizontal, bLoop)
end
function GamepadUIManager.GetCurUIType()
	return nCurUIType
end
function GamepadUIManager.GetCurUIName()
	return sCurUIName
end
function GamepadUIManager.GetInputState()
	return bEnableInput
end
function GamepadUIManager.GetPrveUIName()
	if next(tbHistory) == nil then
		return
	end
	local nCount = #tbHistory
	if 1 < nCount then
		return tbHistory[nCount - 1]
	end
end
function GamepadUIManager.EnterAdventure(bSkipFirstInputEnable)
	InputManager.Instance.IsVirtualMouseEnabled = false
	InputManager.Instance.IsBlockCursor = false
	InputManager.Instance.IsBattleSubmit = true
	sCurUIName = nil
	tbHistory = {}
	mapGamepadUI = {}
	mapMouseConfig = {}
	bEnableInput = true
	bFirstInputEnable = bSkipFirstInputEnable
end
function GamepadUIManager.QuitAdventure()
	InputManager.Instance.IsVirtualMouseEnabled = true
	InputManager.Instance.IsBlockCursor = false
	InputManager.Instance.IsBattleSubmit = false
	sCurUIName = nil
	tbHistory = {}
	mapGamepadUI = {}
	mapMouseConfig = {}
	bEnableInput = false
	bFirstInputEnable = false
end
function GamepadUIManager.GetInputName(mapInput)
	if not mapInput.name or not mapInput.displayName then
		return
	end
	local sName = mapInput.displayName
	if string.find(mapInput.name, "left") then
		sName = string.gsub(mapInput.name, "left", "L-")
	elseif string.find(mapInput.name, "right") then
		sName = string.gsub(mapInput.name, "right", "R-")
	elseif sName == "Num Del" then
		sName = "Num."
	elseif string.find(mapInput.name, "numpad") then
		local position = string.find(sName, " ")
		if position then
			sName = "Num" .. string.sub(sName, position + 1)
		else
			sName = "Num" .. sName
		end
	end
	return sName
end
return GamepadUIManager
