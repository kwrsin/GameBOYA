local base = require 'src.gos.base'
local relations = require 'src.structures.relations'
local go

local function collision(self, event)
	if event.phase == 'began' then
		sound:stop()
		player:walk(go.x, function()
			sound:effect('lblclear')
			timer.performWithDelay( 1000, function(e)
				content:result()
			end, 1 )
		end)
	end
end

local function createGameObject(params)
	go = display.newRect( params.parent, 0, 0, 60, 40 )
	physics.addBody( go, 'static', {
		isSensor=true, 
		filter=relations.wallBits, 
	} )
	go.collision = collision
	go:addEventListener( 'collision' )
	go.alpha = 0
	return go
end

return function(params)
	local M = base(params)
	M.go = createGameObject(params)
	return M
end