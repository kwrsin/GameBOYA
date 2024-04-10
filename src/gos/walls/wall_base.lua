-- wall_base.lua
local generator = require 'src.gos.base'

return function(params)
	local M = generator(params)
	M.go = M:createImage(params)

	return M
end