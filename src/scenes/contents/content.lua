-- content.lua
local tileLoader = require 'src.libs.tileLoader'
local uiLib = require 'src.libs.uiLib'

local M = require('src.scenes.contents.base')()

local content
local gotoNext
local selectedLevel

local function enterFrame(event)
  if player then
    controller:enterFrame(event)
    virtualControlelr:enterFrame(event)
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
  local tileSize = 64
  local tiles = 8
  content.x = (cw - tiles * tileSize) / 2
  content.y = (ch - tiles * tileSize) / 2
  tileLoader{
    parent=content, 
    level=selectedLevel, 
    imageSheets=gImageSheets,
    callback=createGameObject
  }
  content.isContent = true
  return content  
end

function M:result()
  storage:put('levelName', 'YOU WIN')
  storage:put('selectedLevel', utils.dotPath('levels.level02', dot_structures))
  storage:store()
  player = nil
  if gotoNext then
    gotoNext()
  end
end

function M:create(parent, callback)
	gotoNext = callback
	selectedLevel = require(storage:get('selectedLevel'))
	tiled()
  parent:insert(content)

	addEventListeners()
end

function M:start()
  print('start game')
  sound:music1('bgm', {loops=-1})
end

function M:pause()
end

function M:destroy()
	removeEventListeners()
  sound:reset(true)
end

return M