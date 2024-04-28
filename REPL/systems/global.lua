-- global.lua

require 'src.systems.debug'
logger = require 'src.systems.logger'
utils = require 'src.libs.utils' 
require 'REPL.systems.system'

--[[ SCRATCHPAD]]--

local textHelper = require ('src.libs.UIHelpers.text_helper')

local th = textHelper()
th:create{
	charWidth=20,
	charHeight=26,
	maxLength=20,
	x=60,
	y=display.contentCenterY,
	chars=utils.toChars(L('hello')),
	editable=true,
}

local th2 = textHelper()
th2:create{
	charWidth=16,
	charHeight=26,
	maxLength=7,
	x=60,
	y=display.contentCenterY + 100,
	chars=utils.toChars(''),
	editable=true,
}

local onShiftKey = false
local onCtrl = false
Runtime:addEventListener( 'key', function(event)
	if event.phase == 'up' then
		if event.keyName == 'right' then
			if onShiftKey then
				th:upscale()
				th2:upscale()
			else
				th:next()
				th2:next()
			end
		elseif event.keyName == 'left' then
			if onShiftKey then
				th:downscale()
				th2:downscale()
			else
				th:back()
				th2:back()
			end
		elseif event.keyName == 'deleteBack' or event.keyName == 'Delete' then
			th:backspace()
			th2:backspace()
		elseif event.keyName == 'tab' then
			th:blur()
			th2:blur()
		elseif event.keyName == 'leftShift' or event.keyName == 'rightShift' then
			onShiftKey = false
		elseif event.keyName == 'leftCtrl' or event.keyName == 'rightCtrl' or
						event.keyName == 'leftCommand' or event.keyName == 'rightCommand' then
			onCtrl = false
		elseif #event.keyName == 1 and string.match( event.keyName, '[0-9a-zA-Z+-]+' ) then
			if onCtrl and event.keyName == 'c' then
				local result = th:copy()
				logger.info(result)
				onCtrl = false
				return
			elseif onCtrl and event.keyName == 'v' then
				th:paste(utils.toChars('PA123456789'))
				onCtrl = false
				return
			elseif onCtrl and event.keyName == 'x' then
				logger.info(th:cut())
				onCtrl = false
				return
			elseif onCtrl and event.keyName == 'a' then
				th:selectAll()
				onCtrl = false
				return
			end

			local keyName = event.keyName
			if onShiftKey then keyName = string.upper( keyName ) end
			th:input(utils.toChars(keyName)[1])
			th2:input(utils.toChars(keyName)[1])
		end
	elseif event.phase == 'down' then
		if event.keyName == 'leftShift' or event.keyName == 'rightShift' then
			onShiftKey = true
		elseif event.keyName == 'leftControl' or event.keyName == 'rightControl' or
						event.keyName == 'leftCommand' or event.keyName == 'rightCommand' then
			onCtrl = true
		end
	end
end )


--[[ TASKS

- MUTTILINE
	- BACKGROUND
	- SELECTION
	- CURSOR
	- DELETE
	- INSERT
	- CTRL-A/V/C/X
- INVENTORYBOX
	- BTNMAKER
- SCALABLE GRAPH
- 9SLICE MAKER

]]--
