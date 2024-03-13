-- RelationsMaker.lua
local composer = require 'composer'
local scene = composer.newScene( )
local collisionTB
local collisionList
local collisions = {}
local rowIdx = 0

publisher:observe(BIND_SELECTEDITEMS, {})

local function updateCollisionList()
	collisionList:deleteAllRows( )
	for i=1, #collisions do
		collisionList:insertRow{
      isCategory = false,
      rowHeight = 48,
      rowColor = { default={0,0,0}, over={1,0.5,0,0.2} },
      lineColor = { 0.5, 0.5, 0.5 }
		}
	end
end

local function createTitle()
	return uiLib:layout{
		background=display.newRect( 0, 0, display.actualContentWidth, HEADER_HEIGHT),
		evenCols={
			display.newText( 'Relations Maker', 0, 0, native.systemFont, 24 )
		},
		bgcolor={1, 0, 0, 0.6}		
	}
end

local function createCollisionEntry()
	collisionTB = native.newTextField( 0, 0, 280, 32 )
	return uiLib:layout{
		evenCols={
			display.newText('Collision:', 0, 0, native.systemFontBold, 24),
			collisionTB,
			uiLib:createButton('New', 0, 0, function(event)
				if event.phase == 'ended' then
					-- local options = {}
					-- options.params = {
					-- 	path = filename.text,
					-- 	sheetParams = getSheetParams(),
					-- 	sequences = {}
					-- }

					-- utils.gotoSequenceMaker(options)
					if collisionTB.text == "" then
						return
					end
					local categoryBits = #collisions <= 0 and 1 or collisions[#collisions].categoryBits * 2
					collisions[#collisions + 1] = {name=collisionTB.text, categoryBits=categoryBits}
					collisionTB.text = ""
					updateCollisionList()
				end
			end)
		},
	}
end


local function getRowContent(collision)
	return string.format( '%s[%s]: ' ,collision.name, collision.categoryBits )
end

local function getOthers(others)
	local str = ''
	for i, o in ipairs(others) do
		str = str .. o.name .. ', '
	end
	return str
end

local function createCollisionList()
	local g = display.newGroup( )

	collisionList = uiLib:list(g, {
		top = 0,
		left = -CX,
		width = display.actualContentWidth,
		height = 800,
		hideBackground = true,
		onRowRender = function( event )
			local phase = event.phase
			local row = event.row
			local rowTitle = display.newText( row, getRowContent(collisions[row.index]) , 0, 0, nil, 14 )
			rowTitle:setFillColor( 1, 0, 0 )
			rowTitle.x = 10
			rowTitle.anchorX = 0
			rowTitle.y = row.contentHeight * 0.5

			local others = getOthers(collisions[row.index].others or {})
			if #others > 0 then
				local rowOthers = display.newText( row, ' : ' .. others , 0, 0, nil, 14 )
				rowOthers:setFillColor( 1, 0, 0 )
				rowOthers.x = 180
				rowOthers.anchorX = 0
				rowOthers.y = row.contentHeight * 0.5
			end

			local btn = uiLib:createButton('Delete', 400, 0, function(event)
				if event.phase == 'ended' then
					table.remove( collisions, row.index )
					updateCollisionList()
				end
			end)
			row:insert(btn)
		end,
		onRowTouch =  function(event)
			if ( "tap" == event.phase ) then
				local row = event.row
				rowIdx = row.index
				utils.gotoMultiSelector({
					params={
						title=string.format('Relations :%s[%s]', collisions[rowIdx].name, collisions[row.index].categoryBits),
						items=collisions,
						targetIdx=row.index,
					}
				})
			end
		end
	})
	collisionList.update = function(obj, event)
		collisions[rowIdx].others = utils.merge(event.value.selectedItems, {})
		updateCollisionList()
	end
	publisher:subscribe(BIND_SELECTEDITEMS, collisionList)

	updateCollisionList()
	return uiLib:layout{
		evenRows={
			g,
		},
	}
end


local function createContent(sceneGroup)
	uiLib:layout{
		parent=sceneGroup,
		evenRows={
			createTitle(),
			createCollisionEntry(),
			createCollisionList()
		}
	}
end


function scene:create(event)
	local sceneGroup = self.view
	createContent(sceneGroup)
end

function scene:show(event)
	local sceneGroup = self.view
	if event.phase == 'will' then
		collisionTB.isVisible = true
	elseif event.phase == 'did' then
	end
end

function scene:hide(event)
	if event.phase == 'will' then
	elseif event.phase == 'did' then
		collisionTB.isVisible = false
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene