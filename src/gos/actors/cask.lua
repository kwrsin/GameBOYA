-- cask.lua
local base = require 'src.gos.base'
local structure = require 'src.structures.gos.cask'
local relations =  require 'src.structures.relations'

local function createSprite(params)
	local imageSheet = 
		graphics.newImageSheet( structure.path, structure.sheetParams )

	local sprite = display.newSprite( 
		params.parent, 
		imageSheet, 
		structure.sequences )
	sprite.x, sprite.y = params.x, params.y
	sprite.class = 'cask'
	if params.isFront then
		local filter = utils.merge(
			relations.enemyrBulletBits, {})
		filter.maskBits = 1
		physics.addBody( 
			sprite, 'kinematic', {
				isSensor=true, 
				density=1, 
				bounce=0, 
				friction=1, 
				filter=filter, 
				radius=20} )
		sprite:setSequence( 'front' )
	else
		physics.addBody( 
			sprite, 'dynamic', {
				density=1, 
				bounce=0, 
				friction=1, 
				filter=relations.enemyrBulletBits, 
				radius=20} )
		sprite:setSequence( 'side' )
		sprite:applyLinearImpulse( 5, 0 )
	end
	sprite:play()

	return sprite
end

return function ( params )
	local M = base(params)
	M.go = createSprite(params)

	function M:zigzag(origin)
		local wrapped
		wrapped = coroutine.wrap(function()
			transition.moveTo( self.go, {x=origin.x + math.random(0, 300), y=origin.y + 86 - 32, time=200, onComplete=function()
					wrapped()
				end, tag=tagTransition} )
			coroutine.yield()
			transition.moveTo( self.go, {x=origin.x + math.random(0, 300), y=origin.y + 120 - 32, time=600, onComplete=function()
					wrapped()
				end, tag=tagTransition} )
			coroutine.yield()
			transition.moveTo( self.go, {x=origin.x + math.random(0, 300), y=origin.y + 168, time=200, onComplete=function()
					wrapped()
				end, tag=tagTransition} )
			coroutine.yield()
			transition.moveTo( self.go, {x=origin.x + math.random(0, 300), y=origin.y + 200, time=600, onComplete=function()
					wrapped()
				end, tag=tagTransition} )
			coroutine.yield()
			transition.moveTo( self.go, {x=origin.x + math.random(0, 300), y=origin.y + 232, time=200, onComplete=function()
					wrapped()
				end, tag=tagTransition} )
			coroutine.yield()
			transition.moveTo( self.go, {x=origin.x + math.random(0, 300), y=origin.y + 264, time=600, onComplete=function()
					wrapped()
				end, tag=tagTransition} )
			coroutine.yield()
			transition.moveTo( self.go, {x=origin.x + math.random(0, 300), y=origin.y + 420, time=200, onComplete=function()
					wrapped()
				end, tag=tagTransition} )
			coroutine.yield()
			if self.go then
				display.remove(self.go)
				self.go = nil
			end
		end)
		wrapped()
	end

	function M:disable()
     self.disabled = true
	end

	function M:enterFrame(event)
	end
	if params.isFront then
		M:zigzag(params)
	end
	return M
end