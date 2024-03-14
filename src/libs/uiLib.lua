-- uiLib.lua
local widget = require 'widget'

local M = {}

function M:list(parent, options)
	local function tableViewListener( event )
		local phase = event.phase
	end

	local function onRowRender( event )
		local phase = event.phase
		local row = event.row
		local rowTitle = display.newText( row, "Row " .. row.index, 0, 0, nil, 14 )
		rowTitle.x = 10
		rowTitle.anchorX = 0
		rowTitle.y = row.contentHeight * 0.5
	end

	local function onRowUpdate( event )
		local phase = event.phase
		local row = event.row
	end

	local function onRowTouch( event )
		local phase = event.phase
		local row = event.target
		if ( "release" == phase ) then
		end
	end

	local tableView = widget.newTableView(options)
	if options.listener then
		options.listener = tableViewListener
	end
	if options.onRowRender then
		options.onRowRender = onRowRender
	end
	if options.onRowUpdate then
		options.onRowUpdate = onRowUpdate
	end
	if options.onRowTouch then
		options.onRowTouch = onRowTouch
	end

	if parent then
		parent:insert(tableView)
	end

	tableView.refresh = function(self, items, params)
		self:deleteAllRows( )
		for i=1, #items do
			local options = params or {
	      isCategory = false,
	      rowHeight = 48,
	      rowColor = { default={0,0,0}, over={1,0.5,0,0.2} },
	      lineColor = { 0.5, 0.5, 0.5 }
			}
			self:insertRow(options)
		end
	end

	return tableView
end

function M:layout(params)
	local parent = params.parent
	local aWidth = display.actualContentWidth
	local aHeight = display.actualContentHeight
	local group = display.newGroup()
	group.boxWidth = params.boxWidth or aWidth
	group.boxHeight = params.boxHeight
	local background = params.background
	local bgcolor = params.bgcolor
	local topInset, leftInset, bottomInset, rightInset
		 = display.getSafeAreaInsets()
	local cols = params.evenCols or {}
	local colOffsetX = params.colOffsetX or 0
	local colWidth = math.round(aWidth / (#cols))

	local rows = params.evenRows or {}
	local rowHeight = math.round(params.RowHeight or 60)
	local rowsHeight = rowHeight * #rows
	
	if parent then
		parent:insert(group)
	end

	if background then
		group:insert(background)
		if bgcolor then
			background:setFillColor(unpack(bgcolor))
		end
	else
		if bgcolor then
			local bg = display.newRect(
				group,
				0,
				0,
				group.boxWidth,
				group.boxHeight)
			bg:setFillColor(unpack(bgcolor))
		end
	end

	if #cols > 0 then
		for i=1,#cols do
			local w = colWidth
			if cols[i].boxWidth then
				w = cols[i].boxWidth
			end
			local wh = w / 2
			local cell = cols[i]
			group:insert(cell)
			cell.x = -aWidth / 2 + colOffsetX + wh + (i - 1) * w
			cell.y = 0
		end
	end

	if #rows > 0 then
		local totalHeight = 0
		for i=1,#rows do
			if rows[i].boxHeight then
				totalHeight = totalHeight + rows[i].boxHeight
			else
				totalHeight = totalHeight + rowHeight
			end
		end
		if totalHeight > 0 then
			rowsHeight = totalHeight
		end

		local amountHeight = 0
		for i=1,#rows do
			local h = rowHeight
			if rows[i].boxHeight then
				h = rows[i].boxHeight
			end
			local hh = h / 2
			amountHeight = amountHeight + h
			local cell = rows[i]
			group:insert(cell)
			cell.x = 0
			cell.y = -rowsHeight / 2 + amountHeight - hh
		end
	end

	local posY = topInset + rowsHeight / 2
	if params.posY then
		posY = posY + params.posY
	end
	local posX = leftInset + aWidth / 2
	if params.posX then
		posX = posX + params.posX
	else
		posX = leftInset + aWidth / 2
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