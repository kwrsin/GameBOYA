-- gorilla.lua
local base = require 'src.gos.base'
local structure = require 'src.structures.gos.gorilla'
local relations =  require 'src.structures.relations'
local caskGen = require 'src.gos.actors.cask'
local sprite

local function createSprite(params)
	sprite = display.newSprite( 
		params.parent, 
		gImageSheets.gorilla, 
		structure.sequences )
	return sprite
end


return function(params)
	local M = base(params)
	M.go = createSprite(params)
	M.defaultStatus = 'drumming'
	M:play(M.defaultStatus)
	M.counter = 0

	function M:disable()
     self.disabled = true
     -- timer.cancel( tagTimer )
     -- transition.cancel(tagCask)
	end

	function M:throw1()
		caskGen{
			parent=self.go.parent, 
			x=self.go.x + 32, 
			y=self.go.y + 32, 
			isFront=false}
	end

	function M:throw2()
		caskGen{
			parent=self.go.parent, 
			x=self.go.x, 
			y=self.go.y + 64, 
			isFront=true}
	end

	M.commands = {
		throw1=M.throw1,
		throw2=M.throw2
	}

  function M:update(event)
    if not self.go then return end
    if self.delay > 0 then return end

		if self.counter > 100 then
			local rnd = math.random( )
			if rnd < 0.2 then
				self:play('throw1', 10)
			elseif  rnd < 0.6 then
				self:play('throw2', 10)
			else
				self:play(M.defaultStatus)
			end
			self.counter = 0
		end
		self.counter = self.counter + 1
  end

  function M:getButtonStatus()
  end

	function M:sprite( event )
		if event.phase == 'ended' then
			self.commands[self.go.sequence](self)
		end
	end

	M.go:addEventListener( 'sprite', M )
	return M
end