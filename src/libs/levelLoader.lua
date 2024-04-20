-- levelLoader.lua
local content
local level
local register

local function loadGameObjects(parent, layer)
	if not layer.gos or #layer.gos <= 0 then return end
	local gos = layer.gos
	for i, go in ipairs(gos) do
		local generate = require(go.class)
		local params = go.params
		params.parent = parent
		local obj = generate(params)
		if register then
			register(obj, params)
		end
	end
end

local function loadLayers()
	for i, layer in ipairs(level.layers) do
		local gpLayer = display.newGroup()
		content:insert(gpLayer)
		gpLayer.isVisible = layer.props.visible
		gpLayer.name = layer.props.name
		loadGameObjects(gpLayer, layer)
	end
end

return function(params)
	content = display.newGroup()
	if params.parent then
		params.parent:insert(content)
	end
	level = params.level
	register=params.register

	loadLayers()
	return content
end