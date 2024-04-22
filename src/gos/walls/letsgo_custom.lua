local params = require 'src.structures.gos.meta.letsgo'
local generator = require 'src.gos.walls.wall_base'

return function(options)
	local params = utils.fastCopy(options or {}, params)
	local M = generator(params)

	function M.update(obj, event)
		if event.value.onDestory then
		transition.scaleTo(M.go,  { xScale=1.5, yScale=1.5, time=200, transition=easing.outBounce, tag=TAG_TRANSITION })
		end
	end
	publisher:subscribe(PUBSUB_EVENT_TOP, M)
	return M
end
