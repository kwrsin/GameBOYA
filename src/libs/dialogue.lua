local utf8 = require( "plugin.utf8" )

local M = {}
local duration = -1
local _duration
local dec = 0
local words = nil
local pausing = false
local row = 5
local col = 20
local colPos = 1
local rowPos = 1
local index = 1
local fontColor
local accentColor
local counter

local tapped = false

local root
local container
local sentences
local name
local sprite

local prompt
local lineSize
local frameHeight
local frameWidth

local lines = {}
local onEvent = nil

function M:getChar()
	local char = utf8.sub(words, index, index)
	index = index + 1
	return char
end

function swapRow()
	local ln = table.remove(lines, 1)
	ln.y = lines[#lines].y + lineSize
	ln.text = ''
	ln:setFillColor( unpack( fontColor ))
	table.insert( lines, ln )
	rowPos = #lines
end

function createActorProfile(params)
	-- actor's name
	-- actor's image_path
end

function showPrompt()
	prompt.alpha = 1.0
	transition.blink( prompt, {time=3000, tag='dialogue'} )
end

function hidePrompt()
	prompt.alpha = 0.0
	transition.cancel('dialogue')
end

function lock()
	pausing = true
	tapped = false
	duration = _duration
	showPrompt()
end

function liftup(cb)
	transition.moveBy( sentences, {y=-lineSize, time=10, tag='dialogue', onComplete=function()
		swapRow()
		if cb then
			cb()
		end
	end} )
end

function unlock()
	hidePrompt()
	liftup(function()  
		pausing = false
		tapped  = true
	end)
end

function beep()
	-- actor's sound
end

function M:put(char)
	if char == '\n' then
		rowPos = rowPos + 1
		counter = counter + 1
		if counter > #lines then
			lock()
			counter = 1
		else
			if rowPos > #lines then
				liftup(function()  
					pausing = false
					tapped  = true
				end)
			end
		end
		dec = duration
		return
	end
	local line = lines[rowPos]
	line.text =  utf8.insert(line.text, char)
	if accentColor then
		line:setFillColor( unpack(accentColor) )
	end
	dec = duration
	beep()
end

function M:clear()
	self:reset()
	words = nil
	hidePrompt()
	for i, ln in ipairs(lines) do
		ln.y = (frameHeight / 2 * -1 ) + i * lineSize
		ln.text = ''
	end
	sentences.y = 0
end

function M:reset()
	colPos = 1
	rowPos = 1
	index = 1
	counter=1
	pausing= false
	tapped = false
end

function M:say(params)
	self:clear()
	self:showDialogue()
	root.x, root.y = params.x or root.x, params.y or root.y
	words = params.words or ''
	name = params.name or ''
	duration = params.duration or 0
	_duration = duration
	accentColor = params.accentColor
	sprite = params.sprite
	onEvent = params.onComplete
end

function createFrameBackground(group, params)
	local bg = display.newRoundedRect( root, 0, 0, frameWidth, frameHeight, 20 )
	bg.x, bg.y = group.x, group.y
	bg:setFillColor( 1, 1, 0, 0.3 )
end

function createFrame(params)
	row = params.frame.row or row
	col = params.frame.col or col
	fontColor = params.frame.fontColor or {1, 1, 1, 1}
	lineSize = params.frame.lineSize
	frameWidth = params.frame.width
	frameHeight = params.frame.height
	container = display.newContainer( root, frameWidth, frameHeight)
	container.x, container.y = params.frame.x or 0, params.frame.y or 0
	createFrameBackground(container, params)
	sentences = display.newGroup( )
	container:insert(sentences)
	for i=1, row do
		local ln = display.newText( sentences, '', 0, (frameHeight / 2 * -1 ) + i * lineSize, frameWidth-20, 0, params.frame.font, params.frame.fontSize, 'left' )
		ln:setFillColor( unpack( fontColor ))
		lines[#lines + 1] = ln
	end

	return sentences
end

function createDialogue(params)
	root = display.newGroup( )
	params.group:insert(root)
	root.x, root.y = params.x or CX, params.y or CY
	root:addEventListener( 'tap', function(event)
		if tapped then return end
		tapped = true
		if pausing then
			unlock()
		else
			duration = 1
		end
	end )

	return root
end

function createPrompt(params)
	prompt = display.newGroup( )
	root:insert(prompt)
	prompt.x, prompt.y = 
		container.x + frameWidth / 2 -24, 
		container.y + frameHeight / 2 -24
	local bg = display.newRoundedRect( prompt, 0, 0, 30, 20, 60 )
	bg:setFillColor(0.2, 0.2, 0.1, 0.6)
	local lbl = display.newText( prompt, "V", 0, 0, native.systemFontBold, 12 )
	prompt.alpha = 0
end

function M:showDialogue()
	transition.scaleTo( root, {time=120, yScale=1.0, tag='dialogue', transition=easing.inElastic} )
	root.alpha = 1
end

function M:hideDialogue()
	transition.fadeOut( root, {time=120, tag='dialogue', transition=easing.inQuint, onComplete=function()
		root.yScale = 0.1
	end} )
end

function M:create(params)
	pausing = false
	createDialogue(params)
	createFrame(params)
	createPrompt(params)
	root.alpha = 0
	root.yScale = 0.1
end

function M:enterFrame(event)
	if not words or index > utf8.len(words) then return end
	if index == utf8.len(words) then
		if onEvent then
			onEvent()
			onEvent = nil
		end
	end
	if pausing then return end
	if dec < 0 then return end
	if dec == 0 then
		local char = self:getChar()
		self:put(char)
	end
	dec = dec - 1
end

return M