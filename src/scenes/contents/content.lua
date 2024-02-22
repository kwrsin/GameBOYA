-- content.lua
local tileLoader = require 'src.libs.tileLoader'
local camera = require 'src.libs.camera'
local controller = require 'src.libs.controller'
local virtualControlelr = require 'src.libs.virtual_controller'
local uiLib = require 'src.libs.uiLib'

local M = require('src.scenes.contents.base')()

local content
local player
local gotoNext
local selectedLevel

local function createButton()
	local btn = uiLib:createButton("End Game", 120, 120, function(event)
		if event.phase == 'ended' then
			storage:put('levelName', 'YOU WIN')
			storage:put('selectedLevel', utils.dotPath('levels.level02', dot_structures))
      storage:store()
      player = nil
      if gotoNext then
        gotoNext()
      end
		end
	end)
	content:insert(btn)
end

local function enterFrame(event)
  if player then
    controller:enterFrame(event)
    virtualControlelr:enterFrame(event)
    camera:enterFrame(event)
  end
end

local function addEventListeners()
	Runtime:addEventListener( 'enterFrame', enterFrame )
end

local function removeEventListeners()
	Runtime:removeEventListener( 'enterFrame', enterFrame )
end

local function createGameObject(params)
  if not params.gId or params.gId < 0 then return nil end
  local goPath = selectedLevel.gos[params.gId]
  local obj = require(goPath.class)(params)
  if goPath.isPlayer then
    player = obj
  end
  return obj.go
end

local function tiled()
  content = display.newGroup()
  tileLoader{
    parent=content, 
    level=selectedLevel, 
    imageSheets=gImageSheets,
    callback=createGameObject
  }
  content.isContent = true
  return content  
end

function M:create(parent, callback)
	gotoNext = callback
	selectedLevel = require(storage:get('selectedLevel'))
	tiled()
	if player then
		camera:create(parent, {layers={content}, target=player.go, offsetX=content_x, offsetY=content_y, viewWidth=view_width, viewHeight=view_height, frameWidth=0, frameHeight=0})
    virtualControlelr:createVirtualController(parent)
    virtualControlelr:createCursor({x=-cx+90, y=80}, function(cursor) 
      player:move(utils.toKeys(cursor))
    end)
		controller.keyInput(player, function(event, keys)
      player:move(keys)
    end)
	else
		parent:insert(content)
	end

	createButton()

	addEventListeners()
end

function M:start()
  print('start game')
end

function M:pause()
end

function M:destroy()
	removeEventListeners()
end

return M