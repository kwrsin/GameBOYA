-- graph.lua
local GRAPH_SIZE = 300
local GRAPH_GRID_SIZE = 50
local MAX_WIDTH = GRAPH_SIZE
local MAX_HEIGHT = GRAPH_SIZE
local CENTER_X = GRAPH_SIZE / 2
local CENTER_Y = GRAPH_SIZE / 2
local INIT_X = -math.round(CENTER_X - ACW / 2)
local INIT_Y = -math.round(CENTER_Y - ACH / 2) + 1
local scaleRatio = 1.0
local offsetX = 0
local offsetY = 0

local function createGrid(params)
	local grid = {}
	local gridObject = display.newGroup( )
	params.root:insert(gridObject)
	grid.gridObject = gridObject
	grid.size = GRAPH_GRID_SIZE
	grid.rows = {}
	grid.cols = {}

	-- grid.circ = nil
	-- grid.rect = nil
	-- grid.render = function()
	-- 	local tex = graphics.newTexture( { type="canvas", width=ACW, height=ACH } )
	-- 	if grid.circ then
	-- 		display.remove( grid.circ )
	-- 		grid.circ = nil
	-- 		-- print('remove circ')
	-- 	end
	-- 	if grid.rect then
	-- 		display.remove(grid.rect)
	-- 		grid.rect = nil
	-- 		-- print('remove rect')
	-- 	end
		 
	-- 	-- if not grid.rect then -- can not reuse that
	-- 		grid.rect = display.newImageRect(
	-- 		    tex.filename,
	-- 		    tex.baseDir,
	-- 		    ACW,
	-- 		    ACH
	-- 		)
	-- 	-- else
	-- 	-- 	print('grid')
	-- 	-- end
	-- 	grid.rect.x = display.contentCenterX
	-- 	grid.rect.y = display.contentCenterY
	-- 	grid.circ = display.newCircle( 0, 0, 64 * scaleRatio )
	-- 	grid.circ:setFillColor( { type="gradient", color1={0,0.2,1}, color2={0.8,0.8,0.8}, direction="down" } )
	-- 	tex:draw( grid.circ )
	-- 	tex:invalidate()

	-- 	tex:releaseSelf( )
	-- end

	grid.create = function()
		local tex = graphics.newTexture( { type="canvas", width=ACW, height=ACH } )
		if grid.rect then
			display.remove(grid.rect)
			grid.rect = nil
		end
		if #grid.cols > 0 then
			for i, col in ipairs(grid.cols) do
				display.remove( col )
				col = nil
			end
		end
		if #grid.rows > 0 then
			for i, row in ipairs(grid.rows) do
				display.remove( row )
				row = nil
			end
		end

		grid.rect = display.newImageRect(
			    tex.filename,
			    tex.baseDir,
			    ACW*2,
			    ACH*2
			)
		grid.rect.x = display.contentCenterX - offsetX
		grid.rect.y = display.contentCenterY - offsetY
		-- grid.rect.x = display.contentCenterX - MAX_WIDTH / 2
		-- grid.rect.y = display.contentCenterY - MAX_HEIGHT / 2

		local lines = MAX_WIDTH / grid.size
		for i=0,lines do
			local lineOb = display.newLine( 
				i * grid.size * scaleRatio - MAX_WIDTH / 2, 0 - MAX_HEIGHT / 2, i * grid.size * scaleRatio - MAX_WIDTH / 2, MAX_HEIGHT * scaleRatio - MAX_HEIGHT / 2 )
			if lines / 2 == i then
				lineOb:setStrokeColor( 0, 1, 0, 0.7 )
			end
			tex:draw( lineOb )
			grid.cols[#grid.cols + 1] = lineOb
		end

		lines = MAX_HEIGHT / grid.size
		for i=0,lines do
			local lineOb = display.newLine( 
				0 - MAX_WIDTH / 2, i * grid.size * scaleRatio - MAX_HEIGHT / 2,  MAX_WIDTH * scaleRatio - MAX_WIDTH / 2, i * grid.size * scaleRatio - MAX_HEIGHT / 2 )
			if lines / 2 == i then
				lineOb:setStrokeColor( 0, 1, 0, 0.7 )
			end
			tex:draw( lineOb )
			grid.rows[#grid.rows + 1] = lineOb
		end

		tex:invalidate()
		tex:releaseSelf( )
	end

	-- grid.redraw = function()
	-- 	for i, col in ipairs(grid.cols) do
	-- 		col.x = col.x * scaleRatio
	-- 	end
	-- 	for i, row in ipairs(grid.rows) do
	-- 		row.y = row.y * scaleRatio
	-- 	end
	-- end

	return grid
end

return function(params)
	local M = {}
	M.root = display.newGroup( )
	if params.parent then params.parent:insert(M.root) end
	M.grid = createGrid(M)
	-- M.grid.create()
	-- M.grid.render()
	M.root.x , M.root.y  = INIT_X, INIT_Y
	M.offsetX, M.offsetY = 0, 0

	function M:mouse(event)
		-- print(event.scrollY)
		if event.scrollY > 0 then
			scaleRatio = scaleRatio + 0.01
			-- print('big', scaleRatio)
			-- M.grid.render()
		elseif event.scrollY < 0 then
			scaleRatio = scaleRatio - 0.01
			-- print('small', scaleRatio)
			-- M.grid.render()
		else
			if event.isPrimaryButtonDown then
				offsetX = INIT_X - event.x + MAX_WIDTH / 2
				offsetY = INIT_Y - event.y + MAX_HEIGHT / 2
			end
		end
		print(event.phase)

		-- M.grid.redraw()
	end
	Runtime:addEventListener( 'mouse', M )
	Runtime:addEventListener('enterFrame', function(event)
		M.grid.create()
	end)
	return M
end