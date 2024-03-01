-- game.lua
local composer = require 'composer'
local scene = composer.newScene( )

function scene:create(event)
	local sceneGroup = self.view
	content:create(sceneGroup, function()
		utils.gotoScene('intermid')
	end)
end

function scene:show(event)
	local sceneGroup = self.view
	if event.phase == 'will' then
	elseif event.phase == 'did' then
		utils.removeScene('loader')
		content:start()
	end
end

function scene:hide(event)
	if event.phase == 'will' then
		content:pause()
	elseif event.phase == 'did' then
	end
end

function scene:destroy(event)
	print('game scene has destroyed')
	content:destroy()
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )
return scene