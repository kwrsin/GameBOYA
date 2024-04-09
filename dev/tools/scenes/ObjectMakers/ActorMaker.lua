-- ActorMaker.lua
local widget = require 'widget'
local composer = require 'composer'
local scene = composer.newScene( )
local data = {
	type='sprite',
	fileName=nil,
	structurePath=nil,
	seqName=nil,
	group='actors',
}
local sv
local imSheet
local spt
local animPtns = {}
local CURRENTDIR_HOME = 'src/structures/gos'
local stepper
local currentIdx = 1

local function createTitle()
	local title = display.newText( 'ActorMaker', 0, 0, native.systemFont, 24 )
	return uiLib:layout{
		background=display.newRect( 0, 0, display.actualContentWidth, HEADER_HEIGHT),
		evenCols={
			title,
		},
		bgcolor={1, 0, 0, 0.6}		
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
					uiLib:input(nil, 'Input File Name', CX, CY, nil, 'actor', function(event)
						if event.phase == "ended" or event.phase == "submitted" then
							data.fileName.text = event.target.text
						end
					end)
				end
			end)
		},
	}
end

local function clearViewer()
	if spt then
		spt:pause()
		display.remove( spt )
		spt = nil
	end
	if imSheet then
		imSheet = nil
	end
end

local function getAnimationPatterns(sequences)
	for i=#animPtns, 1, -1 do
		table.remove( animPtns, i )
	end
	for k, seq in pairs(sequences) do
		animPtns[#animPtns + 1] = seq.name
	end
	currentIdx = 1
	data.seqName.text = ''
	stepper:setValue(1)
	return animPtns
end

local function toIndex(seqName)
	for i, v in ipairs(animPtns) do
		if v == seqName then
			return i
		end
	end
	return -1
end

local function play(idx)
	if idx > 0 then else return end
	if idx > #animPtns then return end
	if not spt then return end
	local seq = animPtns[idx]
	-- if seq == spt.sequence then return end
	spt:setSequence( seq )
	spt:play()
end

local function loadSprite()
	local path = data.structurePath.text
	if not path or #path <= 0 then return end
	clearViewer()
	local structure = require(path:gsub('/', '.'):gsub('.lua', ''))
	getAnimationPatterns(structure.sequences or {})
	if not structure.sequences or #structure.sequences <= 0 then return end
	imSheet = graphics.newImageSheet( structure.path, structure.sheetParams )
	spt = display.newSprite( sv, imSheet, structure.sequences )
	data.seqName.text = animPtns[1]
	play(toIndex(data.seqName.text))
end

local function sheetSelection()
	data.structurePath = display.newText( '', 0, 0, native.systemFont, 24 )

	return uiLib:layout{
		evenCols={
			display.newText( 'Sheet Name: ', 0, 0, native.systemFont, 24 ),
			data.structurePath,
			uiLib:createButton('Edit', 0, 0, function(event)
				if event.phase == 'ended' then
					utils.gotoFilePicker{params={currentDir=storage:baseDir() .. CURRENTDIR_HOME, selectType='file', numOfSelections=1, callback=function(values, parentDir)
							local file
							for i, v in ipairs(values) do
								if v.selected then
									file = v.name
									break
								end
							end
							data.structurePath.text = ''
							if file then
								local dir = parentDir:gsub(storage:baseDir(), ''):gsub('/', '.')
								data.structurePath.text =
									string.format( '%s.%s', dir, file)
									loadSprite()
							end
					end}}
				end
			end),			
		}
	}
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

local function seqField()
	data.seqName = display.newText('', 0, 0, native.systemFont, 32 )
	stepper = widget.newStepper {
	    left = 0,
	    top = 0,
	    initialValue = 1,
	    minimumValue = 1,
	    -- maximumValue = #animPtns,
	    onPress = function( event )
	    	if data.structurePath.text and #data.structurePath.text > 0 then
	    		if event.value > 0 and event.value <= #animPtns then
	    			if ( "increment" == event.phase ) then
	    				currentIdx = currentIdx + 1
	    			elseif ( "decrement" == event.phase ) then
	    				currentIdx = currentIdx - 1
	    			end
	    		end
	    	end
				if event.value > #animPtns then 
					currentIdx = #animPtns
					stepper:setValue(currentIdx)
				end
				if event.value < 1 then
					currentIdx = 1
					stepper:setValue(currentIdx)
				end
  			play(currentIdx)
  			data.seqName.text = animPtns[currentIdx]
		  end
	}			
	return uiLib:layout{
		evenCols = {
			data.seqName,
			stepper,
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
		seqField(),
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