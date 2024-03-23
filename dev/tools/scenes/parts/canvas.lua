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

local TYPE_LABEL = 0
local TYPE_BUTTON = 1
local TYPE_TEXT = 2

local mode = {}
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
	local menusPos = params.itemsNum * 60 / 4
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
		for k, v in pairs(table) do
			itemsNum = itemsNum + 1
		end
		params.itemsNum = itemsNum
		local frameHeigth = itemsNum * 60 / 2 + 12
		local frame = display.newRoundedRect( self.canvas.menuGroup, params.x, params.y-12, 400, frameHeigth, 30 )
		frame:setFillColor( 1, 0, 0, 0.7 )
		mode:createButtons(params)
	else
		self:hide()
	end
end

mode[MODE_APPEND] = {}
function mode.MODE_APPEND:toggleMenu(params)
	params.items = {
		_NEWGROUP={type=TYPE_BUTTON, fn=function(event)
			print(_NEWGROUP) 
			mode:createGroup(params)
		end,},
		_NEWSPRITE={type=TYPE_BUTTON, fn=function(event)
			print(_NEWSPRITE) 
utils.gotoFilePicker({params={currentDir='../', callback=function(values)
		table.print(values)
	end}})

		end,},
		_NEWRECT={type=TYPE_BUTTON, fn=function(event)
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

mode[MODE_SET] = {}
function mode.MODE_SET:toggleMenu(params)
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
	}
	mode:toggleMenu(params)
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

function M:setMode(state)
	self.mode = mode[state]
	mode.canvas = self
	return self.mode
end

function M:create(params)
	self:setup()

	M.root = display.newGroup( )
	params.parent:insert(M.root)
	M.HUD = display.newGroup( )
	params.parent:insert(M.HUD)
	M.objectManager = display.newGroup( )
	params.parent:insert(M.objectManager)
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
		if event.phase == 'ended' then
			self:modeAppend():toggleMenu{x=event.x, y=event.y}
		end
		return false
	end )
end

return M