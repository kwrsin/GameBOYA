-- player.lua
local base = require 'src.gos.base'
local structure = require 'src.structures.gos.aboya'
local relations = require 'src.structures.relations'
local sprite
local gravityScale = 1
local laderCounter = 0

-- local function preCollision(self, event)
-- 	if event.other.class == 'floor' then
-- 		local flr = event.other
-- 		if sprite.y + (self.height * 0.5) > flr.y - (flr.height * 0.5) + 0.2 then
-- 			if event.contact then
-- 				event.contact.isEnabled = false
-- 				-- self.onFloor = false
-- 			end
-- 		else
-- 			-- self.onFloor = true
-- 		end
-- 	end
-- 	return true
-- end

local function createSprite(params)
	sprite = display.newSprite( params.parent, gImageSheets.aboya, structure.sequences )
	sprite.x, sprite.y = params.x, params.y
	physics.addBody( sprite, 'dynamic', {density=10, bounce=0, friction=1, filter=relations.playerBits, radius=20} )
	sprite.gravityScale = gravityScale
	sprite.isFixedRotation = true
	sprite.class = 'player'
	-- sprite.preCollision = preCollision
	-- sprite:addEventListener( 'preCollision' )
	return sprite
end

return function(params)
	local M = base(params)
	M.speed = mRatio
	M.go = createSprite(params)
	M.onLadder = false
	M:play('move')

	function M:moveLadder()
		self:pause()
		self:setSequence( 'ladder' )
		laderCounter = laderCounter + 1
		if laderCounter < 8 then
			self:setFrame(1)
		elseif laderCounter < 8 * 2 then
			self:setFrame(2)
		else
			laderCounter = 0
		end
	end

	function M:move(keys)
		local pos = {x=0, y=0}
		if keys.up > 0 and self.onLadder then
			pos.y = -self.speed * 0.5
			self:moveLadder()
		elseif keys.down > 0 and self.onLadder then
			pos.y = self.speed * 0.5
			self:moveLadder()
		end
		if keys.right > 0 then
			pos.x = self.speed
			M.go.xScale = 1
			if not self.onLadder then
				M:play('move')
				sound:effect2('aboyaWalk')
			end
		elseif keys.left > 0 then
			pos.x = -self.speed
			M.go.xScale = -1
			if not self.onLadder then
				M:play('move')
				sound:effect2('aboyaWalk')
			end
		end
		self.go.x = self.go.x + pos.x 
		self.go.y = self.go.y + pos.y 
	end

	function M:ladder(enable)
		self.onLadder = enable
		sprite.gravityScale = enable == true or 0 and gravityScale
		if not enable then
			self:setSequence( nil )
			self:play()
			laderCounter = 0
		end
	end

	return M
end