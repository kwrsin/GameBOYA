local composer = require 'composer'
local scene = composer.newScene( )
-- local root = display.newGroup( )

local function createTitle()
	local title = display.newText( 'Game Creator', 0, 0, native.systemFont, 24 )
	return uiLib:layout{
		background=display.newRect( 0, 0, display.actualContentWidth, HEADER_HEIGHT),
		evenCols={
			title,
		},
		bgcolor={1, 0, 0, 0.6}		
	}
end

local function createMenu(sceneGroup)
	uiLib:layout{
		parent=sceneGroup,
		evenRows={
			createTitle(),			
			uiLib:createButton('Data Maker', 0, 0, function(event)
				if event.phase == 'ended' then
					utils.gotoDataMaker(options)
				end
			end),
			uiLib:createButton('Relations', 0, 0, function(event)
				if event.phase == 'ended' then
					utils.gotoRelationsMaker(options)
				end
			end),	
			uiLib:createButton('Wall Maker', 0, 0, function(event)
				if event.phase == 'ended' then
					utils.gotoWallMaker()
				end
			end),				
			uiLib:createButton('Actor Maker', 0, 0, function(event)
				if event.phase == 'ended' then
					utils.gotoActorMaker()
				end
			end),				
		}
	}
end

function scene:create(event)
	local sceneGroup = self.view
	createMenu(sceneGroup)
end

function scene:show(event)
	local sceneGroup = self.view
	if event.phase == 'will' then
	elseif event.phase == 'did' then
	end
end

function scene:hide(event)
	if event.phase == 'will' then
	elseif event.phase == 'did' then
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene