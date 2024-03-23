-- FilePicker.lua
local composer = require 'composer'
local scene = composer.newScene( )
local home
local currentDir
local excludes
local includes
local numOfselections
local selectType
local selections = {}
local fileList
local filteredFiles = {}

local function selectedNum()
	local num = 0
	for i, f in ipairs(filteredFiles) do
		if f.selected then num = num + 1 end
	end
	return num
end

local function select(idx)
	local value = selectedNum() + (filteredFiles[idx].selected and 0 or 1)
	if numOfselections < value then return false end
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

local function update(dir)
	local path = currentDir
	if dir and #dir > 0 then
		path = string.format('%s/%s', path, dir)
	end
	local files = storage:files(path)
	local exfiles = {}
	local infiles = {}
	if #excludes > 0 then
		for l, file in ipairs(files) do
			for m, e in ipairs(excludes) do
				local ignore = true
				if file == e then else
					if selectType == 'file' then else
						if storage:isDir(storage:path(file, currentDir) == true) then
							ignore = false
						end
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
				if storage:isDir(storage:path(file, currentDir) == true) then
					ignore = false
				end
			end
			if ignore then
				exfiles[#exfiles + 1] = file
			end
		end
	end
	if #includes > 0 then
		for l, e in ipairs(exfiles) do
			for m, i in ipairs(includes) do
				if e == i then
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
	currentDir = path
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
						if select(row.index) then
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

local function createContent(sceneGroup)
	createBackground(sceneGroup)
	uiLib:layout{
		parent=sceneGroup,
		evenRows={
			createTitle(),
			createTable(),
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
		event.params = {currentDir='../'}--TODO remove this
		home = event.params.currentDir or './'
		currentDir = home
		event.params.filters = event.params.filters or {}
		excludes = event.params.filters.excludes or {}
		includes = event.params.filters.includes or {}
		selectType = event.params.selectType or 'file'
		numOfselections = event.params.numOfselections or 1
		update()
	elseif event.phase == 'did' then
	end
end

function scene:hide(event)
	if event.phase == 'will' then
		-- if event.parent.backFromFilePicker then
		-- 	event.parent:backFromFilePicker(selections)
		-- end
	elseif event.phase == 'did' then
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene