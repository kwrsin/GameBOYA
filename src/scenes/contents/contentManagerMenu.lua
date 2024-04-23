-- contentManagerMenu.lua
local M = require('src.scenes.contents.base')()


function M:result(params)
  -- player = nil
  -- self:gotoNextLevel{nextLevel=MENU_LEVEL , params={message=params.message or "Next..."}}
  -- self:pushNextLevel{nextLevel=MENU_LEVEL}
end

function M:start()
  logger.info('START MENU')
end

return M