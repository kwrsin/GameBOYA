local composer = require 'composer'
local scene = composer.newScene()
-- local structures = {
--   names={},
--   structurePath = utils.dotPath(dot_structures, 'gameObjects.')
-- }

local function loadData()
  local selectedData = 'data1.js'
  return storage:open(selectedData, {
    name=selectedData, 
    selectedLevel=utils.dotPath('levels.level01', dot_structures),
    flags=require(utils.dotPath('flags', dot_structures))})
end

local function loadAssets(level)
  gImageSheets = utils.getImageSheets(level.structures)
  sound:preload(level.structures)
  sound:preloadMusics(level.musics)
  sound:preloadSounds(level.sounds)
end

local function createTitle(sceneGroup)
  local bg = display.newRect(sceneGroup, cx, cy, cw, ch)
  bg:setFillColor(0, 0, 0)

  local title = 'nowLoading...'
  local nowLoading = display.newText(sceneGroup, title, cx, cy, native.systemFont, 36)
  nowLoading:setFillColor(1, 1, 1)
end

function scene:create(event)
  local sceneGroup = self.view
  createTitle(sceneGroup)

  loadData()
  local lvlPath = storage:get('selectedLevel')
  loadAssets(require(lvlPath))
end

function scene:show(event)
  if event.phase == 'did' then
    utils.gotoScene(game_scene)
  end
end

function scene:destroy(event)
  logger.info('loader scene has destroyed')
end

scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('destroy', scene)

return scene
