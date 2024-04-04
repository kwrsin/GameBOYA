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
	}
	if mode.shapes and #mode.shapes > 0 then
		for i, shape in ipairs(mode.shapes) do
			local title = string.format('delete shape_%i', i)
			params.items[title]={type=TYPE_BUTTON, fn=function(event)
				local s = table.remove(mode.shapes, i)
				display.remove(s)
				s = nil
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
	if #mode.pointers < 2 then return end
	local lPos = {}
	for i, p in ipairs(mode.pointers) do
		lPos[#lPos + 1] = p.x - go.x
		lPos[#lPos + 1] = p.y - go.y 
	end
	lPos[#lPos + 1] = lPos[1]
	lPos[#lPos + 1] = lPos[2]
	local poly = display.newLine( go, unpack(lPos) )
	poly:setStrokeColor( 1, 0, 0, 1 )
	poly.strokeWidth = 8
	local shapes = mode.shapes or {}
	shapes[#shapes + 1] = poly
	mode.shapes = shapes
end

mode[MODE_COL_RECT] = {}
function mode.MODE_COL_RECT:toggleMenu(params)
 return 
end
function mode.MODE_COL_RECT:refrect()
	local go = mode:getTarget( )
	if not go then return end
	local x, y, width, height
	if #mode.pointers <= 0 then
		x, y = 0, 0
		width, height = go.width, go.height
	elseif #mode.pointers <= 1 then
		x, y = 0, 0
		width = math.abs((mode.pointers[1].x - CX) * 2)
		height = math.abs((mode.pointers[1].y - CY) * 2)
	elseif #mode.pointers <= 2 then
		x, y = mode.pointers[1].x - go.x, mode.pointers[1].y - go.y
		width, height = math.abs((mode.pointers[1].x - mode.pointers[2].x) * 2), math.abs((mode.pointers[1].y - mode.pointers[2].y) * 2)
	end
	local rect = display.newRect(go, x, y, width, height)
	rect:setFillColor( 1, 0, 0, 0.4 )
	local shapes = mode.shapes or {}
	shapes[#shapes + 1] = rect
	mode.shapes = shapes
end

mode[MODE_COL_CIRCLE] = {}
function mode.MODE_COL_CIRCLE:toggleMenu(params)
 return 
end
function mode.MODE_COL_CIRCLE:refrect()
	local go = mode:getTarget( )
	if not go then return end
	local x, y, radius
	if #mode.pointers <= 0 then
		x, y = 0, 0
		radius = go.width / 2
	elseif #mode.pointers <= 1 then
		x, y = 0, 0
		radius = math.abs(mode.pointers[1].x - CX)
	elseif #mode.pointers <= 2 then
		x, y = mode.pointers[1].x - go.x, mode.pointers[1].y - go.y
		radius = math.abs(mode.pointers[1].x - mode.pointers[2].x)
	end
	local circle = display.newCircle( go, x, y, radius )
	circle:setFillColor( 1, 0, 0, 0.4 )
	local shapes = mode.shapes or {}
	shapes[#shapes + 1] = circle
	mode.shapes = shapes
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
	self.objectManager:insert(group)
	if self.data.type == 'image' then
		local img = createImage(structure, sheetNumber)
		group:insert(img)
	end
	-- local icon = display.newRoundedRect( group, 0, 0, 80, 80, 24 )
	-- icon:setFillColor( 1, 0.3, 0.3, 0.6 )
	-- local lbl = display.newText( group, 'G', 0, 0 , native.systemFontBold, 48 )
	-- lbl:setFillColor( 0.5, 0.6, 0.7, 0.8 )
	self.isMouseMoving = false
	group:addEventListener( 'touch', function(event)
		if self.mode.state == MODE_COL_POLY or
			self.mode.state == MODE_COL_RECT or
			self.mode.state == MODE_COL_CIRCLE then
			return true
		end
		if event.phase == 'began' then
			group:scale(1.2, 1.2)
			self.isMouseMoving = false
		elseif event.phase == 'moved' then
			group.x = event.x
			group.y = event.y
			self.isMouseMoving = true
		elseif event.phase == 'ended' or event.phase == 'canceled' then
			if self.isMouseMoving then else
				self:modeSet():toggleMenu{x=event.x, y=event.y}
			end
			-- group:scale(1.0, 1.0)
			group.xScale = 1.0
			group.yScale = 1.0
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

end

function M:release()

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