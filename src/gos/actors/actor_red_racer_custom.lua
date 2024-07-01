local params = require 'src.structures.gos.meta.actor_red_racer'
local generator = require 'src.gos.actors.actor_base'

return function(options)
	local shadow = options.shadow
	options.shadow = nil
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)
	M.go.isSensor = true
	M.go.gravityScale = 0
	M.shadow = shadow
	M:play()

	function M:jump(ratio)
		self:setSequence( 'jumping' )
		self.verticalDumping = self.shadow.speed * ratio
		self.direction = -1
		sound:effect2( 'jump' )
	end

-- [ COMMANDS ] --
  function M.commands:default()
  	self:_mappingX()
  	self:_mappingY()  	
  end

  function M.commands:up()
  	self:_mappingX()
  	self:_mappingY()  	
	end  

  function M.commands:down()
  	self:_mappingX()
  	self:_mappingY()  	
	end  

  function M.commands:finish()
  	self:_mappingX()
  	self:_mappingY()  	
	end  

	function M.commands:jumping()
		self:_mappingX()
		self:_mappingJump()
	end

-- [ MICRO COMMANDS ] --
	function M:_mappingX()
		self.go.x = self.shadow.go.x
	end

	function M:_mappingY()
		self.go.y = self.shadow.go.y
	end

	function M:_mappingJump()
		self.go.y = self.go.y + self.verticalDumping * self.direction
		self.verticalDumping = self.verticalDumping + self.direction
		if self.verticalDumping < 0 and self.direction < 0 then
			self.direction =  1
		end
		if self.go.y >= self.shadow.go.y then
			if self.verticalDumping > 15 then
				self:jump(4)
			elseif self.verticalDumping > 5 then
				self:jump(2)
			else
				self.go.y = self.shadow.go.y
				self.verticalDumping = 0
				self.shadow.go.onJump = false
				self:setSequence( 'default' )
				self.shadow:setSequence( 'default' )
			end			
		end
	end

	return M
end
