-- player.lua
local base = require 'src.gos.base'
local structure = require 'src.structures.gos.aboya'
local relations = require 'src.structures.relations'
local sprite
local gravityScale = 1
local ladderCounter = 0

local function createSprite(params)
	sprite = display.newSprite( params.parent, gImageSheets.aboya, structure.sequences )
	sprite.x, sprite.y = params.x, params.y
	physics.addBody( sprite, 'dynamic', {density=1, bounce=0, friction=1, filter=relations.playerBits, radius=20} )
	sprite.gravityScale = gravityScale
	sprite.isFixedRotation = true
	sprite.class = 'player'
	
	return sprite
end


return function(params)
	local M = base(params)
	M.speed = mRatio
	M.go = createSprite(params)
	M.defaultStatus = 'move'
	-- M:play('move')


  function M:getButtonStatus()
    utils.merge(buttonStatus, self.buttons)  	
  end

-- ACTIONS

	function M:_animLadder()
		ladderCounter = ladderCounter + 1
		if ladderCounter < 8 then
			self:setFrame(1)
		elseif ladderCounter < 8 * 2 then
			self:setFrame(2)
		else
			ladderCounter = 0
		end
		sound:effect2('aboyaLadder')
	end

	function M:_right()
		self.vel.x = 1
		if self.buttons.right > 0 then
			M.go.x = M.go.x + M.speed * self.vel.x
			self.go.xScale = 1
			self:play('move')
			sound:effect2('aboyaWalk')
		end
	end

	function M:_left()
		self.vel.x = -1
		if self.buttons.left > 0 then
			M.go.x = M.go.x + M.speed * self.vel.x
			self.go.xScale = -1
			self:play('move')
			sound:effect2('aboyaWalk')
		end
	end

	function M:_jump()
		if self.buttons.btnA == 1 then
			self:play('jump')
			sound:effect('aboyaJump')
			self.delay = 10
			self.go:applyLinearImpulse( 0, -8, self.go.x, self.go.y )
		end
	end

	function M:_jumpright()
		self.vel.x = 1
		if self.buttons.right > 0 then
			M.go.x = M.go.x + M.speed * self.vel.x
			self.go.xScale = 1
		end
	end

	function M:_jumpleft()
		self.vel.x = -1
		if self.buttons.left > 0 then
			M.go.x = M.go.x + M.speed * self.vel.x
			self.go.xScale = -1
		end
	end

	function M:_onFloor()
		if self.delay == 0 and self:raycast('floor') then
			self:play(self.defaultStatus)
		end
	end

	function M:_onLadder()
		if self.delay == 0 and self.messages.onLadder then
			self:play('ladder')
			self:pause()
			self.go.gravityScale = 0
			self.go:setLinearVelocity(0, 0)
		end
	end

	function M:_ladderright()
		self.vel.x = 1
		if self.buttons.right > 0 then
			self.go.x = self.go.x + self.speed * self.vel.x * 0.5
	  	self:_animLadder()
		end
	end

	function M:_ladderleft()
		self.vel.x = -1
		if self.buttons.left > 0 then
			self.go.x = self.go.x + self.speed * self.vel.x * 0.5
			self:_animLadder()
		end
	end

	function M:_ladderup()
		self.vel.y = -1
		if self.buttons.up > 0 then
			self.go.y = self.go.y + self.speed * self.vel.y * 0.5
			self:_animLadder()
		end
	end

	function M:_ladderdown()
		self.vel.y = 1
		if self.buttons.down > 0 then
			self.go.y = self.go.y + self.speed * self.vel.y * 0.5
			self:_animLadder()
		end
	end

	function M:_onUnLadder()
		if not self.messages.onLadder then
			self:play(self.defaultStatus)
			self.go.gravityScale = gravityScale
			laderCounter = 0
		end
	end

	function M:_ladderjump()
		if self.buttons.btnA == 1 then
			self.go.gravityScale = gravityScale
			laderCounter = 0
			self:play('jump')
			sound:effect('aboyaJump')
			self.delay = 10
			self.go:applyLinearImpulse( 0, -8, self.go.x, self.go.y )
		end
	end



-- UPDATE STATUS
  function M:move()
  	self:_right()
  	self:_left()
  	self:_jump()
  	self:_onLadder()
  end
  function M:jump()
  	self:_jumpright()
  	self:_jumpleft()
  	self:_onFloor()
  	self:_onLadder()
  end
  function M:ladder()
  	self:_ladderright()
  	self:_ladderleft()
  	self:_ladderup()
  	self:_ladderdown()
  	self:_ladderjump()
  	self:_onUnLadder()
  end
  function M:damage()
  end
  function M:win()
  end
  function M:lose()
  end
  M.commands.move = M.move
  M.commands.jump = M.jump
  M.commands.ladder = M.ladder
  M.commands.damage = M.damage
  M.commands.win = M.win
  M.commands.lose = M.lose
  M:addEventListeners()
	return M
end