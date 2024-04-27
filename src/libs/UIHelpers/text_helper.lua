-- text_box.lua

local getModel = require 'src.libs.UIHelpers.models.characters_model'

return function ()
	local M = {}
	M.isFocus = false
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
		display.getCurrentStage().stage:setFocus( self.go )
		self.go.alpha = 1
		self.isFocus = true	
		transition.resume( self.cur )
		self.cur.alpha = 1
	end

	function M:blur()
		display.getCurrentStage().stage:setFocus( nil )
		self.go.alpha = 0.8
		self.isFocus = false
		transition.pause( self.cur )	
		self.cur.alpha = 0
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
		self.model:prevCursor(function(pos)
			self:moveCursor(pos)
			self.model:remove()
			self:print{preventCursorMoving=true}
		end)
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
		if self.model:size() >= self.maxLength then return end
		local pos = self.model:insert(character)
		self:moveCursor(pos)

		self:print{preventCursorMoving = true}

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

	function M:next()
		-- if not self.editable then return end
		-- if self.cursorIndex >= self.model:size() then return end
		if not self.isFocus then return end
		local pos = self.model:nextCursor()
		self:moveCursor(pos)
	end

	function M:back()
		-- if not self.editable then return end
		-- if self.cursorIndex <= 1 then return end
		if not self.isFocus then return end
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

		self.go:addEventListener( 'touch', self)

		self:print()
		self:createCursor()
		self:blur()


		return self
	end

	return M

end


--[[ TODO
x- backspace
- clear btn
x- focus on/off
x-		cursor show/hide
- vertual keyboard support
- copy/past/cut/selection
x- uppsercase/lowercase

]]--


-- [EXAMPLE]

-- local textHelper = require ('src.libs.UIHelpers.text_helper')


-- local th = textHelper()
-- th:create{
-- 	charWidth=20,
-- 	charHeight=26,
-- 	maxLength=20,
-- 	x=60,
-- 	y=display.contentCenterY,
-- 	chars=utils.toChars('abcd'),
-- 	editable=true,
-- }

-- local th2 = textHelper()
-- th2:create{
-- 	charWidth=20,
-- 	charHeight=26,
-- 	maxLength=20,
-- 	x=60,
-- 	y=display.contentCenterY + 100,
-- 	chars=utils.toChars(''),
-- 	editable=true,
-- }

-- local onShiftKey = false
-- Runtime:addEventListener( 'key', function(event)
-- 	if event.phase == 'up' then
-- 		if event.keyName == 'right' then
-- 			th:next()
-- 			th2:next()
-- 		elseif event.keyName == 'left' then
-- 			th:back()
-- 			th2:back()
-- 		elseif event.keyName == 'deleteBack' or event.keyName == 'Delete' then
-- 			th:backspace()
-- 			th2:backspace()
-- 		elseif event.keyName == 'tab' then
-- 			th:blur()
-- 			th2:blur()
-- 		elseif event.keyName == 'leftShift' or event.keyName == 'rightShift' then
-- 			onShiftKey = false
-- 		elseif #event.keyName == 1 and string.match( event.keyName, '[0-9a-zA-Z+-]+' ) then
-- 			local keyName = event.keyName
-- 			if onShiftKey then keyName = string.upper( keyName ) end
-- 			th:input(utils.toChars(keyName)[1])
-- 			th2:input(utils.toChars(keyName)[1])
-- 		end
-- 	elseif event.phase == 'down' then
-- 		if event.keyName == 'leftShift' or event.keyName == 'rightShift' then
-- 			onShiftKey = true
-- 		end
-- 	end
-- end )
