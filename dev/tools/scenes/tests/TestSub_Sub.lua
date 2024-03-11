-- TestSub_Sub.lua
local composer = require 'composer'
local scene = composer.newScene( )
local key = 'month'
local alphabetTB
function scene:create(event)
	local sceneGroup = self.view
	alphabetTB = native.newTextField( 60, 180, 300, 32 )
	alphabetTB.anchorX = 0
	alphabetTB:addEventListener( "userInput", function(event)
		if ( event.phase == "ended" or event.phase == "submitted" ) then
			local v = alphabetTB.get()
			v[#v + 1] = alphabetTB.text
			alphabetTB.text = ''
			alphabetTB.put(v)
		end
	end )
	alphabetTB.update = function(obj, event)--1 updator
		alphabetTB.text = event.value[#event.value]
	end
	local v = publisher:get(key)
	alphabetTB.text = v[#v]-- 2 the scene not instantiated yet
	publisher:subscribe(key, alphabetTB) --3 become a subscriver

	sceneGroup:insert(alphabetTB)
	local btn = uiLib:createButton('GOTO TestPubSub', CX-100, 300, function(event)
		composer.gotoScene( 'dev.tools.scenes.tests.TestPubSub' )
	end)
	sceneGroup:insert(btn)
end

function scene:show(event)
	local sceneGroup = self.view
	if event.phase == 'will' then
		alphabetTB.isVisible = true
	elseif event.phase == 'did' then
	end
end

function scene:hide(event)
	if event.phase == 'will' then
		alphabetTB.isVisible = false
	elseif event.phase == 'did' then
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene