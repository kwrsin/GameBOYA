local params = require 'src.structures.gos.meta.actor_shadow'
local generator = require 'src.gos.actors.actor_base'
local racerGenerator = require 'src.gos.actors.actor_red_racer_custom'

return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)
	M.speed = 4
	M.acceleration = 0
  M.go.gravityScale = 0
  M.go.onBank = nil
  M.go.bankHeight = 0
  M.go.onJump = false
  M.baseLineY = params.y
  sound:effect2('idle', {loops=-1, channel=3})


  function M:createRacer()
  	local params = M.params
  	local racerParams = {
			parent = params.parent,
			x = params.x,
			y = params.y,
			shadow = M,
  	}
  	M.racer = racerGenerator(racerParams)

  end
  M.createRacer()

  function M:getTorque()
  	local coef = 2
  	local vX = self.acceleration / 100
  	return coef * vX * vX
  end

-- [ OVERRIDED ] --
 	function M:getButtonStatus()
    utils.merge(buttonStatus, self.buttons)	
  end

  function M:finish()
  	self:setSequence( 'win' )
  end

  function M:subEnterFrame(event)
  	M.racer:enterFrame(event)
  end  

	function M.go:jump()
		if M.acceleration < 60 then return end
		self.onJump = true
		M:setSequence( 'jumping' )
		M.racer:jump(3)
	end


-- [ COMMANDS ] --
  function M.commands:default()
  	self:_up()
  	self:_down()
  	self:_left()
  	self:_right()
  	self:_axelUp()
  	self:_backDefault()
  	self:_setBankHeight()
  	self:_clumpTop()
  	self:_clumpBottom()
  	self:_move()
  end

  function M.commands:jumping()
   	self:_left()
  	self:_right()
  	self:_setBankHeight()
  	self:_clumpTop()
  	self:_clumpBottom()
  	self:_move()
  end

  function M.commands:win()
  	self.racer:setSequence( 'finish' )
  	self:_left()
  	self:_right()
  end

-- [ MICRO COMMANDS ] --
	function M:_move()
		self.go.y = self.baseLineY - self.go.bankHeight
	end

	function M:_setBankHeight()
  	if self.go.onBank then
  		self.go.bankHeight =
  			self.go.onBank:getBankHeightDelta(self.go)
  	end
	end

	function M:_backDefault()
		if self.buttons.up <= 0 and self.buttons.down <= 0 then
			self.racer:play( 'default' )
		end
	end

	function M:_axelUp()
		if self.buttons.btnA and self.buttons.btnA > 0 then
			self.acceleration = self.buttons.btnA
		else
			self.acceleration = self.acceleration - 1
			if self.acceleration <= 0 then
				self.acceleration = 0
			end
		end
	end

  function M:_up()
  	if self.acceleration <= 0 then return end
  	if self.buttons.up > 0 then
  		self.vel.y = -1
  		self.baseLineY = 
	  		self.baseLineY + self.vel.y * self.speed
    	self.racer:play( 'up' )
  	end
  end

  function M:_down()
  	if self.acceleration <= 0 then return end
  	if self.buttons.down > 0 then
  		self.vel.y = 1
  		self.baseLineY =
  			self.baseLineY + self.vel.y * self.speed
    	self.racer:play( 'down' )
  	end
  end

  function M:_left()
  	-- if self.buttons.left > 0 then
  	-- 	self.vel.x = -1
    -- 	self.go.x = 
    -- 		self.go.x + self.vel.x * self.speed
  	-- end	
  end

  function M:_right()
  	-- if self.buttons.right > 0 then
  		self.vel.x = 1
    	self.go.x = 
    		self.go.x + self.vel.x * self.speed * self:getTorque()
  	-- end
  end

  function M:_clumpTop()
  	if self.baseLineY < CY - 42 then
  		self.baseLineY = CY - 42
  	end
  end

  function M:_clumpBottom()
  	if self.baseLineY > CY + 100 then
  		self.baseLineY = CY + 100
  	end
  end

	return M
end
