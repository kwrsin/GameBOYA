-- GOSDataMaker.lua
local composer = require 'composer'
local scene = composer.newScene( )
local root = display.newGroup( )
local filename
local selectedImage
local imageWidth
local imageHeight
local spriteWidth
local spriteHeight
local numFrames
local sequenceList
local sequences = {}

publisher:observe(BIND_SELECTEDITEM, {})
publisher:observe(BIND_SEQUENCE, {})

local function getImageDimention(selectedItem)
	selectedImage = display.newImage( selectedItem )
	local width, height = selectedImage.width, selectedImage.height
	display.remove( selectedImage )
	return width, height
end

local function createTopView()
	uiLib:layout{
		parent=root,
		-- posY=0,
		-- posX=0,
		evenCols={
			display.newText( 'GOSDataMaker', 0, 0, native.systemFont, 24 )
		},
		-- evenRows={
		-- 	display.newText( 'text4', 0, 0, native.systemFont, 24 ),
		-- 	display.newText( 'text5', 0, 0, native.systemFont, 24 ),
		-- 	display.newText( 'text6', 0, 0, native.systemFont, 24 ),
		-- 	display.newText( 'text7', 0, 0, native.systemFont, 24 )
		-- },
		background=display.newRect( 0, 0, display.actualContentWidth, HEADER_HEIGHT),
		bgcolor={1, 0, 0, 0.6}
	}
end

local function fileField()
	local parent = display.newGroup()
	display.newText(parent, 'File Name:', -240, 0, native.systemFontBold, 24)
	filename = native.newTextField( -20, 0, 280, 48 )
	filename.update = function(obj, event)
		filename.text = event.value.selectedItem
		imageWidth.text, imageHeight.text = getImageDimention(filename.text)
	end
	publisher:subscribe(BIND_SELECTEDITEM, filename)
	parent:insert(filename)
	local btn = uiLib:createButton('Open', 80, -24, function(event)
		if event.phase == 'ended' then
			local files = storage:files(IMAGES_PATH)
			local items = {}
			for i, file in ipairs(files) do
				items[#items + 1] = string.format( '%s%s', IMAGES_BASE_PATH, file )
			end
			utils.gotoFileSelector(
				{
					params={
						title='File Selector', 
						items=items
					}
				})
		end
	end)
	parent:insert(btn)

	return parent
end

local function imageField()
	local lblWidth = display.newText('width:', 0, 0, native.systemFontBold, 24)
	imageWidth = display.newText('', 0, 0, native.systemFontBold, 24)
	local lblHeight = display.newText('height:', 0, 0, native.systemFontBold, 24)
	imageHeight = display.newText('', 0, 0, native.systemFontBold, 24)
	return uiLib:layout{
		parent=root,
		posX=CX,
		evenCols={
			lblWidth,
			imageWidth,
			lblHeight,
			imageHeight
		},
		bgcolor={0, 0, 0, 0},
	}
end

local function updateNumFrames()
	local spWidth = tonumber( spriteWidth.text ) or 0
	local spHeight = tonumber( spriteHeight.text ) or 0
	local imgWidth = tonumber( imageWidth.text ) or 0
	local imgHeight = tonumber( imageHeight.text ) or 0
	local tileWidth = math.round( imgWidth / spWidth )
	local tileHeight = math.round( imgHeight / spHeight )
	numFrames.text = tostring( tileWidth * tileHeight )
end

local function spriteField()
	local function userInput( event )
    if event.phase == "ended" or event.phase == "submitted"  then
      updateNumFrames()
    end
	end
	local lblSpriteWidth = display.newText('width:', 0, 0, native.systemFontBold, 24)
	spriteWidth = native.newTextField( 0, 0, 60, 32 )
	spriteWidth.inputType = "number"
	spriteWidth:addEventListener( "userInput", userInput )
	local lblSpriteHeight = display.newText('height:', 0, 0, native.systemFontBold, 24)
	spriteHeight = native.newTextField( 0, 0, 60, 32 )
	spriteHeight.inputType = "number"
	spriteHeight:addEventListener( "userInput", userInput )
	local lblNumFrames = display.newText('NumFrames:', 0, 0, native.systemFontBold, 24)
	numFrames = display.newText('', 0, 0, native.systemFontBold, 24)
	return uiLib:layout{
		parent=root,
		posX=CX,
		evenCols={
			lblSpriteWidth,
			spriteWidth,
			lblSpriteHeight,
			spriteHeight,
			lblNumFrames,
			numFrames
		},
		bgcolor={0, 0, 0, 0},
	}
end

local function getSheetParams()
	return {
		numFrames=numFrames.text,
		width=spriteWidth.text,
		height=spriteHeight.text,
		sheetContentHeight=imageHeight.text,
		sheetContentWidth=imageWidth.text,
	}
end

local function sequenceAppendField()
	local lblSequence = display.newText('Secuences:', 0, 0, native.systemFontBold, 24)
	local btnNewSequence = uiLib:createButton('New', 0, 0, function(event)
		if event.phase == 'ended' then
			local options = {}
			options.params = {
				path = filename.text,
				sheetParams = getSheetParams(),
				sequences = {}
			}

			utils.gotoSequenceMaker(options)
		end
	end)
	return uiLib:layout{
		parent=root,
		posX=CX,
		evenCols={
			lblSequence,
			btnNewSequence
		},
		bgcolor={0, 0, 0, 0},
	}
end

local function updateSequenceList()
	sequenceList:deleteAllRows()
	for i=1, #sequences do
		sequenceList:insertRow{
      isCategory = false,
      rowHeight = 48,
      rowColor = { default={0,0,0}, over={1,0.5,0,0.2} },
      lineColor = { 0.5, 0.5, 0.5 }
    }
	end
end

local function sequenceListView()
	sequenceList = uiLib:list(nil, {
		top = 0,
		left = 0,
		width = 560,
		height = 260,
		hideBackground = true,
		onRowRender = function( event )
			local phase = event.phase
			local row = event.row
			local rowTitle = display.newText( row, sequences[row.index], 0, 0, nil, 14 )
			rowTitle:setFillColor( 1, 0, 0 )
			rowTitle.x = 10
			rowTitle.anchorX = 0
			rowTitle.y = row.contentHeight * 0.5

			local btn = uiLib:createButton('Delete', 400, 0, function(event)
				if event.phase == 'ended' then
					table.remove( sequences, row.index )
					updateSequenceList()
				end
			end)
			row:insert(btn)
		end
	})
	sequenceList.update = function(obj, event)
		local seq = event.value
		local frames = seq.frames
		local frameStr = '{ '
		for i, frame in ipairs(frames) do
			frameStr = frameStr .. frame ..','
		end
		frameStr = frameStr .. '},' 
		local str = string.format( '{ time=%d, loopCount=%d, name="%s", frames=%s },', seq.time, seq.loopCount, seq.name, frameStr )
		sequences[#sequences + 1] = str
		updateSequenceList()
	end
	publisher:subscribe(BIND_SEQUENCE, sequenceList)

	updateSequenceList()

	return uiLib:layout{
		parent=root,
		posY=450,
		evenRows={
			sequenceList,
		},
	}
end

local function createCenterView()
	uiLib:layout{
		parent=root,
		posY=220,
		evenRows={
			fileField(),
			imageField(),
			spriteField(),
			sequenceAppendField(),
		},
		bgcolor={0, 0, 0, 0},
	}
end

local function createContent(sceneGroup)
	sceneGroup:insert(root)
	createTopView()
	createCenterView()
	sequenceListView()

end

function scene:create(event)
	local sceneGroup = self.view
	createContent(sceneGroup)
end

function scene:show(event)
	local sceneGroup = self.view
	if event.phase == 'will' then
		filename.isVisible = true
		spriteWidth.isVisible = true
		spriteHeight.isVisible = true
	elseif event.phase == 'did' then
	end
end

function scene:hide(event)
	if event.phase == 'will' then
	elseif event.phase == 'did' then
		filename.isVisible = false
		spriteWidth.isVisible = false
		spriteHeight.isVisible = false
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene