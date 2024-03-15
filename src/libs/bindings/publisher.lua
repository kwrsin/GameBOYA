-- publisher.lua
local values = {}
local subscribers = {}

local M = {}

local function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in next, orig, nil do
          copy[deepcopy(orig_key)] = deepcopy(orig_value)
      end
      setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end

local function merge(params, options)
	if params == nil then
		return options
	end
	local params = deepcopy(params)	
	for k, v in pairs(params) do
		options[k] = params[k]		
	end
	return options
end

function M:create(globalValues)
	values = merge(globalValues, values)
end

function M:observe(key, value)
	values[key] = value
end

local function existUpdator(entries, updator)
	for i, ent in ipairs(entries) do
		if updator == ent then
			return true
		end
	end
	return false
end

function M:subscribe(key, updator)
	-- if not updator.update then return end
	local entries = subscribers[key] or {}
	if existUpdator(entries, updator) then return end
	updator.PubSubKey = key
	updator.put = function(hash)
		self:put(updator, updator.PubSubKey, hash)
	end
	updator.get = function()
		return self:get(updator.PubSubKey)
	end
	entries[#entries + 1] = updator
	subscribers[key] = entries
	return subscribers[key]
end

function M:unsubscribe(key, updator)
	if not subscribers[key] then return end
	local keySubs = subscribers[key]
	local pos = 0
	for i=1,#keySubs do
		if keySubs[i] == updator then
			pos = i
			break;
		end
	end
	if pos > 0 then
		table.remove( subscribers[key], pos )
	end
	return subscribers[key]
end

function M:unsubscribeAll(key)
	if subscribers[key] then
		subscribers[key] = nil
	else
		for k, v in pairs(subscribers) do
			subscribers[k] = nil
		end
	end
	return subscribers
end

function M:getKeys()
	if not values or #values <= 0 then return end
	local keys = {}
	for k, v in pairs(values) do
		keys[#keys + 1] = k
	end
	return keys
end

function M:get(key)
	return merge(values[key], {})
end

function M:put(source, key, hash)
	if not values[key] then return end
	local old = merge(values[key], {})
	values[key] = merge(hash, old)
	local keySubs = subscribers[key]
	if not keySubs then return end
	for i, sub in ipairs(keySubs) do
		if source == sub then 
		else
			if sub.update then
				local event = {
					source=source,
					value=values[key], 
					oldValue=old, 
					key=key}
				sub.update(sub, event)
			end
		end
	end
end

return M