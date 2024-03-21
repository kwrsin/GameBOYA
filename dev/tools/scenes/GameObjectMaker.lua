-- GameObjectMaker.lua
local composer = require 'composer'
local scene = composer.newScene( )
-- local graphGen = require 'dev.tools.scenes.parts.graph'
local canvas = require 'dev.tools.scenes.parts.canvas'


function scene:create(event)
	local sceneGroup = self.view
	-- graphGen{parent=sceneGroup}
	canvas:create{parent=sceneGroup}
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
