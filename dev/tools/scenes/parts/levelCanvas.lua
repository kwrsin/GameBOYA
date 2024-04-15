-- levelCanvas.lua
local M = {}
local canvas
local HUD
local menu
local status
local buttons
local canvasBackground
local canvasObjects
local canvasGizmos
local viewEditor
local canvasWidth = CW
local canvasHeight = CH
local canvasScale = 1
local gridSize = 32
local MODE_GLOBAL = 'MODE_GLOBAL'
local MODE_LOCAL = 'MODE_LOCAL'
local selections = {}
local onLeftShiftKey = false
local onLeftAltKey = false
local onXAxisKey = true
local onYAxisKey = true

gImageSheets = {}

local CURRENTDIR_HOME = 'src/gos'

local function eulerAngle(src)
	local dashX, dashY = 0, 0
	dashX = math.cos( math.rad(src.rotation) ) * src.x +  -math.sin( math.rad(src.rotation) ) * src.y + 0 * 1
	dashY = math.sin( math.rad(src.rotation) ) * src.x + math.cos( math.rad(src.rotation) ) * src.y + 0 * 1
	return dashX, dashY
end

local function createGizmo(targetGO)
	local root = display.newGroup( )
	root.targetGO = targetGO
	canvasGizmos:insert(root)
	root.x, root.y = root.targetGO.x, root.targetGO.y
	local radius = 
		math.round(
			math.sqrt( (targetGO.width * targetGO.width) / 2 + (targetGO.height * targetGO.height) / 2)) * 1.2
	root.pointCircle = display.newCircle( root, 0, 0, radius )
	function root:selectedColor()
		root.pointCircle:setFillColor( 0.5, 0.5, 0.5, 0.3 )
	end
	function root:unselectedColor()
		root.pointCircle:setFillColor( 0.9, 0.9, 0.9, 0.3 )
	end
	function root:select()
		self.selected = true
		self:selectedColor()
		selections[self.targetGO] = self
	end
	function root:unselect()
		self.selected = false
		self:unselectedColor()
		selections[self.targetGO] = nil
	end
	root:unselect()
	root.rot = 0
	root.localAxis = nil
	root:select()

	function root:createAxis()
		root.localAxis = display.newGroup( )
		root:insert(root.localAxis)
		if onXAxisKey then
			local xLine = display.newLine( root.localAxis, 0, 0, 48, 0 )
			xLine:setStrokeColor( 1, 0, 0 )
			root.localAxis:insert(xLine)
		end
		if onYAxisKey then
			local yLine = display.newLine( root.localAxis, 0, 0, 0, 48)
			root.localAxis:insert(yLine)
			yLine:setStrokeColor( 1, 0, 0 )
		end
	end

	function root:deleteAxis()
		local la = display.remove(root.localAxis)
		la = nil
	end

	function root:toggleLocalAxis(isShown)
		if isShown then
			if not root.localAxis then
				self:createAxis()
			end
		else
			if root.localAxis then
				self:deleteAxis()
			end
		end

	end
	root:toggleLocalAxis(true)

	-- physics.addBody( root, 'static', {isSensor=true, radius=30, filter={ categoryBits=2, maskBits=1 }} )
	-- root.collision = function collision(self, event)
	-- 	if event.phase == 'began' then
	-- 		root:select()
	-- 	elseif event.phase == 'ended' then
	-- 		root:unselect()
	-- 	end
	-- end
	-- root:addEventListener( 'collision' )
	root:addEventListener('touch', function(event)
		if event.phase == 'begain' then
		elseif event.phase == 'moved' then
		elseif event.phase == 'ended' or event.phase == 'canceled' then
		end
		if event.phase == 'ended' then
			root.selected = not root.selected
			if root.selected then
				root:select()
			else
				root:unselect()
			end
		end
		return true
	end)
	function root:enterFrame(event)
		self.targetGO.x, self.targetGO.y = self.x, self.y
		self.rot = self.rot % 360
		self.targetGO.rotation = self.rot	
		if self.localAxis then
			self.localAxis.rotation = self.rot
		end
	end
	return root
end

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
	function origin:addObject()
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
				origin.gizmo = createGizmo(gObj.go)
			end
		end}}
	end
	function origin:update()
		for k, sel in pairs(selections) do
			sel:deleteAxis()
			sel:createAxis()
		end
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
					-- utils.gotoFilePicker{params={currentDir=storage:baseDir() .. CURRENTDIR_HOME, selectType='file', numOfSelections=1, callback=function(values, parentDir)
					-- 	local file
					-- 	for i, v in ipairs(values) do
					-- 		if v.selected then
					-- 			file = v.name
					-- 			break
					-- 		end
					-- 	end
					-- 	if file then
					-- 		local dir = parentDir:gsub(storage:baseDir(), ''):gsub('/', '.')
					-- 		local path = string.format( '%s.%s', dir, file:gsub('.lua', ''))
					-- 		local generator = require(path)
					-- 		local gObj = generator{parent=canvasObjects, x=CX, y=CY}
					-- 		createGizmo(gObj.go)
					-- 	end
					-- self:toggleMenu()
					-- end}}
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

local function invalidRect()
	if viewEditor.numChildren <= 0 then return end
	for i=viewEditor.numChildren, 1, -1 do
		local obj = display.remove( viewEditor[i] )
		obj = nil
	end
end

local function drawRect(topleft, bottomright)
	local r = display.newRect( viewEditor, topleft.x, topleft.y, bottomright.x - topleft.x, bottomright.y - topleft.y )
	r.anchorX, r.anchorY = 0, 0
	r:setFillColor( 1, 0, 0, 0.2 )
end

local function renderRect(topleft, bottomright)
	invalidRect()
	drawRect(topleft, bottomright)
end

local localMode = modeOrigin(MODE_LOCAL)
localMode.startPos = {x=nil, y=nil}
function localMode:_open()
	print('now ' .. self.name)
end
function localMode:_close()
end
function localMode:_move(event)
end
function localMode:_drag(event)
	if event.isPrimaryButtonDown then
		renderRect(self.startPos, event)
		print('start')
	end
end
function localMode:_scroll(event)
end
function localMode:_up(event)
	self.startPos.x, self.startPos.y = nil, nil
	invalidRect()
	print('end')
end
function localMode:_down(event)
	if event.isPrimaryButtonDown then
		self.startPos.x, self.startPos.y = event.x, event.y
	end
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

local function axis(parent, x1, y1, x2, y2, color)
	local ax = display.newLine(parent, x1, y1, x2, y2 )
	ax:setStrokeColor(unpack(color))
end

local function grid()
	local rows = math.round(canvasHeight / gridSize)
	local cols = math.round(canvasWidth / gridSize)
	local gridColor = {0.2, 0.2, 0.2}
	for i=1,cols do
		axis(canvasBackground, (i-1) * gridSize, 0, (i-1) * gridSize, canvasHeight, gridColor)
	end
	for i=1,rows do
		axis(canvasBackground, 0, (i-1) * gridSize, canvasWidth, (i-1) * gridSize, gridColor)
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
	local axisColor = {0, 1, 0}
	axis(canvasBackground, 0, -canvasHeight, 0, canvasHeight, axisColor)
	axis(canvasBackground, -canvasWidth, 0, canvasWidth, 0, axisColor)
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
	canvasGizmos = display.newGroup( )
	canvas:insert(canvasGizmos)
	HUD = display.newGroup( )
	sceneGroup:insert(HUD)
	status = display.newGroup( )
	HUD:insert(status)
	buttons = display.newGroup( )
	HUD:insert(buttons)
	menu = display.newGroup( )
	HUD:insert(menu)
	viewEditor = display.newGroup( )
	HUD:insert(viewEditor)
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
	local speed = onLeftShiftKey and 10 or 1
	local reverse = onLeftAltKey and -1 or 1
	if event.phase == 'up' then
		if event.keyName == 'l' then
			if mode.name == 'MODE_GLOBAL' then
				switch('MODE_LOCAL')
			else
				switch('MODE_GLOBAL')
			end
		elseif event.keyName == 'escape' then
			mode:reset()
		elseif event.keyName == 'space' then
			mode:toggleMenu()
		elseif event.keyName == 'leftShift' then
			onLeftShiftKey = false
		elseif event.keyName == 'leftAlt' then
			onLeftAltKey = false
		elseif event.keyName == 'a' then
			if onLeftShiftKey then
				mode:addObject()
			else
			end
		elseif event.keyName == 'x' then
			onXAxisKey = not onXAxisKey
			mode:update()
		elseif event.keyName == 'y' then
			onYAxisKey = not onYAxisKey
			mode:update()
		end
	elseif event.phase == 'down' then
		if event.keyName == 'left' then
			for i, sel in pairs(selections) do
				if mode.name == 'MODE_LOCAL' then
					local eX, eY = eulerAngle({x=-speed, y=0, rotation=sel.targetGO.rotation})
					sel.x = sel.x + eX
					sel.y = sel.y + eY
				else
					sel.x = sel.x - speed
				end
			end
		end
		if event.keyName == 'right' then
			for k, sel in pairs(selections) do
				if mode.name == 'MODE_LOCAL' then
					local eX, eY = eulerAngle({x=speed, y=0, rotation=sel.targetGO.rotation})
					sel.x = sel.x + eX
					sel.y = sel.y + eY
				else
					sel.x = sel.x + speed
				end
			end
		end
		if event.keyName == 'up' then
			for k, sel in pairs(selections) do
				if mode.name == 'MODE_LOCAL' then
					local eX, eY = eulerAngle({x=0, y=-speed, rotation=sel.targetGO.rotation})
					sel.x = sel.x + eX
					sel.y = sel.y + eY
				else
					sel.y = sel.y - speed
				end
			end
		end
		if event.keyName == 'down' then
			for k, sel in pairs(selections) do
				if mode.name == 'MODE_LOCAL' then
					local eX, eY = eulerAngle({x=0, y=speed, rotation=sel.targetGO.rotation})
					sel.x = sel.x + eX
					sel.y = sel.y + eY
				else
					sel.y = sel.y + speed
				end
			end
		end
		if event.keyName == 'r' then
			for k, sel in pairs(selections) do
				sel.rot = sel.rot + speed * reverse
			end
		end
		if event.keyName == 'leftShift' then
			onLeftShiftKey = true
		end
		if event.keyName == 'leftAlt' then
			onLeftAltKey = true
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

local function enterFrame(event)
	for k, sel in pairs(selections) do
		sel:enterFrame(even)
	end
end

function M:show()
	print('lvl show')
	switch(MODE_GLOBAL)
	Runtime:addEventListener('enterFrame', enterFrame)
end

function M:hide()
	Runtime:removeEventListener('enterFrame', enterFrame)
end

function M:destory()
	print('lvl end')
end

return M