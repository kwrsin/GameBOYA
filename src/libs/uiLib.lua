-- uiLib.lua
local widget = require 'widget'

local M = {}

function M:createButton(title, x, y, onEvent)
	local button = widget.newButton( {
		left=x,
		top=y,
		id=title,
		label=title,
		onEvent=onEvent
	} )
	-- group:insert(button)
	return button
end

return M