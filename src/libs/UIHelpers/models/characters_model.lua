-- characters_model.lua

return function (characters, length)
	local model = {}
	model.characters = characters or {}
	model.pos = #characters
	model.length = length

	if model.pos <= 0 then model.pos = 1 end

	function model:getCurrentPos()
		return model.pos
	end

	function model:first()
		model.pos = 1
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
		-- if self.pos <= 1 or self.pos > self:size() then return nil end
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
		self.pos = start
	end

	function model:size()
		return #self.characters
	end

	function model:getXY(pos)
		local x, y = 1, 1
		local newLine = 0

		for i = 1, #self.characters do
			local c = self.characters[i]

			if newLine == 1 then
				x = 1
				y = y + 1
				newLine = 0
			end

			if c.value == '\n' then
				newLine = 1
			elseif x == self.length then
				if (i + 1) <= #self.characters and 
					self.characters[i + 1].value == '\n' then
					-- NOP	
				else
					newLine = 1		
				end
			end

			if i == pos then break end

			x = x + 1
		end
		return x, y
	end

	return model
end

-- local characters = utils.toChars(L('hel\nlo\ngoodbyeeee\n\n\n'))
-- local length = 5
-- local function getXY(pos)
-- 	local x, y = 1, 1
-- 	local newLine = 0

-- 	for i = 1, #characters do
-- 		local c = characters[i]

-- 		if newLine == 1 then
-- 			x = 1
-- 			y = y + 1
-- 			newLine = 0
-- 		end

-- 		if c.value == '\n' then
-- 			newLine = 1
-- 		elseif x == length then
-- 			if (i + 1) <= #characters and 
-- 				characters[i + 1].value == '\n' then
-- 				-- NOP	
-- 			else
-- 				newLine = 1		
-- 			end
-- 		end

-- 		if i == pos then break end

-- 		x = x + 1
-- 	end
-- 	return x, y
-- end

-- for i, c in ipairs(characters) do
-- 	local x, y = getXY(i)
-- 	print(string.format('x=%d,y=%d,value=%s\n', x, y , c.value))
-- end
-- local idx = 9
-- local x, y = getXY(idx)
-- print(string.format('x=%d,y=%d,value=%s\n', x, y , characters[idx].value))
