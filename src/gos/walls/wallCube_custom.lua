local params = require 'src.structures.gos.meta.wallCube'
local generator = require 'src.gos.walls.wall_base'

return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)

	return M
end
