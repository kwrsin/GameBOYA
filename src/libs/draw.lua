-- draw.lua
local utils = require 'src.libs.utils'

local M = {}

M.red={1, 0, 0}
M.green={0, 1, 0}
M.blue={0, 0, 1}

function M.point(params)
	local x, y = params.x or 0, params.y or 0
	local radius = params.radius or 12
	local color = params.color or {1, 0, 0}
	local circle = display.newCircle(x, y, radius)
	if params.parent then
		params.parent:insert(circle)
	end
	circle:setFillColor(unpack(color))
	
	return circle
end

function M.box(params)
	local x, y = params.x or 0, params.y or 0
	local width = params.width or 30
	local height = params.height or 30
	local color = params.color or {1, 0, 0}
	local rect = display.newRect(x, y, width, height)
	if params.parent then
		params.parent:insert(rect)
	end
	rect:setFillColor(unpack(color))

	return rect
end

function M.wall(parent, x, y, width, height, color, options)
	local wall = M.box{parent=parent, x=x, y=y, width=width, height=height, color=color}
	local physicsOptions = utils.merge(options or {}, {friction=0.2, bounce=0, density=1.0})
	physics.addBody( wall, 'static', physicsOptions )	
	return wall
end

function M.sprite(params)
	local sprite = display.newSprite( params.imageSheet, params.sequences )
	sprite.x, sprite.y = params.x or cx, params.y or cy
	if params.parent then
		params.parent:insert(sprite)
	end

	function sprite:transit(sequenceName)
		if self.sequence == sequenceName then return end
		self:setSequence(sequenceName)
		self:play()
	end

	return sprite
end

return M