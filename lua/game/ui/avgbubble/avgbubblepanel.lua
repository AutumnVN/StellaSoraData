local AvgBubblePanel = class("AvgBubblePanel", BasePanel)
AvgBubblePanel._sSortingLayerName = AllEnum.SortingLayerName.UI_Top
AvgBubblePanel._bAddToBackHistory = false
AvgBubblePanel._tbDefine = {
	{
		sPrefabPath = "AvgBubble/AvgBubbleUI.prefab",
		sCtrlName = "Game.UI.AvgBubble.AvgBubbleCtrl"
	}
}
function AvgBubblePanel:Awake()
	self.sAvgBBCmdCfgPath = nil
	self.tbAvgBBCmdCfg = {}
	self.nBubbleType = 1
	local tbParam = self:GetPanelParam()
	self.sAvgId = tbParam[1]
	self.sGroupId = tostring(tbParam[2])
	self.nCurLanguageIdx = GetLanguageIndex(tbParam[3])
	self.sTxtLan = tbParam[3]
	self.sVoLan = tbParam[4]
	self.bIsPlayerMale = PlayerData.Base:GetPlayerSex() == true
	self.bParseSuc = self:ParseAvgBubbleConfig()
end
function AvgBubblePanel:OnEnable()
	if self.bParseSuc == false then
		EventManager.Hit(EventId.AvgBubbleExit)
		NovaAPI.DispatchEventWithData("AVG_BB_END", nil, string.format("%s|%s", self.sAvgId, tostring(self.sGroupId)))
	end
end
function AvgBubblePanel:OnDestroy()
	self.tbAvgBBCmdCfg = nil
	if self.sAvgBBCmdCfgPath ~= nil then
		package.loaded[self.sAvgBBCmdCfgPath] = nil
		self.sAvgBBCmdCfgPath = nil
	end
end
function AvgBubblePanel:ParseAvgBubbleConfig()
	self.sAvgBBCmdCfgPath = GetAvgLuaRequireRoot(self.nCurLanguageIdx) .. "Config/" .. self.sAvgId
	local ok, tbEntireAvgBBCmdCfg = pcall(require, self.sAvgBBCmdCfgPath)
	if not ok then
		printError("AvgId\229\175\185\229\186\148\231\154\132\233\133\141\231\189\174\230\150\135\228\187\182\230\178\161\230\156\137\230\137\190\229\136\176,path:" .. self.sAvgBBCmdCfgPath .. ". error: " .. tbEntireAvgBBCmdCfg)
		return false
	else
		local bMatch = false
		for _, v in ipairs(tbEntireAvgBBCmdCfg) do
			if v.cmd == "SetGroupId" then
				if self.sGroupId == "PLAY_ALL_PLAY_ALL" then
					bMatch = true
				else
					bMatch = tostring(v.param[1]) == self.sGroupId
				end
			end
			if bMatch == true then
				if v.cmd == "SetBubbleUIType" then
					self.nBubbleType = v.param[1]
				elseif v.cmd == "SetBubble" then
					table.insert(self.tbAvgBBCmdCfg, v)
				end
			end
		end
		if #self.tbAvgBBCmdCfg > 0 then
			return true
		else
			printError(string.format("\230\173\164AVG\230\176\148\230\179\161\230\140\135\228\187\164\233\133\141\231\189\174\230\150\135\228\187\182\233\135\140,\232\175\165\231\187\132\230\156\170\230\137\190\229\136\176\228\187\187\228\189\149\230\149\176\230\141\174,path:%s, groupId:%s", self.sAvgBBCmdCfgPath, self.sGroupId))
			return false
		end
	end
end
return AvgBubblePanel
