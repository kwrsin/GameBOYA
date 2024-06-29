local params = require 'src.structures.gos.meta.actor_shadow'
local generator = require 'src.gos.actors.actor_base'
local racerGenerator = require 'src.gos.actors.actor_red_racer_custom'

return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)
	M.speed = 2
  M.go.gravityScale = 0
  M.go.onBank = nil
  M.go.bankHeight = 0


  function M:createRacer()
  	local params = M.params
  	local racerParams = {
			parent = params.parent,
			x = params.x,
			y = params.y,
  	}
  	M.racer = racerGenerator(racerParams)

  end
  M.createRacer()

-- [ OVERRIDED ] --
 	function M:getButtonStatus()
    utils.merge(buttonStatus, self.buttons)	
  end

  function M:finish()
  	self:setSequence( 'win' )
  end

-- [ COMMANDS ] --
  function M.commands:default()
  	self:_up()
  	self:_down()
  	self:_left()
  	self:_right()
  	self:_backDefault()
  	self:_mappingX()
  	self:_mappingY()
  	if self.go.onBank then
  		self.go.y = self.go.y -self.go.onBank:getBankHeightDelta(self.go)
  	end
  	self:_clumpTop()
  	self:_clumpBottom()
  end

  function M.commands:win()
  	self.racer:setSequence( 'finish' )
  	self:_left()
  	self:_right()
  	self:_mappingX()
  	self:_mappingY()
  end

-- [ MICRO COMMANDS ] --
	function M:_backDefault()
		if self.buttons.up <= 0 and self.buttons.down <= 0 then
			self.racer:play( 'default' )
		end
	end

	function M:_mappingX()
  	self.racer.go.x = self.go.x
	end

	function M:_mappingY()
  	self.racer.go.y = self.go.y
	end

  function M:_up()
  	if self.buttons.up > 0 then
  		self.vel.y = -1
    	self.go.y = 
    		self.go.y + self.vel.y * self.speed
    	self.racer:play( 'up' )
  	end
  end

  function M:_down()
  	if self.buttons.down > 0 then
  		self.vel.y = 1
    	self.go.y = 
    		self.go.y + self.vel.y * self.speed
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
    		self.go.x + self.vel.x * self.speed
  	-- end
  end

  function M:_clumpTop()
  	if self.go.y < CY - 42 - self.go.bankHeight then
  		self.go.y = CY - 42 - self.go.bankHeight
  	end
  end

  function M:_clumpBottom()
  	if self.go.y > CY + 100 - self.go.bankHeight then
  		self.go.y = CY + 100 - self.go.bankHeight
  	end
  end

	return M
end
