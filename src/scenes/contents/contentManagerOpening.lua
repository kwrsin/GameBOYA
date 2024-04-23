-- contentManager.lua
local M = require('src.scenes.contents.base')()

local function tap(event)
  publisher:put(nil, PUBSUB_EVENT_TOP, {onDestory=true})
  contentManager:result{message="Start Game!!"}
end

function M:result(params)
  -- player = nil
  -- self:pushNextLevel{nextLevel=MENU_LEVEL , params={message=params.message or "Next..."}}
  self:gotoNextLevel{nextLevel=MENU_LEVEL}
end

function M:start()
  logger.info(LABEL_OPENING)
  Runtime:addEventListener( 'tap', tap)
end

function M:destroy()
  publisher:unsubscribeAll(PUBSUB_EVENT_TOP)
  Runtime:removeEventListener( 'tap', tap)
end

return M