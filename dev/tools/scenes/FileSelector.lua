-- FileSelector.lua
local widget = require( "widget" )
local composer = require 'composer'
local scene = composer.newScene( )
local tableView
local items
local title
local seletectedItem = ''

local function update(params)
	items = params.items or {}
	title.text = params.title or  ''
	for i=1, #items do
		tableView:insertRow{
      isCategory = false,
      rowHeight = 64,
      rowColor = { default={0,0,0}, over={1,0.5,0,0.2} },
      lineColor = { 0.5, 0.5, 0.5 }
    }
	end
end

local function tableViewListener( event )
	local phase = event.phase
	--print( "Event.phase is:", event.phase )
end

local function onRowRender( event )
	local phase = event.phase
	local row = event.row
	local rowTitle = display.newText( row, items[row.index], 0, 0, nil, 14 )
	rowTitle.x = 10
	rowTitle.anchorX = 0
	rowTitle.y = row.contentHeight * 0.5
end

local function onRowUpdate( event )
	local phase = event.phase
	local row = event.row
	--print( row.index, ": is now onscreen" )
end

local function onRowTouch( event )
	local phase = event.phase
	local row = event.target
	if ( "release" == phase ) then
		seletectedItem = items[row.index]
		utils.hideFileSelector()
	end
end

local function createTable(sceneGroup)
	tableView = widget.newTableView
	{
		top = 160,
		left = 0,
		width = display.actualContentWidth,
		height = 800,
		hideBackground = true,
		listener = tableViewListener,
		onRowRender = onRowRender,
		onRowUpdate = onRowUpdate,
		onRowTouch = onRowTouch,
	}
	sceneGroup:insert( tableView )

end

local function createTitle(sceneGroup)
	title = display.newText( seletectedItem, 0, 0, native.systemFont, 24 )
	uiLib:layout{
		parent=sceneGroup,
		background=display.newRect( 0, 0, display.actualContentWidth, HEADER_HEIGHT),
		evenCols={
			title,
		},
		bgcolor={1, 0, 0, 0.6}		
	}
end

local function createClose(sceneGroup)
	local btn = uiLib:createButton('Close', CX, 900, function(event)
		seletectedItem = ''
		utils.hideFileSelector()
	end)
	btn.anchorX = 1
	sceneGroup:insert(btn)
end

local function createBackground(sceneGroup)
	local topInset, leftInset, bottomInset, rightInset
		 = display.getSafeAreaInsets()
	local bg = display.newRect( 
		sceneGroup, CX, CY + topInset, display.contentWidth, display.contentHeight )
	bg:setFillColor( 0, 0, 0 )
end

local function createContent(sceneGroup)
	createBackground(sceneGroup)
	createTitle(sceneGroup)
	createTable(sceneGroup)
	createClose(sceneGroup)
end

function scene:create(event)
	local sceneGroup = self.view
	createContent(sceneGroup)
end

function scene:show(event)
	local sceneGroup = self.view
	if event.phase == 'will' then
		update(event.params)
	elseif event.phase == 'did' then
	end
end

function scene:hide(event)
	if event.phase == 'will' then
		local parent = event.parent
		parent:resumeGame(seletectedItem)
	elseif event.phase == 'did' then
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene