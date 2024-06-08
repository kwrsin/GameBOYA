local params = require 'src.structures.gos.meta.wallCube'
local generator = require 'src.gos.walls.wall_base'

return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)
	M.go.isSensor = true
	M.finished = false
	M.go.collision = function(self, event)
		if event.phase == 'began' then
			if not self.finished then
				self.finished = true
				contentManager:result()
			end
		end
	end
	M.go:addEventListener('collision')

	return M
end
