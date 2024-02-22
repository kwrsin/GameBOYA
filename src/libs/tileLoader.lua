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
					local imageSheet
					if tileset then
						imageSheet = tileset.imageSheet
					end
					if gId > 0 then
						local go
						if callback then
							go = callback({
								parent=gp, 
								gId=gId,
								imageSheet=imageSheet,
								index=toIndex(gId),
								width=tile.tilewidth,
								height=tile.tileheight,
								layername=layer.name,
								})
						else
							go = display.newImageRect( 
								gp, 
								imageSheet, 
								toIndex(gId), 
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