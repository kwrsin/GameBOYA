-- sound.lua
local M = {}

M.resources = {}
M.ignoreList = {}

local function isIgnoredResource(name)
	for i, ignore in ipairs(self.ignoreList) do
		if ignore == name then
			return true
		end
	end
	return false
end

function M:index(name)
	local idx = 0
	for key, res in pairs(self.resources) do
		if key == name then
			return idx + 1
		end
		idx = idx + 1
	end
	return -1
end

function M:name(handle)
	for k, v in pairs(self.resources) do
		if v == handle then
			return v
		end
	end
	return nil
end

function M:reserveChannels(num)
	audio.reserveChannels( num )
end

function M:setVolume(volume, options)
	audio.setVolume( volume, options )
end

function M:stop(channel)
	if channel then
		audio.stop( channel )
	else
		audio.stop( )
	end
end

function M:preload(resources, protect)
	for i, filename in ipairs(resources.names) do
		local structure = require(resources.structPath .. filename)
		if structure and structure.sounds then
			for name, path in pairs(structure.sounds) do
				self.resources[name] = audio.loadSound(path)
				if protect then
					self.ignoreList[#self.ignoreList + 1] = name
				end
			end
		end
	end
end

function M:preloadStream(musics, protect)
	for name, path in pairs(musics) do
		self.resources[name] = audio.loadStream(path)
		if protect then
			self.ignoreList[#self.ignoreList + 1] = name
		end
	end
end

-- function M:preloadStream(resources, protect)
-- 	for i, filename in ipairs(resources.names) do
-- 		local structure = require(resources.structPath .. filename)
-- 		if structure and structure.sounds and #structure.sounds > 0 then
-- 			for name, path in pairs(structure.sounds) do
-- 				self.resources[name] = audio.loadStream(path)
-- 				if protect then
-- 					self.ignoreList[#self.ignoreList + 1] = name
-- 				end
-- 			end
-- 		end
-- 	end
-- end

function M:play(params)
	if params and params.name and self.resources[params.name] then
		audio.play( self.resources[params.name], params )
	end
end

function M:music1(name, params)
	local params = params or {}
	params.name = params.name or name
	params.channel= params.channel or 1
	self:play(params)
end

function M:effect2(name, params)
	local params = params or {}
	params.name = params.name or name
	params.channel= params.channel or 2
	self:play(params)
end

function M:effect(name, params)
	local params = params or {}
	params.name = params.name or name
	-- params.channel = audio.findFreeChannel()
	self:play(params)
end

function M:fade(params)
	audio.fade( params )
end

function M:fadeOut(params)
	audio.fadeOut( params )
end

function M:pause(channel)
	if channel then
		return audio.pause( channel )
	end
	return audio.pause( )
end

function M:resume(channel)
	if channel then
		return audio.resume( channel )
	end
	return audio.resume( )
end

function M:isPlaying(channel)
	return audio.isChannelPlaying( channel )
end

function M:isPaused(channel)
	return audio.isChannelPaused( channel )
end

function M:rewind(params)
	return audio.rewind( params )
end

function M:seek(time, options)
	return audio.seek( time, options )
end

function M:stopWithDelay( duration, options)
	audio.stopWithDelay( duration, options  )
end

function M:getMaxVolume(options)
	audio.getMaxVolume( options )
end

function M:getMinVolume(options)
	audio.getMinVolume(options)
end

function M:getVolume(options)
	audio.getVolume(options)
end

function M:setMaxVolume(volume, options )
	return audio.setMaxVolume( volume, options  )
end

function M:setMinVolume(volume, options )
	return audio.setMinVolume(volume, options )
end

function M:setVolume(volume, options )
	return audio.setVolume(volume, options )
end

function M:dispose()
	for name, resource in pairs(self.resources) do
		if not isIgnoredResource(name) then
			audio.dispose( resource )
			table.remove( self.resources, self.index(name) )
		end
	end
end

function M:reset(all)
	self:stop()
	if all then
		self.ignoreList = {}
	end
	self:dispose()
end

return M