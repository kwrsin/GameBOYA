local params = require 'src.structures.gos.meta.my_examples'
local generator = require 'src.gos.walls.wall_base'

return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)
	transition.loop(M.go, {xScale=1.2, yScale=1.2, iterations=0, time=500, tag=TAG_TRANSITION})

	return M
end
