-- game.lua
local composer = require 'composer'
local scene = composer.newScene( )

local function getContentManager(sceneGroup)
	local function getNextLevelPath()
		local lvlPath = 
			publisher:get(PUBSUB_PARAMETERS).nextLevel or 
			storage:get(STORAGE_SELECTED_LEVEL)
	    publisher:put(nil, PUBSUB_PARAMETERS, {nextLevel=nil})
	    return lvlPath
	end

	local lvlPath = getNextLevelPath()
	local dotPath = GAME_LEVELS[utils.lastWord(lvlPath)] or DEFAULT_CONTENT_MANAGER
	contentManager = require(dotPath)
	contentManager:create(sceneGroup, lvlPath)
end

function scene:create(event)
	local sceneGroup = self.view
	getContentManager(sceneGroup)
end

function scene:show(event)
	local sceneGroup = self.view
	if event.phase == 'will' then
	elseif event.phase == 'did' then
		utils.removeScene('loader')
		contentManager:start()
	end
end

function scene:hide(event)
	if event.phase == 'will' then
		contentManager:pause()
	elseif event.phase == 'did' then
	end
end

function scene:destroy(event)
	logger.info('game scene has destroyed')
	contentManager:destroy()
	contentManager = nil
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )
return scene