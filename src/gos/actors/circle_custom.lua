local function createShape(obj)
	local sp = display.newCircle( obj.go, 0, 0, 30 )
	sp:setFillColor( 0.3, 0.3, 0.3 )

	local t = display.newText(obj.go, 'Welcom', 0, 0, native.systemFontBold, 34)
	t.anchorX = 0
	

end

local function createGroup(obj)
	obj.go = display.newGroup()
	if obj.params.parent then obj.params.parent:insert(obj.go) end
	obj.go.x = obj.params.x or 0
	obj.go.y = obj.params.y or 0
	createShape(obj)
end

local function create(obj)
	createGroup(obj)

end

return function(params)
	local M = {}
	M.params = params
	create(M)

	return M
end