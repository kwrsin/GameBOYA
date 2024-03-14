-- MultiSelector.lua
local composer = require 'composer'
local scene = composer.newScene( )
local items
local multiSelectorTable
local title
local response
local targetIdx

local function update(params)
	items = params.items or {}
	title.text = params.title or ''
	targetIdx = params.targetIdx
	response = params.response
	multiSelectorTable:deleteAllRows()
	for i=1, #items do
		multiSelectorTable:insertRow{
      isCategory = false,
      rowHeight = 64,
      rowColor = { default={0,0,0}, over={1,0.5,0,0.2} },
      lineColor = { 0.5, 0.5, 0.5 }
    }
	end
end

local function createTitle()
	title = display.newText( 'Item Selector', 0, 0, native.systemFont, 24 )
	return uiLib:layout{
		background=display.newRect( 0, 0, display.actualContentWidth, HEADER_HEIGHT),
		evenCols={
			title,
		},
		bgcolor={1, 0, 0, 0.6}		
	}
end

local function getRowContent(item)
	return string.format( '%s[%s]:' , item.name, item.categoryBits)
end

local function createTable(sceneGroup)
	multiSelectorTable = uiLib:list(sceneGroup, {
		top = 160,
		left = 0,
		width = display.actualContentWidth,
		height = 800,
		hideBackground = true,
		listener = tableViewListener,
		onRowRender = function(event)
			local phase = event.phase
			local row = event.row
			local rowTitle = display.newText( row, items[row.index].name , 0, 0, nil, 14 )
			rowTitle:setFillColor( 1, 0, 0 )
			rowTitle.x = 10
			rowTitle.anchorX = 0
			rowTitle.y = row.contentHeight * 0.5

			if items[row.index].selected then
				local r = display.newRect( row, row.width / 2, row.height / 2, row.width, row.height )
				r:setFillColor( 1, 0, 1, 0.5 )
			end
		end,
		onRowTouch =  function(event)
			local row = event.row
			local col = items[row.index]
			col.selected = not col.selected
			multiSelectorTable:reloadData( )
		end,
	})
end

function createContent(sceneGroup)
	return uiLib:layout{
		parent=sceneGroup,
		evenRows={
			createTitle(),
		}
	}
end

function createDone(sceneGroup)
	return uiLib:layout{
		parent=sceneGroup,
		posY=960,
		evenRows={
			uiLib:createButton('done', 0, 0, function(event)
				if event.phase == 'ended' then
					if response then
						local selectedItems = utils.deepcopy(items)
						response({selectedItems=selectedItems, targetIdx=targetIdx})
					end
					items = {}
					utils.previous()
				end
			end)
		}
	}
end


function scene:create(event)
	local sceneGroup = self.view
	createContent(sceneGroup)
	createTable(sceneGroup)
	createDone(sceneGroup)
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
	elseif event.phase == 'did' then
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene