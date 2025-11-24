local cacheTable = {}
local GetCache = function(name)
	if name == nil then
		traceback("\232\142\183\229\143\150\231\188\147\229\173\152\230\149\176\230\141\174\230\151\182, name \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	if cacheTable[name] == nil then
		cacheTable[name] = {}
	end
	return cacheTable[name]
end
local SetCache = function(name, tb)
	if name == nil then
		traceback("\229\134\153\229\133\165\231\188\147\229\173\152\230\149\176\230\141\174\230\151\182, name \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	cacheTable[name] = tb
end
local GetCacheData = function(name, key)
	if key == nil then
		traceback("\232\142\183\229\143\150\231\188\147\229\173\152\230\149\176\230\141\174\230\151\182, key \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	local tb = GetCache(name)
	if tb == nil then
		return
	end
	return tb[key]
end
local SetCacheData = function(name, key, data)
	if name == nil then
		traceback("\229\134\153\229\133\165\231\188\147\229\173\152\230\149\176\230\141\174\230\151\182, name \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	if key == nil then
		traceback("\229\134\153\229\133\165\231\188\147\229\173\152\230\149\176\230\141\174\230\151\182, key \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	local tb = GetCache(name)
	tb[key] = data
end
local SetCacheField = function(name, key, field, data)
	if name == nil then
		traceback("\229\134\153\229\133\165\231\188\147\229\173\152\230\149\176\230\141\174\230\151\182, name \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	if key == nil then
		traceback("\229\134\153\229\133\165\231\188\147\229\173\152\230\149\176\230\141\174\230\151\182, key \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	if field == nil then
		traceback("\229\134\153\229\133\165\231\188\147\229\173\152\230\149\176\230\141\174\230\151\182, field \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	local tb = GetCache(name)
	if tb == nil then
		return
	end
	if tb[key] == nil then
		tb[key] = {}
	end
	tb[key][field] = data
end
local InsertCacheData = function(name, key, data)
	if name == nil then
		traceback("\229\134\153\229\133\165\231\188\147\229\173\152\230\149\176\230\141\174\230\151\182, name \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	if key == nil then
		traceback("\229\134\153\229\133\165\231\188\147\229\173\152\230\149\176\230\141\174\230\151\182, key \229\143\130\230\149\176\228\184\141\232\131\189\228\184\186\231\169\186\239\188\129\239\188\129\239\188\129")
		return
	end
	local tb = GetCache(name)
	if tb == nil then
		return
	end
	if tb[key] == nil then
		tb[key] = {}
	end
	table.insert(tb[key], data)
end
_G.CacheTable = {
	Get = GetCache,
	Set = SetCache,
	GetData = GetCacheData,
	SetData = SetCacheData,
	SetField = SetCacheField,
	InsertData = InsertCacheData
}
