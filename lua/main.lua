require("GameCore.GameCore")
NovaAPI.EnterModule("LoginModuleScene", true)
if NovaAPI.IsEditorPlatform() then
	local forEachLine_Story = function(mapLineData)
		if mapLineData.AvgLuaName ~= "" then
			local nLanIdx = GetLanguageIndex(Settings.sCurrentTxtLanguage)
			local sRequireRootPath = GetAvgLuaRequireRoot(nLanIdx) .. "Config/"
			local sAvgCfgPath = NovaAPI.ApplicationDataPath .. "/../Lua/" .. sRequireRootPath .. mapLineData.AvgLuaName .. ".lua"
			local isFileExists = CS.System.IO.File.Exists(sAvgCfgPath)
			if not isFileExists then
				printError("Story\232\161\168\228\184\173\230\156\137\228\184\141\229\173\152\229\156\168\231\154\132Avg\230\150\135\228\187\182\239\188\140\232\175\183\230\163\128\230\159\165Story\232\161\168\239\188\140AvgName\239\188\154" .. sAvgCfgPath)
			end
		end
	end
	ForEachTableLine(DataTable.Story, forEachLine_Story)
end
