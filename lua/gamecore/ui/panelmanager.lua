local TimerManager = require("GameCore.Timer.TimerManager")
local WwiseAudioMgr = CS.WwiseAudioManager.Instance
local ClientMgr = CS.ClientManager
local AdventureModuleHelper = CS.AdventureModuleHelper
local PanelManager = {}
local mapUIRootTransform, mapDefinePanel, objCurPanel, objNextPanel, tbBackHistory, tbDisposablePanel, trSnapshotParent, tbTemplateSnapshot, nThresholdHistoryPanelCount, objTransitionPanel, bMainViewSkipAnimIn
local nInputRC = 0
local tbGoSnapShot, objPlayerInfoPanel
local OnClearRequiredLua = function(listener, strPath)
	printLog("[Lua\233\135\141\232\189\189] \230\184\133\233\153\164\228\186\134\239\188\154" .. strPath)
	package.loaded[strPath] = nil
end
local TakeSnapshot = function(nType)
	local goSnapshotIns
	if nType <= 0 or tbTemplateSnapshot == nil then
		return goSnapshotIns
	end
	local goT = tbTemplateSnapshot[nType]
	if goT ~= nil and goT:IsNull() == false then
		goSnapshotIns = instantiate(goT, trSnapshotParent)
		goSnapshotIns:SetActive(true)
		local goUIEffectSnapshot
		if nType == 1 or nType == 3 or nType == 4 then
			goUIEffectSnapshot = goSnapshotIns.transform:GetChild(0).gameObject
		else
			goUIEffectSnapshot = goSnapshotIns
		end
		NovaAPI.UIEffectSnapShotCapture(goUIEffectSnapshot)
	end
	return goSnapshotIns
end
local GetPanelName = function(nPanelId)
	for k, v in pairs(PanelId) do
		if v == nPanelId then
			return k
		end
	end
end
local AddTbGoSnapShot = function(nPanelId, goIns)
	if Settings.bDestroyHistoryUIInstance then
		if tbGoSnapShot == nil then
			tbGoSnapShot = {}
		end
		if goIns ~= nil then
			tbGoSnapShot[nPanelId] = {goIns = goIns, bMove = false}
		end
	end
end
local MoveSnapShot = function(nPanelId)
	if Settings.bDestroyHistoryUIInstance and tbGoSnapShot[nPanelId] ~= nil then
		tbGoSnapShot[nPanelId].bMove = true
		tbGoSnapShot[nPanelId].goIns.gameObject.transform:SetParent(trSnapshotParent)
	end
end
local GetSnapShot = function(nPanelId)
	if Settings.bDestroyHistoryUIInstance and tbGoSnapShot[nPanelId] ~= nil then
		tbGoSnapShot[nPanelId].bMove = false
		tbGoSnapShot[nPanelId].goIns.gameObject:SetActive(true)
		return tbGoSnapShot[nPanelId].goIns
	end
end
local HideMoveSnapshot = function()
	if Settings.bDestroyHistoryUIInstance and tbGoSnapShot ~= nil then
		for _, v in pairs(tbGoSnapShot) do
			if v.bMove and v.goIns ~= nil then
				v.goIns.gameObject:SetActive(false)
			end
		end
	end
end
local RemoveTbSnapShot = function(nPanelId)
	if Settings.bDestroyHistoryUIInstance and tbGoSnapShot[nPanelId] ~= nil then
		local goIns = tbGoSnapShot[nPanelId].goIns
		if goIns ~= nil then
			destroy(goIns)
		end
		tbGoSnapShot[nPanelId] = nil
	end
end
local CheckThresholdCount = function()
	if nThresholdHistoryPanelCount == nil then
		nThresholdHistoryPanelCount = ConfigTable.GetConfigNumber("MaxHistoryPanel")
	end
	local nCurCount = #tbBackHistory
	if nCurCount > nThresholdHistoryPanelCount then
		local nDelCount = nCurCount - nThresholdHistoryPanelCount
		local tbNeedRemovePanelIndex = {}
		for i = 1, nCurCount do
			if tbBackHistory[i]._nPanelId ~= PanelId.MainView then
				table.insert(tbNeedRemovePanelIndex, i)
				nDelCount = nDelCount - 1
				if nDelCount <= 0 then
					break
				end
			end
		end
		nDelCount = #tbNeedRemovePanelIndex
		if nDelCount == nCurCount - nThresholdHistoryPanelCount then
			for i = nDelCount, 1, -1 do
				local nPanelIndex = tbNeedRemovePanelIndex[i]
				RemoveTbSnapShot(tbBackHistory[nPanelIndex]._nPanelId)
				tbBackHistory[nPanelIndex]:_Exit()
				tbBackHistory[nPanelIndex]:_Destroy()
				table.remove(tbBackHistory, nPanelIndex)
			end
		end
	end
end
local DoBackToTarget = function(nTargetIndex)
	if type(nTargetIndex) ~= "number" then
		nTargetIndex = 1
	end
	local nCount = #tbBackHistory
	if nTargetIndex < nCount and objCurPanel ~= nil then
		local func_PreExitDone = function()
			if objCurPanel._bAddToBackHistory == true then
				table.remove(tbBackHistory, nCount)
			end
			nCount = #tbBackHistory
			for i = nCount, nTargetIndex + 1, -1 do
				local objPanel = tbBackHistory[i]
				RemoveTbSnapShot(objPanel._nPanelId)
				objPanel:_PreExit()
				objPanel:_Exit()
				objPanel:_Destroy()
				table.remove(tbBackHistory, i)
			end
			local objBackPanel = tbBackHistory[nTargetIndex]
			if type(objBackPanel.Awake) == "function" then
				objBackPanel:Awake()
			end
			local goSnapshot = GetSnapShot(objBackPanel._nPanelId)
			objBackPanel:_PreEnter(nil, goSnapshot)
			objCurPanel:_Exit()
			objBackPanel:_Enter()
			objCurPanel:_Destroy()
			objCurPanel = objBackPanel
			printLog("[\231\149\140\233\157\162\229\136\135\230\141\162] \229\183\178\232\191\148\229\155\158\232\135\179\229\142\134\229\143\178\233\152\159\229\136\151\230\140\135\229\174\154\231\154\132\231\180\162\229\188\149\239\188\154" .. tostring(nTargetIndex) .. "\239\188\140\231\149\140\233\157\162\239\188\154" .. GetPanelName(objCurPanel._nPanelId))
		end
		objCurPanel:_PreExit(func_PreExitDone, true)
	end
	PanelManager.CloseAllDisposablePanel()
end
local CloseCurPanel = function()
	local nLastIndex = #tbBackHistory
	if objCurPanel == nil then
		return
	end
	if objCurPanel._bAddToBackHistory ~= true or objCurPanel._bAddToBackHistory == true and 1 < nLastIndex then
		local func_DoBack = function()
			if objCurPanel._bAddToBackHistory == true then
				table.remove(tbBackHistory, nLastIndex)
			end
			nLastIndex = #tbBackHistory
			local objBackPanel = tbBackHistory[nLastIndex]
			local goSnapshot = GetSnapShot(objBackPanel._nPanelId)
			objBackPanel:_PreEnter(nil, goSnapshot)
			objCurPanel:_Exit()
			objBackPanel:_Enter()
			objCurPanel:_Destroy()
			objCurPanel = objBackPanel
			objCurPanel:_AfterEnter()
			printLog("[\231\149\140\233\157\162\229\136\135\230\141\162] \229\183\178\229\174\140\230\136\144\239\188\154\229\133\179\233\151\173\229\189\147\229\137\141\229\185\182\230\137\147\229\188\128\229\142\134\229\143\178\233\152\159\229\136\151\231\154\132\230\156\128\229\144\142\228\184\128\228\184\170\239\188\140 \229\189\147\229\137\141\230\137\147\229\188\128\231\154\132\231\149\140\233\157\162\239\188\154" .. GetPanelName(objCurPanel._nPanelId))
		end
		RemoveTbSnapShot(objCurPanel._nPanelId)
		objCurPanel:_PreExit(func_DoBack, true)
	end
end
local ClosePanel = function(nPanelId)
	if objCurPanel ~= nil then
		if objCurPanel._nPanelId == nPanelId then
			CloseCurPanel()
		else
			local nCount = #tbBackHistory
			for i = nCount, 1, -1 do
				local objPanel = tbBackHistory[i]
				if objPanel._nPanelId == nPanelId then
					table.remove(tbBackHistory, i)
					objPanel:_Destroy()
					RemoveTbSnapShot(objPanel._nPanelId)
					objPanel = nil
					printLog("[\231\149\140\233\157\162\229\136\135\230\141\162] \228\187\133\229\133\179\233\151\173\230\140\135\229\174\154\231\154\132\231\149\140\233\157\162\239\188\154" .. GetPanelName(nPanelId))
					break
				end
			end
		end
	end
end
local OnClosePanel = function(listener, nPanelId)
	if objNextPanel ~= nil then
		printError("[\231\149\140\233\157\162\229\136\135\230\141\162] \229\133\179\233\151\173\231\149\140\233\157\162\239\188\154" .. GetPanelName(nPanelId) .. " \229\164\177\232\180\165\239\188\140\228\184\138\228\184\128\230\172\161\231\149\140\233\157\162\229\136\135\230\141\162\230\181\129\231\168\139\229\176\154\230\156\170\229\174\140\230\136\144\239\188\140\230\173\163\229\156\168\229\164\132\231\144\134\239\188\154" .. GetPanelName(objNextPanel._nPanelId))
		return
	end
	if type(nPanelId) == "number" then
		local bIsMainPanel = true
		if type(tbDisposablePanel) == "table" then
			for i, v in ipairs(tbDisposablePanel) do
				if v._nPanelId == nPanelId then
					EventManager.Hit("Guide_CloseDisposablePanel", nPanelId)
					v:_PreExit()
					v:_Exit()
					v:_Destroy()
					table.remove(tbDisposablePanel, i)
					RemoveTbSnapShot(v._nPanelId)
					bIsMainPanel = false
					printLog("[\231\149\140\233\157\162\229\136\135\230\141\162] \229\133\179\233\151\173\228\186\134\233\157\158\228\184\187 Panel \231\149\140\233\157\162\239\188\154" .. GetPanelName(nPanelId))
					break
				end
			end
		end
		if bIsMainPanel == true then
			ClosePanel(nPanelId)
		end
	end
end
local OnCloseCurPanel = function(listener)
	if objCurPanel ~= nil and objCurPanel._bIsMainPanel == true then
		CloseCurPanel()
	end
end
local EnterNext = function()
	objNextPanel:_Enter(true)
	if objCurPanel ~= nil then
		if objCurPanel._bAddToBackHistory == true then
			objCurPanel:_SetPrefabInstance(Settings.bDestroyHistoryUIInstance)
		else
			objCurPanel:_Destroy()
		end
	end
	objCurPanel = objNextPanel
	objNextPanel = nil
	objCurPanel:_AfterEnter()
	printLog("[\231\149\140\233\157\162\229\136\135\230\141\162] \229\174\140\230\136\144\239\188\140\229\189\147\229\137\141\231\149\140\233\157\162\239\188\154" .. tostring(objCurPanel._nPanelId) .. ", " .. GetPanelName(objCurPanel._nPanelId))
end
local ExitCurrent = function()
	if objCurPanel == nil then
		EnterNext()
	else
		objCurPanel:_Exit()
		EnterNext()
	end
end
local PreEnterNext = function()
	local goSnapshot = TakeSnapshot(objNextPanel._nSnapshotPrePanel)
	AddTbGoSnapShot(objNextPanel._nPanelId, goSnapshot)
	cs_coroutine.start(function()
		coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
		objNextPanel:_PreEnter(ExitCurrent, goSnapshot)
		HideMoveSnapshot()
	end)
end
local PreExitCurrent = function()
	if objCurPanel == nil then
		PreEnterNext()
	else
		MoveSnapShot(objCurPanel._nPanelId)
		objCurPanel:_PreExit(PreEnterNext, true)
	end
end
local OnOpenPanel = function(listener, nPanelId, ...)
	if objNextPanel ~= nil then
		printError("[\231\149\140\233\157\162\229\136\135\230\141\162] \230\137\147\229\188\128\231\149\140\233\157\162\239\188\154" .. GetPanelName(nPanelId) .. " \229\164\177\232\180\165\239\188\140\228\184\138\228\184\128\230\172\161\231\149\140\233\157\162\229\136\135\230\141\162\230\181\129\231\168\139\229\176\154\230\156\170\229\174\140\230\136\144\239\188\140\230\173\163\229\156\168\229\164\132\231\144\134\239\188\154" .. GetPanelName(objNextPanel._nPanelId))
		return
	end
	if nPanelId == PanelId.MainView and 0 < #tbBackHistory then
		EventManager.Hit(EventId.CloesCurPanel)
		return
	end
	if objCurPanel ~= nil and objCurPanel._nPanelId == nPanelId then
		return
	end
	local luaClass = require(mapDefinePanel[nPanelId])
	local tbParameter = {}
	for i = 1, select("#", ...) do
		local param = select(i, ...)
		table.insert(tbParameter, param)
	end
	local nIndex = 1
	if objCurPanel ~= nil then
		nIndex = objCurPanel._nIndex + 1
	end
	local objTempPanel = luaClass.new(nIndex, nPanelId, tbParameter)
	if objTempPanel._bIsMainPanel == true then
		objNextPanel = objTempPanel
		if objNextPanel._bAddToBackHistory == true then
			table.insert(tbBackHistory, objNextPanel)
		end
		PreExitCurrent()
	else
		local _bHasOpenTips = false
		for i, v in ipairs(tbDisposablePanel) do
			if _bHasOpenTips == false then
				_bHasOpenTips = UTILS.CheckIsTipsPanel(v._nPanelId)
			end
			if v._nPanelId == nPanelId then
				MoveSnapShot(v._nPanelId)
				objTempPanel:_PreExit()
				objTempPanel:_Exit()
				objTempPanel:_Destroy()
				objTempPanel = nil
				printLog("[\231\149\140\233\157\162\229\136\135\230\141\162] \230\137\147\229\188\128\233\157\158\228\184\187 Panel\239\188\154" .. GetPanelName(nPanelId) .. " \229\164\177\232\180\165\239\188\140\228\184\141\232\131\189\233\135\141\229\164\141\230\137\147\229\188\128\227\128\130")
				return
			end
		end
		objTempPanel._nIndex = objTempPanel._nIndex + #tbDisposablePanel
		objTempPanel._bIsExtraTips = _bHasOpenTips
		local goSnapshot = TakeSnapshot(objTempPanel._nSnapshotPrePanel)
		objTempPanel:_PreEnter(nil, goSnapshot)
		objTempPanel:_Enter()
		table.insert(tbDisposablePanel, objTempPanel)
		printLog("[\231\149\140\233\157\162\229\136\135\230\141\162] \230\137\147\229\188\128\233\157\158\228\184\187 Panel\239\188\154" .. GetPanelName(nPanelId) .. "\230\136\144\229\138\159\227\128\130")
	end
	CheckThresholdCount()
end
local OnOpenLoading = function(listener, objTarget, callbackUpdate, callbackDone)
	if objTarget == nil or type(callbackUpdate) == "function" then
	else
	end
end
local OnBlockInput = function(listener, bEnable)
	if bEnable == true then
		ClientMgr.Instance:EnableInputBlock()
	else
		ClientMgr.Instance:DisableInputBlock()
	end
end
local OnTemporaryBlockInput = function(listener, nDuration, callback)
	if 0 < nDuration then
		local timerCallback = function()
			OnBlockInput(PanelManager, false)
			if type(callback) == "function" then
				callback()
			end
		end
		OnBlockInput(PanelManager, true)
		TimerManager.Add(1, nDuration, PanelManager, timerCallback, true, true, true)
	end
end
local OnMarkCurCanvasFullRectWH = function()
	if trSnapshotParent ~= nil and trSnapshotParent:IsNull() == false then
		local rt = trSnapshotParent:GetComponent("RectTransform")
		Settings.CURRENT_CANVAS_FULL_RECT_WIDTH = rt.rect.width
		Settings.CURRENT_CANVAS_FULL_RECT_HEIGHT = rt.rect.height
		Settings.CANVAS_SCALE = rt.localScale.x
	end
end
local function OnCSLuaManagerShutdown()
	if objCurPanel ~= nil then
		objCurPanel:_PreExit()
		objCurPanel:_Exit()
		objCurPanel:_Destroy()
	end
	EventManager.Remove(EventId.CSLuaManagerShutdown, PanelManager, OnCSLuaManagerShutdown)
	EventManager.Remove(EventId.OpenPanel, PanelManager, OnOpenPanel)
	EventManager.Remove(EventId.ClosePanel, PanelManager, OnClosePanel)
	EventManager.Remove(EventId.CloesCurPanel, PanelManager, OnCloseCurPanel)
	EventManager.Remove(EventId.OpenLoading, PanelManager, OnOpenLoading)
	EventManager.Remove(EventId.BlockInput, PanelManager, OnBlockInput)
	EventManager.Remove(EventId.TemporaryBlockInput, PanelManager, OnTemporaryBlockInput)
	EventManager.Remove("ReEnterLogin", PanelManager, PanelManager.OnConfirmBackToLogIn)
	EventManager.Remove("OnSdkLogout", PanelManager, PanelManager.OnConfirmBackToLogIn)
	EventManager.Remove(EventId.MarkFullRectWH, PanelManager, OnMarkCurCanvasFullRectWH)
	EventManager.Remove("ClearRequiredLua", PanelManager, OnClearRequiredLua)
end
local AddEventCallback = function()
	EventManager.Add(EventId.CSLuaManagerShutdown, PanelManager, OnCSLuaManagerShutdown)
	EventManager.Add(EventId.OpenPanel, PanelManager, OnOpenPanel)
	EventManager.Add(EventId.ClosePanel, PanelManager, OnClosePanel)
	EventManager.Add(EventId.CloesCurPanel, PanelManager, OnCloseCurPanel)
	EventManager.Add(EventId.OpenLoading, PanelManager, OnOpenLoading)
	EventManager.Add(EventId.BlockInput, PanelManager, OnBlockInput)
	EventManager.Add(EventId.TemporaryBlockInput, PanelManager, OnTemporaryBlockInput)
	EventManager.Add("ReEnterLogin", PanelManager, PanelManager.OnConfirmBackToLogIn)
	EventManager.Add("OnSdkLogout", PanelManager, PanelManager.OnConfirmBackToLogIn)
	EventManager.Add(EventId.MarkFullRectWH, PanelManager, OnMarkCurCanvasFullRectWH)
	EventManager.Add("ClearRequiredLua", PanelManager, OnClearRequiredLua)
end
local InitGuidePanel = function()
	if AVG_EDITOR == true then
		return
	end
	local GuidePanel = require("Game.UI.Guide.GuidePanel")
	local objGuidePanel = GuidePanel.new(AllEnum.UI_SORTING_ORDER.Guide, PanelId.Guide, {})
	objGuidePanel:_PreEnter()
	objGuidePanel:_Enter()
end
local InitTransitionPanel = function()
	local TransitionPanel = require("Game.UI.TransitionEx.TransitionPanel")
	objTransitionPanel = TransitionPanel.new(AllEnum.UI_SORTING_ORDER.Transition, PanelId.Transition, {})
	objTransitionPanel:_PreEnter()
	objTransitionPanel:_Enter()
end
local CreateCBTTips = function()
	if EXE_EDITOR == true then
		return
	end
	local GameResourceLoader = require("Game.Common.Resource.GameResourceLoader")
	local ResType = GameResourceLoader.ResType
	local prefab = GameResourceLoader.LoadAsset(ResType.Any, Settings.AB_ROOT_PATH .. "UI/CBT_Tips/CBT_TipsPanel.prefab", typeof(Object), "UI", -999)
	local trParent = PanelManager.GetUIRoot(AllEnum.SortingLayerName.UI_Top)
	local goPrefabInstance = instantiate(prefab, trParent)
	goPrefabInstance.name = prefab.name
	goPrefabInstance.transform:SetAsLastSibling()
	local _canvasCBTTips = goPrefabInstance:GetComponent("Canvas")
	NovaAPI.SetCanvasWorldCamera(_canvasCBTTips, CS.GameCameraStackManager.Instance.uiCamera)
end
local CreatePlayerInfoTips = function()
	if EXE_EDITOR == true then
		return
	end
	local PlayerInfoPanel = require("Game.UI.PlayerInfo.PlayerInfoPanel")
	objPlayerInfoPanel = PlayerInfoPanel.new(AllEnum.UI_SORTING_ORDER.Player_Info, PanelId.PlayerInfo, {})
	objPlayerInfoPanel:_PreEnter()
	objPlayerInfoPanel:_Enter()
end
function PanelManager.Init()
	local goUIRoot = GameObject.Find("==== UI ROOT ====")
	if goUIRoot ~= nil then
		mapUIRootTransform = {}
		mapUIRootTransform[0] = goUIRoot.transform
		local func_CacheRootTransform = function(sSortingLayerName, sNodeName)
			local trNode = goUIRoot.transform:Find(sNodeName)
			mapUIRootTransform[sSortingLayerName] = trNode
		end
		func_CacheRootTransform(AllEnum.SortingLayerName.HUD, "---- HUD ----")
		func_CacheRootTransform(AllEnum.SortingLayerName.UI, "---- UI ----")
		func_CacheRootTransform(AllEnum.SortingLayerName.UI_Top, "---- UI TOP ----")
		func_CacheRootTransform(AllEnum.SortingLayerName.UI_Video, "---- UI Video ----")
		func_CacheRootTransform(AllEnum.SortingLayerName.Overlay, "---- UI OVERLAY ----")
		trSnapshotParent = mapUIRootTransform[0]:Find("---- UI ----/Snapshot")
		tbTemplateSnapshot = {}
		tbTemplateSnapshot[1] = trSnapshotParent:GetChild(0).gameObject
		tbTemplateSnapshot[2] = trSnapshotParent:GetChild(1).gameObject
		tbTemplateSnapshot[3] = trSnapshotParent:GetChild(2).gameObject
		tbTemplateSnapshot[4] = trSnapshotParent:GetChild(3).gameObject
		OnMarkCurCanvasFullRectWH()
	end
	objCurPanel = nil
	objNextPanel = nil
	tbBackHistory = {}
	tbDisposablePanel = {}
	mapDefinePanel = require("GameCore.UI.PanelDefine")
	AddEventCallback()
	InitGuidePanel()
	InitTransitionPanel()
	local goBootstrapUI = GameObject.Find("==== Builtin UI ====/BootstrapUI")
	GameObject.Destroy(goBootstrapUI)
	local goLaunchUI = GameObject.Find("==== Builtin UI ====/LaunchUI")
	NovaAPI.CloseLaunchLoading(goLaunchUI)
	CreatePlayerInfoTips()
end
function PanelManager.GetUIRoot(sSortingLayerName)
	if sSortingLayerName == nil then
		sSortingLayerName = 0
	end
	return mapUIRootTransform[sSortingLayerName]
end
function PanelManager.Home()
	local nBackToIdx = 1
	for nIndex, objPanel in ipairs(tbBackHistory) do
		if objPanel._nPanelId == PanelId.MainMenu then
			nBackToIdx = nIndex
			break
		end
	end
	DoBackToTarget(nBackToIdx)
end
function PanelManager.OnConfirmBackToLogIn()
	if objCurPanel == nil then
		return
	end
	if objCurPanel._bAddToBackHistory ~= true then
		objCurPanel:_PreExit()
		objCurPanel:_Exit()
		objCurPanel:_Destroy()
		objCurPanel = nil
	end
	local nCount = #tbBackHistory
	for i = nCount, 1, -1 do
		local objPanel = tbBackHistory[i]
		objPanel:_PreExit()
		objPanel:_Exit()
		objPanel:_Destroy()
		table.remove(tbBackHistory, i)
		RemoveTbSnapShot(objPanel._nPanelId)
		if objCurPanel ~= nil and objCurPanel == objPanel then
			objCurPanel = nil
		end
		objPanel = nil
	end
	PlayerData.UnInit()
	PlayerData.Init()
	NovaAPI.ExitGame()
end
function PanelManager.Release()
	if type(tbBackHistory) == "table" then
		for i, objPanel in ipairs(tbBackHistory) do
			objPanel:_Release()
		end
	end
end
function PanelManager.GetCurPanelId()
	if objCurPanel ~= nil then
		return objCurPanel._nPanelId
	end
	return 0
end
function PanelManager.GetDisposablePanelState(nPanelId)
	for i, v in ipairs(tbDisposablePanel) do
		if v._nPanelId == nPanelId then
			return true
		end
	end
	return false
end
function PanelManager.CheckPanelOpen(nPanelId)
	if type(tbBackHistory) == "table" then
		for i, objPanel in ipairs(tbBackHistory) do
			if objPanel._nPanelId == nPanelId then
				return true, objPanel._bIsActive
			end
		end
	end
	if type(tbDisposablePanel) == "table" then
		for i, v in ipairs(tbDisposablePanel) do
			if v._nPanelId == nPanelId then
				return true, v._bIsActive
			end
		end
	end
	return false, false
end
function PanelManager.CheckNextPanelOpening()
	return objNextPanel ~= nil
end
function PanelManager.SetMainViewSkipAnimIn(bIn)
	bMainViewSkipAnimIn = bIn
end
function PanelManager.GetMainViewSkipAnimIn()
	return bMainViewSkipAnimIn
end
function PanelManager.InputEnable(bAudioStop, bDisActiveUICombat)
	print("PanelManager.InputEnable")
	local resume = function()
		local wait = function()
			coroutine.yield(CS.UnityEngine.WaitForEndOfFrame())
			NovaAPI.InputEnable()
			AdventureModuleHelper.ResumeLogic()
			if bAudioStop then
				WwiseAudioMgr:PostEvent("char_common_all_stop")
				WwiseAudioMgr:PostEvent("mon_common_all_stop")
			else
				WwiseAudioMgr:PostEvent("char_common_all_resume")
				WwiseAudioMgr:PostEvent("mon_common_all_resume")
			end
			if not bDisActiveUICombat then
				WwiseAudioMgr:PostEvent("ui_loading_combatSFX_active", nil, false)
			end
		end
		cs_coroutine.start(wait)
	end
	nInputRC = nInputRC - 1
	if nInputRC == 0 then
		resume()
	end
	if nInputRC < 0 then
		nInputRC = 0
		printError("InputEnable\228\184\142InputDisable\228\189\191\231\148\168\228\184\141\229\140\185\233\133\141\239\188\140\232\175\183\230\136\144\229\175\185\228\189\191\231\148\168")
		resume()
	end
end
function PanelManager.InputDisable()
	print("PanelManager.InputDisable")
	if nInputRC == 0 then
		NovaAPI.InputDisable()
		AdventureModuleHelper.PauseLogic()
		WwiseAudioMgr:PostEvent("ui_loading_combatSFX_mute", nil, false)
		WwiseAudioMgr:PostEvent("char_common_all_pause")
		WwiseAudioMgr:PostEvent("mon_common_all_pause")
	end
	nInputRC = nInputRC + 1
end
function PanelManager.ClearInputState()
	nInputRC = 0
end
local goDiscSkillActive, goSelect1, goSelect2, goSelect3, goDashboard, trSupportRole, trMainRole, trSkillHint, trJoystick, goTransition, goPlayerInfo
function PanelManager.SwitchUI()
	if mapUIRootTransform == nil then
		return
	end
	local trUIRoot
	trUIRoot = mapUIRootTransform[AllEnum.SortingLayerName.UI]
	if trUIRoot ~= nil then
		if goDiscSkillActive == nil or goDiscSkillActive ~= nil and goDiscSkillActive:IsNull() == true then
			goDiscSkillActive = trUIRoot:Find("DiscSkillActivePanel")
			if goDiscSkillActive ~= nil and goDiscSkillActive:IsNull() == false then
				goDiscSkillActive:SetParent(mapUIRootTransform[0])
			end
		end
		if goSelect1 == nil or goSelect1 ~= nil and goSelect1:IsNull() == true then
			goSelect1 = trUIRoot:Find("FateCardSelectPanel")
			if goSelect1 ~= nil and goSelect1:IsNull() == false then
				goSelect1:SetParent(mapUIRootTransform[0])
			end
		end
		if goSelect2 == nil or goSelect2 ~= nil and goSelect2:IsNull() == true then
			goSelect2 = trUIRoot:Find("NoteSelectPanel")
			if goSelect2 ~= nil and goSelect2:IsNull() == false then
				goSelect2:SetParent(mapUIRootTransform[0])
			end
		end
		if goSelect3 == nil or goSelect3 ~= nil and goSelect3:IsNull() == true then
			goSelect3 = trUIRoot:Find("PotentialSelectPanel")
			if goSelect3 ~= nil and goSelect3:IsNull() == false then
				goSelect3:SetParent(mapUIRootTransform[0])
			end
		end
		if goDashboard == nil or goDashboard ~= nil and goDashboard:IsNull() == true then
			goDashboard = trUIRoot:Find("BattleDashboard")
			if goDashboard ~= nil and goDashboard:IsNull() == false then
				goDashboard:SetParent(mapUIRootTransform[0])
				trSupportRole = goDashboard:Find("--safe_area--/--support_role--")
				trMainRole = goDashboard:Find("--safe_area--/--main_role--")
				trSkillHint = goDashboard:Find("--safe_area--/--skill_hint--")
				trJoystick = goDashboard:Find("--safe_area--/--joystick--")
			end
		end
		if 0 < trUIRoot.localScale.x then
			trUIRoot.localScale = Vector3.zero
			trJoystick.localScale = Vector3.zero
		else
			trUIRoot.localScale = Vector3.one
			trJoystick.localScale = Vector3.one
		end
	end
	trUIRoot = mapUIRootTransform[AllEnum.SortingLayerName.UI_Top]
	if trUIRoot ~= nil then
		if goTransition == nil or goTransition ~= nil and goTransition:IsNull() == true then
			goTransition = trUIRoot:Find("TransitionPanel")
			if goTransition ~= nil and goTransition:IsNull() == false then
				goTransition:SetParent(mapUIRootTransform[0])
			end
		end
		if 0 < trUIRoot.localScale.x then
			trUIRoot.localScale = Vector3.zero
		else
			trUIRoot.localScale = Vector3.one
		end
	end
	trUIRoot = mapUIRootTransform[AllEnum.SortingLayerName.Overlay]
	if trUIRoot ~= nil then
		if goPlayerInfo == nil or goPlayerInfo ~= nil and goPlayerInfo:IsNull() == true then
			goPlayerInfo = trUIRoot:Find("PlayerInfoPanel/----AdaptedArea----")
		end
		if 0 < goPlayerInfo.localScale.x then
			goPlayerInfo.localScale = Vector3.zero
		else
			goPlayerInfo.localScale = Vector3.one
		end
	end
end
function PanelManager.SwitchSkillBtn()
	if mapUIRootTransform == nil then
		return
	end
	if goDashboard == nil or goDashboard ~= nil and goDashboard:IsNull() == true then
		local trUIRoot = mapUIRootTransform[AllEnum.SortingLayerName.UI]
		goDashboard = trUIRoot:Find("BattleDashboard")
		if goDashboard ~= nil and goDashboard:IsNull() == false then
			goDashboard:SetParent(mapUIRootTransform[0])
			trSupportRole = goDashboard:Find("--safe_area--/--support_role--")
			trMainRole = goDashboard:Find("--safe_area--/--main_role--")
			trSkillHint = goDashboard:Find("--safe_area--/--skill_hint--")
			trJoystick = goDashboard:Find("--safe_area--/--joystick--")
		end
	end
	if 0 < trSupportRole.localScale.x then
		trSupportRole.localScale = Vector3.zero
		trMainRole.localScale = Vector3.zero
		trSkillHint.localScale = Vector3.zero
	else
		trSupportRole.localScale = Vector3.one
		trMainRole.localScale = Vector3.one
		trSkillHint.localScale = Vector3.one
	end
end
function PanelManager.CloseAllDisposablePanel()
	if type(tbDisposablePanel) == "table" then
		local n = #tbDisposablePanel
		for i = n, 1, -1 do
			local objTempPanel = tbDisposablePanel[i]
			objTempPanel:_PreExit()
			objTempPanel:_Exit()
			objTempPanel:_Destroy()
			objTempPanel = nil
			table.remove(tbDisposablePanel, i)
		end
		if 0 < n then
			printLog("[\231\149\140\233\157\162\229\136\135\230\141\162] \229\144\140\230\151\182\229\133\179\233\151\173\230\137\128\230\156\137\233\157\158\228\184\187 Panel \231\149\140\233\157\162")
		end
	end
end
function PanelManager.CheckInTransition()
	if objTransitionPanel ~= nil then
		local nStatus = objTransitionPanel:GetTransitionStatus()
		if nStatus ~= AllEnum.TransitionStatus.OutAnimDone then
			return true
		end
	end
	return false
end
return PanelManager
