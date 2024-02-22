-- green.lua
local base = require 'src.gos.base'

return function(params)
	local M = base(params)
	M.go = display.newImageRect(params.parent, 'assets/images/platforms2groundgreen.png', 4096, 4096)
  M.go.anchorX, M.go.anchorY = 0, 0

	return M
end