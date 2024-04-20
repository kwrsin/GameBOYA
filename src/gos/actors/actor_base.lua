-- actor_base.lua
local generator = require 'src.gos.base'

return function(params)
	local M = generator(params)
	M:createSprite(params)
	M.defaultStatus = params.default
	M.isActor=true
	return M
end