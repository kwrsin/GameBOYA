-- text_box.lua

local getModel = require 'src.libs.UIHelpers.models.characters_model'

return function ()
	local M = {}
	M.isFocus = false
	M.originPoint = 0
	M.range = { start = 0, stop = 0 }

	function M:emptyRange()
		return self.range.start == 0 and self.range.stop == 0
	end

	function M:removeRange()
		self.model:removeRangedChars(self.range)

		self:moveCursor(self.range.start)

		self:print{preventCursorMoving=true}

		self:unselecteChars()
		self:resetRelection()
	end

	function M:background(params)
		local strWidth = self.maxLength * self.charWidth
		local charHeight = self.charHeight
		local bgcolor = params.bgcolor or {0.2, 0.2, 0.2, 1}
		local r = display.newRect(M.go, 0, 0, strWidth, charHeight)
		r:setFillColor( unpack(bgcolor) )
		r.anchorX = 0
	end

	function M:charObject(character, startXPos)
		local font = self.params.font or native.systemFont
		local fontSize = self.params.fontSize or self.charWidth
		local charWidth = self.charWidth
		local obj = display.newText( self.goChidren, character, startXPos, 0, font, fontSize )
		local padding = charWidth / 2 - obj.width / 2
		local color = self.params.color or {1, 1, 1, 1}
		obj:setStrokeColor(color)
		obj.x = obj.x + padding
		obj.anchorX = 0
	end

	function M:focus()
		self:resetRelection()
		display.getCurrentStage().stage:setFocus( self.go )
		self.go.alpha = 1
		self.isFocus = true	
		transition.resume( self.cur )
		self.cur.alpha = 1
	end

	function M:blur()
		self:resetRelection()
		display.getCurrentStage().stage:setFocus( nil )
		self.go.alpha = 0.8
		self.isFocus = false
		transition.pause( self.cur )	
		self.cur.alpha = 0
	end

	function M:copy()
		if not self.isFocus then return end
		local result = {}
		if self.range.start + self.range.stop <= 2 then
			return result
		end
		local chars = self.model:getCharacters()
		for i=self.range.start, self.range.stop - 1 do
			result[#result + 1] = chars[i]
		end
		return result
	end

	function M:paste(characters)
		if not self.isFocus then return end
		if #characters <= 0 then return end
		
		if not self:emptyRange() then
			self:backspace()
		end
		local pos = self.model:getCurrentPos()

		local overflow = (self.model:size() + #characters) - self.maxLength
		if overflow > 0 then
			local num = #characters - overflow
			for i=1,num do
				self.model:insert(characters[i])
			end
			self:moveCursor(pos + num)
		else
			for i, c in ipairs(characters) do
				self.model:insert(c)
			end
			self:moveCursor(pos + #characters)
		end

		self:print{preventCursorMoving=true}
		self:resetRelection()
	end

	function M:cut()
		if not self.isFocus then return end
		local result = self:copy()
		self:removeRange()
		return result
	end

	function M:drawSelection(start, stop)
		local startAt = (start-1) * self.charWidth
		local stopAt = (stop-1) * self.charWidth
		local width = stopAt - startAt
		local height = self.charHeight
		local rect = display.newRect( self.selectionLayer, startAt, 0, width, height )
		rect:setFillColor( 0.2, 0.2, 1, 0.3 )
		rect.anchorX = 0
	end

	function M:createSelection(start, stop)
		self:unselecteChars()
		self.range.start, self.range.stop = start, stop
		self:drawSelection(start, stop)
	end

	function M:selectAll()
		if not self.isFocus then return end
		self.model:first()
		for i=1,self.model:size() do
			self:upscale()
		end
	end

	function M:selectChars()
		local currentPos = self.model:getCurrentPos()
		local start
		local stop

		if currentPos - self.originPoint > 0 then
			start = math.min(self.originPoint, self.model:size()) 
			stop = currentPos
			self:createSelection(start, stop)
		elseif currentPos - self.originPoint < 0 then
			stop = math.max(1, self.originPoint) 
			start = currentPos
			self:createSelection(start, stop)
		else
			self:unselecteChars()
		end
	end

	function M:unselecteChars()
		for i = self.selectionLayer.numChildren, 1, -1 do
			local o = display.remove( self.selectionLayer[i] )
			o = nil
		end
	end

	function M:upscale()
		if not self.isFocus then return end
		self:next(true)
		self:selectChars()
	end

	function M:downscale()
		if not self.isFocus then return end
		self:back(true)
		self:selectChars()
	end

	function M:resetRelection()
		self.originPoint = 0
		self.range.start, self.range.stop = 0, 0
		self:unselecteChars()
	end

	function M:removeChildObjects()
		local numChildren = self.goChidren.numChildren
		if numChildren and numChildren > 0 then
			for i=numChildren, 1, -1 do
				local o = display.remove( self.goChidren[i] )
				o = nil
			end
		end	
	end

	function M:clear()
		if not self.isFocus then return end
		self:removeChildObjects()

		self.model:removeChars()
	end

	function M:backspace()
		if not self.isFocus then return end
		if self:emptyRange() then
			self.model:prevCursor(function(pos)
				self:moveCursor(pos)
				self.model:remove()
				self:print{preventCursorMoving=true}
				self:resetRelection()
			end)
		else
			self:removeRange()
		end
	end

	-- function M:append(character)
	-- 	if not self.editable then return end
	-- 	if self.model:size() >= self.maxLength then return end
	-- 	self.model:insert(character, self.cursorIndex)
	-- 	self:charObject(character.value)

	-- 	M.startXPos = (self.model:size() - 1) * self.charWidth
	-- 	self.cursorIndex = self.model:size()
	-- end

	function M:print(params)
		local params = params or {}
		self:removeChildObjects()

		for i, c in ipairs(self.model:getCharacters()) do
			if c then
				local startXPos = (i - 1) * self.charWidth
				self:charObject(c.value, startXPos)
				if params.preventCursorMoving then else
					self.model:nextCursor()
				end
			end
		end
	end

	function M:input(character)
		-- if self.cursorIndex >= self.model:size() then
		-- 	print('a')
		-- 	self:append(character)
		-- else
		-- 	print('i')
		-- end
			self:insert(character)
	end

	function M:insert(character)
		if not self.isFocus then return end
		if not self.editable then return end

		if not self:emptyRange() then
			self:backspace()
		end
		if self.model:size() >= self.maxLength then return end

		local pos = self.model:insert(character)
		self:moveCursor(pos)

		self:print{preventCursorMoving = true}
		self:resetRelection()
	end

	function M:touch(event)
		if event.phase == 'ended' then
			if self.isFocus then
				self:blur()
			else
				self:focus()
			end
		end
		return true
	end

	function M:createCursor()
		if not self.editable then return end
		self.cur = display.newRect( self.cursorLayer, self.model:size() * self.charWidth, 0, 2, self.charHeight*0.7 )
		self.cur.anchorX = 0
		self.cur:setFillColor( 1, 1, 1, 1 )
		transition.blink( self.cur, {tag='trans', time=2000} )
	end

	function M:moveCursor(pos)
		if self.cur then
			self.cur.x = (pos - 1) * self.charWidth
		end
	end

	function M:next(cancelReset)
		-- if not self.editable then return end
		-- if self.cursorIndex >= self.model:size() then return end
		if not self.isFocus then return end
		if not cancelReset then
			self:resetRelection()
		elseif self.originPoint <= 0 then
			self.originPoint = self.model:getCurrentPos()
		end
		local pos = self.model:nextCursor()
		self:moveCursor(pos)
	end

	function M:back(cancelReset)
		-- if not self.editable then return end
		-- if self.cursorIndex <= 1 then return end
		if not self.isFocus then return end
		if not cancelReset then
			self:resetRelection()
		elseif self.originPoint <= 0 then
			self.originPoint = self.model:getCurrentPos()
		end
		local pos = self.model:prevCursor()
		self:moveCursor(pos)
	end

	function M:create(params)
		self.model = getModel(params.chars or {})
		self.charWidth = params.charWidth
		self.charHeight = params.charHeight
		self.maxLength = params.maxLength or 20
		self.editable = params.editable
		self.params = params

		self.go = display.newGroup()
		if params.parent then params.parent:insert(self.go) end
		self:background(params)
		self.go.x, self.go.y = params.x or 0, params.y or 0
		self.goChidren = display.newGroup()
		self.go:insert(self.goChidren)
		self.cursorLayer = display.newGroup()
		self.go:insert(self.cursorLayer)

		self.selectionLayer = display.newGroup( )
		self.go:insert(self.selectionLayer)

		self.go:addEventListener( 'touch', self)

		self:print()
		self:createCursor()
		self:blur()
		self:resetRelection()

		return self
	end

	return M

end


--[[ TODO
x- backspace
- clear btn
x- focus on/off
x-		cursor show/hide
x- copy/past/cut/selection
x- uppsercase/lowercase

]]--


-- [EXAMPLE]

-- require 'REPL.systems.global'

-- local textHelper = require ('src.libs.UIHelpers.text_helper')

-- local th = textHelper()
-- th:create{
-- 	charWidth=20,
-- 	charHeight=26,
-- 	maxLength=20,
-- 	x=60,
-- 	y=display.contentCenterY,
-- 	chars=utils.toChars(L('hello')),
-- 	editable=true,
-- }

-- local th2 = textHelper()
-- th2:create{
-- 	charWidth=16,
-- 	charHeight=26,
-- 	maxLength=7,
-- 	x=60,
-- 	y=display.contentCenterY + 100,
-- 	chars=utils.toChars(''),
-- 	editable=true,
-- }

-- local onShiftKey = false
-- local onCtrl = false
-- Runtime:addEventListener( 'key', function(event)
-- 	if event.phase == 'up' then
-- 		if event.keyName == 'right' then
-- 			if onShiftKey then
-- 				th:upscale()
-- 				th2:upscale()
-- 			else
-- 				th:next()
-- 				th2:next()
-- 			end
-- 		elseif event.keyName == 'left' then
-- 			if onShiftKey then
-- 				th:downscale()
-- 				th2:downscale()
-- 			else
-- 				th:back()
-- 				th2:back()
-- 			end
-- 		elseif event.keyName == 'deleteBack' or event.keyName == 'Delete' then
-- 			th:backspace()
-- 			th2:backspace()
-- 		elseif event.keyName == 'tab' then
-- 			th:blur()
-- 			th2:blur()
-- 		elseif event.keyName == 'leftShift' or event.keyName == 'rightShift' then
-- 			onShiftKey = false
-- 		elseif event.keyName == 'leftCtrl' or event.keyName == 'rightCtrl' or
-- 						event.keyName == 'leftCommand' or event.keyName == 'rightCommand' then
-- 			onCtrl = false
-- 		elseif #event.keyName == 1 and string.match( event.keyName, '[0-9a-zA-Z+-]+' ) then
-- 			if onCtrl and event.keyName == 'c' then
-- 				local result = th:copy()
-- 				logger.info(result)
-- 				onCtrl = false
-- 				return
-- 			elseif onCtrl and event.keyName == 'v' then
-- 				th:paste(utils.toChars('PA123456789'))
-- 				onCtrl = false
-- 				return
-- 			elseif onCtrl and event.keyName == 'x' then
-- 				logger.info(th:cut())
-- 				onCtrl = false
-- 				return
-- 			elseif onCtrl and event.keyName == 'a' then
-- 				th:selectAll()
-- 				onCtrl = false
-- 				return
-- 			end

-- 			local keyName = event.keyName
-- 			if onShiftKey then keyName = string.upper( keyName ) end
-- 			th:input(utils.toChars(keyName)[1])
-- 			th2:input(utils.toChars(keyName)[1])
-- 		end
-- 	elseif event.phase == 'down' then
-- 		if event.keyName == 'leftShift' or event.keyName == 'rightShift' then
-- 			onShiftKey = true
-- 		elseif event.keyName == 'leftControl' or event.keyName == 'rightControl' or
-- 						event.keyName == 'leftCommand' or event.keyName == 'rightCommand' then
-- 			onCtrl = true
-- 		end
-- 	end
-- end )
