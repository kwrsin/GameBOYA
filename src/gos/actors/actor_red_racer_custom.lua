local params = require 'src.structures.gos.meta.actor_red_racer'
local generator = require 'src.gos.actors.actor_base'

return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)
	M.go.isSensor = true
	M.go.gravityScale = 0
	M:play()

	return M
end
