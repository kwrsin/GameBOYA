-- levelCanvas.lua
--[[ TASKS
-- label displaying
-- anchor switch
-- change canvas size
-- generate level
]]--

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
local onCenterKey = false
local onLeftBracket = false
local onRightBracket = false
local onBigger = false
local onSmaller = false
local seq = 0

gImageSheets = {}

local CURRENTDIR_HOME = 'src/gos'
local RELEATION_PATH = 'src/structures/relations.lua'
local ITEM_SELECTOR = 'FILTER SELECTOR'

publisher:observe(BIND_SELECTEDITEM, {})
local relations

local function removeRelations()
	for k, sel in pairs(selections) do
		sel.selectedFilters = nil
		sel.label1.text = ''
	end
end

local function openRelations()
	local p = string.format('%s%s', storage:baseDir(), RELEATION_PATH)
	if not storage:exists(p) then return end
	local dotPath = RELEATION_PATH:gsub('.lua', ''):gsub('/', '.')
	relations = require(dotPath)
	local filterNames = {}
	for k, r in pairs(relations) do
		filterNames[#filterNames + 1] = k
	end
	if #filterNames <= 0 then return end
	utils.gotoFileSelector{
		params={
			title=ITEM_SELECTOR, 
			items=filterNames
		}
	}
end

local function getSequence()
	seq = seq + 1
	return seq
end

local function toFront()
	for k, sel in pairs(selections) do
		sel:toFront()
		k:toFront()
	end
end

local function toBack()
	for k, sel in pairs(selections) do
		sel:toBack()
		k:toBack()
	end
end

local function removeObjects()
	for k, sel in pairs(selections) do
		selections[k] = nil
		sel:removeSelf( )
		sel = nil
		k:removeSelf( )
		k = nil
	end
end

local function unselectAll()
	for k, sel in pairs(selections) do
		sel:unselect()
	end
end

local function selectAll()
	if canvasGizmos.numChildren <= 0 then return end
	for i = 1, canvasGizmos.numChildren  do
	 	canvasGizmos[i]:select()
	 end 
end

local function lastSelection()
	local lastSeq = -1
	local lastSel = nil
	for k, sel in pairs(selections) do
		if lastSeq < sel.sequence then
			lastSeq = sel.sequence
			lastSel = sel
		end
	end
	return lastSel
end

local function toXSortedSelections()
	local sortedSelections = {}
	local function insert(sel)
		if #sortedSelections <= 0 then
			sortedSelections[#sortedSelections + 1] = sel
		else
			local inserted = false
			for i=1,#sortedSelections do
				if sortedSelections[i].x > sel.x then
					table.insert( sortedSelections, i , sel)
					inserted = true
					break
				end 
			end
			if not inserted then
				sortedSelections[#sortedSelections + 1] = sel
			end
		end
	end
	for k, sel in pairs(selections) do
		insert(sel)
	end
	return sortedSelections
end

local function toYSortedSelections()
	local sortedSelections = {}
	local function insert(sel)
		if #sortedSelections <= 0 then
			sortedSelections[#sortedSelections + 1] = sel
		else
			local inserted = false
			for i=1,#sortedSelections do
				if sortedSelections[i].y > sel.y then
					table.insert( sortedSelections, i , sel)
					inserted = true
					break
				end 
			end
			if not inserted then
				sortedSelections[#sortedSelections + 1] = sel
			end
		end
	end
	for k, sel in pairs(selections) do
		insert(sel)
	end
	return sortedSelections
end

local function arrangeXEvenly()
	local sortedSelections = toXSortedSelections()
	if #sortedSelections < 3 then return end
	local length = sortedSelections[#sortedSelections].x - sortedSelections[1].x
	local diff = length / (#sortedSelections - 1)
	for i=2, (#sortedSelections - 1) do
		sortedSelections[i].x = sortedSelections[i-1].x + diff
	end
end

local function arrangeYEvenly()
	local sortedSelections = toYSortedSelections()
	if #sortedSelections < 3 then return end
	local length = sortedSelections[#sortedSelections].y - sortedSelections[1].y
	local diff = length / (#sortedSelections - 1)
	for i=2, (#sortedSelections - 1) do
		sortedSelections[i].y = sortedSelections[i-1].y + diff
	end
end

local function eulerAngle(src)
	local dashX, dashY = 0, 0
	dashX = math.cos( math.rad(src.rotation) ) * src.x + -math.sin( math.rad(src.rotation) ) * src.y + 0 * 1
	dashY = math.sin( math.rad(src.rotation) ) * src.x + math.cos( math.rad(src.rotation) ) * src.y + 0 * 1
	return dashX, dashY
end

local function createGizmo(targetGO, generator)
	local root = display.newGroup( )
	root.targetGO = targetGO
	canvasGizmos:insert(root)
	root.x, root.y = root.targetGO.x, root.targetGO.y
	root.generator = generator

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
		self.sequence = getSequence()
		selections[self.targetGO] = self
	end
	function root:unselect()
		self.selected = false
		self:unselectedColor()
		selections[self.targetGO] = nil
	end
	function root:createLabels()
		local labels = display.newGroup( )
		root:insert(labels)
		root.label1 = display.newText( labels, '', 0, -20 , native.systemFont, 24 )
		root.label1:setFillColor( 0, 1, 1 )
	end
	root.rot = root.targetGO.rotation
	root.localAxis = nil
	root:createLabels()
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
				origin.gizmo = createGizmo(gObj.go, generator)
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
			if mode.name == MODE_GLOBAL then
				switch(MODE_LOCAL)
			else
				switch(MODE_GLOBAL)
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
		elseif event.keyName == 'd' then
			if onLeftShiftKey then
				local originPoint = lastSelection()
				if originPoint then
					local distX, distY = 0, 0
					if onXAxisKey then
						distX = originPoint.width / 2
					end
					if onYAxisKey then
						distY = originPoint.height / 2
					end
					local generator = originPoint.generator
					if mode.name == MODE_LOCAL then
						distX, distY = eulerAngle{x=distX, y=distY, rotation=originPoint.targetGO.rotation}
						local gObj = generator{parent=canvasObjects, x=originPoint.x + distX, y=originPoint.y + distY}
						gObj.go.rotation = originPoint.targetGO.rotation
						createGizmo(gObj.go, generator)
					else
						local gObj = generator{parent=canvasObjects, x=originPoint.x + distX, y=originPoint.y + distY}
						gObj.go.rotation = originPoint.targetGO.rotation
						createGizmo(gObj.go, generator)
					end
				end
			end
		elseif event.keyName == 'c' then
			local centerX, centerY = canvasWidth / 2, canvasHeight / 2
			for k, sel in pairs(selections) do
				if onXAxisKey then
					sel.x = centerX
				end
				if onYAxisKey then
					sel.y = centerY
				end
			end
			onCenterKey = false
		elseif event.keyName == '[' then
			for k, sel in pairs(selections) do
				if onXAxisKey then
					sel.x = 0
				end
				if onYAxisKey then
					sel.y = 0
				end
			end
			onLeftBracket = false
		elseif event.keyName == ']' then
			for k, sel in pairs(selections) do
				if onXAxisKey then
					sel.x = canvasWidth
				end
				if onYAxisKey then
					sel.y = canvasHeight
				end
			end
			onRightBracket = false
		elseif event.keyName == '.' then
			if onXAxisKey then
				for i, sel in ipairs(toXSortedSelections(selections)) do
					sel.x = sel.x + (i-1) * speed
				end
			end
			if onYAxisKey then
				for i, sel in ipairs(toYSortedSelections(selections)) do
					sel.y = sel.y + (i-1) * speed
				end
			end
			onBigger = false
		elseif event.keyName == ',' then
			if onXAxisKey then
				for i, sel in ipairs(toXSortedSelections(selections)) do
					sel.x = sel.x - (i-1) * speed
				end
			end
			if onYAxisKey then
				for i, sel in ipairs(toYSortedSelections(selections)) do
					sel.y = sel.y - (i-1) * speed
				end
			end
			onSmaller = false
		elseif event.keyName == 'u' then
			if onLeftShiftKey then
				unselectAll()
			else
				selectAll()
			end
		elseif event.keyName == 'i' then
			if onXAxisKey then
				arrangeXEvenly()
			end
			if onYAxisKey then
				arrangeYEvenly()
			end
		elseif event.keyName == 'deleteBack' then
			if onLeftShiftKey then
				removeObjects()
			end
		elseif event.keyName == 'z' then
			if onLeftShiftKey then
				toBack()
			else
				toFront()
			end
		elseif event.keyName == 'b' then
			if onLeftShiftKey then
				removeRelations()
			else
				openRelations()
			end
		end
	elseif event.phase == 'down' then
		if event.keyName == 'left' then
			for i, sel in pairs(selections) do
				if mode.name == MODE_LOCAL then
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
				if mode.name == MODE_LOCAL then
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
				if mode.name == MODE_LOCAL then
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
				if mode.name == MODE_LOCAL then
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
		if event.keyName == 'c' then
			onCenterKey = true
		end
		if event.keyName == '[' then
			onLeftBracket = true
		end
		if event.keyName == ']' then
			onRightBracket = true
		end
		if event.keyName == '.' then
			onBigger = true
		end
		if event.keyName == ',' then
			onSmaller = true
		end
	end
end

local selectedItem = {}
function selectedItem.update(obj, event)
	if relations == nil then return end
	for k, sel in pairs(selections) do
		sel.selectedFilters = {}
		sel.selectedFilters[event.value.selectedItem] =
			relations[event.value.selectedItem]
		sel.label1.text = event.value.selectedItem
	end
end
publisher:subscribe(BIND_SELECTEDITEM, selectedItem)


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
	seq=0
	print('lvl end')
end

return M