local params = require 'src.structures.gos.meta.actor_starter'
local generator = require 'src.gos.actors.actor_base'

return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)
	M.go.bodyType='static'
	M.go.isSensor=true
	M:setSequence( 'default' )

  function M:startGame()
		M:setSequence( 'release' )  	
		sound:effect2( 'start' )
  end

	return M
end
