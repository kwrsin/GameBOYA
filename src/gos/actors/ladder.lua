-- ladder.lua
local base = require 'src.gos.base'
local relations = require 'src.structures.relations'
local group

local function createImage(params)
	group = display.newGroup( )
	params.parent:insert(group)
	group.x, group.y = params.x, params.y
	local ite = params.iterations or 4
	local heightAmount = 0
	local objectHeight = 30
	for i=1,ite do
		local img = display.newImage( 
			group, 
			gImageSheets.ladder, 
			1, 
			0, (i - 1) * -objectHeight )
		heightAmount = heightAmount + objectHeight
	end
	physics.addBody( group, 'static', {
		isSensor=true, 
		filter=relations.wallBits, 
		box={halfWidth=5, halfHeight=heightAmount/ 2, x=0, y=-heightAmount/2 + objectHeight / 2}} )
	
	group.collision = function(self,event)
		if player then
			if event.other.class == 'player' then return 
				player:message({onLadder=event.phase == 'began' or true and false})
			end
		end
	end
	group:addEventListener( 'collision')
	group.class = 'ladder'
	return group
end

return function(params)
	local M = base(params)
	M.go = createImage(params)

	return M
end