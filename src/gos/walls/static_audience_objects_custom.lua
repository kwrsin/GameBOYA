-- static_audience_objects_custom.lua
local generator = require 'src.gos.actors.actor_cirkit_audience_custom'

return function(options)
	local params = utils.fastCopy(options or {}, {})
	local M = {}
	M.go = display.newGroup()
	local level = params.parent
	level:insert(M.go)
	for i=1,10 do
		params.parent = M.go
		local object = generator(params)
		object.go.x = object.go.x + (i - 1) * object.go.width
		object.go.bodyType = "static"
		M.go:insert(object.go)
		contentManager:entry(object)
	end
	return M
end