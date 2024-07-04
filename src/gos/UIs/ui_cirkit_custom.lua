-- ui_cirkit_custom.lua
local params = require 'src.structures.gos.meta.ui_meta'
local generator = require 'src.gos.UIs.ui_base'
local guageGenerator = require 'src.libs.guage'

local len = 10

return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)
	physics.removeBody(M.go)

	function M:createSubObjects(params)
		local function create9Slice(params)
			local frameWidth = 460
			local frameHeight = 120
			local bg = display.newRect( self.go, 0, 0, frameWidth - 2 + 32, frameHeight - 2 + 32 )
			bg:setFillColor( 0, 0, 0, 0.8 )
			uiLib:nineslice{
				parent=M.go,
				x = 0,
				y = 0,
				imageSheet = gImageSheets.cirkit_9slice,
				barsize=16,
				width=frameWidth,
				height=frameHeight,
			}
		end

		local function createGuage(params)
			M.guage = guageGenerator{
				parent=M.go,
				x = 0,
				y = 0,
				length = len,
				bar={
					fgcolor={1, 0, 0},
					bgcolor={0.2, 0.3, 0.4},
					width=5,
					height=20,
					padding=2,
					radius=30,
				},
			}
			M.guage:setValue(0)

		end

		create9Slice(params)
		createGuage(params)
	end

	function M:subEnterFrame(event)
		if player then
			M.guage:setValue(player.acceleration / 300)
		end
	end

	M:createSubObjects(params)
	return M
end