-- playgournd.lua
physics.start()
physics.setDrawMode( 'hybrid' )

local composer = require 'composer'
local scene = composer.newScene( )
local gen_actor22 = require('src.gos.actors.actor22_custom')
gImageSheets = {}

local function content( sceneGroup )
	local st_aboya = require('src.structures.gos.aboya')
	gImageSheets.aboya = graphics.newImageSheet( st_aboya.path, st_aboya.sheetParams )
	local obj = gen_actor22{parent=sceneGroup, x=CX, y=CY}

end

function scene:create(event)
	local sceneGroup = self.view
	content(sceneGroup)
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