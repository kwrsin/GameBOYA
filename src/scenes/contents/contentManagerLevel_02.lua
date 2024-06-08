-- contentManagerLevel_02.lua
local M = require('src.scenes.contents.base')()

function M:enterFrame(event)
  if M.gameStatus == GAMESTATUS_STARTING then
    self:startBanner()
    return
  elseif M.gameStatus == GAMESTATUS_ENDING then
    self:endBanner()
    return
  elseif player and M.gameStatus == GAMESTATUS_PLAYING then
    controller:enterFrame(event)
    virtualControlelr:enterFrame(event)
  end
  local actors = self:getActors()
  for i, actor in ipairs(actors) do
    actor:enterFrame(event)
  end

  camera:enterFrame(event)
end

function M:result(params)
  player = nil
  self.gameStatus = GAMESTATUS_ENDING
  -- self:pushNextLevel{nextLevel=MENU_LEVEL , params={message=params.message or "Next..."}}
  -- self:gotoNextLevel{nextLevel=MENU_LEVEL}
end

-- function M:start()
--   print('level02')
-- end

-- function M:destroy()
-- end
return M