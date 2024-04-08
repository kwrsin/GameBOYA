-- canvas.lua
local GRAPH_SIZE = 300
local GRAPH_GRID_SIZE = 50
local MAX_WIDTH = GRAPH_SIZE
local MAX_HEIGHT = GRAPH_SIZE
local CENTER_X = GRAPH_SIZE / 2
local CENTER_Y = GRAPH_SIZE / 2
local INIT_X = -math.round(CENTER_X - ACW / 2)
local INIT_Y = -math.round(CENTER_Y - ACH / 2) + 1

local _NEWGROUP = 'newGroup'
local _NEWSPRITE = 'newSprite'
local _NEWRECT = 'newRect'
local _NEWCIRCLE = 'newCircle'
local _NEWROUNDEDRECT='newRoundedRect'

local MODE_APPEND = 'MODE_APPEND'
local MODE_SET = 'MODE_SET'
local MODE_COL_POLY = 'MODE_COL_POLY'
local MODE_COL_RECT = 'MODE_COL_RECT'
local MODE_COL_CIRCLE = 'MODE_COL_CIRCLE'

local TYPE_LABEL = 0
local TYPE_BUTTON = 1
local TYPE_TEXT = 2

local mode = {}
function mode:getTarget()
	if not self.canvas.objectManager then return nil end
	if self.canvas.objectManager.numChildren <= 0 then return nil end
	return self.canvas.objectManager[1]
end

function mode:key(event)
	if event.phase == 'up' and event.keyName == 'enter' then
		self:closeEditing()
	end
end

function mode:createPointer(event)
	-- local t = self:getTarget( )
	-- if not t then return end
	-- local x, y = target.x - event.x, target.y - event.y
	-- local c = display.newCircle( t, x, y, 6 )
	local c = display.newCircle( self.canvas.marks, event.x, event.y, 6 )
	c:setFillColor(0.6, 0.2, 0.2)
	self.pointers[#self.pointers + 1] = c
end

function mode:removeLastPointer(event)
	if #self.pointers > 0 then
		local p = table.remove( self.pointers, #self.pointers )
		if p then
			display.remove(p)
		end
	end
end

function mode:mouse(event)
	local icon = self.canvas.marks[1]
	if not icon then return end
	icon.x, icon.y = event.x, event.y

	if event.type == "down" then
		if event.isPrimaryButtonDown then
			self:createPointer(event)
		elseif event.isSecondaryButtonDown then
			self:removeLastPointer(event)
		end
	end
end

function mode:clearPointers()
	if #self.pointers > 0 then
		for i=#self.pointers,1, -1 do
			table.remove( self.pointers, i )
		end
	end
end

function mode:createPointers()
	self.pointers = self.pointers or {} 
	return self.pointers
end

function mode:openEditing(params)
	-- mouse cursor
	local c = display.newCircle( self.canvas.marks, params.x, params.y, 12 )
	c:setFillColor( 0, 0.7, 0.2, 0.8 )
	Runtime:addEventListener( 'mouse', mode)
	Runtime:addEventListener('key', mode)

	self:createPointers()
end

function mode:closeEditing()
	Runtime:removeEventListener('mouse', mode)
	Runtime:removeEventListener('key', mode)
	if self.canvas.marks.numChildren > 0 then
		for i=self.canvas.marks.numChildren,1,-1 do
			local icon = self.canvas.marks[i]
			display.remove(icon)
			icon = nil
		end
	end
	self.canvas.mode:refrect()
	self:clearPointers()	
	self.canvas:modeSet()
end
function mode:createGroup(params)
	local group = display.newGroup( )
	self.canvas.objectManager:insert(group)
	local icon = display.newRoundedRect( group, 0, 0, 80, 80, 24 )
	icon:setFillColor( 1, 0.3, 0.3, 0.6 )
	local lbl = display.newText( group, 'G', 0, 0 , native.systemFontBold, 48 )
	lbl:setFillColor( 0.5, 0.6, 0.7, 0.8 )
	self.isMouseMoving = false
	group:addEventListener( 'touch', function(event)
		if event.phase == 'began' then
			group:scale(1.2, 1.2)
			self.isMouseMoving = false
		elseif event.phase == 'moved' then
			group.x = event.x
			group.y = event.y
			self.isMouseMoving = true
		elseif event.phase == 'ended' or event.phase == 'canceled' then
			if self.isMouseMoving then else
				self.canvas:modeSet():toggleMenu{x=event.x, y=event.y}
			end
			-- group:scale(1.0, 1.0)
			group.xScale = 1.0
			group.yScale = 1.0
		end
		return true
	end )
end
function mode:createButtons(params)
	local menusPos = params.itemsNum * 60 / 2
	local i = 1
	for key, item in pairs(params.items) do
		if item.type == TYPE_TEXT then 

		else
			local btn = uiLib:createButton(key, params.x - 60, (i - 1) * 60 + params.y - menusPos, function(event)
				if event.phase == 'ended' then
					item.fn(event)
					mode:hide() 
				end
			end)
			self.canvas.menuGroup:insert(btn)
		end
		i = i + 1
	end
end
function mode:hide()
	display.remove( self.canvas.menuGroup )
	self.canvas.menuGroup = nil
end
function mode:toggleMenu(params)
	if not self.canvas.menuGroup then
		self.canvas.menuGroup = display.newGroup()
		self.canvas.HUD:insert(self.canvas.menuGroup)
		local bg = display.newRect( self.canvas.menuGroup, CX, CY, ACW, ACH )
		bg:setFillColor( 0.3, 0.3, 0.3, 0.6 )
		local itemsNum = 0
		for k, v in pairs(params.items) do
			itemsNum = itemsNum + 1
		end
		params.itemsNum = itemsNum
		local frameHeigth = itemsNum * 60  + 12
		local frame = display.newRoundedRect( self.canvas.menuGroup, params.x, params.y, 400, frameHeigth, 30 )
		frame:setFillColor( 1, 0, 0, 0.7 )
		mode:createButtons(params)
	else
		self:hide()
	end
end

function mode:renderCollisions()
	if self.shapes then else return end
	local target = self:getTarget( )
	if target.numChildren <= 0 then return end
	local obj = target[1]
	physics.removeBody( obj )
	local polygons, rects, circles = {}, {}, {}
	for i, shape in ipairs(self.shapes) do
		if shape.type == 'polygon' then
			polygons[#polygons + 1] = {shape=shape.data}
		elseif shape.type == 'rect' then
			rects[#rects + 1] = shape.data
		elseif shape.type == 'circle' then
			circles[#circles + 1] = shape.data
		end
	end
	if #polygons > 0 then
		physics.addBody( obj, 'static', unpack(polygons) )
	end
	for i, r in ipairs(rects) do
		physics.addBody( obj, 'static', {box=r} )
	end
	for i, c in ipairs(circles) do
		physics.addBody( obj, 'static', {radius=c} )
	end
end

function mode:clearShapes(excludes)
	local function contain(shape)
		for i=1,#excludes do
			if excludes[i] == shape.type then
				return true
			end
		end
		return false
	end
	if not self.shapes or #self.shapes <= 0 then return end
	for i=#self.shapes,1,-1 do
		local prevent = false
		if excludes then
			if contain(self.shapes[i]) then
				prevent = true
			end
		end
		if not prevent then
			table.remove(self.shapes, i)
		end
	end
end

mode[MODE_APPEND] = {}
--TODO: load GOs with Levelmaker
function mode.MODE_APPEND:toggleMenu(params)
	params.items = {
		_NEWGROUP={type=TYPE_BUTTON, fn=function(event)
			print(_NEWGROUP) 
			mode:createGroup(params)
		end,},
		_NEWSPRITE={type=TYPE_BUTTON, fn=function(event)
			print(_NEWSPRITE) 
utils.gotoFilePicker({params={currentDir='../', selectType='file', numOfSelections=2, callback=function(values, parentDir)
		print(parentDir)
		table.print(values)
	end}})

		end,},
		_NEWRECT={type=TYPE_BUTTON, fn=function(event)
			uiLib:menu({
					{title='abc', value={
						{title='ghi', value=function(title) print(title) end},
						{title='jkl', value=function(title) print(title) end},
						{title='mno', value=function(title) print(title) end},
						{title='pqr', value=function(title) print(title) end},
					}
				},
				{title='def', value=function(title) print(title) end},
			})
			print(_NEWRECT) 
		end,},
		_NEWCIRCLE={type=TYPE_BUTTON, fn=function(event)
			print(_NEWCIRCLE) 
		end,},
		_NEWROUNDEDRECT={type=TYPE_BUTTON, fn=function(event)
			print(_NEWROUNDEDRECT) 
		end,},
	}
	mode:toggleMenu(params)
end
function mode.MODE_APPEND:refrect()
end

mode[MODE_SET] = {}
function mode.MODE_SET:toggleMenu(params)
	-- TODO: dynamic menu loading
	params.items = {
		x={type=TYPE_BUTTON, fn=function(event)
			uiLib:input(nil, 'input x', nil, nil, 'number', '0', function(event)
				if event.phase == "ended" or event.phase == "submitted" then
					print(event.target.text)
				end
			end)
			print('x')
		end,},
		y={type=TYPE_BUTTON, fn=function(event)
			print('y')
		end,},
		width={type=TYPE_BUTTON, fn=function(event)
			print('width')
		end,},
		height={type=TYPE_BUTTON, fn=function(event)
			print('height')
		end,},
		addChild={type=TYPE_BUTTON, fn=function(event)
			print('addChild')
		end,},
		addCollisionPoly={type=TYPE_BUTTON, fn=function(event)
			mode:hide()
			mode.canvas:modeColPoly()
			mode:openEditing(event)
		end,},
		addCollisionRect={type=TYPE_BUTTON, fn=function(event)
			mode:hide()
			mode.canvas:modeColRect()
			mode:openEditing(event)
		end,},
		addCollisionCircle={type=TYPE_BUTTON, fn=function(event)
			mode:hide()
			mode.canvas:modeColCircle()
			mode:openEditing(event)
		end,},
		rotation={type=TYPE_BUTTON, fn=function(event)
			local target = mode:getTarget()
			if target.numChildren < 1 then return end
			local obj = target[1]
			local rot = string.format( '%d' , obj.rotation )
			uiLib:input(nil, 'Input Rotation', CX, CY, 'number', rot, function(event)
				if event.phase == "ended" or event.phase == "submitted" then
					obj.rotation = tonumber( event.target.text )
					mode:hide()
				end
			end)
		end,},
		scaleX={type=TYPE_BUTTON, fn=function(event)
			local target = mode:getTarget()
			if target.numChildren < 1 then return end
			local obj = target[1]
			local xs = string.format( '%d' , obj.xScale )
			uiLib:input(nil, 'Input xScale', CX, CY, 'phone', xs, function(event)
				if event.phase == "ended" or event.phase == "submitted" then
					obj.xScale = tonumber( event.target.text )
					mode:hide()
				end
			end)
		end,},
		scaleY={type=TYPE_BUTTON, fn=function(event)
			local target = mode:getTarget()
			if target.numChildren < 1 then return end
			local obj = target[1]
			local ys = string.format( '%d' , obj.yScale )
			uiLib:input(nil, 'Input yScale', CX, CY, 'phone', ys, function(event)
				if event.phase == "ended" or event.phase == "submitted" then
					obj.yScale = tonumber( event.target.text )
					mode:hide()
				end
			end)
		end,},
		anchorX={type=TYPE_BUTTON, fn=function(event)
			local target = mode:getTarget()
			if target.numChildren < 1 then return end
			local obj = target[1]
			local xa = string.format( '%f' , obj.anchorX )
			uiLib:input(nil, 'Input anchorX', CX, CY, 'decimal', xa, function(event)
				if event.phase == "ended" or event.phase == "submitted" then
					obj.anchorX = tonumber( event.target.text )
					mode:hide()
				end
			end)
		end,},
		anchorY={type=TYPE_BUTTON, fn=function(event)
			local target = mode:getTarget()
			if target.numChildren < 1 then return end
			local obj = target[1]
			local ya = string.format( '%f' , obj.anchorY )
			uiLib:input(nil, 'Input anchorY', CX, CY, 'decimal', ya, function(event)
				if event.phase == "ended" or event.phase == "submitted" then
					obj.anchorY = tonumber( event.target.text )
					mode:hide()
				end
			end)
		end,},
	}
	if mode.shapes and #mode.shapes > 0 then
		for i, shape in ipairs(mode.shapes) do
			local title = string.format('delete shape_%i', i)
			params.items[title]={type=TYPE_BUTTON, fn=function(event)
				table.remove(mode.shapes, i)
				mode:renderCollisions()
			end}
		end
	end
	mode:toggleMenu(params)
end
function mode.MODE_SET:refrect()
end


mode[MODE_COL_POLY] = {}
function mode.MODE_COL_POLY:toggleMenu(params)
 return 
end
function mode.MODE_COL_POLY:refrect()
	local go = mode:getTarget( )
	if not go then return end
	mode:clearShapes({'polygon'})
	if go.numChildren <= 0 then return end
	local obj = go[1]
	if #mode.pointers < 2 then return end
	local lPos = {}
	for i, p in ipairs(mode.pointers) do
		lPos[#lPos + 1] = p.x - go.x - obj.x
		lPos[#lPos + 1] = p.y - go.y - obj.y 
	end
	lPos[#lPos + 1] = lPos[1]
	lPos[#lPos + 1] = lPos[2]
	local shapes = mode.shapes or {}
	shapes[#shapes + 1] = {type='polygon', data=lPos}
	mode.shapes = shapes
	mode:renderCollisions()
end

mode[MODE_COL_RECT] = {}
function mode.MODE_COL_RECT:toggleMenu(params)
 return 
end
function mode.MODE_COL_RECT:refrect()
	local go = mode:getTarget( )
	if not go then return end
	if go.numChildren <= 0 then return end
	mode:clearShapes()
	local obj = go[1]
	local rect = {}
	if #mode.pointers <= 0 then
		rect.x, rect.y = 0, 0
		rect.halfWidth, rect.halfHeight = obj.width / 2, obj.height / 2
	elseif #mode.pointers <= 1 then
		rect.x, rect.y = 0, 0
		rect.halfWidth = math.abs(mode.pointers[1].x - go.x - obj.x)
		rect.halfHeight = math.abs(mode.pointers[1].y - go.y - obj.y)
	elseif #mode.pointers >= 2 then
		rect.x, rect.y = mode.pointers[1].x - obj.x - go.x, mode.pointers[1].y - obj.y - go.y
		rect.halfWidth, rect.halfHeight = math.abs(mode.pointers[1].x - mode.pointers[2].x), math.abs(mode.pointers[1].y - mode.pointers[2].y)
	end
	local shapes = mode.shapes or {}
	shapes[#shapes + 1] = {type='rect', data=rect}
	mode.shapes = shapes
	mode:renderCollisions()
end

mode[MODE_COL_CIRCLE] = {}
function mode.MODE_COL_CIRCLE:toggleMenu(params)
 return 
end
function mode.MODE_COL_CIRCLE:refrect()
	local go = mode:getTarget( )
	if not go then return end
	if go.numChildren <= 0 then return end
	mode:clearShapes()
	local obj = go[1]
	local radius
	if #mode.pointers <= 0 then
		radius = obj.width / 2
	elseif #mode.pointers >= 1 then
		local w = mode.pointers[1].x - go.x - obj.x
		local h = mode.pointers[1].y - go.y - obj.y
		local sqrt = math.sqrt( w * w + h * h )
		radius = math.abs(sqrt)
		-- radius = math.abs(mode.pointers[1].x - go.x - obj.x)
	end
	local shapes = mode.shapes or {}
	shapes[#shapes + 1] = {type='circle', data=radius}
	mode.shapes = shapes
	mode:renderCollisions()
end

local M = {}

function M:setup()
	M.structures = {x=0, y=0, width=0, height=0, type=_NEWGROUP, children={}}
	self:modeAppend()
end

function M:modeAppend()
	return self:setMode(MODE_APPEND)
end

function M:modeSet()
	return self:setMode(MODE_SET)
end

function M:modeColPoly()
	return self:setMode(MODE_COL_POLY)
end

function M:modeColRect()
	return self:setMode(MODE_COL_RECT)
end

function M:modeColCircle()
	return self:setMode(MODE_COL_CIRCLE)
end

function M:setMode(state)
	self.mode = mode[state]
	mode.canvas = self
	self.mode.state = state
	return self.mode
end

local function createImage(structure, sheetNumber)
	local sheet = graphics.newImageSheet( structure.path, structure.sheetParams )
	return display.newImage( sheet, sheetNumber )
end

function M:createObject(structure, sheetNumber)
	local group = display.newGroup( )
	group.x = CX
	group.y = CY
	local gobj
	self.objectManager:insert(group)
	if self.data.type == 'image' then
		gobj = createImage(structure, sheetNumber)
		group:insert(gobj)
	end
	-- local icon = display.newRoundedRect( group, 0, 0, 80, 80, 24 )
	-- icon:setFillColor( 1, 0.3, 0.3, 0.6 )
	-- local lbl = display.newText( group, 'G', 0, 0 , native.systemFontBold, 48 )
	-- lbl:setFillColor( 0.5, 0.6, 0.7, 0.8 )
	self.isMouseMoving = false
	gobj:addEventListener( 'touch', function(event)
		if self.mode.state == MODE_COL_POLY or
			self.mode.state == MODE_COL_RECT or
			self.mode.state == MODE_COL_CIRCLE then
			return true
		end
		if event.phase == 'began' then
			-- gobj:scale(1.2, 1.2)
			self.isMouseMoving = false
		elseif event.phase == 'moved' then
			gobj.x = event.x - group.x
			gobj.y = event.y - group.y
			self.isMouseMoving = true
		elseif event.phase == 'ended' or event.phase == 'canceled' then
			if self.isMouseMoving then else
				self:modeSet():toggleMenu{x=event.x, y=event.y}
			end
			-- gobj:scale(1.0, 1.0)
			-- gobj.xScale = 1.0
			-- gobj.yScale = 1.0
		end
		return true
	end )
end

function M:show(params)
	local function loadStructure()
		local data = mode.canvas.data or {}
		if not data.structurePath then return end
		local path = data.structurePath.text
		if #path <= 0 then return end
		local structure = require(path:gsub('/', '.'):gsub('.lua', ''))
		local go = self:createObject(structure, tonumber(data.sheetNumber.text))

	end
	M.data = params.data
	M.callback = params.callback
	loadStructure()
	physics.start()
	physics.setDrawMode( "hybrid" )
end

function M:release()
	physics.stop()
	physics.setDrawMode( "normal" )
end

function M:createGenBtn()
	local function getPath(dir, data)
		local baseDir = storage:baseDir()
		local parentDir = 
			string.format('%ssrc/structures/gos', baseDir)
		local path = nil
		if storage:isDir(parentDir) then
			path =
				string.format('%s/%s.lua', parentDir, self.data.fileName.text)
		end
		return path
	end
	local function toData()
		local props = {}
		local target = mode:getTarget( )
		local gobj
		if target.numChildren > 0 then
			gobj = target[1]
		end
		props.potation = gobj.rotation
		props.xScale = gobj.xScale
		props.yScale = gobj.yScale
		props.anchorX = gobj.anchorX
		props.anchorY = gobj.anchorY
		return {
			path=self.data.structurePath.text,
			frameNum=tonumber(self.data.sheetNumber.text),
			props = props,
			colliders = mode.shapes,
		}
	end
	local function write(path, data)
		if storage:exists(path) then
			return
		end
		storage:writeTable(path, data)
	end
	local function generate()
		local path = getPath()
		if not path then return end
		local data = toData()
		if not data then return end
		write(path, data)
	end
	local genBtn = uiLib:createButton('Generate', 0, CH - 60, function(event)
		if event.phase == 'ended' then
			generate()
		end
	end)
	self.HUD:insert(genBtn)
end

function M:create(params)
	self:setup()

	M.root = display.newGroup( )
	params.parent:insert(M.root)
	M.HUD = display.newGroup( )
	params.parent:insert(M.HUD)
	M.objectManager = display.newGroup( )
	params.parent:insert(M.objectManager)
	M.marks = display.newGroup()
	params.parent:insert(M.marks)
	self:createContentBorder()
	self:createCenterAixs()
	self:startMouseEvent()
	self:createGenBtn()
end

function M:createContentBorder()
	local r = display.newRect( M.root, CX, CY, CW, CH )
	r.strokeWidth = 2
	r:setFillColor( 0, 0, 0, 0 )
	r:setStrokeColor(1, 1, 0)
end

function M:createCenterAixs()
	local yAxis = display.newLine( M.root, CX, 0, CX, CH )
	yAxis:setStrokeColor(0, 1, 0)
	local xAxis = display.newLine( M.root, 0, CY, CW, CY )
	xAxis:setStrokeColor(0, 1, 0)
end

function M:startMouseEvent()
	Runtime:addEventListener( 'touch', function(event)
		if self.data.type == 'level' then
			if event.phase == 'ended' then
				self:modeAppend():toggleMenu{x=event.x, y=event.y}
			end
			return false
		end
	end )
end

return M