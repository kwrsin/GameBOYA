-- ui_base.lua
local generator = require 'src.gos.groupBase'

return function(params)
	local M = generator(params)
	M:createObject(params)
	M.defaultStatus = params.default
	M.isUI=true
	return M
end