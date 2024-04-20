-- RelationsMaker.lua
local composer = require 'composer'
local scene = composer.newScene( )
local collisionTypesTB
local collisionTB
local collisionList
local collisionTypes = {}
local collisions = {}
local rowIdx = 0

local function updateCollisionList()
	collisionList:deleteAllRows( )
	for i=1, #collisions do
		collisionList:insertRow{
      isCategory = false,
      rowHeight = 128,
      rowColor = { default={0,0,0}, over={1,0.5,0,0.2} },
      lineColor = { 0.5, 0.5, 0.5 }
		}
	end
end

local function createTitle()
	return uiLib:layout{
		background=display.newRect( 0, 0, display.actualContentWidth, HEADER_HEIGHT),
		evenCols={
			display.newText( 'Relations Maker', 0, 0, native.systemFont, 24 ),
		},
		bgcolor={1, 0, 0, 0.6}		
	}
end

local function toCategoryBits(values)
	local bits = {}
	for i, v in ipairs(values) do
		local categoryBits = #bits <= 0 and 1 or bits[#bits] * 2
		bits[#bits + 1] = categoryBits
	end
	return bits
end

local function createCollisionTypes()
	local function toJoinedString(values)
		local str = ''
		if values and #values > 0 then
			for i, v in ipairs(values) do
				str = str .. string.format( '%s[%i], ', v.name, v.bits )
			end
		end
		return str
	end
	local function toArrayMapped(values)
		local ary = {}
		if values and #values > 0 then
			local bits = toCategoryBits(values)
			for i, v in ipairs(values) do
				ary[#ary + 1] = {name=v.name, bits=bits[i]}
			end
		end
		return ary
	end
	collisionTypesTB = native.newTextField( 0, 0, 330, 32 )
	collisionTypesTB.placeholder = 'Collision Types'
	return uiLib:layout{
		evenCols={
			collisionTypesTB,
			uiLib:createButton('Define', 0, 0, function(event)
				if event.phase == 'ended' then
					utils.gotoArrayMaker{
						params={
							titile=NAME_COLLISION_TYPE,
							items=utils.deepcopy(collisionTypes),
							callback=function(results)
								collisionTypes = toArrayMapped(results)
								collisionTypesTB.text = toJoinedString(collisionTypes)
								collisions = {}
								updateCollisionList()
							end
						}
					}
				end
			end)
		},
	}
end

local function createCollisionEntry()
	collisionTB = native.newTextField( 0, 0, 280, 32 )
	collisionTB.placeholder = 'Collision Name'
	collisionTB:addEventListener( 'userInput', function(event)
		if ( event.phase == "ended" or event.phase == "submitted" ) then
			if collisionTB.text == "" then
				return
			end
			collisions[#collisions + 1] = {name=collisionTB.text}
			collisionTB.text = ""
			updateCollisionList()
		end
	end )
	return uiLib:layout{
		evenCols={
			collisionTB,
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
	local function unselected(collisionTypes)
		for i, t in ipairs(collisionTypes) do
			t.selected = false
		end
		return collisionTypes
	end
	collisionList = uiLib:list(nil, {
		width = display.actualContentWidth,
		height = 800,
		hideBackground = true,
		onRowRender = function( event )
			local phase = event.phase
			local row = event.row
			local rowTitle = display.newText( row, collisions[row.index].name , 0, 0, nil, 34 )
			rowTitle:setFillColor( 1, 0, 0 )
			rowTitle.x = 10
			rowTitle.anchorX = 0
			rowTitle.y = row.contentHeight * 0.5
			-- local others = getOthers(collisions[row.index].others or {})
			-- if #others > 0 then
			-- 	local rowOthers = display.newText( row, ' : ' .. others , 0, 0, nil, 14 )
			-- 	rowOthers:setFillColor( 1, 0, 0 )
			-- 	rowOthers.x = 180
			-- 	rowOthers.anchorX = 0
			-- 	rowOthers.y = row.contentHeight * 0.5
			-- end
			local maskBitBtn = uiLib:createButton('maskBit', 120, 0, function(event)
				if event.phase == 'ended' then
					utils.gotoMultiSelector({
						params={
							title=string.format('MaskBits[%s]', collisions[row.index].name),
							items=collisions[row.index].maskBits or unselected(collisionTypes),
							targetIdx=row.index,
							response=function(value)
								if #collisions > 0 then
									collisions[value.targetIdx].maskBits = value.selectedItems
									updateCollisionList()
								end
							end
						}
					})
				end
			end)
			maskBitBtn.y = row.contentHeight * 0.25
			maskBitBtn.anchorX = 1
			row:insert(maskBitBtn)
			if collisions[row.index].maskBits and #collisions[row.index].maskBits > 0 then
				local mbs = collisions[row.index].maskBits
				local str = ''
				for i, mb in ipairs(mbs) do
					if mb.selected then
						str = str .. string.format( '%s[%i], ' ,mb.name, mb.bits )
					end
				end
				local lbl = display.newText(row, str, 320, row.contentHeight * 0.25, native.systemFont, 24)
				lbl:setFillColor( 0, 1, 0 )
			end

			local categoryBitBtn = uiLib:createButton('categoryBit', 120, 0, function(event)
				if event.phase == 'ended' then
					utils.gotoMultiSelector({
						params={
							title=string.format('CategoryBits[%s]', collisions[row.index].name),
							items=collisions[row.index].categoryBits or unselected(collisionTypes),
							targetIdx=row.index,
							response=function(value)
								if #collisions > 0 then
									collisions[value.targetIdx].categoryBits = value.selectedItems
									updateCollisionList()
								end
							end
						}
					})
				end
			end)
			categoryBitBtn.y = row.contentHeight * 0.75
			categoryBitBtn.anchorX = 1
			row:insert(categoryBitBtn)
			if collisions[row.index].categoryBits and #collisions[row.index].categoryBits > 0 then
				local mbs = collisions[row.index].categoryBits
				local str = ''
				for i, mb in ipairs(mbs) do
					if mb.selected then
						str = str .. string.format( '%s[%i], ' ,mb.name, mb.bits )
					end
				end
				local lbl = display.newText(row, str, 320, row.contentHeight * 0.75, native.systemFont, 24)
				lbl:setFillColor( 1, 0.5, 0 )
			end

			local deleteBtn = uiLib:createButton('Delete', 500, 0, function(event)
				if event.phase == 'ended' then
					table.remove( collisions, row.index )
					updateCollisionList()
				end
			end)
			deleteBtn.y = row.contentHeight * 0.5
			row:insert(deleteBtn)
		end,
	})

	updateCollisionList()
	return uiLib:layout{
		boxHeight=800,
		evenCols={
			collisionList,
		},
	}
end

local function relations()
	local function getBits(bits)
		local bits = bits or {}
		local sum = 0
		for i, v in ipairs(bits) do
			if v.selected then
				sum = sum + v.bits
			end
		end
		return sum
	end
	local str = 'local M = {}\n\n'
	for i, col in ipairs(collisions) do
		str = str .. string.format( 'M.%s = { categoryBits=%i, maskBits=%i }\n' ,col.name , getBits(col.maskBits), getBits(col.categoryBits))
	end
	str = str .. '\nreturn M\n'
	return str		
end

local function createRelations()
	return uiLib:layout{
		evenCols={
			uiLib:createButton('Generate', 0, 0, function(event)
				if event.phase == 'ended' then
					local p = string.format('%s%s', storage:baseDir(), RELATIONS_PATH)
					storage:writeString(p, relations())
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
			createCollisionTypes(),
			createCollisionEntry(),
			createCollisionList(),
			createRelations(),
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
		collisionTypesTB.isVisible = true
		collisionTB.isVisible = true
	elseif event.phase == 'did' then
	end
end

function scene:hide(event)
	if event.phase == 'will' then
	elseif event.phase == 'did' then
		collisionTypesTB.isVisible = false
		collisionTB.isVisible = false
	end
end

scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
return scene