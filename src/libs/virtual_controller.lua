-- virtual_controller.lua
local M = {}

local rootGroup
local actor
local buttonList
local cursorBase
local cursor

local function toLocalPos(origin, gPos)
	return  gPos.x - (rootGroup.x + origin.x), gPos.y - (rootGroup.y + origin.y)
end

local function isOut(x, y, radius)
	local nor = x * x + y * y
	local len = radius * radius
	return nor > len
end

local function touch(event)
	local x, y = toLocalPos(event.target.orig, event)
	event.target.lx = x
	event.target.ly = y
	if event.phase == 'began' then
		display.getCurrentStage():setFocus( event.target, event.id )
		event.target.pressed = true
	elseif event.phase == 'moved' then
		if isOut(x, y, event.target.orig.radius ) then
			display.getCurrentStage():setFocus( event.target, nil )
			event.target.pressed = false
		end

	elseif event.phase == 'ended' or event.phase == "cancelled"  then
		display.getCurrentStage():setFocus( event.target, nil )
		event.target.pressed = false
	end
	return true
end

function M:defaultCursor(group, curPos)
	local radius = curPos.radius or 64
	cursorBase = display.newCircle( group, 0, 0, radius )
	cursorBase:setFillColor( 0, 0, 0 )
	cursorBase.orig = {x=group.x, y=group.y, radius=radius}

	cursor = display.newCircle( group, 0, 0, 32 )
	cursor:setFillColor( 1, 0, 0 )
	return cursorBase
end

function M:createCursor(curPos, callback)
	local cursorGroup = display.newGroup()
	rootGroup:insert(cursorGroup)
	cursorGroup.x, cursorGroup.y = curPos.x, curPos.y

	self:defaultCursor(cursorGroup, curPos)
	cursorBase:addEventListener( 'touch', touch)
	cursorBase.counter = 0
	cursorBase.onTouch = callback
	buttonList[#buttonList + 1] = cursorBase

end

function M:defaultButton(group, btnPos)
	local radius = btnPos.radius or 24
	local button = display.newCircle( group, 0, 0, radius )
	local color = btnPos.color or {0.5, 0.5, 0.5}
	button:setFillColor(unpack( color ))
	button.orig = {x=group.x, y=group.y, radius=radius}
	return button
end

function M:createButton(btnPos, callback)
	local buttonsGroup = display.newGroup()
	rootGroup:insert(buttonsGroup)
	buttonsGroup.x, buttonsGroup.y = btnPos.x, btnPos.y

	local button = self:defaultButton(buttonsGroup, btnPos)
	button:addEventListener( 'touch', touch )
	button.counter = 0
	button.onTouch = callback
	buttonList[#buttonList + 1] = button
end

function M:createVirtualController(parent)
	buttonList = {}
	rootGroup = display.newGroup( )
	parent:insert(rootGroup)
	rootGroup.x, rootGroup.y = cx, cy
end

function M:moveCursor()
	if cursorBase.pressed then
		cursor.x, cursor.y = cursorBase.lx, cursorBase.ly
	else
		cursor.x, cursor.y = 0, 0
	end
end

function M:enterFrame(event)
	for i, btn in ipairs(buttonList) do
		if btn.pressed then
			btn.counter = btn.counter + 1
		else
			btn.counter = 0
		end
		if btn.onTouch then
			btn:onTouch()
		end
	end
	self:moveCursor()
end

return M