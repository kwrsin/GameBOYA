-- characters_model.lua

return function (characters)
	local model = {}
	model.characters = characters or {}
	model.pos = #characters
	if model.pos <= 0 then model.pos = 1 end

	function model:getCurrentPos()
		return model.pos
	end

	function model:insert(chracter, fn)
		table.insert(self.characters , self.pos, chracter)
		self:nextCursor(fn)
		return self.pos
	end

	function model:getCharacters()
		return self.characters
	end
	function model:nextCursor(fn)
		local nextPos = self.pos + 1
		if nextPos > #self.characters + 1 then
			return self.pos 
		end
		self.pos = nextPos
		if fn then
			fn(self.pos)
		end
		return self.pos
	end

	function model:prevCursor(fn)
		local prevPos = self.pos - 1
		if prevPos < 1 then 
			return self.pos
		end
		self.pos = prevPos
		if fn then
			fn(self.pos)
		end
		return self.pos
	end

	function model:get()
		if self.pos <= 0 then return nil end
		return self.characters[self.pos]
	end

	function model:remove()
		-- if self.pos <= 1 or self.pos > #self.characters then return nil end
		table.remove( self.characters, self.pos )
	end

	function model:removeChars()
		for i=self.characters, 1, -1 do
			local o = table.remove( self.characters, i )
			o=nil
		end
	end

	function model:removeRangedChars(range)
		local start = range.start
		local stop = range.stop - 1
		for i = stop, start, -1 do
			local o = table.remove( self.characters, i )
			o=nil
		end
	end

	function model:size()
		return #self.characters
	end

	return model
end