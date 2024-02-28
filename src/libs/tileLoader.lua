-- tileLoader.lua
local parent
local tile
local imageSheets
local dictionary
local callback

local function getTileset(name)
	for i, tileset in ipairs(tile.tilesets) do
		if tileset.name == name then
			return tileset
		end
	end
	return nil
end

local function bind()
	dictionary = {}
	for name, imageSheet in pairs(imageSheets) do
		local tileset = getTileset(name)
		if tileset then
			tileset.imageSheet = imageSheet
			dictionary[name] = {
				from=tileset.firstgid,
				to=tileset.firstgid + tileset.columns - 1
			}
		end
	end
end

local function getCollision(tileset, index)
	if not tileset.tiles or #tileset.tiles <= 0 then return end
	for i, tile in ipairs(tileset.tiles) do
		if index - 1 == tile.id and tile.objectGroup then
			return tile.objectGroup
		end
	end
	return nil
end

local function getTilesetFromId(id)
	for k, v in pairs(dictionary) do
		if id >= v.from and id <= v.to then
			return getTileset(k)
		end
	end
	return nil
end

local function toIndex(id)
	local tileset = getTilesetFromId(id)
	if not tileset then return -1 end
	return id - tileset.firstgid + 1
end

local function proc()
	bind()
	for i, layer in ipairs(tile.layers) do
		if layer.type == 'tilelayer' and layer.visible then
			local gp = display.newGroup( )
			local data = layer.data
			
			for i=1,layer.height do
				for j=1,layer.width do
					local gId = data[(i-1) * layer.width + j]
					local tileset = getTilesetFromId(gId)
					local index = toIndex(gId)
					local imageSheet
					local collision
					if tileset then
						imageSheet = tileset.imageSheet
						collision = getCollision(tileset, index)
					end
					if gId > 0 then
						local go
						if callback then
							go = callback({
								parent=gp, 
								gId=gId,
								imageSheet=imageSheet,
								index=index,
								width=tile.tilewidth,
								height=tile.tileheight,
								layername=layer.name,
								type=layer.type,
								collision=collision
								})
						else
							go = display.newImageRect( 
								gp, 
								imageSheet, 
								index, 
								tile.tilewidth, 
								tile.tileheight )
						end
						if go then
							go.x = j * tile.tilewidth - tile.tilewidth / 2
							go.y = i * tile.tileheight - tile.tileheight / 2
						end
					end
				end
			end
			parent:insert(gp)
		elseif layer.type == 'imagelayer' and layer.visible then
			local gp = display.newGroup( )
			local path = string.gsub(layer.image, '%.%./', '')
			local img = display.newImageRect( gp, path, tile.width * tile.tilewidth, tile.height * tile.tileheight)
			img.anchorX, img.anchorY = 0, 0
			parent:insert(gp)
		elseif layer.type == 'objectgroup' and layer.visible then
			local gp = display.newGroup( )
			for i=1,#layer.objects do
				local obj = layer.objects[i]
				local gId = obj.gid
				local go
				if gId then
					local tileset = getTilesetFromId(gId)
					local index = toIndex(gId)
					local imageSheet
					local collision
					if tileset then
						imageSheet = tileset.imageSheet
						collision = getCollision(tileset, index)
					end
					if callback then
						go = callback({
							parent=gp, 
							gId=gId,
							imageSheet=imageSheet,
							index=index,
							width=tile.tilewidth,
							height=tile.tileheight,
							layername=layer.name,
							type=layer.type,
							collision=collision
							})
						-- go.anchorX = 0
						-- go.anchorY = 1.0
						go.x = obj.x + obj.width / 2
						go.y = obj.y - obj.height / 2
					end
				elseif obj.shape == 'polygon' then
					local top, bottom, right, left
					local vertices = {}
					for i, v in ipairs(obj.polygon) do
						vertices[#vertices + 1] = v.x
						vertices[#vertices + 1] = v.y
						if not top then top = v.y end 
						if not bottom then bottom = v.y end 
						if not right then right = v.x end 
						if not left then left = v.x end
						if top > v.y then top = v.y end
						if bottom < v.y then bottom = v.y end
						if left > v.x then left = v.x end
						if right < v.x then right = v.x end
					end
					local halfHeight= (math.abs(top) + math.abs(bottom)) / 2
					local halfWidth = (math.abs(left) + math.abs(right)) / 2
					go = display.newPolygon(
						gp,
						obj.x + halfWidth + left,
						obj.y + halfHeight + top,
						vertices)
						-- go.anchorX = 0
						-- go.anchorY = 0
					physics.addBody( go, 'static', {density=1, friction=1, bounce=0} )
					go.class = 'floor'
				elseif obj.shape == 'ellipse' then
					local radius = obj.width / 2
					go = display.newCircle( 
						gp, 
						obj.x + obj.width / 2, 
						obj.y + obj.height / 2, 
						radius )
					physics.addBody( go, 'static', {density=1, friction=1, bounce=0, radius=radius} )
					go.class = 'floor'
				else
					go = display.newRect( 
						gp,
						obj.x,
						obj.y + obj.height,
						obj.width, 
						obj.height )					
						go.anchorX = 0
						go.anchorY = 1
					physics.addBody( go, 'static', {density=1, friction=1, bounce=0} )
					go.class = 'floor'
				end
				if go then
					if obj.rotation then
						go:rotate(obj.rotation)
					end
					if not obj.visible then
						go.alpha = 0
					end
				end
			end
			parent:insert(gp)
		end
	end
end

return function(params)
	parent = params.parent
	tile = params.level
	imageSheets = params.imageSheets
	callback = params.callback
	proc()
end