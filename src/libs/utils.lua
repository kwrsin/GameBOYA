-- base.lua
local json = require 'json'
local network = require 'network'
local composer = require 'composer'

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

local function getImageSheets(resources)
	local imageSheets = {}
	for i, filename in ipairs(resources.names) do
		local structure = require(resources.structPath .. filename)
		if structure then
			local imageSheet = 
				graphics.newImageSheet( structure.path, structure.sheetParams )
			if imageSheet then
				imageSheets[filename] = imageSheet
			end
		end
	end
	return imageSheets
end

local function normalize(width, height)
	local magnitude = math.sqrt(width * width + height * height)
	local x = width / magnitude
	local y = height / magnitude
	return {x=x, y=y}
end

local clamp = function(v, l, h) return (v < l and l) or (v > h and h) or v end

local tagCountdown = 'countdown'
local function startCountdown(countdown, callback)
	timer.performWithDelay(1000, callback, countdown, tagCountdown)
end

local function resumeCountdown()
	timer.resume( tagCountdown )
end

local function pauseCountdown()
	timer.pause( tagCountdown )
end

local function cancelCountdown()
	timer.cancel( tagCountdown )
end

local function toJSON(t, options)
	return json.encode( t, options )
end

local function toTable(jText)
	local result
	local decoded, pos, msg = json.decode(jText)
	if not decoded then
		print(string.format( 'error at %d, %s', pos, msg ))
		result = ''
	else
		result = decoded
	end
	return result
end

local function toKeys(cursor, threshold)
	local p = threshold or 16
	local keys = {}
	keys.up, keys.down, keys.left, keys.right = 0, 0, 0, 0
	cursor.lx, cursor.ly = cursor.lx or 0, cursor.ly or 0
	if cursor.ly > 0 + p then
		keys.down = cursor.counter
	elseif cursor.ly < 0  - p then
		keys.up = cursor.counter
	end
	if cursor.lx > 0 + p then
		keys.right = cursor.counter
	elseif cursor.lx < 0 - p then
		keys.left = cursor.counter
	end
	return keys
end

local function request(params)
	network.request(params.url, params.method, function(event)
		if event.isError then
			print('Network Error: ', event.response)
		else
			if params.callback then
				params.callback(event)
			end
		end
	end, params.options)
end

local function dotPath(file, dir)
	return string.format( '%s.%s', dir, file )
end

local function gotoScene(name, options)
	composer.gotoScene( dotPath(name, dot_scenes), options)
end

local function removeScene(name)
	composer.removeScene( dotPath(name, dot_scenes) )
end

M.dotPath = dotPath
M.gotoScene = gotoScene
M.removeScene = removeScene
M.deepcopy = deepcopy
M.toJSON = toJSON
M.toTable = toTable
M.request = request
M.toKeys = toKeys
M.merge = merge
M.getImageSheets = getImageSheets
M.normalize = normalize
M.clamp = clamp
M.startCountdown = startCountdown
M.resumeCountdown = resumeCountdown
M.pauseCountdown = pauseCountdown
M.cancelCountdown = cancelCountdown
return M