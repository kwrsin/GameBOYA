-- guage.lua

function createBar(guage, params, idx)
	local width = params.width or 2
	local height = params.height or 10
	local padding = params.padding or 1
	local x = (idx - 1) * (width + padding)
	local radius = params.radius
	if radius and radius > 0 then
		return display.newRoundedRect( guage.root, x, 0, width, height, radius )
	else
		return display.newRect( guage.root, x, 0, width, height )
	end
end

function createBackgroundBar(guage, params, idx)
	local color = params.bgcolor or {1, 1, 1}
	local bar = createBar(guage, params, idx)
	bar:setFillColor( unpack(color) )
end

function createForegroundBar(guage, params, idx)
	local color = params.fgcolor or {1, 0, 0}
	local bar = createBar(guage, params, idx)
	bar:setFillColor( unpack(color) )
	bar.alpha = 0
	guage.bars[#guage.bars + 1] = bar
end

function createGuage(guage)
	local root = display.newGroup( )
	local params = guage.params
	local length = params.length
	params.parent:insert(root)
	guage.root = root
	guage.root.x = params.x or 0
	guage.root.y = params.y or 0
	guage.bars = {}
	guage.length = length
	guage._value = 0

	for i=1,length do
		createBackgroundBar(guage, params.bar, i)
		createForegroundBar(guage, params.bar, i)
	end
end

function soundInc()
	print('inc')
end

function soudnDec()
	print('dec')

end

return function(params)
	local guage = {}
	guage.params = params
	createGuage(guage)

	function guage:setValue(rate, sound)
		for i=1,guage.length do
			guage.bars[i].alpha = 0
		end
		local value = math.floor( guage.length * rate )
		for i=1,value do
			guage.bars[i].alpha = 1.0
		end
		if sound then
			if value > guage._value then
				soundInc()
			elseif value < guage._value then
				soudnDec()
			end
		end
		guage._value = value
	end

	function guage:rotate(degree)
		guage.root.rotation = degree
	end

	return guage
end