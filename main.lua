-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
--[ Game Main ]
-- require 'src.systems.global'

--[ Development Tools ]
-- require 'dev.tools.systems.global' 

--[ REPL SCRACHPAD ]
require 'REPL.systems.global'

local textHelper = require ('src.libs.UIHelpers.text_helper')


local th = textHelper()
th:create{
	charWidth=20,
	charHeight=26,
	maxLength=20,
	x=60,
	y=display.contentCenterY,
	chars=utils.toChars('abcd'),
	editable=true,
}

local th2 = textHelper()
th2:create{
	charWidth=20,
	charHeight=26,
	maxLength=20,
	x=60,
	y=display.contentCenterY + 100,
	chars=utils.toChars(''),
	editable=true,
}

local onShiftKey = false
Runtime:addEventListener( 'key', function(event)
	if event.phase == 'up' then
		if event.keyName == 'right' then
			th:next()
			th2:next()
		elseif event.keyName == 'left' then
			th:back()
			th2:back()
		elseif event.keyName == 'deleteBack' or event.keyName == 'Delete' then
			th:backspace()
			th2:backspace()
		elseif event.keyName == 'tab' then
			th:blur()
			th2:blur()
		elseif event.keyName == 'leftShift' or event.keyName == 'rightShift' then
			onShiftKey = false
		elseif #event.keyName == 1 and string.match( event.keyName, '[0-9a-zA-Z+-]+' ) then
			local keyName = event.keyName
			if onShiftKey then keyName = string.upper( keyName ) end
			th:input(utils.toChars(keyName)[1])
			th2:input(utils.toChars(keyName)[1])
		end
	elseif event.phase == 'down' then
		if event.keyName == 'leftShift' or event.keyName == 'rightShift' then
			onShiftKey = true
		end
	end
end )
