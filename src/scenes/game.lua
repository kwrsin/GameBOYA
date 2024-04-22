-- game.lua
local composer = require 'composer'
local scene = composer.newScene( )

function scene:create(event)
	local sceneGroup = self.view
	contentManager = getContentManager()
	contentManager:create(sceneGroup)
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