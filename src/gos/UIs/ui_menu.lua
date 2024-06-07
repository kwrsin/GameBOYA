-- ui_base.lua
local generator = require 'src.gos.base'

local function createTitle()
	local title = display.newText( 'Menu', 0, 0, native.systemFont, 24 )
	return uiLib:layout{
		background=display.newRect( 0, 0, display.actualContentWidth, 64),
		evenCols={
			title,
		},
		bgcolor={0.2, 0.2, 0.2, 0.8}		
	}
end


return function(params)
	local M = generator(params)
	function M:menu(params)
		M.go = uiLib:layout{
			parent=params.parent,
			evenRows={
				createTitle(),
				uiLib:createCustomButton{
					label=L('toTitle'),
					fn=function(event)
						contentManager:gotoNextLevel{nextLevel=string.format('%s.%s', DOT_STRUCTURES, INITIAL_LEVEL)}
					end
				},
				uiLib:createCustomButton{
					label=L('cameraTest'),
					fn=function(event)
						contentManager:gotoNextLevel{nextLevel=string.format('%s.%s', DOT_STRUCTURES, TEST_LEVEL)}
					end
				},
				uiLib:createCustomButton{
					label=L('hello'),
					fn=function(event)
						print('aaaadddddffff')
					end
				},
				uiLib:createCustomButton{
					label=L('hello'),
					fn=function(event)
						print('aaaadddddffff')
					end
				},
			},
			RowHeight=80
		}
	end
	M:menu(params)
	return M
end