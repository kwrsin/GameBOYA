-- player.lua
local base = require 'src.gos.base'
local structure = require 'src.structures.gos.aboya'
local relations = require 'src.structures.relations'
local sprite
local gravityScale = 1
local laderCounter = 0

local function onFloor(x)
	local hits = physics.rayCast( 
		sprite.x + x, 
		sprite.y, 
		sprite.x + x, 
		sprite.y + sprite.height / 2 + 1, 
		"closest" )
  if hits then
    local hitFirst = hits[1]
    local class = hitFirst.object.class
    if class == 'floor' then
    	return true
    end
  end
	return false
end

local function enterFrame(event)
	sprite.onFloor = false
  local left = onFloor(-sprite.width / 2)
  local center = onFloor(0)
  local right = onFloor(sprite.width / 2)
  if left or right or center then 
  	sprite.onFloor = true
  end
end

local function createSprite(params)
	sprite = display.newSprite( params.parent, gImageSheets.aboya, structure.sequences )
	sprite.x, sprite.y = params.x, params.y
	physics.addBody( sprite, 'dynamic', {density=10, bounce=0, friction=1, filter=relations.playerBits, radius=20} )
	sprite.gravityScale = gravityScale
	sprite.isFixedRotation = true
	sprite.class = 'player'
	Runtime:addEventListener( 'enterFrame', enterFrame )
	return sprite
end

return function(params)
	local M = base(params)
	M.speed = mRatio
	M.go = createSprite(params)
	M.go.onFloor = false
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
		sound:effect2('aboyaLadder')
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
			if not self.onLadder and self.go.onFloor then
				M:play('move')
				sound:effect2('aboyaWalk')
			end
		elseif keys.left > 0 then
			pos.x = -self.speed
			M.go.xScale = -1
			if not self.onLadder and self.go.onFloor then
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

	function M:walk(x, complete)
		if self.disabled then return end
		self:disable()

		local direction = x - sprite.x
		local keys = {}
		keys.up, keys.down, keys.right, keys.left = 0, 0, 0, 0
		if direction > 0 then
			keys.right = self.speed
		elseif direction < 0 then
			keys.left = self.speed
		end
		local count = math.round(math.abs(direction / self.speed))
		if count < 0 then 
			if complete then
				complete()
			end
			return 
		end
		timer.performWithDelay( 20, function(event)
			player:move(keys)
			if event.count == count then
				if complete then
					complete()
				end
			end
		end,  count )
	end

  function M:disable()
		Runtime:removeEventListener( 'enterFrame', enterFrame )
    self.disabled = true
  end


	return M
end