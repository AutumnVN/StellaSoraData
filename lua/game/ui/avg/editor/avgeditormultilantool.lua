local CS_SYS = CS.System
local CS_SYS_IO = CS_SYS.IO
local AvgEditorMultiLanTool = class("AvgEditorMultiLanTool", BaseCtrl)
AvgEditorMultiLanTool._mapNodeConfig = {
	btn_Refresh = {
		sComponentName = "Button",
		callback = "OnBtn_Refresh"
	},
	dd_MultiLanFrom = {
		sComponentName = "Dropdown",
		callback = "OnDD_LanFrom"
	},
	dd_MultiLanTo = {sComponentName = "Dropdown", callback = "OnDD_LanTo"},
	btn_SellectAll = {
		sComponentName = "Button",
		callback = "OnBtn_SelectAll_InCurLuaGroup"
	},
	btn_SellectNone = {
		sComponentName = "Button",
		callback = "OnBtn_SellectNone_InCurLuaGroup"
	},
	tbTog = {
		nCount = 9,
		sNodeName = "tog_",
		sComponentName = "Toggle",
		callback = "onToggle_LuaGroup"
	},
	lsv_multi_lan = {
		sComponentName = "LoopScrollView"
	},
	cgLSV = {
		sNodeName = "lsv_multi_lan",
		sComponentName = "CanvasGroup"
	},
	btn_ProcMultiLanguage = {
		sComponentName = "Button",
		callback = "OnBtnClick_ProcMultiLanguage"
	},
	procContent = {sComponentName = "Transform"}
}
AvgEditorMultiLanTool._mapEventConfig = {}
function AvgEditorMultiLanTool:Awake()
	self:SetLSV_Visible(false)
	local ListString = CS_SYS.Collections.Generic.List(CS_SYS.String)
	local listLanguage = ListString()
	for i, v in ipairs(AllEnum.LanguageInfo) do
		listLanguage:Add(v[2])
	end
	NovaAPI.ClearDropDownOptions(self._mapNode.dd_MultiLanFrom)
	NovaAPI.ClearDropDownOptions(self._mapNode.dd_MultiLanTo)
	NovaAPI.DropDownAddOptions(self._mapNode.dd_MultiLanFrom, listLanguage)
	NovaAPI.DropDownAddOptions(self._mapNode.dd_MultiLanTo, listLanguage)
	self.nFromLanIdx = 1
	self.nToLanIdx = 2
	NovaAPI.SetDropDownValue(self._mapNode.dd_MultiLanFrom, self.nFromLanIdx - 1)
	NovaAPI.SetDropDownValue(self._mapNode.dd_MultiLanTo, self.nToLanIdx - 1)
end
function AvgEditorMultiLanTool:OnBtn_Refresh()
	if self.nFromLanIdx == self.nToLanIdx then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Alert,
			sContent = "\226\128\156\228\187\142\226\128\157\228\184\142\226\128\156\232\135\179\226\128\157\231\154\132\232\175\173\232\168\128\228\184\141\232\131\189\228\184\128\230\160\183\227\128\130"
		})
		return
	end
	local sRequireRoot = GetAvgLuaRequireRoot(self.nFromLanIdx)
	local sWriteFileRoot = NovaAPI.ApplicationDataPath .. "/../Lua/"
	if NovaAPI.IsRuntimeWindowsPlayer() == true then
		sWriteFileRoot = NovaAPI.StreamingAssetsPath .. "/Lua/"
	end
	sWriteFileRoot = sWriteFileRoot .. sRequireRoot
	local sRootConfig = sWriteFileRoot .. "Config/"
	local sRootPreset = sWriteFileRoot .. "Preset/"
	local func_CollectLuaFileName = function(sRoot, sPattern)
		local files = CS_SYS_IO.Directory.GetFiles(sRoot, sPattern, CS_SYS_IO.SearchOption.TopDirectoryOnly)
		local nFileCount = files.Length - 1
		local tbFileName = {}
		for i = 0, nFileCount do
			local sFileName = string.gsub(CS_SYS_IO.Path.GetFileName(files[i]), ".lua", "")
			table.insert(tbFileName, {sName = sFileName, bSelected = false})
		end
		return tbFileName
	end
	self.tbLuaFileName = {}
	self.tbLuaFileName[1] = 0
	self.tbLuaFileName[2] = func_CollectLuaFileName(sRootConfig, "BB*.lua")
	self.tbLuaFileName[3] = func_CollectLuaFileName(sRootConfig, "BT*.lua")
	self.tbLuaFileName[4] = func_CollectLuaFileName(sRootConfig, "CG*.lua")
	self.tbLuaFileName[5] = func_CollectLuaFileName(sRootConfig, "DP*.lua")
	self.tbLuaFileName[6] = func_CollectLuaFileName(sRootConfig, "GD*.lua")
	self.tbLuaFileName[7] = func_CollectLuaFileName(sRootConfig, "PM*.lua")
	self.tbLuaFileName[8] = func_CollectLuaFileName(sRootConfig, "ST*.lua")
	self.tbLuaFileName[9] = func_CollectLuaFileName(sRootPreset, "*.lua")
	self.nCurTogIdx = 1
	NovaAPI.SetToggleIsOn(self._mapNode.tbTog[self.nCurTogIdx], true)
	self:InitLSV()
	self:SetLSV_Visible(true)
end
function AvgEditorMultiLanTool:OnDD_LanFrom()
	self:SetLSV_Visible(false)
	self.nFromLanIdx = NovaAPI.GetDropDownValue(self._mapNode.dd_MultiLanFrom) + 1
end
function AvgEditorMultiLanTool:OnDD_LanTo()
	self:SetLSV_Visible(false)
	self.nToLanIdx = NovaAPI.GetDropDownValue(self._mapNode.dd_MultiLanTo) + 1
end
function AvgEditorMultiLanTool:OnBtn_SelectAll_InCurLuaGroup()
	if self.nCurTogIdx == 1 then
		local nTogCount = #self.tbLuaFileName
		for i = 2, nTogCount do
			for ii, vv in ipairs(self.tbLuaFileName[i]) do
				vv.bSelected = true
			end
		end
	else
		for i, v in ipairs(self.tbLuaFileName[self.nCurTogIdx]) do
			v.bSelected = true
		end
	end
	self._mapNode.lsv_multi_lan:ForceRefresh()
end
function AvgEditorMultiLanTool:OnBtn_SellectNone_InCurLuaGroup()
	if self.nCurTogIdx == 1 then
		local nTogCount = #self.tbLuaFileName
		for i = 2, nTogCount do
			for ii, vv in ipairs(self.tbLuaFileName[i]) do
				vv.bSelected = false
			end
		end
	else
		for i, v in ipairs(self.tbLuaFileName[self.nCurTogIdx]) do
			v.bSelected = false
		end
	end
	self._mapNode.lsv_multi_lan:ForceRefresh()
end
function AvgEditorMultiLanTool:onToggle_LuaGroup(toggle, nIndex, bIsOn)
	if bIsOn == false then
		return
	end
	if nIndex == self.nCurTogIdx then
		return
	end
	self.nCurTogIdx = nIndex
	self:InitLSV()
end
function AvgEditorMultiLanTool:SetLSV_Visible(bVisible)
	NovaAPI.SetCanvasGroupAlpha(self._mapNode.cgLSV, bVisible == true and 1 or 0)
	NovaAPI.SetCanvasGroupInteractable(self._mapNode.cgLSV, bVisible == true)
	NovaAPI.SetCanvasGroupBlocksRaycasts(self._mapNode.cgLSV, bVisible == true)
	NovaAPI.SetButtonInteractable(self._mapNode.btn_ProcMultiLanguage, bVisible == true)
end
function AvgEditorMultiLanTool:InitLSV()
	local nCount = 0
	if self.nCurTogIdx == 1 then
		local nTogCount = #self.tbLuaFileName
		for i = 2, nTogCount do
			nCount = nCount + #self.tbLuaFileName[i]
		end
	else
		nCount = #self.tbLuaFileName[self.nCurTogIdx]
	end
	if 0 < nCount then
		self._mapNode.lsv_multi_lan:Init(nCount, self, self.OnRefreshGrid, self.OnGridBtnClick)
		self._mapNode.lsv_multi_lan:ForceRefresh()
	else
		delChildren(self._mapNode.procContent)
	end
end
function AvgEditorMultiLanTool:OnRefreshGrid(go)
	local nIndex = tonumber(go.name) + 1
	local tbGridData = self:GetGridData(nIndex)
	if tbGridData == nil then
		return
	end
	NovaAPI.SetImageColor(go:GetComponent("Image"), tbGridData.bSelected == true and Color.green or Color.white)
	NovaAPI.SetText(go.transform:GetChild(0):GetComponent("Text"), tbGridData.sName)
end
function AvgEditorMultiLanTool:OnGridBtnClick(go)
	local nIndex = tonumber(go.name) + 1
	local tbGridData = self:GetGridData(nIndex)
	if tbGridData == nil then
		return
	end
	tbGridData.bSelected = not tbGridData.bSelected
	NovaAPI.SetImageColor(go:GetComponent("Image"), tbGridData.bSelected == true and Color.green or Color.white)
end
function AvgEditorMultiLanTool:GetGridData(nIndex)
	if self.nCurTogIdx == 1 then
		local nTogCount = #self.tbLuaFileName
		local n = 0
		for i = 2, nTogCount do
			for ii, vv in ipairs(self.tbLuaFileName[i]) do
				n = n + 1
				if n == nIndex then
					return self.tbLuaFileName[i][ii]
				end
			end
		end
	else
		local tb = self.tbLuaFileName[self.nCurTogIdx]
		return tb[nIndex]
	end
	return nil
end
function AvgEditorMultiLanTool:OnBtnClick_ProcMultiLanguage()
	local tbSelected = {}
	local nTogCount = #self.tbLuaFileName
	for i = 2, nTogCount do
		for ii, vv in ipairs(self.tbLuaFileName[i]) do
			if vv.bSelected == true then
				table.insert(tbSelected, vv.sName)
			end
		end
	end
	if #tbSelected <= 0 then
		EventManager.Hit(EventId.OpenMessageBox, {
			nType = AllEnum.MessageBox.Alert,
			sContent = "\230\156\170\233\128\137\228\184\173\228\187\187\228\189\149\233\156\128\229\164\132\231\144\134\231\154\132\230\150\135\228\187\182\227\128\130"
		})
		return
	end
	local nLanguageIndex_From = self.nFromLanIdx
	local nLanguageIndex_To = self.nToLanIdx
	local sRequireRoot = GetAvgLuaRequireRoot(nLanguageIndex_From)
	local sWriteFileRoot = NovaAPI.ApplicationDataPath .. "/../Lua/"
	if NovaAPI.IsRuntimeWindowsPlayer() == true then
		sWriteFileRoot = NovaAPI.StreamingAssetsPath .. "/Lua/"
	end
	local sWriteTo = sWriteFileRoot .. GetAvgLuaRequireRoot(nLanguageIndex_To)
	local _tbAvgChar = require(sRequireRoot .. "Preset/AvgCharacter")
	self.mapAvgCharacter_MultiLanProc = {}
	for i, v in ipairs(_tbAvgChar) do
		self.mapAvgCharacter_MultiLanProc[v.id] = v.name
	end
	_tbAvgChar = nil
	package.loaded[sRequireRoot .. "Preset/AvgCharacter"] = nil
	local sProcLog = ""
	for i, sLuaFileName in ipairs(tbSelected) do
		local sLuaFolder = "Config/"
		if sLuaFileName == "AvgCharacter" or sLuaFileName == "AvgContacts" or sLuaFileName == "AvgUIText" then
			sLuaFolder = "Preset/"
		end
		local sRequireFrom = sRequireRoot .. sLuaFolder .. sLuaFileName
		local tbLuaData = require(sRequireFrom)
		sProcLog = sProcLog .. self:_ProcSingleLuaFile(sLuaFolder, sLuaFileName, tbLuaData, sWriteTo)
		tbLuaData = nil
		package.loaded[sRequireFrom] = nil
	end
	self.mapAvgCharacter_MultiLanProc = nil
	package.loaded[sRequireRoot .. "Preset/AvgUIText"] = nil
	local sProcLogPath = sWriteTo .. "/proc_log.txt"
	local fs
	if CS_SYS_IO.File.Exists(sProcLogPath) == false then
		fs = CS_SYS_IO.FileStream(sProcLogPath, CS_SYS_IO.FileMode.CreateNew)
	else
		fs = CS_SYS_IO.FileStream(sProcLogPath, CS_SYS_IO.FileMode.Append)
	end
	local sw = CS_SYS_IO.StreamWriter(fs, CS_SYS.Text.UTF8Encoding(false))
	local timeString = os.date("%Y-%m-%d %H:%M:%S")
	local sFromLan = AllEnum.LanguageInfo[nLanguageIndex_From][2]
	local sToLan = AllEnum.LanguageInfo[nLanguageIndex_To][2]
	local sLogTitle = string.format("----------\227\128\144\230\156\172\229\156\176\229\140\150\229\164\132\231\144\134\230\151\165\229\191\151\227\128\145From:%s To:%s date:%s----------\n", sFromLan, sToLan, timeString)
	sw:Write(sLogTitle .. sProcLog)
	sw:Close()
	fs:Close()
	EventManager.Hit(EventId.OpenMessageBox, {
		nType = AllEnum.MessageBox.Alert,
		sContent = "\229\164\154\232\175\173\232\168\128\229\164\132\231\144\134\229\183\178\229\174\140\230\136\144\239\188\140\232\175\166\232\167\129\229\164\132\231\144\134\230\151\165\229\191\151\227\128\130\n" .. sProcLogPath
	})
end
function AvgEditorMultiLanTool:_ProcSingleLuaFile(sLuaFolder, sLuaFileName, tbLuaData, sWriteTo)
	local sExcelPath_1 = sWriteTo .. "Excel_1_ToBeTranslate/" .. sLuaFileName .. ".xlsx"
	local sExcelPath_2 = sWriteTo .. "Excel_2_Translating/" .. sLuaFileName .. ".xlsx"
	local sExcelPath_3 = sWriteTo .. "Excel_3_Translated/" .. sLuaFileName .. ".xlsx"
	local func_Export = self["_Export_" .. sLuaFileName]
	if func_Export == nil then
		func_Export = self._Export_Text
	end
	local tbExportData = func_Export(self, tbLuaData)
	NovaAPI.WriteDataToExcel(tbExportData, sExcelPath_1)
	if CS_SYS_IO.File.Exists(sExcelPath_2) == true then
		CS_SYS_IO.File.Delete(sExcelPath_1)
		return sLuaFileName .. " \230\173\163\229\156\168\231\191\187\232\175\145\228\184\173\233\156\128\231\168\141\229\144\142\229\164\132\231\144\134\227\128\130\n"
	end
	if CS_SYS_IO.File.Exists(sExcelPath_3) ~= true then
		return sLuaFileName .. " \233\156\128\232\166\129\231\191\187\232\175\145\227\128\130\n"
	end
	local tbTranslatedData = NovaAPI.ReadDataFromExcel(sExcelPath_3)
	local func_Compare = self["_Compare_" .. sLuaFileName]
	if func_Compare == nil then
		func_Compare = self._Compare_Text
	end
	local bSame, tbOverwriteTranslatedData = func_Compare(self, tbTranslatedData, tbExportData)
	if bSame == false then
		return sLuaFileName .. " \230\150\135\230\156\172\230\156\137\229\143\152\229\138\168\239\188\140\233\156\128\232\166\129\230\155\180\230\150\176\229\183\178\231\191\187\232\175\145\229\174\140\231\154\132 excel \230\149\176\230\141\174\227\128\130\n"
	else
		if tbOverwriteTranslatedData ~= nil then
			NovaAPI.WriteDataToExcel(tbOverwriteTranslatedData, sExcelPath_3)
		end
		CS_SYS_IO.File.Delete(sExcelPath_1)
		local func_Import = self["_Import_" .. sLuaFileName]
		if func_Import == nil then
			func_Import = self._Import_Text
		end
		tbLuaData = func_Import(self, tbTranslatedData, tbLuaData)
		local sWriteLuaPath = sWriteTo .. sLuaFolder .. sLuaFileName .. ".lua"
		if sLuaFolder == "Preset/" then
			local tbLineData = {}
			table.insert(tbLineData, "return {")
			local sToString
			if sLuaFileName == "AvgUIText" then
				local tbMainKeys = {}
				local tbSexKeys = {}
				for k, v in pairs(tbLuaData) do
					table.insert(tbMainKeys, k)
					if k == "SEX" then
						for kk, vv in pairs(v) do
							table.insert(tbSexKeys, kk)
						end
					end
				end
				table.sort(tbMainKeys)
				table.sort(tbSexKeys)
				for i, keyM in ipairs(tbMainKeys) do
					if keyM == "SEX" then
						table.insert(tbLineData, "    SEX={")
						for ii, keyS in ipairs(tbSexKeys) do
							sToString = "        [\"" .. tostring(keyS) .. "\"]={\"" .. Avg_ProcEnquotes(tbLuaData.SEX[keyS][1]) .. "\",\"" .. Avg_ProcEnquotes(tbLuaData.SEX[keyS][2]) .. "\"},"
							table.insert(tbLineData, sToString)
						end
						table.insert(tbLineData, "    },")
					else
						sToString = "    " .. tostring(keyM) .. "=\"" .. Avg_ProcEnquotes(tbLuaData[keyM]) .. "\","
						table.insert(tbLineData, sToString)
					end
				end
			else
				for i, tbData in ipairs(tbLuaData) do
					if sLuaFileName == "AvgCharacter" then
						sToString = "    {id=\"" .. tbData.id .. "\",name=\"" .. Avg_ProcEnquotes(tbData.name) .. "\",name_bg_color=\"" .. tbData.name_bg_color .. "\""
						if type(tbData.surfix) == "string" then
							sToString = sToString .. ",surfix=\"" .. tbData.surfix .. "\""
						end
						if type(tbData.reuse) == "string" then
							sToString = sToString .. ",reuse=\"" .. tbData.reuse .. "\""
						end
						if type(tbData.reuseL2DPose) == "string" then
							sToString = sToString .. ",reuseL2DPose=\"" .. tbData.reuseL2DPose .. "\""
						end
						sToString = sToString .. "},"
					elseif sLuaFileName == "AvgContacts" then
						sToString = "    {id=" .. tbData.id .. ",icon=\"" .. tbData.icon .. "\",name=\"" .. Avg_ProcEnquotes(tbData.name) .. "\",landmark=\"" .. Avg_ProcEnquotes(tbData.landmark) .. "\",signature=\"" .. Avg_ProcEnquotes(tbData.signature) .. "\"},"
					end
					table.insert(tbLineData, sToString)
				end
			end
			table.insert(tbLineData, "}")
			EventManager.Hit("AvgMultiLanTool_DO_SAVE_LUA_FILE", sWriteLuaPath, tbLineData)
		else
			EventManager.Hit("AvgMultiLanTool_SAVE_AVG_CONFIG", tbLuaData, sWriteLuaPath)
		end
		return sLuaFileName .. " \229\183\178\229\174\140\230\136\144\230\156\172\229\156\176\229\140\150\239\188\140\229\186\148\228\184\142 excel \228\184\128\232\181\183\230\143\144\228\186\164\232\135\179P4\227\128\130\n"
	end
end
function AvgEditorMultiLanTool:_GetAvgCharName(sAvgCharId)
	local sName = self.mapAvgCharacter_MultiLanProc[sAvgCharId]
	return sName ~= nil, sName or ""
end
function AvgEditorMultiLanTool:_ProcText(_s, bIsExport)
	if bIsExport == true then
		if TRANSLATE_SIGNAL == true then
			_s = ProcAvgTextContent(_s, self.nFromLanIdx)
			if string.find(_s, "==B==") ~= nil then
				_s = string.gsub(_s, "==B==", "")
			end
			if string.find(_s, "==W==") ~= nil then
				_s = string.gsub(_s, "==W==", "")
			end
			if string.find(_s, "==P==") ~= nil then
				_s = string.gsub(_s, "==P==", "")
			end
			if string.find(_s, "==A") ~= nil then
				_s = string.gsub(_s, "==A.-==", "")
			end
			if string.find(_s, "<") ~= nil then
				_s = string.gsub(_s, "<.->", "")
			end
		end
		if DEL_RT_SIGNAL == true and string.find(_s, "==RT==") ~= nil then
			_s = string.gsub(_s, "==RT==", "\n")
		end
	else
		if string.find(_s, "\r\n") ~= nil then
			_s = string.gsub(_s, "\r\n", "==RT==")
		end
		if string.find(_s, "\r") ~= nil then
			_s = string.gsub(_s, "\r", "==RT==")
		end
		if string.find(_s, "\n") ~= nil then
			_s = string.gsub(_s, "\n", "==RT==")
		end
	end
	return _s
end
function AvgEditorMultiLanTool:_Export_Text(tbLuaData)
	local tbExportData = {
		{
			"\232\175\180\232\175\157\232\128\133",
			"\232\183\175\228\186\186\232\175\145\229\144\141",
			"\229\142\159\230\150\135-\228\184\173\233\133\141-\229\165\179",
			"\232\175\145\230\150\135-\228\184\173\233\133\141-\229\165\179",
			"\229\142\159\230\150\135-\228\184\173\233\133\141-\231\148\183",
			"\232\175\145\230\150\135-\228\184\173\233\133\141-\231\148\183",
			"\229\142\159\230\150\135-\230\151\165\233\133\141-\229\165\179",
			"\232\175\145\230\150\135-\230\151\165\233\133\141-\229\165\179",
			"\229\142\159\230\150\135-\230\151\165\233\133\141-\231\148\183",
			"\232\175\145\230\150\135-\230\151\165\233\133\141-\231\148\183"
		}
	}
	for i, v in ipairs(tbLuaData) do
		local sCmdName = v.cmd
		if sCmdName == "SetTalk" then
			local nType = v.param[1]
			local sAvgCharId = v.param[2]
			local sTalker = "error"
			if sAvgCharId == "0" then
				sTalker = "\230\151\129\231\153\189 \232\175\180"
			elseif sAvgCharId == "1" then
				sTalker = "\228\184\187\232\167\146 \232\175\180"
			else
				local bExist, sCharName = self:_GetAvgCharName(sAvgCharId)
				if bExist == true then
					sTalker = sAvgCharId .. sCharName .. " \232\175\180"
				else
					sTalker = "\226\128\187\230\151\160ID\232\167\146\232\137\178 \232\175\180\226\128\187" .. sAvgCharId
				end
			end
			if nType == 1 then
				sTalker = sAvgCharId == "avg4_999" and sTalker .. " \232\175\180" or "\228\184\187\232\167\146 \232\175\180"
			elseif nType == 2 then
				sTalker = sAvgCharId == "avg4_999" and sTalker .. " \230\131\179" or "\228\184\187\232\167\146 \230\131\179"
			elseif nType == 3 then
				sTalker = "\229\186\149\233\131\168\229\173\151\229\185\149 " .. sTalker
			elseif nType == 8 then
				sTalker = "\229\177\133\228\184\173\229\173\151\229\185\149"
			elseif nType == 10 then
				sTalker = "\229\133\168\229\177\143\229\173\151\229\185\149"
			end
			local sCn_F = self:_ProcText(v.param[3] or "", true)
			local sCn_M = self:_ProcText(v.param[7] or "", true)
			local sJp_F = self:_ProcText(v.param[8] or "", true)
			local sJp_M = self:_ProcText(v.param[9] or "", true)
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. sTalker,
				"",
				sCn_F,
				"",
				sCn_M,
				"",
				sJp_F,
				"",
				sCn_M,
				""
			})
		elseif sCmdName == "SetPhoneMsg" then
			local nType = v.param[1]
			local sAvgCharId = v.param[2]
			local sTalker = "error"
			if sAvgCharId == "0" then
				sTalker = "\230\151\129\231\153\189"
			elseif sAvgCharId == "1" then
				sTalker = "\228\184\187\232\167\146"
			else
				local bExist, sCharName = self:_GetAvgCharName(sAvgCharId)
				sTalker = sAvgCharId .. sCharName
			end
			if nType == 0 then
				sTalker = "\230\137\139\230\156\186\230\148\182\229\136\176\230\182\136\230\129\175 " .. sTalker
			elseif nType == 1 or nType == 2 then
				sTalker = "\228\184\187\232\167\146\229\155\158\229\164\141\230\137\139\230\156\186\230\182\136\230\129\175"
			elseif nType == 5 then
				sTalker = "\230\137\139\230\156\186\231\179\187\231\187\159\230\182\136\230\129\175"
			else
				sTalker = ""
			end
			if sTalker ~= "" then
				local sCn_F = self:_ProcText(v.param[3] or "", true)
				local sCn_M = self:_ProcText(v.param[7] or "", true)
				local sJp_F = self:_ProcText(v.param[8] or "", true)
				local sJp_M = self:_ProcText(v.param[9] or "", true)
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. sTalker,
					"",
					sCn_F,
					"",
					sCn_M,
					"",
					sJp_F,
					"",
					sCn_M,
					""
				})
			end
		elseif sCmdName == "SetPhoneThinking" then
			if self.nFromLanIdx == 1 then
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\137\139\230\156\186\233\128\137\233\161\185\230\128\157\232\128\131\231\139\172\231\153\189(\228\184\187\232\167\146)",
					"",
					self:_ProcText(v.param[4] or "", true),
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
			else
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\137\139\230\156\186\233\128\137\233\161\185\230\128\157\232\128\131\231\139\172\231\153\189(\228\184\187\232\167\146)",
					"",
					"",
					"",
					"",
					"",
					self:_ProcText(v.param[4] or "", true),
					"",
					"",
					""
				})
			end
		elseif sCmdName == "SetPhoneMsgChoiceBegin" then
			sGroupId = v.param[1]
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("----[\230\137\139\230\156\186\233\128\137\233\161\185] \229\188\128\229\167\139 \231\187\132:%s----", sGroupId),
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
			for j = 2, 4 do
				local sContent = v.param[j]
				if type(sContent) == "string" and sContent ~= "" then
					if self.nFromLanIdx == 1 then
						table.insert(tbExportData, {
							"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("[\230\137\139\230\156\186\233\128\137\233\161\185] \231\187\132:%s \233\128\137\233\161\185:%d", sGroupId, j - 1),
							"",
							self:_ProcText(sContent, true),
							"",
							"",
							"",
							"",
							"",
							"",
							""
						})
					else
						table.insert(tbExportData, {
							"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("[\230\137\139\230\156\186\233\128\137\233\161\185] \231\187\132:%s \233\128\137\233\161\185:%d", sGroupId, j - 1),
							"",
							"",
							"",
							"",
							"",
							self:_ProcText(sContent, true),
							"",
							"",
							""
						})
					end
				end
			end
		elseif sCmdName == "SetPhoneMsgChoiceJumpTo" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("----[\230\137\139\230\156\186\233\128\137\233\161\185] \228\187\165\228\184\139\228\184\186\231\187\132:%s \233\128\137\233\161\185:%d \229\175\185\229\186\148\231\154\132\230\188\148\229\135\186----", v.param[1], v.param[2]),
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "SetPhoneMsgChoiceEnd" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("----[\230\137\139\230\156\186\233\128\137\233\161\185] \231\187\147\230\157\159 \231\187\132:%s----", v.param[1]),
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "SetSceneHeading" then
			sContent = string.format("%s|%s|%s|%s|%s", v.param[1], v.param[2], v.param[3], v.param[4], v.param[5])
			if self.nFromLanIdx == 1 then
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\151\182\233\151\180\229\156\176\231\130\185\230\160\188\229\188\143: \230\151\182\233\151\180|\230\156\136|\230\151\165|\228\184\187\232\166\129\229\156\176\231\130\185|\230\172\161\232\166\129\229\156\176\231\130\185",
					"",
					sContent,
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
			else
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\151\182\233\151\180\229\156\176\231\130\185\230\160\188\229\188\143: \230\151\182\233\151\180|\230\156\136|\230\151\165|\228\184\187\232\166\129\229\156\176\231\130\185|\230\172\161\232\166\129\229\156\176\231\130\185",
					"",
					"",
					"",
					"",
					"",
					sContent,
					"",
					"",
					""
				})
			end
		elseif sCmdName == "SetIntro" then
			sContent = string.format("%s|%s|%s", v.param[2], v.param[3], self:_ProcText(v.param[4], true))
			if self.nFromLanIdx == 1 then
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\229\137\167\230\131\133\230\162\151\230\166\130\230\160\188\229\188\143: \230\160\135\233\162\152|\229\144\141\231\167\176|\230\162\151\230\166\130\229\134\133\229\174\185",
					"",
					sContent,
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
			else
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\229\137\167\230\131\133\230\162\151\230\166\130\230\160\188\229\188\143: \230\160\135\233\162\152|\229\144\141\231\167\176|\230\162\151\230\166\130\229\134\133\229\174\185",
					"",
					"",
					"",
					"",
					"",
					sContent,
					"",
					"",
					""
				})
			end
		elseif sCmdName == "SetChoiceBegin" then
			sGroupId = v.param[1]
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("----[\229\184\184\232\167\132\233\128\137\233\161\185] \229\188\128\229\167\139 \231\187\132:%s----", sGroupId),
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
			local tbContent = v.param[4]
			for j, sContent in ipairs(tbContent) do
				if type(sContent) == "string" and sContent ~= "" then
					if self.nFromLanIdx == 1 then
						table.insert(tbExportData, {
							"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("[\229\184\184\232\167\132\233\128\137\233\161\185] \231\187\132:%s \233\128\137\233\161\185:%d", sGroupId, j),
							"",
							self:_ProcText(sContent, true),
							"",
							"",
							"",
							"",
							"",
							"",
							""
						})
					else
						table.insert(tbExportData, {
							"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("[\229\184\184\232\167\132\233\128\137\233\161\185] \231\187\132:%s \233\128\137\233\161\185:%d", sGroupId, j),
							"",
							"",
							"",
							"",
							"",
							self:_ProcText(sContent, true),
							"",
							"",
							""
						})
					end
				end
			end
			local sContent = v.param[10]
			if v.param[6] == 1 and type(sContent) == "string" and sContent ~= "" then
				if self.nFromLanIdx == 1 then
					table.insert(tbExportData, {
						"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "[\229\184\184\232\167\132\233\128\137\233\161\185] \228\184\187\232\167\146\230\178\137\230\128\157 \231\187\132:%s" .. sGroupId,
						"",
						self:_ProcText(sContent, true),
						"",
						"",
						"",
						"",
						"",
						"",
						""
					})
				else
					table.insert(tbExportData, {
						"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "[\229\184\184\232\167\132\233\128\137\233\161\185] \228\184\187\232\167\146\230\178\137\230\128\157 \231\187\132:%s" .. sGroupId,
						"",
						"",
						"",
						"",
						"",
						self:_ProcText(sContent, true),
						"",
						"",
						""
					})
				end
			end
		elseif sCmdName == "SetChoiceJumpTo" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("----[\229\184\184\232\167\132\233\128\137\233\161\185] \228\187\165\228\184\139\228\184\186\231\187\132:%s \233\128\137\233\161\185:%d \229\175\185\229\186\148\231\154\132\230\188\148\229\135\186----", v.param[1], v.param[2]),
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "SetChoiceRollback" then
			local sContent = string.format("\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "----[\229\184\184\232\167\132\233\128\137\233\161\185] \232\191\148\229\155\158\232\135\179\233\128\137\233\161\185\229\188\128\229\167\139 \231\187\132:%s----", v.param[1])
			if v.param[2] == 1 then
				sContent = sContent .. "\n(\232\139\165\233\128\137\233\161\185\233\131\189\233\128\137\232\191\135\228\186\134\239\188\140\229\136\153\232\183\179\232\135\179\233\128\137\233\161\185\231\187\147\230\157\159\229\164\132)"
			end
			table.insert(tbExportData, {
				sContent,
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "SetChoiceRollover" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("----[\229\184\184\232\167\132\233\128\137\233\161\185] \232\183\179\232\135\179\233\128\137\233\161\185\231\187\147\230\157\159 \231\187\132:%s ----", v.param[1]),
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "SetChoiceEnd" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("----[\229\184\184\232\167\132\233\128\137\233\161\185] \231\187\147\230\157\159 \231\187\132:%s----", v.param[1]),
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "SetMajorChoice" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "----[\232\183\175\231\186\191\233\128\137\233\161\185] \229\188\128\229\167\139----",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
			if self.nFromLanIdx == 1 then
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\1851-\230\160\135\233\162\152",
					"",
					self:_ProcText(v.param[4], true),
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\1851-\230\143\143\232\191\176",
					"",
					self:_ProcText(v.param[5], true),
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\1852-\230\160\135\233\162\152",
					"",
					self:_ProcText(v.param[11], true),
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\1852-\230\143\143\232\191\176",
					"",
					self:_ProcText(v.param[12], true),
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\1853-\230\160\135\233\162\152",
					"",
					self:_ProcText(v.param[18], true),
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\1853-\230\143\143\232\191\176",
					"",
					self:_ProcText(v.param[19], true),
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\185-\228\184\187\232\167\146\230\178\137\230\128\157",
					"",
					self:_ProcText(v.param[26], true),
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
			else
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\1851-\230\160\135\233\162\152",
					"",
					"",
					"",
					"",
					"",
					self:_ProcText(v.param[4], true),
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\1851-\230\143\143\232\191\176",
					"",
					"",
					"",
					"",
					"",
					self:_ProcText(v.param[5], true),
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\1852-\230\160\135\233\162\152",
					"",
					"",
					"",
					"",
					"",
					self:_ProcText(v.param[11], true),
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\1852-\230\143\143\232\191\176",
					"",
					"",
					"",
					"",
					"",
					self:_ProcText(v.param[12], true),
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\1853-\230\160\135\233\162\152",
					"",
					"",
					"",
					"",
					"",
					self:_ProcText(v.param[18], true),
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\1853-\230\143\143\232\191\176",
					"",
					"",
					"",
					"",
					"",
					self:_ProcText(v.param[19], true),
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\232\183\175\231\186\191\233\128\137\233\161\185-\228\184\187\232\167\146\230\178\137\230\128\157",
					"",
					"",
					"",
					"",
					"",
					self:_ProcText(v.param[26], true),
					"",
					"",
					""
				})
			end
		elseif sCmdName == "SetMajorChoiceJumpTo" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("----[\232\183\175\231\186\191\233\128\137\233\161\185] \228\187\165\228\184\139\228\184\186\233\128\137\233\161\185:%d \229\175\185\229\186\148\231\154\132\230\188\148\229\135\186----", v.param[2]),
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "SetMajorChoiceRollover" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "----[\232\183\175\231\186\191\233\128\137\233\161\185] \232\183\179\232\135\179\233\128\137\233\161\185\231\187\147\230\157\159----",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "SetMajorChoiceEnd" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "----[\232\183\175\231\186\191\233\128\137\233\161\185] \231\187\147\230\157\159----",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "SetPersonalityChoice" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "----[\230\128\167\230\160\188\233\128\137\233\161\185] \229\188\128\229\167\139----",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
			if self.nFromLanIdx == 1 then
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\128\167\230\160\188\233\128\137\233\161\1851",
					"",
					self:_ProcText(v.param[3], true),
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\128\167\230\160\188\233\128\137\233\161\1852",
					"",
					self:_ProcText(v.param[4], true),
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\128\167\230\160\188\233\128\137\233\161\1853",
					"",
					self:_ProcText(v.param[5], true),
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\128\167\230\160\188\233\128\137\233\161\185-\228\184\187\232\167\146\230\178\137\230\128\157",
					"",
					self:_ProcText(v.param[9], true),
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
			else
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\128\167\230\160\188\233\128\137\233\161\1851",
					"",
					"",
					"",
					"",
					"",
					self:_ProcText(v.param[3], true),
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\128\167\230\160\188\233\128\137\233\161\1852",
					"",
					"",
					"",
					"",
					"",
					self:_ProcText(v.param[4], true),
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\128\167\230\160\188\233\128\137\233\161\1853",
					"",
					"",
					"",
					"",
					"",
					self:_ProcText(v.param[5], true),
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\128\167\230\160\188\233\128\137\233\161\185-\228\184\187\232\167\146\230\178\137\230\128\157",
					"",
					"",
					"",
					"",
					"",
					self:_ProcText(v.param[9], true),
					"",
					"",
					""
				})
			end
		elseif sCmdName == "SetPersonalityChoiceJumpTo" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("----[\230\128\167\230\160\188\233\128\137\233\161\185] \228\187\165\228\184\139\228\184\186\233\128\137\233\161\185:%d \229\175\185\229\186\148\231\154\132\230\188\148\229\135\186----", v.param[2]),
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "SetPersonalityChoiceRollover" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "----[\230\128\167\230\160\188\233\128\137\233\161\185] \232\183\179\232\135\179\233\128\137\233\161\185\231\187\147\230\157\159----",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "SetPersonalityChoiceEnd" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "----[\230\128\167\230\160\188\233\128\137\233\161\185] \231\187\147\230\157\159----",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "SetBubble" then
			local sAvgCharId = v.param[1]
			local bExist, sCharName = self:_GetAvgCharName(sAvgCharId)
			local sTalker = "\230\176\148\230\179\161\229\175\185\232\175\157" .. sAvgCharId .. sCharName
			local spName = v.param[7]
			if type(spName) == "string" and spName ~= "" then
				sTalker = "\226\128\187\230\151\160ID\232\167\146\232\137\178 \230\176\148\230\179\161\229\175\185\232\175\157\226\128\187" .. spName
			end
			local sCn_F = self:_ProcText(v.param[3] or "", true)
			local sCn_M = self:_ProcText(v.param[6] or "", true)
			local sJp_F = self:_ProcText(v.param[9] or "", true)
			local sJp_M = self:_ProcText(v.param[10] or "", true)
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. sTalker,
				"",
				sCn_F,
				"",
				sCn_M,
				"",
				sJp_F,
				"",
				sCn_M,
				""
			})
		elseif sCmdName == "SetGroupId" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. string.format("----[\229\136\134\231\187\132] \228\187\165\228\184\139\228\184\186\231\187\132:%s \229\175\185\229\186\148\231\154\132\230\188\148\229\135\186----", v.param[1]),
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				"",
				""
			})
		elseif sCmdName == "NewCharIntro" then
			if self.nFromLanIdx == 1 then
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\150\176\232\167\146\231\153\187\229\156\186-\229\144\141\229\173\151",
					"",
					v.param[2],
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\150\176\232\167\146\231\153\187\229\156\186-\228\187\139\231\187\141",
					"",
					v.param[3],
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
			else
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\150\176\232\167\146\231\153\187\229\156\186-\229\144\141\229\173\151",
					"",
					"",
					"",
					"",
					"",
					v.param[2],
					"",
					"",
					""
				})
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\150\176\232\167\146\231\153\187\229\156\186-\228\187\139\231\187\141",
					"",
					"",
					"",
					"",
					"",
					v.param[3],
					"",
					"",
					""
				})
			end
		elseif sCmdName == "SetWordTrans" then
			local sContent = self:_ProcText(v.param[1] or "", true)
			if self.nFromLanIdx == 1 then
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\150\135\229\173\151\232\189\172\229\156\186",
					"",
					sContent,
					"",
					"",
					"",
					"",
					"",
					"",
					""
				})
			else
				table.insert(tbExportData, {
					"\227\128\144id:" .. tostring(i) .. "\227\128\145" .. "\230\150\135\229\173\151\232\189\172\229\156\186",
					"",
					"",
					"",
					"",
					"",
					sContent,
					"",
					"",
					""
				})
			end
		end
	end
	return tbExportData
end
function AvgEditorMultiLanTool:_Compare_Text(tbTranslatedData, tbExportData)
	if tbTranslatedData == nil then
		return false
	end
	local nRowCountT = tbTranslatedData.Length
	if nRowCountT ~= #tbExportData then
		return false
	end
	nRowCountT = nRowCountT - 1
	local tbOverwrite = {}
	for i = 0, nRowCountT do
		local tbRowTranslated = tbTranslatedData[i]
		local tbRowExport = tbExportData[i + 1]
		table.insert(tbOverwrite, {
			tbRowTranslated[0],
			tbRowTranslated[1],
			tbRowTranslated[2],
			tbRowTranslated[3],
			tbRowTranslated[4],
			tbRowTranslated[5],
			tbRowTranslated[6],
			tbRowTranslated[7],
			tbRowTranslated[8],
			tbRowTranslated[9]
		})
		for j = 1, 9, 2 do
			local sTranslated = tbRowTranslated[j - 1]
			local sExport = tbRowExport[j]
			if j == 1 then
				if sTranslated ~= sExport then
					local tbTranslated = string.split(sTranslated, "\227\128\145")
					local tbExport = string.split(sExport, "\227\128\145")
					if #tbTranslated == 2 and #tbExport == 2 and tbTranslated[2] ~= tbExport[2] then
						return false
					end
					tbOverwrite[i + 1][j] = sExport
				end
			elseif sTranslated ~= sExport then
				return false
			end
		end
	end
	return true, tbOverwrite
end
function AvgEditorMultiLanTool:_Import_Text(tbTranslatedData, tbLuaData)
	local nTranslatedDataIndex = 0
	local func_GetTranslatedData = function()
		nTranslatedDataIndex = nTranslatedDataIndex + 1
		return tbTranslatedData[nTranslatedDataIndex]
	end
	local func_GetColumn_H_D = function(rowData)
		local sText = rowData[7]
		if sText == nil or sText == "" then
			sText = rowData[3]
		end
		return sText
	end
	for i, v in ipairs(tbLuaData) do
		local sCmdName = v.cmd
		if sCmdName == "SetTalk" then
			local rowData = func_GetTranslatedData()
			local sAvgCharId = v.param[2]
			local bExist, sCharName = self:_GetAvgCharName(sAvgCharId)
			if bExist == false then
				v.param[2] = rowData[1]
			end
			v.param[3] = self:_ProcText(rowData[3], false)
			v.param[7] = self:_ProcText(rowData[5], false)
			v.param[8] = self:_ProcText(rowData[7], false)
			v.param[9] = self:_ProcText(rowData[9], false)
		elseif sCmdName == "SetPhoneMsg" then
			local nType = v.param[1]
			if nType == 0 or nType == 1 or nType == 2 or nType == 5 then
				local rowData = func_GetTranslatedData()
				v.param[3] = self:_ProcText(rowData[3], false)
				v.param[7] = self:_ProcText(rowData[5], false)
				v.param[8] = self:_ProcText(rowData[7], false)
				v.param[9] = self:_ProcText(rowData[9], false)
			end
		elseif sCmdName == "SetPhoneThinking" then
			local rowData = func_GetTranslatedData()
			v.param[4] = self:_ProcText(func_GetColumn_H_D(rowData), false)
		elseif sCmdName == "SetPhoneMsgChoiceBegin" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
			for j = 2, 4 do
				local sContent = v.param[j]
				if type(sContent) == "string" and sContent ~= "" then
					local rowData = func_GetTranslatedData()
					v.param[j] = self:_ProcText(func_GetColumn_H_D(rowData), false)
				end
			end
		elseif sCmdName == "SetPhoneMsgChoiceJumpTo" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "SetPhoneMsgChoiceEnd" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "SetSceneHeading" then
			local rowData = func_GetTranslatedData()
			local sContent = self:_ProcText(func_GetColumn_H_D(rowData), false)
			local tbContent = string.split(sContent, "|")
			for ii, vv in ipairs(tbContent) do
				v.param[ii] = vv
			end
		elseif sCmdName == "SetIntro" then
			local rowData = func_GetTranslatedData()
			local sContent = self:_ProcText(func_GetColumn_H_D(rowData), false)
			local tbContent = string.split(sContent, "|")
			for ii, vv in ipairs(tbContent) do
				v.param[ii + 1] = vv
			end
		elseif sCmdName == "SetChoiceBegin" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
			local tbContent = v.param[4]
			if v.param[13] == nil then
				v.param[13] = {
					"",
					"",
					"",
					""
				}
			end
			if v.param[14] == nil then
				v.param[14] = {
					"",
					"",
					"",
					""
				}
			end
			for j, sContent in ipairs(tbContent) do
				if type(sContent) == "string" and sContent ~= "" then
					local rowData = func_GetTranslatedData()
					v.param[4][j] = self:_ProcText(rowData[3], false)
					v.param[11][j] = self:_ProcText(rowData[5], false)
					v.param[13][j] = self:_ProcText(rowData[7], false)
					v.param[14][j] = self:_ProcText(rowData[9], false)
				end
			end
			local sContent = v.param[10]
			if v.param[6] == 1 and type(sContent) == "string" and sContent ~= "" then
				local rowData = func_GetTranslatedData()
				v.param[10] = self:_ProcText(func_GetColumn_H_D(rowData), false)
			end
		elseif sCmdName == "SetChoiceJumpTo" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "SetChoiceRollback" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "SetChoiceRollover" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "SetChoiceEnd" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "SetMajorChoice" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
			local rowData = func_GetTranslatedData()
			v.param[4] = self:_ProcText(func_GetColumn_H_D(rowData), false)
			local rowData = func_GetTranslatedData()
			v.param[5] = self:_ProcText(func_GetColumn_H_D(rowData), false)
			local rowData = func_GetTranslatedData()
			v.param[11] = self:_ProcText(func_GetColumn_H_D(rowData), false)
			local rowData = func_GetTranslatedData()
			v.param[12] = self:_ProcText(func_GetColumn_H_D(rowData), false)
			local rowData = func_GetTranslatedData()
			v.param[18] = self:_ProcText(func_GetColumn_H_D(rowData), false)
			local rowData = func_GetTranslatedData()
			v.param[19] = self:_ProcText(func_GetColumn_H_D(rowData), false)
			local rowData = func_GetTranslatedData()
			v.param[26] = self:_ProcText(func_GetColumn_H_D(rowData), false)
		elseif sCmdName == "SetMajorChoiceJumpTo" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "SetMajorChoiceRollover" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "SetMajorChoiceEnd" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "SetPersonalityChoice" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
			local rowData = func_GetTranslatedData()
			v.param[3] = self:_ProcText(func_GetColumn_H_D(rowData), false)
			local rowData = func_GetTranslatedData()
			v.param[4] = self:_ProcText(func_GetColumn_H_D(rowData), false)
			local rowData = func_GetTranslatedData()
			v.param[5] = self:_ProcText(func_GetColumn_H_D(rowData), false)
			local rowData = func_GetTranslatedData()
			v.param[9] = self:_ProcText(func_GetColumn_H_D(rowData), false)
		elseif sCmdName == "SetPersonalityChoiceJumpTo" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "SetPersonalityChoiceRollover" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "SetPersonalityChoiceEnd" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "SetBubble" then
			local rowData = func_GetTranslatedData()
			local spName = v.param[7]
			if type(spName) == "string" and spName ~= "" then
				v.param[7] = rowData[1]
			end
			v.param[3] = self:_ProcText(rowData[3], false)
			v.param[6] = self:_ProcText(rowData[5], false)
			v.param[9] = self:_ProcText(rowData[7], false)
			v.param[10] = self:_ProcText(rowData[9], false)
		elseif sCmdName == "SetGroupId" then
			nTranslatedDataIndex = nTranslatedDataIndex + 1
		elseif sCmdName == "NewCharIntro" then
			local rowData = func_GetTranslatedData()
			v.param[2] = self:_ProcText(func_GetColumn_H_D(rowData), false)
			local rowData = func_GetTranslatedData()
			v.param[3] = self:_ProcText(func_GetColumn_H_D(rowData), false)
		elseif sCmdName == "SetWordTrans" then
			local rowData = func_GetTranslatedData()
			v.param[1] = self:_ProcText(func_GetColumn_H_D(rowData), false)
		end
	end
	return tbLuaData
end
function AvgEditorMultiLanTool:_Export_AvgCharacter(tbLuaData)
	local tbExportData = {
		{
			"\232\167\146\232\137\178\229\144\141\229\173\151",
			"\232\175\145\230\150\135-\229\144\141\229\173\151"
		}
	}
	for i, v in ipairs(tbLuaData) do
		local id = v.id
		local name = v.name
		if id ~= "0" and id ~= "1" and type(name) == "string" and name ~= "" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. id .. "\227\128\145" .. v.name,
				""
			})
		end
	end
	return tbExportData
end
function AvgEditorMultiLanTool:_Compare_AvgCharacter(tbTranslatedData, tbExportData)
	if tbTranslatedData == nil then
		return false
	end
	local nRowCountT = tbTranslatedData.Length
	if nRowCountT ~= #tbExportData then
		return false
	end
	nRowCountT = nRowCountT - 1
	for i = 0, nRowCountT do
		local tbRowTranslated = tbTranslatedData[i]
		local tbRowExport = tbExportData[i + 1]
		local sTranslated = tbRowTranslated[0]
		local sExport = tbRowExport[1]
		if sTranslated ~= sExport then
			return false
		end
	end
	return true
end
function AvgEditorMultiLanTool:_Import_AvgCharacter(tbTranslatedData, tbLuaData)
	local nTranslatedDataIndex = 0
	local func_GetTranslatedData = function()
		nTranslatedDataIndex = nTranslatedDataIndex + 1
		return tbTranslatedData[nTranslatedDataIndex]
	end
	for i, v in ipairs(tbLuaData) do
		local id = v.id
		local name = v.name
		if id ~= "0" and id ~= "1" and type(name) == "string" and name ~= "" then
			local rowData = func_GetTranslatedData()
			local sName = rowData[1]
			v.name = sName
		end
	end
	return tbLuaData
end
function AvgEditorMultiLanTool:_Export_AvgContacts(tbLuaData)
	local tbExportData = {
		{
			"\229\144\141\229\173\151",
			"\232\175\145\230\150\135-\229\144\141\229\173\151",
			"\230\137\128\229\156\168\229\156\176",
			"\232\175\145\230\150\135-\230\137\128\229\156\168\229\156\176",
			"\228\184\170\230\128\167\231\173\190\229\144\141",
			"\232\175\145\230\150\135-\228\184\170\230\128\167\231\173\190\229\144\141"
		}
	}
	for i, v in ipairs(tbLuaData) do
		local name = v.name
		if name ~= "==PLAYER_NAME==" then
			table.insert(tbExportData, {
				"\227\128\144id:" .. tostring(v.id) .. "\227\128\145" .. name,
				"",
				self:_ProcText(v.landmark, true),
				"",
				self:_ProcText(v.signature, true),
				""
			})
		end
	end
	return tbExportData
end
function AvgEditorMultiLanTool:_Compare_AvgContacts(tbTranslatedData, tbExportData)
	if tbTranslatedData == nil then
		return false
	end
	local nRowCountT = tbTranslatedData.Length
	if nRowCountT ~= #tbExportData then
		return false
	end
	nRowCountT = nRowCountT - 1
	for i = 0, nRowCountT do
		local tbRowTranslated = tbTranslatedData[i]
		local tbRowExport = tbExportData[i + 1]
		for j = 1, 5, 2 do
			local sTranslated = tbRowTranslated[j - 1]
			local sExport = tbRowExport[j]
			if sTranslated ~= sExport then
				return false
			end
		end
	end
	return true
end
function AvgEditorMultiLanTool:_Import_AvgContacts(tbTranslatedData, tbLuaData)
	local nTranslatedDataIndex = 0
	local func_GetTranslatedData = function()
		nTranslatedDataIndex = nTranslatedDataIndex + 1
		return tbTranslatedData[nTranslatedDataIndex]
	end
	for i, v in ipairs(tbLuaData) do
		local name = v.name
		if name ~= "==PLAYER_NAME==" then
			local rowData = func_GetTranslatedData()
			v.name = rowData[1]
			v.landmark = self:_ProcText(rowData[3], false)
			v.signature = self:_ProcText(rowData[5], false)
		end
	end
	return tbLuaData
end
function AvgEditorMultiLanTool:_Export_AvgUIText(tbLuaData)
	local tbExportData = {
		{
			"\228\184\187\233\148\174",
			"\230\150\135\230\156\172\229\134\133\229\174\185",
			"\232\175\145\230\150\135"
		}
	}
	local tbMainKeys = {}
	local tbSexKeys = {}
	for k, v in pairs(tbLuaData) do
		table.insert(tbMainKeys, k)
		if k == "SEX" then
			for kk, vv in pairs(v) do
				table.insert(tbSexKeys, kk)
			end
		end
	end
	table.sort(tbMainKeys)
	table.sort(tbSexKeys)
	for i, keyM in ipairs(tbMainKeys) do
		if keyM == "SEX" then
			local mapSex = tbLuaData.SEX
			for ii, keyS in ipairs(tbSexKeys) do
				local _tb = mapSex[keyS]
				local sContent = _tb[1] .. "|" .. _tb[2]
				table.insert(tbExportData, {
					keyS,
					sContent,
					""
				})
			end
		else
			table.insert(tbExportData, {
				keyM,
				self:_ProcText(tbLuaData[keyM], true),
				""
			})
		end
	end
	return tbExportData
end
function AvgEditorMultiLanTool:_Compare_AvgUIText(tbTranslatedData, tbExportData)
	if tbTranslatedData == nil then
		return false
	end
	local nRowCountT = tbTranslatedData.Length
	if nRowCountT ~= #tbExportData then
		return false
	end
	nRowCountT = nRowCountT - 1
	for i = 0, nRowCountT do
		local tbRowTranslated = tbTranslatedData[i]
		local tbRowExport = tbExportData[i + 1]
		for j = 1, 2 do
			local sTranslated = tbRowTranslated[j - 1]
			local sExport = tbRowExport[j]
			if sTranslated ~= sExport then
				return false
			end
		end
	end
	return true
end
function AvgEditorMultiLanTool:_Import_AvgUIText(tbTranslatedData, tbLuaData)
	local nTranslatedDataIndex = 0
	local func_GetTranslatedData = function()
		nTranslatedDataIndex = nTranslatedDataIndex + 1
		return tbTranslatedData[nTranslatedDataIndex]
	end
	local tbMainKeys = {}
	local tbSexKeys = {}
	for k, v in pairs(tbLuaData) do
		table.insert(tbMainKeys, k)
		if k == "SEX" then
			for kk, vv in pairs(v) do
				table.insert(tbSexKeys, kk)
			end
		end
	end
	table.sort(tbMainKeys)
	table.sort(tbSexKeys)
	for i, keyM in ipairs(tbMainKeys) do
		if keyM == "SEX" then
			for ii, keyS in ipairs(tbSexKeys) do
				local rowData = func_GetTranslatedData()
				local tbSplit = string.split(rowData[2], "|")
				tbLuaData.SEX[keyS][1] = tbSplit[1]
				tbLuaData.SEX[keyS][2] = tbSplit[2]
			end
		else
			local rowData = func_GetTranslatedData()
			tbLuaData[keyM] = self:_ProcText(rowData[2], false)
		end
	end
	return tbLuaData
end
return AvgEditorMultiLanTool
