local params = require 'src.structures.gos.meta.wall_fence'
local generator = require 'src.gos.walls.wall_base'

return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = {}
	M.go = display.newGroup()
	local level = params.parent
	level:insert(M.go)
	for i=1,10 do
		params.parent = M.go
		local object = generator(params)
		object.go.x = object.go.x + (i - 1) * object.go.width
		M.go:insert(object.go)
	end

	return M
end
