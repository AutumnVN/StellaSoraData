local warn_color_tag = "<color=#FFFF00>"
local error_color_tag = "<color=#FF0000>"
local end_color_tag = "</color>"
local table_tag = "<color=#00FF00><b>\226\152\128\239\184\143\231\173\150\229\136\146\230\149\176\230\141\174\232\161\168\226\152\128\239\184\143</b></color>"
local cache = {}
local ClearCache = function()
	cache = {}
end
local ClearTableCache = function(name)
	if name == nil then
		traceback("\232\142\183\229\143\150\231\173\150\229\136\146\230\149\176\230\141\174\232\161\168\230\149\176\230\141\174\230\151\182, name \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	cache[name] = {}
end
local GetTable = function(name, post_warn)
	if name == nil then
		traceback("\232\142\183\229\143\150\231\173\150\229\136\146\230\149\176\230\141\174\232\161\168\230\149\176\230\141\174\230\151\182, name \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	local tb = _G.DataTable[name]
	if tb == nil then
		if post_warn == true then
			printWarn(table_tag .. " [" .. warn_color_tag .. name .. end_color_tag .. "] \228\184\141\229\173\152\229\156\168\239\188\129\239\188\129\239\188\129")
		else
			traceback(table_tag .. " [" .. error_color_tag .. name .. end_color_tag .. "] \228\184\141\229\173\152\229\156\168\239\188\129\239\188\129\239\188\129")
		end
		return
	end
	if cache[name] == nil then
		cache[name] = {}
	end
	return tb
end
local GetTableData = function(name, key, post_warn)
	if key == nil then
		traceback("\232\142\183\229\143\150\231\173\150\229\136\146\230\149\176\230\141\174\232\161\168\230\149\176\230\141\174\230\151\182, key \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	local tb = GetTable(name, post_warn)
	if tb == nil then
		return
	end
	local cacheTb = cache[name]
	local line = cacheTb[key]
	if line ~= nil then
		return line
	end
	line = tb[key]
	if line == nil then
		if post_warn == true then
			printWarn(table_tag .. " [" .. warn_color_tag .. name .. end_color_tag .. "] \228\184\173\230\178\161\230\137\190\229\136\176 Id = [" .. warn_color_tag .. key .. end_color_tag .. "] \231\154\132\230\149\176\230\141\174\232\161\140\239\188\129\239\188\129\239\188\129")
		else
			traceback(table_tag .. " [" .. error_color_tag .. name .. end_color_tag .. "] \228\184\173\230\178\161\230\137\190\229\136\176 Id = [" .. error_color_tag .. key .. end_color_tag .. "] \231\154\132\230\149\176\230\141\174\232\161\140\239\188\129\239\188\129\239\188\129")
		end
		return
	end
	cacheTb[key] = line
	return line
end
local GetTableField = function(name, key, field, post_warn)
	local line = GetTableData(name, key, post_warn)
	if line == nil then
		return
	end
	if field == nil then
		traceback("\232\142\183\229\143\150\231\173\150\229\136\146\230\149\176\230\141\174\232\161\168\230\149\176\230\141\174\230\151\182, field \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	local field_obj = line[field]
	if field_obj == nil then
		if post_warn == true then
			printWarn(table_tag .. " [" .. warn_color_tag .. name .. end_color_tag .. "] \228\184\173 Id = [" .. warn_color_tag .. key .. end_color_tag .. "] \231\154\132\230\149\176\230\141\174\232\161\140\228\184\173\230\178\161\230\137\190\229\136\176\229\173\151\230\174\181 [" .. warn_color_tag .. field .. end_color_tag .. "] \239\188\129\239\188\129\239\188\129")
		else
			traceback(table_tag .. " [" .. error_color_tag .. name .. end_color_tag .. "] \228\184\173 Id = [" .. error_color_tag .. key .. end_color_tag .. "] \231\154\132\230\149\176\230\141\174\232\161\140\228\184\173\230\178\161\230\137\190\229\136\176\229\173\151\230\174\181 [" .. error_color_tag .. field .. end_color_tag .. "] \239\188\129\239\188\129\239\188\129")
		end
	end
	return field_obj
end
local GetUITextData = function(key, post_warn)
	return GetTableField("UIText", key, "Text", post_warn) or ""
end
local configCache = {}
local GetTableConfigData = function(key, post_warn)
	if key == nil then
		traceback("\232\142\183\229\143\150\231\173\150\229\136\146\230\149\176\230\141\174\232\161\168\230\149\176\230\141\174\230\151\182, key \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	local data = configCache[key]
	if data ~= nil then
		return data
	end
	data = GetTableField("Config", key, "Value", post_warn)
	if data == nil then
		return
	end
	configCache[key] = data
	return data
end
local GetTableConfigNumber = function(key, post_warn)
	if key == nil then
		traceback("\232\142\183\229\143\150\231\173\150\229\136\146\230\149\176\230\141\174\232\161\168\230\149\176\230\141\174\230\151\182, key \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	local data = configCache[key]
	if data ~= nil then
		return data
	end
	data = GetTableField("Config", key, "Value", post_warn)
	if data == nil then
		return
	end
	local num = tonumber(data)
	if num == nil then
		if post_warn == true then
			printWarn(table_tag .. " [" .. warn_color_tag .. "Config" .. end_color_tag .. "] \228\184\173 Id = [" .. warn_color_tag .. key .. end_color_tag .. "] \231\154\132\230\149\176\230\141\174\232\161\140\228\184\173\231\154\132\229\173\151\230\174\181 [" .. warn_color_tag .. "Value" .. end_color_tag .. "] \228\184\141\230\152\175\230\149\176\229\173\151\239\188\129\239\188\129\239\188\129")
		else
			traceback(table_tag .. " [" .. error_color_tag .. "Config" .. end_color_tag .. "] \228\184\173 Id = [" .. error_color_tag .. key .. end_color_tag .. "] \231\154\132\230\149\176\230\141\174\232\161\140\228\184\173\231\154\132\229\173\151\230\174\181 [" .. error_color_tag .. "Value" .. end_color_tag .. "] \228\184\141\230\152\175\230\149\176\229\173\151\239\188\129\239\188\129\239\188\129")
		end
		return
	end
	configCache[key] = num
	return num
end
local GetTableConfigArray = function(key, post_warn)
	if key == nil then
		traceback("\232\142\183\229\143\150\231\173\150\229\136\146\230\149\176\230\141\174\232\161\168\230\149\176\230\141\174\230\151\182, key \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	local data = configCache[key]
	if data ~= nil then
		return data
	end
	data = GetTableField("Config", key, "Value", post_warn)
	if data == nil then
		return
	end
	local arr = string.split(data, ",")
	configCache[key] = arr
	return arr
end
local GetTableConfigNumberArray = function(key, post_warn)
	if key == nil then
		traceback("\232\142\183\229\143\150\231\173\150\229\136\146\230\149\176\230\141\174\232\161\168\230\149\176\230\141\174\230\151\182, key \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	local data = configCache[key]
	if data ~= nil then
		return data
	end
	data = GetTableField("Config", key, "Value", post_warn)
	if data == nil then
		return
	end
	local arr = string.split(data, ",") or {}
	if #arr == 0 then
		configCache[key] = {}
		return {}
	end
	local res = {}
	for _, v in ipairs(arr) do
		local num = tonumber(v)
		if num == nil then
			if post_warn == true then
				printWarn(table_tag .. " [" .. warn_color_tag .. "Config" .. end_color_tag .. "] \228\184\173 Id = [" .. warn_color_tag .. key .. end_color_tag .. "] \231\154\132\230\149\176\230\141\174\232\161\140\228\184\173\231\154\132\229\173\151\230\174\181 [" .. warn_color_tag .. "Value" .. end_color_tag .. "] \228\184\141\230\152\175\230\149\176\229\173\151\230\149\176\231\187\132\239\188\129\239\188\129\239\188\129")
			else
				traceback(table_tag .. " [" .. error_color_tag .. "Config" .. end_color_tag .. "] \228\184\173 Id = [" .. error_color_tag .. key .. end_color_tag .. "] \231\154\132\230\149\176\230\141\174\232\161\140\228\184\173\231\154\132\229\173\151\230\174\181 [" .. error_color_tag .. "Value" .. end_color_tag .. "] \228\184\141\230\152\175\230\149\176\229\173\151\230\149\176\231\187\132\239\188\129\239\188\129\239\188\129")
			end
			return res
		end
		table.insert(res, num)
	end
	configCache[key] = res
	return res
end
local GetTableData_Character = function(key, post_warn)
	return GetTableData("Character", key, post_warn)
end
local GetTableData_Skill = function(key, post_warn)
	return GetTableData("Skill", key, post_warn)
end
local GetTableData_Item = function(key, post_warn)
	return GetTableData("Item", key, post_warn)
end
local GetTableData_World = function(key, post_warn)
	return GetTableData("World", key, post_warn)
end
local GetTableData_HitDamage = function(key, post_warn)
	return GetTableData("HitDamage", key, post_warn)
end
local GetTableData_Attribute = function(key, post_warn)
	return GetTableData("Attribute", key, post_warn)
end
local GetTableData_Buff = function(key, post_warn)
	return GetTableData("Buff", key, post_warn)
end
local GetTableData_Effect = function(key, post_warn)
	return GetTableData("Effect", key, post_warn)
end
local GetTableData_Mainline = function(key, post_warn)
	return GetTableData("Mainline", key, post_warn)
end
local GetTableData_Perk = function(key, post_warn)
	return GetTableData("Perk", key, post_warn)
end
local GetTableData_Story = function(key, post_warn)
	return GetTableData("Story", key, post_warn)
end
local GetTableData_CharacterSkin = function(key, post_warn)
	return GetTableData("CharacterSkin", key, post_warn)
end
local GetTableData_Trap = function(key, post_warn)
	return GetTableData("Trap", key, post_warn)
end
_G.ConfigTable = {
	ClearCache = ClearCache,
	ClearTableCache = ClearTableCache,
	Get = GetTable,
	GetData = GetTableData,
	GetField = GetTableField,
	GetUIText = GetUITextData,
	GetConfigValue = GetTableConfigData,
	GetConfigNumber = GetTableConfigNumber,
	GetConfigArray = GetTableConfigArray,
	GetConfigNumberArray = GetTableConfigNumberArray,
	GetData_Character = GetTableData_Character,
	GetData_Skill = GetTableData_Skill,
	GetData_Item = GetTableData_Item,
	GetData_World = GetTableData_World,
	GetData_HitDamage = GetTableData_HitDamage,
	GetData_Attribute = GetTableData_Attribute,
	GetData_Buff = GetTableData_Buff,
	GetData_Effect = GetTableData_Effect,
	GetData_Mainline = GetTableData_Mainline,
	GetData_Perk = GetTableData_Perk,
	GetData_Story = GetTableData_Story,
	GetData_CharacterSkin = GetTableData_CharacterSkin,
	GetData_Trap = GetTableData_Trap
}
