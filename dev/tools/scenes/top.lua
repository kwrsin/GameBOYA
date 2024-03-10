local composer = require 'composer'
local scene = composer.newScene( )
local root = display.newGroup( )

local function createMenu(sceneGroup)
	root = display.newGroup( )
	sceneGroup:insert(root)
	local button = uiLib:createButton('DataMaker', 0, -120, function(event)
		if event.phase == 'ended' then
			utils.gotoDataMaker(options)
		end
	end)
	button.anchorX = 1
	root:insert(button)
	button = uiLib:createButton('Relations', 0, -0, function(event)
		if event.phase == 'ended' then
			print('Relations')
		end
	end)
	button.anchorX = 1
	root:insert(button)
	button = uiLib:createButton('GOS', 0, 120, function(event)
		if event.phase == 'ended' then
			print('GOS')
		end
	end)
	button.anchorX = 1
	root:insert(button)

	root.x = CX
	root.y = CY
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