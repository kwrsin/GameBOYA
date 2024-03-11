-- TestPubSub.lua
local widget = require 'widget'
local composer = require 'composer'
local scene = composer.newScene( )
local nameTB

local function showValue(key)
	value = publisher:get(key)
	for k, v in pairs(value) do
		print(string.format('%s = %s', k, v))
	end
end

local function test()
	local key = 'greetings'
	publisher:observe(key, {'hello', 'goodbye', 'thank you'})
	local obj1 = {name='ob1', update=function(obj, event)
		print('i am obj1')
		print(event.value[4])
	end}
	local obj2 = {name='ob2', update=function(obj, event)
		print('i am obj2')
		print(event.value[4])
	end}
	local obj3 = {name='ob3', update=function(obj, event)
		print('i am obj3')
		print(event.value[4])
	end}
	publisher:subscribe(key, obj1)
	publisher:subscribe(key, obj2)
	publisher:subscribe(key, obj3)
	local val = publisher:get(key)
	val[#val + 1] = 'ohayou'
	publisher:put(obj2, key, val)
	-- showValue(key)
	local subs = publisher:unsubscribe(key, obj1)
	-- local subs = publisher:unsubscribeAll()
	-- subs[1] = nil
	table.print(subs)
end


local key = 'month'
publisher:observe(key, {'jan', 'feb', 'mar'})

function scene:create(event)
	local sceneGroup = self.view
	-- test()
	nameTB = native.newTextField( 60, 100, 300, 32 )
	nameTB.anchorX = 0
	nameTB:addEventListener( "userInput", function(event)
		if ( event.phase == "ended" or event.phase == "submitted" ) then
			local v = publisher:get(key)
			v[#v + 1] = nameTB.text
			nameTB.text = ''
			nameTB.put(key, v)
		end
	end )
	nameTB.update = function(obj, event)
		nameTB.text = event.value[#event.value]
	end

	publisher:subscribe(key, nameTB)

	sceneGroup:insert(nameTB)
	local btn = uiLib:createButton('GOTO Sub', CX, 300, function(event)
		composer.gotoScene( 'dev.tools.scenes.tests.TestSub_Sub' )
	end)
	sceneGroup:insert(btn)
end

function scene:show(event)
	local sceneGroup = self.view
	if event.phase == 'will' then
	elseif event.phase == 'did' then
		nameTB.isVisible = true
	end
end

function scene:hide(event)
	if event.phase == 'will' then
	elseif event.phase == 'did' then
		nameTB.isVisible = false
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene