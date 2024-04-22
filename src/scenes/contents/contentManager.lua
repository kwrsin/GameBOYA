-- contentManager.lua
local M = require('src.scenes.contents.base')()

local function tap(event)
  publisher:put(nil, PUBSUB_TOP, {onDestory=true})
  contentManager:result{message="Start Game!!"}
end

function M:result(params)
  -- storage:put('selectedLevel', utils.dotPath('levels.opening', DOT_STRUCTURES))
  -- storage:store()
  -- player = nil
  -- self:gotoNext({params={message=params.message or "Next..."}})
  utils.gotoScene(INTERMID_SCENE, {
    effect = "fade",
    time = 800,
    params={lvlPath=OPENING_LEVEL, time=1000}})
end

function M:start()
  logger.info('START TITLE')
  Runtime:addEventListener( 'tap', tap)
end

function M:destroy()
  Runtime:removeEventListener( 'tap', tap)
end

return M