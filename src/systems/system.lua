-- system.lua
local composer = require "composer"
local physics = require 'physics'
local uiLib = require 'src.libs.uiLib'

local function getContentBackground()
    local bg = display.newGroup()
    -- local r = display.newRect(bg, cx, cy, cw, ch)
    -- r:setFillColor(0, 0, 0)
    return bg
end

local function getContentForeground()
    local parent = display.newGroup()
    local imageSheet = 
				graphics.newImageSheet( 
					'assets/images/frame00.png', 
					{
						numFrames = 8, 
						height = 64, 
						width = 64,
						sheetContentHeight = 64, 
						sheetContentWidth = 8*64, 
					} )
		uiLib:nineslice{
			parent=parent,
			x=cx,
			y=cy,
			width=512,
			height=512,
			barsize=64,
			imageSheet=imageSheet,
		}
    virtualControlelr:createVirtualController(parent)
    virtualControlelr:createCursor({x=-cx, y=0}, function(cursor)
    	if not player then return end
      player:move(utils.toKeys(cursor))
    end)
		controller.keyInput(player, function(event, keys)
    	if not player then return end
      player:move(keys)
    end)

    return parent
end

physics.start()
system.activate( "multitouch" )
display.setDefault( "background", 0, 0, 1 )
display.getCurrentStage():insert(getContentBackground())
display.getCurrentStage():insert(composer.stage)
display.getCurrentStage():insert(getContentForeground())
