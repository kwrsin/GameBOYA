-- LevelMaker.lua
local composer = require 'composer'
local scene = composer.newScene( )
local levelCanvas = require 'dev.tools.scenes.parts.levelCanvas'

function scene:create(event)
	local sceneGroup = self.view
	levelCanvas:create(sceneGroup)
end

function scene:show(event)
	local sceneGroup = self.view
	if event.phase == 'will' then
		levelCanvas:show()
	elseif event.phase == 'did' then
	end
end

function scene:hide(event)
	if event.phase == 'will' then
	elseif event.phase == 'did' then
	end
end

function scene:destory(event)
	levelCanvas:destory()
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destory', scene )
return scene