-- contentManager.lua
local M = require('src.scenes.contents.base')()

function M:result()
  storage:put('selectedLevel', utils.dotPath('levels.level01', DOT_STRUCTURES))
  storage:store()
  player = nil
  self:gotoNext({params={message='NEXT'}})
end

function M:start()
  logger.info('START GAME')
  sound:music1('bgm', {loops=-1})
end

return M