-- levelCanvas.lua
local M = {}
local canvas
local HUD
local menu
local status
local buttons
local canvasBackground
local canvasObjects
local canvasWidth = CW
local canvasHeight = CH
local canvasScale = 1
local gridSize = 32
local MODE_GLOBAL = 'MODE_GLOBAL'
local MODE_LOCAL = 'MODE_LOCAL'
gImageSheets = {}

local CURRENTDIR_HOME = 'src/gos'

local function modeOrigin(name)
	local origin = { 
		name=name,
		oldX,
		oldY,
	}
	function origin:open() self:_open() end
	function origin:close() self:_close() end
	function origin:move(event) self:_move(event) end
	function origin:drag(event)
		self:_drag(event)
	end
	function origin:scroll(event) self:_scroll(event) end
	function origin:up(event) 
		self.oldX, self.oldY = nil, nil
		self:_up(event) 
	end
	function origin:down(event)
		self:_down(event)
	end
	function origin:reset() 
		self.oldX, self.oldY = nil, nil
		self:_reset()
	end
	function origin:toggleMenu()
		if menu.numChildren > 0 then
			for i=menu.numChildren, 1, -1 do
				local ob = display.remove( menu[i] )
				ob = nil
			end
		else
			local btnHeight = 30
			local items = self:getMenuItems()
			if #items <= 0 then return end
			local menuHeight = btnHeight * #items
			local padding = 32
			local menuWidth = 320
			local bg = display.newRoundedRect( menu, CX, CY, menuWidth, menuHeight + padding, 20 )
			bg:setFillColor( 1, 0, 0 )
			for i, item in ipairs(items) do
				local btn =uiLib:createButton(item.title, CX - menuWidth / 2, (CY - menuHeight / 2 - btnHeight / 2) + (i-1) * btnHeight, item.fn)
				menu:insert(btn)
			end

		end
	end
	function origin:getMenuItems()
		return self:_getMenuItems()
	end
	return origin
end
local globalMode = modeOrigin(MODE_GLOBAL)
function globalMode:_open()
	print('now ' .. self.name)
end
function globalMode:_close()
end
function globalMode:_move(event)
end
function globalMode:_drag(event)
	if event.isPrimaryButtonDown then
		if not self.oldX then self.oldX = event.x end
		if not self.oldY then self.oldY = event.y end
		local x, y = 0, 0
		local diffX = event.x - self.oldX
		local diffY = event.y - self.oldY
		canvas.x = canvas.x + diffX
		canvas.y = canvas.y + diffY
		self.oldX = event.x
		self.oldY = event.y
	elseif event.isSecondaryButtonDown then
		print('right')
	end
end
function globalMode:_scroll(event)
	if event.scrollY > 0 then
		canvasScale = 1 + 0.01
	elseif event.scrollY < 0 then
		canvasScale = 1 - 0.01
	end
	canvas:renderBG()
end
function globalMode:_up(event)
end
function globalMode:_down(event)
end
function globalMode:_reset(event)
	canvas.x = 0
	canvas.y = 0
	canvasScale = 1
	canvas.xScale = 1
	canvas.yScale = 1
end
function globalMode:_getMenuItems()
	return {
		{
			title='ADD A OBJECT',
			fn=function(event)
				if event.phase == 'ended' then
					utils.gotoFilePicker{params={currentDir=storage:baseDir() .. CURRENTDIR_HOME, selectType='file', numOfSelections=1, callback=function(values, parentDir)
						local file
						for i, v in ipairs(values) do
							if v.selected then
								file = v.name
								break
							end
						end
						if file then
							local dir = parentDir:gsub(storage:baseDir(), ''):gsub('/', '.')
							local path = string.format( '%s.%s', dir, file:gsub('.lua', ''))
							local generator = require(path)
							local gObj = generator{parent=canvasObjects, x=CX, y=CY}

						end
					self:toggleMenu()
					end}}
				end
				return true
			end,
		},
		{
			title='GRID SIZE',
			fn=function(event)
				if event.phase == 'ended' then
					print('grid size')
					self:toggleMenu()
				end
				return true
			end			
		},
	}
end
local localMode = modeOrigin(MODE_LOCAL)
function localMode:_open()
	print('now ' .. self.name)
end
function localMode:_close()
end
function localMode:_move(event)
end
function localMode:_drag(event)
end
function localMode:_scroll(event)
end
function localMode:_up(event)
end
function localMode:_down(event)
end
function localMode:_reset(event)
end
function localMode:_getMenuItems()
	return {}
end


local mode = globalMode
mode:open()

local function switch(kind)
	if kind == MODE_LOCAL then
		if kind == mode.name then return end
		mode:close()
		mode = localMode
		mode:open()
	else
		if kind == mode.name then return end
		mode:close()
		mode = globalMode
		mode:open()
	end
end

local function aixs(parent, x1, y1, x2, y2, color)
	local ax = display.newLine(parent, x1, y1, x2, y2 )
	ax:setStrokeColor(unpack(color))
end

local function grid()
	local rows = math.round(canvasHeight / gridSize)
	local cols = math.round(canvasWidth / gridSize)
	local gridColor = {0.2, 0.2, 0.2}
	for i=1,cols do
		aixs(canvasBackground, (i-1) * gridSize, 0, (i-1) * gridSize, canvasHeight, gridColor)
	end
	for i=1,rows do
		aixs(canvasBackground, 0, (i-1) * gridSize, canvasWidth, (i-1) * gridSize, gridColor)
	end
end

local function clearCanvasBackground()
	local num = canvasBackground.numChildren
	if num > 0 then
		for i=num,1,-1 do
			local obj = display.remove( canvasBackground[i] )
			obj = nil
		end
	end
end

local function background()
	clearCanvasBackground()
	grid()
	local aixsColor = {0, 1, 0}
	aixs(canvasBackground, 0, -canvasHeight, 0, canvasHeight, aixsColor)
	aixs(canvasBackground, -canvasWidth, 0, canvasWidth, 0, aixsColor)
	canvas:scale( canvasScale, canvasScale )
end

local function content(sceneGroup)
	canvas = display.newGroup( )
	canvas.renderBG = background
	sceneGroup:insert(canvas)
	canvasBackground = display.newGroup( )
	canvas:insert(canvasBackground)
	canvasObjects = display.newGroup( )
	canvas:insert(canvasObjects)
	HUD = display.newGroup( )
	sceneGroup:insert(HUD)
	status = display.newGroup( )
	HUD:insert(status)
	buttons = display.newGroup( )
	HUD:insert(buttons)
	menu = display.newGroup( )
	HUD:insert(menu)
	background()
end

local function loadAllStructures()
	gImageSheets = 
		storage:readAllImageSheets(
			'src/structures/gos', storage:baseDir())
end

function M:mouse(event)
	if event.type == "move" then
		mode:move(event)
	elseif event.type == "drag" then
		mode:drag(event)
	elseif event.type == "scroll" then
		mode:scroll(event)
	elseif event.type == "up" then
		mode:up(event)
	elseif event.type == "down" then
		mode:down(event)
	end
end

function M:key(event)
	if event.phase == 'up' then
		if event.keyName == 'x' then
			if mode.name == 'MODE_GLOBAL' then
				switch('MODE_LOCAL')
			else
				switch('MODE_GLOBAL')
			end
		elseif event.keyName == 'escape' then
			mode:reset()
		elseif event.keyName == 'space' then
			mode:toggleMenu()
		end
	end
end

function M:create(sceneGroup)
	physics.start( )
	loadAllStructures()
	content(sceneGroup)
	Runtime:addEventListener( 'mouse', self )
	Runtime:addEventListener( 'key', self )
end

function M:show()
	print('lvl show')
	switch(MODE_GLOBAL)
end

function M:destory()
	print('lvl end')
end

return M