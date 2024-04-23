-- intermid.lua
local storage = require 'src.libs.storage'

local composer = require 'composer'
local scene = composer.newScene( )
local cBanner = ''

local function createCenterBanner(sceneGroup)
	cBanner = display.newText( sceneGroup, '', CX, CY, native.systemFont, 36 )
	cBanner:setFillColor( 1, 1, 1 )
end

local function createBackground(sceneGroup)
	local bg = display.newRect( sceneGroup, CX, CY, CW, CH )
	bg:setFillColor( 0, 0, 0 )
end

local function createContents(sceneGroup)
	createBackground(sceneGroup)
	createCenterBanner(sceneGroup)
end

local function update(event)
	local message = event.params.message or ''
	cBanner.text = string.format( '%s', message )
	timer.performWithDelay( event.params.time or 5000, function()
		utils.gotoScene( LOADER_SCENE )
	end )
end

function scene:create(event)
  logger.info(LABEL_INTERMID)
	local sceneGroup = self.view
	createContents(sceneGroup)
end

function scene:show(event)
	local sceneGroup = self.view
	if event.phase == 'will' then
		update(event)
	elseif event.phase == 'did' then
		utils.removeScene(GAME_SCENE)
	end
end

function scene:destroy(event)
	logger.info('intermid scene destroyed')
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'destroy', scene )

return scene