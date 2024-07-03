local params = require 'src.structures.gos.meta.wall_bankA'
local generator = require 'src.gos.walls.wall_base'

return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)
	M.go.isSensor = true
	M.go.collision = function(self, event)
		if event.phase == 'began' then
			if event.other.class == 'actor_shadow' then
				event.other.onBank = event.target
				event.other.bankHeight = 0
			end
		elseif event.phase == 'ended' then
			if event.other.class == 'actor_shadow' then
				event.other.onBank = nil
				-- event.other.bankHeight = 0
			end
		end
	end
	M.go:addEventListener( 'collision' )
	-- function M:getBankInfo(shadow)
	-- 	return {
	-- 		x=self.go.x,
	-- 		width=self.go.width,
	-- 		height=34,
	-- 		up=0,
	-- 		top=64,
	-- 		down=32,
	-- 		grad=1.4,
	-- 	}
	-- end
  function M.go:getBankHeightDelta(shadow)
  	local rightEdge = self.x + self.width / 2
  	local colHalfWidth = 12
  	local grad = 1.4
  	local diff = rightEdge - shadow.x - colHalfWidth
  	if diff > 0 then
  		if diff > 64 then
  			return -(diff - 64 - 32) * grad
  		elseif diff > 32 then
  			if not shadow.onJump then
  				shadow:jump()
  			end
				return 32
  		else
  			return -(-diff * grad)
  		end
  	end
		return 0
  end

	return M
end
