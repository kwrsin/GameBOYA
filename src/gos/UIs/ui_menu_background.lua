-- ui_menu_background.lua
local adventures = {}
local ADV_WIDTH = 700
local ADV_NUM = 4
local SPEED = 2
local generator = require 'src.gos.base'

local function adventure(parent, x, y)
	return display.newImage( parent, 'assets/images/adventure.png', x, y )
end

local function band(parent, offsetX, y)
	local glogo = display.newGroup()
	glogo.x, glogo.y = parent.x, y
	parent:insert(glogo)
	for i=1,ADV_NUM do
		adventures[#adventures + 1] = 
			adventure(glogo, (i-1) * ADV_WIDTH + offsetX, 0)
	end
	return glogo
end

local function tile(parent, params)
	for i=1,6 do
		local offsetX = ((i-1) % 2 == 0 and ADV_WIDTH / 2 or 0 )
		-- a.x = a.x + diff
		local glogo = band(parent, offsetX, (i-1) * 220)
	end
	parent.y = parent.y - 460
	parent.rotation = 45
end

local function largeTiles(parent, params)
	local rect = display.newRect(parent, CX, CY, CW, CH)
	local group = display.newGroup()
	parent:insert(group)
	rect:setFillColor( 0.7, 0.7, 0 )
	tile(group, params)
end

local function enterFrame(event)
	for i, adventure in ipairs(adventures) do
		if adventure.x > ADV_WIDTH * (ADV_NUM - 1) + ADV_WIDTH / 2 then
			adventure.x = -ADV_WIDTH / 2
		else
			adventure.x = adventure.x + SPEED
		end
	end
end

return function(params)
	local M = generator(params)
	M.go = display.newGroup( )
	params.parent:insert(M.go)
	largeTiles(M.go, params)
	function M.update(obj, event)
		if event.value.onDestory then
			for i=#adventures,1,-1 do
				local obj = table.remove( adventures, i )
				obj = nil
			end
			Runtime:removeEventListener( 'enterFrame', enterFrame )
		end
	end

	Runtime:addEventListener( 'enterFrame', enterFrame )
	publisher:subscribe(PUBSUB_EVENT_MENU, M)
	return M
end