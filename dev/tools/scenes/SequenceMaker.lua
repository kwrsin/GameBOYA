local widget = require 'widget'
local composer = require 'composer'
local scene = composer.newScene( )

local nameTB
local loopCountTB
local timeTB
local data
local containerGroup
local imageGO
local selectorGroup
local cells
local unselectedColor = {0, 0, 1, 0.2}
local selectedColor = {1, 0, 0, 0.2}
local previewGroup
local previewSprite
local selectedFrames

local function background(sceneGroup)
	local topInset, leftInset, bottomInset, rightInset
		 = display.getSafeAreaInsets()
	local bg = display.newRect( 
		sceneGroup, CX, CY + topInset, display.contentWidth, display.contentHeight )
	bg:setFillColor( 0, 0, 0 )
end

local function createTitle(sceneGroup)
	uiLib:layout{
		parent=sceneGroup,
		background=display.newRect( 0, 0, display.actualContentWidth, HEADER_HEIGHT),
		evenCols={
			display.newText( 'Sequence Maker', 0, 0, native.systemFont, 24 ),
		},
		bgcolor={1, 0, 0, 0.6}		
	}
end

local function nameField()
	nameTB = native.newTextField( 0, 0, 200, 32 )
	return uiLib:layout{
		evenCols={
			display.newText( 'Sequence Name:', 0, 0, native.systemFont, 24 ),	
			nameTB,		
		}
	}
end

local function loopCountField()
	loopCountTB = native.newTextField( 0, 0, 200, 32 )
	loopCountTB.inputType = "number"
	return uiLib:layout{
		evenCols={
			display.newText( 'Loop Count:', 0, 0, native.systemFont, 24 ),	
			loopCountTB,		
		}
	}
end

local function timeField()
	timeTB = native.newTextField( 0, 0, 200, 32 )
	timeTB.inputType = "number"
	return uiLib:layout{
		evenCols={
			display.newText( 'Time:', 0, 0, native.systemFont, 24 ),	
			timeTB,		
		}
	}
end

local function center(sceneGroup)
	return uiLib:layout{
		parent=sceneGroup,
		posY=140,
		evenRows={
			nameField(),
			loopCountField(),
			timeField(),
		}
	}
end

local function framesSelector(sceneGroup)
	-- containerGroup = display.newGroup()
	-- sceneGroup:insert(containerGroup)
	-- containerGroup.x, containerGroup.y = CX, CY
	containerGroup = widget.newScrollView
			{
				x = CX,
				y = CY + 60,
				width = 600,
				height = 400,
				hideBackground = true,
				topPadding = 0,
				bottomPadding = 0
			}
	sceneGroup:insert(containerGroup)
end

local function clear()
	selectedFrames = {}
	if cells and #cells > 0 then
		for i, cell in ipairs(cells) do
			cell.selected = false
			cell:setFillColor( unpack( unselectedColor ) )
		end
	end
end

local function getIdxFromFrames(value)
	local idx = 0
	for i, frame in ipairs(selectedFrames) do
		if frame == value then
			idx = i
			break
		end
	end
	return idx
end

local function update()
	local iWidth = math.round(data.sheetParams.sheetContentWidth)
	local iHeight = math.round(data.sheetParams.sheetContentHeight)
	local sWidth = math.round(data.sheetParams.width)
	local sHeight = math.round(data.sheetParams.height)
	local cols = math.round(iWidth / sWidth)
	local rows = math.round(iHeight / sHeight)
	local startXpos = -iWidth / 2 + sWidth / 2
	local startYpos = -iHeight / 2 + sHeight / 2

	cells = {}
	imageGO = display.newImageRect( 
		containerGroup, 
		data.path, 
		iWidth, 
		iHeight)
	-- selectorGroup = display.newGroup()
	-- containerGroup:insert(selectorGroup)
	for j=1,rows do
		for i=1,cols do
			local idx = (j - 1) * cols + i
			local rect = display.newRect( 
				containerGroup, 
				startXpos + (i-1) * sWidth, 
				startYpos + (j-1) * sHeight, 
				sWidth, 
				sHeight )
			rect.value = idx
			local selected = false
			if data.selectedItem and 
				data.selectedItem.frames and 
				#data.selectedItem.frames > 0 then
				for i, frame in ipairs(data.selectedItem.frames) do
					if idx == frame then
						selected = true
						selectedFrames[#selectedFrames + 1] = frame
					end
				end
			end
			rect.selected = selected
			if selected then
				rect:setFillColor( unpack( selectedColor ) )
			else
				rect:setFillColor( unpack( unselectedColor ) )
			end
			rect:addEventListener( 'tap', function(event)
				event.target.selected = not event.target.selected
				if event.target.selected then
					selectedFrames[#selectedFrames + 1] = event.target.value
					rect:setFillColor( unpack( selectedColor ) )
				else
					local i = getIdxFromFrames(event.target.value)
					if i > 0 then
						table.remove( selectedFrames, i )
					end
					rect:setFillColor( unpack( unselectedColor ) )
				end
			end )
			cells[#cells + 1] = rect
		end
	end
end

local function previewStop()
	if previewSprite then
		display.remove(previewSprite)
		previewSprite = nil
	end
end

local function previewPlay()
	if previewSprite then
		previewStop()
	end
	if not data then return end
	local options = {
		loopCount = tonumber( loopCountTB.text ),
		time = tonumber( timeTB.text ),
		frames = selectedFrames
	}
	local imageSheet = graphics.newImageSheet( data.path, data.sheetParams )
	previewSprite = display.newSprite( previewGroup, imageSheet, options )
	previewSprite:play()
end

local function createToggle()
	toggle = uiLib:createButton('Preview', 0, 0, function(event)
		if event.phase == 'ended' then
			if event.target.isPlaying then
				event.target.isPlaying = false
				event.target:setLabel('Play')
				previewStop()
			else
				event.target.isPlaying = true
				event.target:setLabel('Stop')
				previewPlay()
			end
		end
	end)
	toggle.isPlaying = false
	return toggle
end

local function frameField()
	return uiLib:layout{
		evenCols={
			uiLib:createButton('Clear', 0, 0, function(event)
				if event.phase == 'ended' then
					clear()
				end
			end),
			createToggle(),
		}
	}
end

local function previewField()
	previewGroup = display.newGroup()
	local sWidth = math.round(64)
	local sHeight = math.round(64)

	local bg = display.newRect(previewGroup, 0, 0, sWidth, sHeight)
	bg:setFillColor(0.3, 0.7, 0.3, 0.4)
	return previewGroup
end

local function doneField()
	return uiLib:createButton('Done', 0, 0, function(event)
		if event.phase == 'ended' then
			local result = {
				name=nameTB.text,
				loopCount=tonumber(loopCountTB.text),
				time=tonumber(timeTB.text),
				frames=selectedFrames
			}
			publisher:put({}, BIND_SEQUENCE, result)
			utils.previous()
		end
	end)
end

local function bottom(sceneGroup)
	return uiLib:layout{
		parent=sceneGroup,
		posY=800,
		evenRows={
			frameField(),
			previewField(),
			doneField()
		}
	}
end

local function createContent(sceneGroup)
	background(sceneGroup)
	createTitle(sceneGroup)
	center(sceneGroup)
	framesSelector(sceneGroup)
	bottom(sceneGroup)
end

function scene:create(event)
	local sceneGroup = self.view
	createContent(sceneGroup)
end

function scene:show(event)
	local sceneGroup = self.view
	if event.phase == 'will' then
		selectedFrames = {}
		nameTB.isVisible = true
		loopCountTB.isVisible = true
		timeTB.isVisible = true
		data = event.params
		nameTB.text = ''
		loopCountTB.text = '0'
		timeTB.text = '270'
		update()
	elseif event.phase == 'did' then
	end
end

function scene:hide(event)
	if event.phase == 'will' then
	elseif event.phase == 'did' then
		nameTB.isVisible = false
		loopCountTB.isVisible = false
		timeTB.isVisible = false

		if previewSprite then
			display.remove(previewSprite)
			previewSprite = nil
		end
		for i, cell in ipairs(cells) do
			display.remove(cell)
			cell = nil
		end
		display.remove(imageGO)
		imageGO = nil
		display.remove(selectorGroup)
		selectorGroup = nil
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene