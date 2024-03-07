-- content.lua
local tileLoader = require 'src.libs.tileLoader'
local uiLib = require 'src.libs.uiLib'

local M = require('src.scenes.contents.base')()

local content
local gotoNext
local selectedLevel
local actors

local function enterFrame(event)
  if player then
    controller:enterFrame(event)
    virtualControlelr:enterFrame(event)
  end
  for i, actor in ipairs(actors) do
    actor:enterFrame(event)
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
  M:entry(obj)
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

function M:entry(actor)
  if not actor then return end
  actors[#actors + 1] = actor
end

function M:disableActors()
  for i, actor in ipairs(actors) do
    if actor then
      actor:disable()
    end
  end
end

function M:stopTheWorld()
  physics.pause()
  timer.pause(tagTimer)
  transition.pause(tagTransition)
  for i, actor in ipairs(actors) do
    if actor then
      actor:freez()
    end
  end
end

function M:restartTheWorld()
  physics.start()
  timer.resume(tagTimer)
  transition.resume(tagTransition)
  for i, actor in ipairs(actors) do
    if actor then
      actor:restart()
    end
  end
end

function M:disappearAll()
  for i, actor in ipairs(actors) do
    if actor then
      actor:disappear()
    end
  end
end

function M:result()
  storage:put('levelName', 'YOU WIN')
  storage:put('selectedLevel', utils.dotPath('levels.level01', dot_structures))
  storage:store()
  player = nil
  if gotoNext then
    gotoNext()
  end
end

function M:create(parent, callback)
  actors = {}
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