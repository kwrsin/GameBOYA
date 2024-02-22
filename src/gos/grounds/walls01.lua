-- walls01.lua
local base = require 'src.gos.base'
local relations = require 'src.structures.relations'

return function(params)
	local M = base(params)
	M.go = display.newImageRect( params.parent, params.imageSheet, params.index, params.width, params.height )
	physics.addBody( M.go, 'static', {density=1.0, friction=0, bounce=0, filter=relations.wallBits,} )

	return M
end
