-- WallMaker.lua
local widget = require 'widget'
local composer = require 'composer'
local scene = composer.newScene( )
local data = {
	type='image',
	fileName=nil,
	structurePath=nil,
	sheetNumber=nil,
	group='walls',
}
local sv
local imSheet
local img
local numFrames
local SHEETNUMBER_DEFAULT = '1'
local CURRENTDIR_HOME = '../../../../src/structures/gos'

local function clearViewer()
	if img then
		display.remove( img )
		img = nil
	end
	if imSheet then
		imSheet = nil
	end
	numFrames = 0
end

local function loadImage()
	local path = data.structurePath.text
	if not path or #path <= 0 then return end
	clearViewer()
	local structure = require(path:gsub('/', '.'):gsub('.lua', ''))
	imSheet = graphics.newImageSheet( structure.path, structure.sheetParams )
	img = display.newImage( sv, imSheet, tonumber(data.sheetNumber.text) )
	numFrames = structure.sheetParams.numFrames
	data.sheetNumber.text = SHEETNUMBER_DEFAULT
end

local function showImage()
	local path = data.structurePath.text
	if not path or #path <= 0 then return end
	if img then
		display.remove( img )
		img = nil
	end
	img = display.newImage( sv, imSheet, tonumber(data.sheetNumber.text) )
end

local function viewer()
	sv = widget.newScrollView {
		x=0,
		y=0,
		width=600,
		height=400,
		hideBackground=true,
		topPadding=0,
		bottomPadding=0,
	}
	-- local r = display.newRect( sv, 0, 0, 60, 30 )
	return uiLib:layout{
		evenCols={
			sv,
		},
		boxHeight=400,
	}
end

local function sheetSelection()
	data.structurePath = display.newText( '', 0, 0, native.systemFont, 24 )

	return uiLib:layout{
		evenCols={
			display.newText( 'Sheet Name: ', 0, 0, native.systemFont, 24 ),
			data.structurePath,
			uiLib:createButton('Edit', 0, 0, function(event)
				if event.phase == 'ended' then
					utils.gotoFilePicker{params={currentDir=CURRENTDIR_HOME, selectType='file', numOfSelections=1, callback=function(values, parentDir)
							local file
							for i, v in ipairs(values) do
								if v.selected then
									file = v.name
									break
								end
							end
							data.structurePath.text = ''
							if file then
								local dir = parentDir:gsub('^[\.\.\/]+', '')
								data.structurePath.text =
									string.format( '%s.%s', dir, file)
									loadImage()
							end
					end}}
				end
			end),			
		}
	}
end

local function createNameField()
	data.fileName = display.newText( '', 0, 0, native.systemFont, 24 )
	return uiLib:layout{
		evenCols={
			display.newText( 'FileName: ', 0, 0, native.systemFont, 24 ),
			data.fileName,
			uiLib:createButton('Edit', 0, 0, function(event)
				if event.phase == 'ended' then
					uiLib:input(nil, 'Input File Name', CX, CY, nil, 'wall', function(event)
						if event.phase == "ended" or event.phase == "submitted" then
							data.fileName.text = event.target.text
						end
					end)
				end
			end)
		},
	}
end

local function createTitle()
	local title = display.newText( 'WallMaker', 0, 0, native.systemFont, 24 )
	return uiLib:layout{
		background=display.newRect( 0, 0, display.actualContentWidth, HEADER_HEIGHT),
		evenCols={
			title,
		},
		bgcolor={1, 0, 0, 0.6}		
	}
end

local function frameNumber()
	data.sheetNumber = display.newText(SHEETNUMBER_DEFAULT, 0, 0, native.systemFont, 32 )
	return uiLib:layout{
		evenCols = {
			data.sheetNumber,
			widget.newStepper {
				    left = 0,
				    top = 0,
				    initialValue = 1,
				    minimumValue = 1,
				    maximumValue = numFrames,
						timerIncrementSpeed = 500,
						changeSpeedAtIncrement = 1,
				    onPress = function( event )
				    	if data.structurePath.text and #data.structurePath.text > 0 then
				    		if event.value > 0 and event.value <= numFrames then
						    	data.sheetNumber.text = event.value
						    	showImage()
						    elseif event.value < 1 then
						    	event.target:setValue(1)
						    elseif event.value > numFrames then
						    	event.target:setValue(numFrames )
				    		end
				    	end
					  end
				}			
		}
	}
end

local function createPreview()
	return uiLib:layout{
		evenCols={
			uiLib:createButton('Preview', 0, 0, function(event)
				if event.phase == 'ended' then
					if #data.structurePath.text <= 0 then return end
					if #data.fileName.text <= 0 then return end
					utils.gotoGameObjectMaker{params={data=data, callback=function()
					end}}
				end
			end)
		}
	}
end

local function createContent(sceneGroup)
	uiLib:layout{
		parent=sceneGroup,
		evenRows={
			createTitle(),
			createNameField(),
			sheetSelection(),
			viewer(),
			frameNumber(),
			createPreview(),
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
