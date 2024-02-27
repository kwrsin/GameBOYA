-- walls01.lua
local base = require 'src.gos.base'
local relations = require 'src.structures.relations'

return function(params)
	local M = base(params)
	local collision = params.collision
	M.go = display.newImageRect( params.parent, params.imageSheet, params.index, params.width, params.height )
	if collision and collision.objects and #collision.objects > 0 then
		local paramList = {}
		for i, object in ipairs(collision.objects) do
			local vertex = object
			if vertex.shape == 'polygon' then
				local vertices = {}
				local origin = vertex.polygon[1]
				for i, v in ipairs(vertex.polygon) do
					vertices[#vertices + 1] = v.x - origin.x + vertex.x - params.width / 2
					vertices[#vertices + 1] = v.y + origin.y + vertex.y - params.height / 2
				end
				paramList[#paramList + 1] = {density=1.0, friction=0, bounce=0, filter=relations.wallBits,shape=vertices}		

			elseif vertex.shape == 'rectangle' then
				local box = {halfWidth=vertex.width / 2, halfHeight=vertex.height / 2, x=vertex.x * -1, y=vertex.y * -1}
				paramList[#paramList + 1] = {density=1.0, friction=0, bounce=0, filter=relations.wallBits,box=box}
			end
		end
		if #paramList > 0 then
			physics.addBody( M.go, 'static',  unpack(paramList))
		end
		-- local vertex = collision.objects[1]
		-- if vertex.shape == 'polygon' then
		-- 	local vertices = {}
		-- 	local origin = vertex.polygon[1]
		-- 	for i, v in ipairs(vertex.polygon) do
		-- 		vertices[#vertices + 1] = v.x - origin.x + vertex.x - params.width / 2
		-- 		vertices[#vertices + 1] = v.y + origin.y + vertex.y - params.height / 2
		-- 	end
		-- 	physics.addBody( M.go, 'static', {density=1.0, friction=0, bounce=0, filter=relations.wallBits,shape=vertices} )			

		-- elseif vertex.shape == 'rectangle' then
		-- 	local box = {halfWidth=vertex.width / 2, halfHeight=vertex.height / 2, x=vertex.x * -1, y=vertex.y * -1}
		-- 	physics.addBody( M.go, 'static', {density=1.0, friction=0, bounce=0, filter=relations.wallBits,box=box} )
		-- end
	else
		physics.addBody( M.go, 'static', {density=1.0, friction=0, bounce=0, filter=relations.wallBits} )
	end

	return M
end
