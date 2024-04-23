local composer = require 'composer'
local scene = composer.newScene()
-- local structures = {
--   names={},
--   structurePath = utils.dotPath(DOT_STRUCTURES, 'gameObjects.')
-- }

local function loadData()
  local selectedData = SAVE_FILENAME
  return storage:open(selectedData, {
    name=selectedData, 
    selectedLevel=utils.dotPath(INITIAL_LEVEL, DOT_STRUCTURES),
    flags=require(utils.dotPath(QUEST_FLAGS, DOT_STRUCTURES))})
end

local function loadAssets(level)
  gImageSheets = utils.getImageSheets(level.structures)
  sound:preload(level.structures)
  sound:preloadMusics(level.musics)
  sound:preloadSounds(level.sounds)
end

local function createTitle(sceneGroup)
  local bg = display.newRect(sceneGroup, CX, CY, CW, CH)
  bg:setFillColor(0, 0, 0)

  local title = 'nowLoading...'
  local nowLoading = display.newText(sceneGroup, title, CX, CY, native.systemFont, 36)
  nowLoading:setFillColor(1, 1, 1)
end

function scene:create(event)
  function getNextLevel()
    local nextLevel = publisher:get(PUBSUB_PARAMETERS).nextLevel
    return nextLevel
  end
  
  local sceneGroup = self.view
  createTitle(sceneGroup)

  loadData()
  local lvlPath = getNextLevel() or storage:get(STORAGE_SELECTED_LEVEL)
  loadAssets(require(lvlPath))
end

function scene:show(event)
  if event.phase == 'did' then
    utils.gotoScene(GAME_SCENE)
  end
end

function scene:destroy(event)
  logger.info('loader scene has destroyed')
end

scene:addEventListener('create', scene)
scene:addEventListener('show', scene)
scene:addEventListener('destroy', scene)

return scene
