-- scalableGraph.lua
local m
local SCALE_RATIO = 0.01
local scaleDirection = 0
local isGOEditing = false

local function setParams(params)
	m.params = params or {}
	m.scaleFactor = m.params.scaleFactor or 1.0
	m.tileSize = m.params.tileSize or 32
	m.canvasWidth = m.params.canvasWidth or display.actualContentWidth
	m.canvasHeight = m.params.canvasHeight or display.actualContentHeight
	m.oldMousePosition = {x=0, y=0}
	m.gridXLines = {}
	m.gridYLines = {}
end

local function createCanvas()
	m.canvas = display.newGroup( )
	if m.params.parent then
		m.params.parent:insert( m.canvas )
	end
	m.canvas.x = m.params.x or CX
	m.canvas.y = m.params.y or CY
end

local function createAxis()
	m.axis = display.newGroup()
	m.canvas:insert(m.axis)
	m.axis.x, m.axis.y = m.canvas.x, m.canvas.y
	m.axisX = display.newLine( 
		m.axis, 
		0, 
		-display.actualContentHeight, 
		0, 
		display.actualContentHeight)
	m.axisX:setStrokeColor( 0, 1, 0 )
	m.axisY = display.newLine( 
		m.axis, 
		-display.actualContentWidth, 
		0, 
		display.actualContentWidth,
		0 )
	m.axisY:setStrokeColor( 0, 1, 0 )
end

local function removeGrid()
	if #m.gridXLines <= 0 then return end
	for i=m.gridXLines.numChildren,1, -1 do
		local o = display.remove( m.gridXLines[i] )
		o = nil
	end
	if #m.gridYLines <= 0 then return end
	for i=m.gridYLines.numChildren,1, -1 do
		local o =display.remove( m.gridYLines[i] )
		o = nil
	end
end

local function createGrid()
	removeGrid()
	local numX = math.ceil(m.canvasWidth / m.tileSize)
	local numY = math.ceil(m.canvasHeight / m.tileSize )
	m.grid = display.newGroup()
	m.canvas:insert(m.grid)
	m.grid.x, m.grid.y = m.canvas.x, m.canvas.y
	for i = 0, numX do
		local grid = display.newLine( 
			m.grid, 
			i * m.tileSize * m.scaleFactor, 
			0, 
			i * m.tileSize * m.scaleFactor, 
			m.canvasHeight)
		grid:setStrokeColor( 1, 1, 1, 0.6 )
		m.gridXLines[#m.gridXLines + 1] = grid
	end
	for i = 0, numY do
		local grid = display.newLine( 
			m.grid, 
			0, 
			i * m.tileSize * m.scaleFactor, 
			m.canvasWidth,
			i * m.tileSize * m.scaleFactor )
		grid:setStrokeColor( 1, 1, 1, 0.6 )
		m.gridYLines[#m.gridYLines + 1] = grid
	end
end

local function updateGrid()
	for i = 1, #m.gridXLines do
		m.gridXLines[i].x = (i - 1) * m.tileSize * m.scaleFactor
	end
	for i = 1, #m.gridYLines do
		m.gridYLines[i].y = (i - 1) * m.tileSize * m.scaleFactor
	end
end

local function updateGO()
	for i = 1,m.gameObjects.numChildren do
		m.gameObjects[i].xScale = (m.scaleFactor + scaleDirection) 
		m.gameObjects[i].yScale = (m.scaleFactor + scaleDirection)
	end
end

local function update()
	updateGrid()
	updateGO()
end

local function createGOLayer()
	m.gameObjects = display.newGroup( )
	m.canvas:insert(m.gameObjects)
end

return function(params)
	local M = {}
	m = M
	setParams(params)
	createCanvas()
	createGrid()
	createAxis()
	createGOLayer()

	function M:mouse(event)
		if isGOEditing then return end
		if event.type == "down" then
      if event.isPrimaryButtonDown then
		  	m.oldMousePosition.x, 
		  	m.oldMousePosition.y = 
			  	event.x - m.canvas.x, 
			  	event.y - m.canvas.y
      elseif event.isSecondaryButtonDown then
        print( "Right mouse button clicked." )        
      end
		elseif event.type == "up" then
      if event.isPrimaryButtonDown then

      elseif event.isSecondaryButtonDown then
        print( "Right mouse button clicked." )        
      end
    elseif event.type == 'drag' then
    	if event.isPrimaryButtonDown then
	    	m.canvas.x, 
	    	m.canvas.y =
	    		event.x - m.oldMousePosition.x, 
	    		event.y - m.oldMousePosition.y
    	end
    elseif event.type == 'scroll' then
    	if event.scrollY > 0 then
    		m.scaleFactor = m.scaleFactor + SCALE_RATIO
    		scaleDirection = SCALE_RATIO
    	elseif event.scrollY < 0 then
    		m.scaleFactor = m.scaleFactor - SCALE_RATIO
    		scaleDirection = -SCALE_RATIO
    	end
    	update()
    end
	end

	function M:key(event)
		if event.phase == 'up' then
			if event.keyName == 'i' and event.isShiftDown then
				self:addDummyObject{x=130, y=100}
			end
		elseif event.phase == 'down' then

		end
		return false
	end

	function M:logicalLocation(target, dir)
		target.x = target.x + dir.x * m.scaleFactor
		target.y = target.y + dir.y * m.scaleFactor
		print(m.scaleFactor)
	end

	function M:addDummyObject(params)
		local ob = display.newGroup( )
		self.gameObjects:insert(ob)
		local rect = 
			display.newRect( 
				ob, 
				params.x or CX, 
				params.y or CY, 
				params.width or 60, 
				params.height or 40 )
		rect:setFillColor( params.color or unpack{0.8, 0.5, 0.2} )
		rect.vec = {x = 0, y = 0}
		rect:addEventListener( 'touch', function(event)
			if event.phase == 'began' then
				isGOEditing = true
				event.target.vec.x,
				event.target.vec.y
					= event.x, event.y
			elseif event.phase == 'moved' then
				local x, y = event.x, event.y
				local w, h = x - event.target.vec.x, y - event.target.vec.y
				-- local nrm = utils.normalize(w, h)
				-- if w == 0 then nrm.x = 0 end
				-- if h == 0 then nrm.y = 0 end
				self:logicalLocation(event.target, {x=w, y=h})

				event.target.vec.x,
				event.target.vec.y
					= event.x, event.y

			elseif event.phase == 'ended' then
				isGOEditing = false
			end
			return true
		end )
	end

	return M
end