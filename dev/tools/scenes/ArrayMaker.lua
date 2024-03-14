-- ArrayMaker.lua
local composer = require 'composer'
local scene = composer.newScene( )
local title
local labelTB
local itemList
local items = {}
local callback

local function createTitle()
	title = display.newText( 'Array Maker', 0, 0, native.systemFont, 24 )
	return uiLib:layout{
		background=display.newRect( 0, 0, display.actualContentWidth, HEADER_HEIGHT),
		evenCols={
			title,
		},
		bgcolor={1, 0, 0, 0.6}		
	}
end

local function createInputBox()
		labelTB = native.newTextField( CX, 160, 360, 48 )
		labelTB.placeholder = 'Input Text'
		labelTB:addEventListener( "userInput", function(event)
			if ( event.phase == "ended" or event.phase == "submitted" ) then
				if #labelTB.text > 0 then
					items[#items + 1] = {name=labelTB.text}
					labelTB.text = ''
					itemList:refresh(items)
				end 
			end
		end )

	return uiLib:layout{
		boxHeight=140,
		evenCols={
			labelTB,
		},
		-- bgcolor={0, 1, 0, 0.6}	
	}
end

local function createList()
	itemList = uiLib:list(nil, {
		width = display.actualContentWidth,
		height = 800,
		hideBackground = true,
		onRowRender = function( event )
			local phase = event.phase
			local row = event.row
			local rowTitle = display.newText( row, items[row.index].name , 0, 0, nil, 24 )
			rowTitle:setFillColor( 1, 0, 0 )
			rowTitle.x = 10
			rowTitle.anchorX = 0
			rowTitle.y = row.contentHeight * 0.5

			local btn = uiLib:createButton('Delete', 400, 0, function(event)
				if event.phase == 'ended' then
					table.remove( items, row.index )
					itemList:refresh(items)
				end
			end)
			row:insert(btn)
		end,
		onRowTouch =  function(event)
		end,
	})
	itemList:refresh(items)
	return uiLib:layout{
		boxHeight=800,
		evenCols={
			itemList
		}
	}
end

function createDoneBtn()
	return uiLib:layout{
		evenCols={
			uiLib:createButton('Done', 0, 0, function(event)
				if event.phase == 'ended' then
					if callback then
						callback(items)
					end
					utils.previous()
				end
			end)
		}
	}

end

function createContent(sceneGroup)
	return uiLib:layout{
		parent=sceneGroup,
		evenRows={
			createTitle(),
			createInputBox(),
			createList(),
			createDoneBtn(),
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
		labelTB.isVisible = true
		if event.params then
			items = event.params.items or {}
			title.text = event.params.title or title.text
			callback = event.params.callback
		end
	elseif event.phase == 'did' then
	end
end

function scene:hide(event)
	if event.phase == 'will' then
	elseif event.phase == 'did' then
		labelTB.isVisible = false
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene