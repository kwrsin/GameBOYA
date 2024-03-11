-- publisher.lua
local values = {}
local subscribers = {}

local M = {}

local function merge(params, options)
	if params == nil then
		return options
	end
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

function M:subscribe(key, updator)
	if not updator.update then return end
	local entries = subscribers[key] or {}
	updator.put = function(key, value)
		self:put(updator, key, value)
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

function M:put(source, key, value)
	if not values[key] then return end
	local old = values[key]
	values[key] = merge(value, old)
	local keySubs = subscribers[key]
	if not keySubs then return end
	for i, sub in ipairs(keySubs) do
		if source == sub then 
		else
			local event = {
				source=source,
				value=values[key], 
				oldValue=old, 
				key=key}
			sub.update(sub, event)
		end
	end
end

return M