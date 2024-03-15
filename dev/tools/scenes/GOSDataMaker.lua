-- GOSDataMaker.lua
local composer = require 'composer'
local scene = composer.newScene( )
local filename
local selectedImage
local imageWidth
local imageHeight
local spriteWidth
local spriteHeight
local numFrames
local sequenceList
local sequences = {}
local soundList
local sounds = {}
local dataname = {}
local soundKey

local BIND_SOUNDCONTROLS = 'bind_soundcontrols'
publisher:observe(BIND_SELECTEDITEM, {})
publisher:observe(BIND_SEQUENCE, {})
publisher:observe(BIND_SOUNDCONTROLS, {})

local function getImageDimention(selectedItem)
	selectedImage = display.newImage( selectedItem )
	local width, height = selectedImage.width, selectedImage.height
	display.remove( selectedImage )
	return width, height
end

local function createTitle()
	return uiLib:layout{
		background=display.newRect( 0, 0, display.actualContentWidth, HEADER_HEIGHT),
		evenCols={
			display.newText( 'GOSDataMaker', 0, 0, native.systemFont, 24 )
		},
		bgcolor={1, 0, 0, 0.6}
	}
end

local function fileField()
	local parent = display.newGroup()
	display.newText(parent, 'File Name:', -240, 0, native.systemFontBold, 24)
	filename = native.newTextField( -20, 0, 280, 48 )
	filename.update = function(obj, event)
		if event.value.title == NAME_FILE_SELECTOR then
			filename.text = event.value.selectedItem
			imageWidth.text, imageHeight.text = getImageDimention(filename.text)
		end
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
						title=NAME_FILE_SELECTOR, 
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
			if #filename.text <= 0 then return end
			if #spriteWidth.text  < 0 or tonumber(spriteWidth.text) == nil then return end
			if #spriteHeight.text  < 0 or tonumber(spriteHeight.text) == nil  then return end
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
		boxHeight=260,
		evenCols={
			sequenceList,
		},
	}
end

local function soundNameField()
	local addSoundBtn = uiLib:createButton('Add', 0, 0, function(event)
		if event.phase == 'ended' then
		local files = storage:files(SOUNDS_PATH)
		local items = {}
		for i, file in ipairs(files) do
			items[#items + 1] = string.format( '%s%s', SOUNDS_BASE_PATH, file )
		end
		utils.gotoFileSelector(
			{
				params={
					title=NAME_SOUND_SELECTOR, 
					items=items,
				}
			})
		end
	end)
	addSoundBtn.update = function(obj, event)
		if event.value.soundEnabled then
			addSoundBtn:setEnabled(true)
		else
			addSoundBtn:setEnabled(false)
		end
	end
	addSoundBtn:setEnabled(false)
	publisher:subscribe(BIND_SOUNDCONTROLS, addSoundBtn)

	soundKey = native.newTextField( 0, 0, 280, 32 )
	soundKey.placeholder = 'Key Name'
	soundKey:addEventListener( 'userInput', function(event)
		if ( event.phase == "ended" or event.phase == "submitted" ) then
			if #soundKey.text > 0 then
				publisher:put({}, BIND_SOUNDCONTROLS, {soundEnabled=true})
			else
				publisher:put({}, BIND_SOUNDCONTROLS, {soundEnabled=false})
			end
		end
	end )
	return uiLib:layout{
			evenCols={
				soundKey,
				addSoundBtn,
			},
		}
end

local function soundLabelField()
	return uiLib:layout{
		boxHeight=160,
		evenRows={
			display.newText('Sound List', 0, 0, native.systemFontBold, 24),
			soundNameField(),
		},
	}
end

local function updateSoundList()
	soundKey.text = ''
	publisher:put({}, BIND_SOUNDCONTROLS, {soundEnabled=false})
	soundList:deleteAllRows()
	for i=1, #sounds do
		soundList:insertRow{
      isCategory = false,
      rowHeight = 48,
      rowColor = { default={0,0,0}, over={1,0.5,0,0.2} },
      lineColor = { 0.5, 0.5, 0.5 }
    }
	end
end

local function soundListField()
	soundList = uiLib:list(nil, {
		top = 0,
		left = 0,
		width = 560,
		height = 260,
		hideBackground = true,
		onRowRender = function( event )
			local phase = event.phase
			local row = event.row
			local rowTitle = display.newText( row, sounds[row.index], 0, 0, nil, 14 )
			rowTitle:setFillColor( 1, 0, 0 )
			rowTitle.x = 10
			rowTitle.anchorX = 0
			rowTitle.y = row.contentHeight * 0.5

			local btn = uiLib:createButton('Delete', 440, 0, function(event)
				if event.phase == 'ended' then
					table.remove( sounds, row.index )
					updateSoundList()
				end
			end)
			row:insert(btn)
		end
	})
	soundList.update = function(obj, event)
		if event.value.title == NAME_SOUND_SELECTOR then
			sounds[#sounds + 1] = string.format('{ %s="%s", },', soundKey.text, event.value.selectedItem)
			updateSoundList()
			soundKey.text = ''
		end
	end
	publisher:subscribe(BIND_SELECTEDITEM, soundList)

	updateSoundList()

	return uiLib:layout{
		boxHeight=260,
		evenRows={
			soundList,
		},
	}
end

local function createGOSData()
	local function getStrItems(array)
		local tab = '\t\t'
		local str = ''
		for i, seq in ipairs(array) do
			str = str .. string.format('%s%s\n', tab, seq)
		end
		return str
	end

	local str = 'return {\n'
	str = str .. string.format('\tpath="%s",\n', filename.text)
	str = str .. string.format(
		'\tsheetParams = { numFrames = %s, height = %s, sheetContentHeight = %s, sheetContentWidth = %s, width = %s },\n' ,
		numFrames.text, spriteHeight.text, imageHeight.text, spriteWidth.text, imageWidth.text )
	str = str .. '\tsequences = {\n'
	str = str .. getStrItems(sequences)
	str = str .. '\t},\n'
	str = str .. '\tsounds = {\n'
	str = str .. getStrItems(sounds)
	str = str .. '\t},\n'
	str = str .. '}\n'

	return str
end

local function saveGosData(filename)
	local str = createGOSData()
	local path = string.format( '%s/%s.lua' , GOS_DATA_PATH, filename )
	storage:writeString(path, str)
end

local function genField()
	dataname = native.newTextField( 0, 0, 280, 48 )
	dataname.placeholder = 'Data Name'
	return uiLib:layout{
		evenCols={
			dataname,
			uiLib:createButton('Generate', 0, 0, function(event)
				if event.phase == 'ended' then
					if #dataname.text > 0 then
						saveGosData(dataname.text)
					end
				end
			end),
		},
		bgcolor={0, 0, 0, 0},
	}
end

local function bottomView()
	return uiLib:layout{
		evenRows={
			genField()
		},
		bgcolor={0, 0, 0, 0},
	}
end

local function createContent(sceneGroup)
	uiLib:layout{
		parent=sceneGroup,
		evenRows={
			createTitle(),
			fileField(),
			imageField(),
			spriteField(),
			sequenceAppendField(),
			sequenceListView(),
			soundLabelField(),
			soundListField(),
			bottomView(),
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
		filename.isVisible = true
		spriteWidth.isVisible = true
		spriteHeight.isVisible = true
		soundKey.isVisible = true
		dataname.isVisible = true
	elseif event.phase == 'did' then
	end
end

function scene:hide(event)
	if event.phase == 'will' then
	elseif event.phase == 'did' then
		filename.isVisible = false
		spriteWidth.isVisible = false
		spriteHeight.isVisible = false
		soundKey.isVisible = false
		dataname.isVisible = false
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene