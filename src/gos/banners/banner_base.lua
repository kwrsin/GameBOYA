-- banner_base.lua
local generator = require 'src.gos.base'

return function(params)
	local M = generator(params)

	function M:createBanner(params)
	end

	function M:apply(params)
		M:createBanner(params)
		M:setProperties(params)
	end
	return M
end