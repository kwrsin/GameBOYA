local M = {}
local root
local contentWidth
local contentHeight
local frameWidth
local frameHeight
local content
local target
local parallaxTable = {}
local preX = 0
local preY = 0
local dirX = 0
local dirY = 0

local factor = 1.0
local value = 0
local dumping = 0.9
local cutoff = 0.1
local balancing = 0.5
local onComplete
local offsetX = 0
local offsetY = 0
local viewWidth = nil
local viewHeight = nil
local enabled = false

function M:setContentPosition(params)
	if params.transition then
		params.tag = 'camera'
		transition.to( content, params )
	else
		content.x, content.y = params.x, params.y
	end
end

function M:update()
  local lx, ly = self:localize()
  local halfHeight = frameHeight / 2
  local halfWidth = frameWidth / 2
  local paddingTop = halfHeight
  local paddingBottom = viewHeight - halfHeight
  local paddingLeft = halfWidth
  local paddingRight = viewWidth - halfWidth
  local diffX
  local diffY
  local cntX = content.x
  local cntY = content.y

  if ly < paddingTop then
    diffY = paddingTop - ly
  elseif ly > paddingBottom then
    diffY = paddingBottom - ly
  end
  if lx < paddingLeft then
    diffX = paddingLeft - lx
  elseif lx > paddingRight then
    diffX = paddingRight - lx
  end
  dirX = (target.x - preX)
  dirY = (target.y - preY)
  if diffX then
    cntX = cntX - dirX
  end
  if diffY then
    cntY = cntY - dirY
  end

  if target.y < halfHeight or target.y > contentHeight - halfHeight then
  	cntY = content.y
  end
  if target.x < halfWidth or target.x > contentWidth - halfWidth then
  	cntX = content.x
  end
  local x, y = self:adjustedTopLeft(cntX, cntY)
  self:setContentPosition{x=x, y=y}
end

function M:localize()
  return target.x + content.x, target.y + content.y
end

function M:setTarget(object)
	target = object
  preX = object.x
  preY = object.y	
end

--[[
sceneGroup
	container
		layerGroup[parallaxBackground]
		layerGroup[content => background & gameObjects]
		layerGroup[parallaxForeground]
]]--
function M:create(parent, options)
  local layers = options.layers
  viewWidth = options.viewWidth or CW
  viewHeight = options.viewHeight or CH
  contentWidth = viewWidth
  contentHeight = viewHeight

  root = display.newGroup()
  root.x = options.offsetX or 0
  root.y = options.offsetY or 0
  parent:insert(root)
  for i, layer in ipairs(layers) do
    root:insert(layer, true)
    if layer.isContent then
      content = layer
      contentWidth = layer.width
		  contentHeight = layer.height
    else
      parallaxTable[#parallaxTable + 1] = layer
    end
  end
  frameWidth = options.frameWidth or 100
  frameHeight = options.frameHeight or 100
  self:setFocus( options.target )
end

function M:setFocus(object, params)
	target = object or target

	self:setTarget( target )
	local x, y = self:getTopLeftCorner()
	if content then
		x, y = 
			self:adjustedTopLeft(content.x - x, content.y - y)
	end
	local options = params or {}
	options.x, options.y = x, y
	self:setContentPosition(options)
end

function M:adjustedTopLeft(x, y)
	local ax = x
	local ay = y
	local maxWidth = -(contentWidth - viewWidth)
	local maxHeight = -(contentHeight - viewHeight)
	if ax > 0 then 
		ax = 0
	elseif x < maxWidth then
		ax = maxWidth
	end
	if ay > 0 then 
		ay = 0
	elseif y < maxHeight then
		ay = maxHeight
	end

	return ax, ay
end

function M:getTopLeftCorner()
	local halfWidth = viewWidth / 2
	local halfHeight = viewHeight / 2
	local x = target.x - halfWidth
	local y = target.y - halfHeight

	return x, y
end

function M:updatePrePosition()
	preX = target.x
	preY = target.y
end

function M:shake(params)
	params = params or {}
	value = params.value or 100
	dumping = params.dumping or 0.9
	cutoff = params.cutoff or 0.1
	balancing = params.balancing or 0.5
	onComplete = params.onComplete
end

function M:shakeAction()
	if value <= 0 then return end
	if value < cutoff then
		value = 0
		root.x = 0
		if onComplete then onComplete() end
	end
	local x = value * factor * balancing
	root.x = x
	factor = factor * -1

	value = dumping * value
end

function M:parallax()
	for i, layer in ipairs(parallaxTable) do
		if layer.parallax then
			layer:parallax{x=dirX, y=dirY}
		end
	end
end

function M:enable( bool )
	enabled = bool
end

function M:enterFrame(event)
	if not enabled then return end
  self:update()
	self:updatePrePosition()
	self:shakeAction()
	self:parallax()
end

return M