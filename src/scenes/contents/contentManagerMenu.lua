-- contentManagerMenu.lua
local M = require('src.scenes.contents.base')()


function M:result(params)
  -- player = nil
  -- self:pushNextLevel{nextLevel=MENU_LEVEL , params={message=params.message or "Next..."}}
  -- self:gotoNextLevel{nextLevel=MENU_LEVEL}
end

function M:start()
  logger.info(LABEL_MENU)
end

function M:destroy()
  publisher:put(nil, PUBSUB_EVENT_MENU, {onDestory=true})
  publisher:unsubscribeAll(PUBSUB_EVENT_MENU)
end
return M