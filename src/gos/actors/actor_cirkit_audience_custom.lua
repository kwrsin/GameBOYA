local params = require 'src.structures.gos.meta.actor_cirkit_audience'
local generator = require 'src.gos.actors.actor_base'
return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)
  function M:finish()
  	M.go:setSequence( 'fever' )
  	M.go:play()
  	sound:effect2('fever')
  end

	return M
end
