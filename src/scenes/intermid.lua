-- intermid.lua
local storage = require 'src.libs.storage'

local composer = require 'composer'
local scene = composer.newScene( )
local cBanner = ''

local function createCenterBanner(sceneGroup)
	cBanner = display.newText( sceneGroup, '', cx, cy, native.systemFont, 36 )
	cBanner:setFillColor( 1, 1, 1 )
end

local function createBackground(sceneGroup)
	local bg = display.newRect( sceneGroup, cx, cy, cw, ch )
	bg:setFillColor( 0, 0, 0 )
end

local function createContents(sceneGroup)
	createBackground(sceneGroup)
	createCenterBanner(sceneGroup)
end

local function update()
	local levelName = storage:get('levelName', 'none')
	cBanner.text = string.format( 'go to %s', levelName )
	timer.performWithDelay( 5000, function()
		utils.gotoScene( loader_scene )
	end )
end

function scene:create(event)
	local sceneGroup = self.view
	createContents(sceneGroup)
end

function scene:show(event)
	local sceneGroup = self.view
	if event.phase == 'will' then
		update()
	elseif event.phase == 'did' then
		utils.removeScene(game_scene)
	end
end

function scene:destroy(event)
	logger.info('intermid scene destroyed')
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'destroy', scene )

return scene