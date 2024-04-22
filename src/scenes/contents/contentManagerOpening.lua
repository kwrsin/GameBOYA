-- contentManager.lua
local M = require('src.scenes.contents.base')()

local function tap(event)
  publisher:put(nil, PUBSUB_EVENT_TOP, {onDestory=true})
  contentManager:result{message="Start Game!!"}
end

function M:result(params)
  local messaeg = params.message or ""
  -- storage:put(STORAGE_SELECTED_LEVEL, OPENING_LEVEL)
  -- storage:store()
  -- player = nil
  -- self:gotoNext({params={message=params.message or "Next..."}})
  publisher:put(nil, PUBSUB_PARAMETERS, {nextLevel=OPENING_LEVEL})
  self:gotoNext{
    effect = "fade",
    time = 400,
    params={message=messaeg, time=1000}}
end

function M:start()
  logger.info('START TITLE')
  Runtime:addEventListener( 'tap', tap)
end

function M:destroy()
  publisher:unsubscribeAll(PUBSUB_EVENT_TOP)
  Runtime:removeEventListener( 'tap', tap)
end

return M