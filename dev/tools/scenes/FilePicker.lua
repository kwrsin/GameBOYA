-- FilePicker.lua
local composer = require 'composer'
local scene = composer.newScene( )
local home
local currentDir
local excludes
local includes
local numOfSelections
local selectType
local selections = {}
local fileList
local filteredFiles = {}
local callback

local function selectedNum()
	local num = 0
	for i, f in ipairs(filteredFiles) do
		if f.selected then num = num + 1 end
	end
	return num
end

local function select(idx)
	local value = selectedNum() + (filteredFiles[idx].selected and 0 or 1)
	if numOfSelections < value then return false end
	filteredFiles[idx].selected = not filteredFiles[idx].selected
	return true
end

local function parentPath()
	currentDir = currentDir:gsub('/$', ""):gsub('/([^/]+)$', "")
	if not currentDir or #currentDir <= 0 then
		currentDir = home
	end
	return currentDir
end

local function isContained(v1, v2)
	local i, j = string.match( v1, v2 )
	return i  or false
end

local function update(dir)
	local path = currentDir:gsub('/$', '')
	if dir and #dir > 0 then
		path = string.format('%s/%s', path, dir)
	end
	currentDir = path
	local files = storage:files(path)
	local exfiles = {}
	local infiles = {}
	if #excludes > 0 then
		for l, file in ipairs(files) do
			for m, e in ipairs(excludes) do
				local ignore = true
				if isContained(file, e) then else
					if selectType == 'file' then else
						ignore = storage:isDir(string.format('%s/%s', currentDir, file))
					end
					if ignore then
						exfiles[#exfiles + 1] = file
					end
				end
			end
		end
	else
		for l, file in ipairs(files) do
			local ignore = true
			if selectType == 'file' then else
				ignore = storage:isDir(string.format('%s/%s', currentDir, file))
			end
			if ignore then
				exfiles[#exfiles + 1] = file
			end
		end
	end
	if #includes > 0 then
		for l, e in ipairs(exfiles) do
			for m, i in ipairs(includes) do
				if isContained(e, i) then
					infiles[#infiles + 1] = e
				end
			end
		end
	else
		infiles = exfiles
	end
	for i=#filteredFiles,1,-1 do
		table.remove( filteredFiles, i )
	end
	if home:gsub('/$', "") ~= currentDir:gsub('/$', "") then
		filteredFiles[#filteredFiles + 1] = {
			name='../',
			selected=false
		}
	end
	for i, file in ipairs(infiles) do
		filteredFiles[#filteredFiles + 1] = {
			name=file,
			selected=false
		}
	end
	fileList:refresh(filteredFiles)
end

local function createBackground(sceneGroup)
	local topInset, leftInset, bottomInset, rightInset
		 = display.getSafeAreaInsets()
	local bg = display.newRect( 
		sceneGroup, CX, CY + topInset, display.contentWidth, display.contentHeight )
	bg:setFillColor( 0, 0, 0 )
end

local function createTitle(sceneGroup)
	local title = display.newText( 'FilePicker', 0, 0, native.systemFont, 24 )
	return uiLib:layout{
		parent=sceneGroup,
		background=display.newRect( 0, 0, display.actualContentWidth, HEADER_HEIGHT),
		evenCols={
			title,
		},
		bgcolor={1, 0, 0, 0.6}		
	}
end

local function createTable()
	fileList = uiLib:list(nil, {
		width = display.actualContentWidth,
		height = 800,
		hideBackground = true,
		onRowRender = function(event)
			local phase = event.phase
			local row = event.row
			local cellBg = display.newRect(row, CX, 26, row.width, row.height)
			cellBg:setFillColor( 0, 0, 0, 0 )
			cellBg.isHitTestable = true
			cellBg:addEventListener( 'tap', function(event)
				local col = filteredFiles[row.index]
		    if ( event.numTaps == 1 ) then
		    	local canSelect = true
	    		if selectType == 'file' and storage:isDir(
						string.format('%s/%s', currentDir, col.name)) then
	    			canSelect = false
	    		end
					if canSelect and select(row.index) then
						fileList:reloadData()
					end
		    elseif ( event.numTaps == 2 ) then
		    	if col.name:gsub('/$', '') == '..' then
		    		parentPath()
		    		update()
		    	else
						if storage:isDir(
							string.format('%s/%s', currentDir, col.name)) then
							update(col.name)
						end
		    	end
		    else
		      return true
		    end
			end )
			local rowTitle = display.newText( row, filteredFiles[row.index].name , 0, 0, nil, 14 )
			rowTitle:setFillColor( 1, 0, 0 )
			rowTitle.x = 10
			rowTitle.anchorX = 0
			rowTitle.y = row.contentHeight * 0.5

			if filteredFiles[row.index].selected then
				local r = display.newRect( row, row.width / 2, row.height / 2, row.width, row.height )
				r:setFillColor( 1, 0, 1, 0.5 )
			end
		end,
	})
	return uiLib:layout{
		boxHeight=800,
		evenCols={
			fileList,	
		}
	}
end

local function clear()
	for i, f in ipairs(filteredFiles) do
		f.selected = false
	end
end

local function createButtons()
	return uiLib:layout{
		evenCols={
			uiLib:createButton('CANCEL', 0, 0, function(event)
				if event.phase == 'ended'then
					clear()
					utils.previous()
				end
			end),
			uiLib:createButton('OK', 0, 0, function(event)
				if event.phase == 'ended'then
					if callback then
						callback(filteredFiles, currentDir)
					end
					utils.previous()
				end
			end),
		}
	}
end

local function createContent(sceneGroup)
	createBackground(sceneGroup)
	uiLib:layout{
		parent=sceneGroup,
		evenRows={
			createTitle(),
			createTable(),
			createButtons(),
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
		local params = event.params or {}
		home = params.currentDir or './'
		currentDir = home
		params.filters = params.filters or {}
		excludes = params.filters.excludes or {'.DS_Store',}
		includes = params.filters.includes or {}
		selectType = params.selectType or 'file'
		numOfSelections = params.numOfSelections or 1
		callback = params.callback
		update()
	elseif event.phase == 'did' then
	end
end

function scene:hide(event)
	local parent = event.parent
	if event.phase == 'will' then
	elseif event.phase == 'did' then
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene