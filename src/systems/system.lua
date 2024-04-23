-- system.lua
local composer = require "composer"
local physics = require 'physics'
local uiLib = require 'src.libs.uiLib'

-- GLOBAL
function getContentManager()
	local key = 
		utils.lastWord(storage:get(STORAGE_SELECTED_LEVEL))
	local dotPath = GAME_LEVELS[key] or DEFAULT_CONTENT_MANAGER
	return require(dotPath)
end

function getText(key)
	return language[key] or key
end

-- FRONT COVER
local function getContentBackground()
    local bg = display.newGroup()
    -- local r = display.newRect(bg, CX, CY, CW, CH)
    -- r:setFillColor(0, 0, 0)
    return bg
end

local function gameGuyBody(parent)
	local top = display.newRect(parent, CX, -128, 640, 260)
	top:setFillColor( 0, 0, 0 )
	top.anchorY = 0
	local buttom = display.newRect(parent, CX, CH + 160, 640, 320)
	buttom:setFillColor( 0, 0, 0 )
	buttom.anchorY = 1
    local img = display.newImageRect(parent, 'assets/images/gameguy.png', 648, 1264)
    img.x = CX
    img.y = CY + 64
end

local function testFrameBody(parent)
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
		x=CX,
		y=CY,
		width=512,
		height=512,
		barsize=64,
		imageSheet=imageSheet,
	}
end

local function getContentForeground()
    local parent = display.newGroup()
	
	-- testFrameBody(parent)
	-- gameGuyBody(parent)

    virtualControlelr:createVirtualController(parent)
    virtualControlelr:createCursor({x=VC_POS.x, y=VC_POS.y}, function(cursor)
    	if not player then return end
    	if player.disabled then return end
    	local keys = utils.toKeys(cursor)
    	-- buttonStatus.up = keys.up
    	-- buttonStatus.down = keys.down
    	-- buttonStatus.right = keys.right
    	-- buttonStatus.left = keys.left
    end)
    virtualControlelr:createButton({x=VBA_POS.x, y=VBA_POS.y}, function(button)
        if not player then return end
    	if player.disabled then return end
    	-- buttonStatus.btnA = button.counter
    end)
	controller.keyInput(player, function(event, keys)
    	if not player then return end
    	if player.disabled then return end
    	buttonStatus.up = keys.up
    	buttonStatus.down = keys.down
    	buttonStatus.right = keys.right
    	buttonStatus.left = keys.left
    	buttonStatus.btnA = keys.space
    end)

    return parent
end

math.randomseed( os.time() )
physics.start()
system.activate( "multitouch" )
display.setDefault( "background", 0, 0, 1 )
display.getCurrentStage():insert(getContentBackground())
display.getCurrentStage():insert(composer.stage)
display.getCurrentStage():insert(getContentForeground())
