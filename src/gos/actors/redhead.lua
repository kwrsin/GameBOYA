local base = require 'src.gos.base'
local structure = require 'src.structures.gos.redhead'
local sprite

local function createSprite(params)
	sprite = display.newSprite( params.parent, gImageSheets.redhead, structure.sequences )
	sprite.x, sprite.y = params.x, params.y
	physics.addBody( sprite, 'dynamic', {density=1.0, bounce=0, friction=0, filter=structure.relation} )
	sprite.gravityScale = 0
	sprite.isFixedRotation = true
	return sprite
end

return function(params)
	local M = base(params)
	M.speed = 2
	M.go = createSprite(params)
	M:play('down')

	function M:move(keys)

		local pos = {x=0, y=0}
		if keys.up > 0 then
			pos.y =  -self.speed
		elseif keys.down > 0 then
			pos.y = self.speed
		end
		if keys.right > 0 then
			pos.x = self.speed
		elseif keys.left > 0 then
			pos.x = -self.speed
		end
		self.go.x = self.go.x + pos.x 
		self.go.y = self.go.y + pos.y 
	end

	return M
end