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

local function hasGameContent(layers)
	for i, l in ipairs(layers) do
		if l.width and l.height then
			return true
		end
	end
	return false
end

local function loadLayers()
	if hasGameContent(level.layers) then
		content.useCamera = true
		local layerGroup = {}
		for i, layer in ipairs(level.layers) do
			local gpLayer = display.newGroup()
			layerGroup[#layerGroup + 1] = gpLayer
			gpLayer.isVisible = layer.props.visible
			gpLayer.name = layer.props.name
			if layer.width and layer.height then
				gpLayer.isContent = true
				local area = display.newRect( gpLayer, 0, 0, layer.width, layer.height )
				area.isVisible = false
				area.anchorX, area.anchorY = 0, 0
			end
			loadGameObjects(gpLayer, layer)
		end
		camera:create(content, {layers=layerGroup, target=player.go or {x=0, y=0}})
	else
		for i, layer in ipairs(level.layers) do
			local gpLayer = display.newGroup()
			content:insert(gpLayer)
			gpLayer.isVisible = layer.props.visible
			gpLayer.name = layer.props.name
			loadGameObjects(gpLayer, layer)
		end
	end
end

return function(params)
	content = display.newGroup()
	content.useCamera = false
	if params.parent then
		params.parent:insert(content)
	end
	level = params.level
	register=params.register

	loadLayers()
	return content
end