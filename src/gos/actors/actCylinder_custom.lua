local params = require 'src.structures.gos.meta.actCylinder'
local generator = require 'src.gos.actors.actor_base'

return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)
	M.speed = 1
  M.go.gravityScale = 0

 	function M:getButtonStatus()
    utils.merge(buttonStatus, self.buttons)  	
  end

-- [ COMMANDS ] --
  function M.commands:default()
  	self:_up()
  	self:_down()
  	self:_left()
  	self:_right()
  end

-- [ MICRO COMMANDS ] --
  function M:_up()
  	if self.buttons.up > 0 then
  		self.vel.y = -1
  	end
  	self.go.y = 
  		self.go.y + self.vel.y * self.speed
  end

  function M:_down()
  	if self.buttons.down > 0 then
  		self.vel.y = 1
  	end
  	self.go.y = 
  		self.go.y + self.vel.y * self.speed
  end

  function M:_left()
  	if self.buttons.left > 0 then
  		self.vel.x = -1
  	end	
  	self.go.x = 
  		self.go.x + self.vel.x * self.speed
  end

  function M:_right()
  	if self.buttons.right > 0 then
  		self.vel.x = 1
  	end
  	self.go.x = 
  		self.go.x + self.vel.x * self.speed
  end

	return M
end
