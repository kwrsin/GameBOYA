-- ui_base.lua
local generator = require 'src.gos.base'

return function(params)
	local M = generator(params)
	function M:menu(params)
		M.go = uiLib:layout{
			parent=params.parent,
			evenRows={
				display.newText( L('hello'), 0, 0, native.systemFont, 34 ),
				display.newText( 'CCCC', 0, 0, native.systemFont, 34 ),
				display.newText( 'DDDD', 0, 0, native.systemFont, 34 ),
			}
			,bgcolor={1, 0, 0, 0.6}	
		}
	end
	M:menu(params)
	return M
end