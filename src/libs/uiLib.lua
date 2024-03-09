-- uiLib.lua
local widget = require 'widget'

local M = {}

function M:layout(params)
	local parent = params.parent
	local height = params.height or 160
	local aWidth = display.actualContentWidth
	local aHeight = display.actualContentHeight
	local color = params.color or {1, 0, 0}
	local group = display.newGroup()
	local topInset, leftInset, bottomInset, rightInset
		 = display.getSafeAreaInsets()
	local cols = params.evenCols or {}
	local colOffsetX = params.colOffsetX or 0
	local colWidth = math.round(aWidth / (#cols))

	local rows = params.evenRows or {}
	local rowHeight = math.round(params.RowHegiht or 60)
	local rowsHeight = rowHeight * #rows
	
	local posY = topInset + height / 2
	if params.posY then
		posY = posY + params.posY
	end
	local posX = leftInset + aWidth / 2
	if params.posX then
		posX = posX + params.posX
	else
		posX = leftInset + aWidth / 2
	end

	parent:insert(group)

	local bg = display.newRect(
		group,
		0,
		0,
		aWidth,
		height)
	bg:setFillColor(unpack(color))

	if #cols > 0 then
		local w = colWidth
		local wh = w / 2
		for i=1,#cols do
			local cell = cols[i]
			group:insert(cell)
			cell.x = -aWidth / 2 + colOffsetX + wh + (i - 1) * w
			cell.y = 0
		end
	end

	if #rows > 0 then
		local h = rowHeight
		local hh = h / 2
		for i=1,#rows do
			local cell = rows[i]
			group:insert(cell)
			cell.x = 0
			cell.y = -rowsHeight / 2 + hh + (i - 1) * h
		end
	end

	group.x = posX
	group.y = posY
	return group
end

function M:createButton(title, x, y, onEvent)
	local button = widget.newButton( {
		left=x,
		top=y,
		id=title,
		label=title,
		onEvent=onEvent
	} )
	-- group:insert(button)
	return button
end

function M:nineslice(params)
	local parent = params.parent
	local frame = display.newGroup()
	if parent then parent:insert(frame) end
	local x, y = params.x or cx, params.y or cy
	local halfWidth = params.width / 2
	local halfHeight = params.height / 2
	local halfBarsize = params.barsize / 2
	local imageSheet = params.imageSheet
	local top = y - halfHeight - halfBarsize
	local bottom = y + halfHeight + halfBarsize
	local left = x - halfWidth - halfBarsize
	local right = x + halfWidth + halfBarsize

	local topleft = display.newImageRect(frame, imageSheet, 1, params.barsize, params.barsize)
	topleft.x, topleft.y = left, top
	local topcenter = display.newImageRect(frame, imageSheet, 2, params.width, params.barsize)
	topcenter.x, topcenter.y = x, top
	local topright = display.newImageRect(frame, imageSheet, 3, params.barsize, params.barsize)
	topright.x, topright.y = right, top
	local centerleft = display.newImageRect(frame, imageSheet, 4, params.barsize, params.height)
	centerleft.x, centerleft.y = left, y
	local centerright = display.newImageRect(frame, imageSheet, 5, params.barsize, params.height)
	centerright.x, centerright.y = right, y
	local bottomleft = display.newImageRect(frame, imageSheet, 6, params.barsize, params.barsize)
	bottomleft.x, bottomleft.y = left, bottom
	local bottomcenter = display.newImageRect(frame, imageSheet, 7, params.width, params.barsize)
	bottomcenter.x, bottomcenter.y = x, bottom
	local bottomright = display.newImageRect(frame, imageSheet, 8, params.barsize, params.barsize)
	bottomright.x, bottomright.y = right, bottom
end

return M