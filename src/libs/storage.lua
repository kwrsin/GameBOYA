-- storage.lua
local lfs = require 'lfs'
local utils = require 'src.libs.utils'

local M = {}

function M:exists(path)
	local f = io.open(path, 'r')
	return f ~= nil and f:close()
end

function M:path(filename, dir)
	return system.pathForFile( filename, dir or system.DocumentsDirectory )
end

function M:writeString(path, str)
	local file, error = io.open(path, 'w')
	if not file then
		print('Error: ', error)
	else
		file:write(str)
		io.close( file )
	end	
end

function M:write(path, tbl)
	local jText = utils.toJSON(tbl, {indent=true})

	local file, error = io.open(path, 'w')
	if not file then
		print('Error: ', error)
	else
		file:write(jText)
		io.close( file )
	end
end

function M:read(path)
	local data
	local file, error = io.open(path, 'r')
	if not file then
		print('Error: ', error)
	else
		local jText = file:read( "*a" )
		data = utils.toTable(jText) or {}
		io.close( file )
	end
	return data
end

function M:mkdir(name, dir)
	if self:exists(self:path(name, dir)) then return false end
	local dirPath = self:path('', dir)
	if lfs.chdir( dirPath ) then
		lfs.mkdir( name )
		return true
	end
	return false
end

function M:remove(path)
	if not self:exists(path) then return false end
	local result, reason = os.remove(path)
	if result then
    print( "Directory removed!" )
    return true
	else
    print( "Removal failed: " .. reason )
	end
	return false
end

function M:files(dirPath)
	local files = {}
	for file in lfs.dir( dirPath ) do
		if file == '.' or file == '..' then
		else
			files[#files + 1] = file
		end
	end
	return files
end

M.configJSON = 'config.js'
function M:loadConfig(init)
	local filepath = self:path(M.configJSON)
	if self:exists(filepath) then
		return self:read(filepath)
	end
	return init or {}
end

function M:saveConfig(options)
	local filepath = self:path(M.configJSON)
	self:write(filepath, options or {})
end

M.dirs = 'data'
function M:load(filename, init)
	local dirpath = self:path(M.dirs)
	local filepath = dirpath .. '/' .. filename
	if not self:exists(filepath) then return init or {} end
	return self:read(filepath)
end

function M:save(filename, options)
	self:mkdir(self.dirs)
	local dirpath = self:path(self.dirs)
	local filepath = dirpath .. '/' .. filename
	self:write(filepath, options or {})
end

function M:removeAll()
	local dirpath = self:path(self.dirs)
	local files = self:files(dirpath)
	for i, filename in ipairs(files) do
		local filepath = dirpath .. '/' .. filename
		self:remove(filepath)
	end
	self:remove(dirpath)
	self:remove(self:path(self.configJSON))
end

M.selectedData = nil
M.selectedFile = nil
function M:open(filename, init)
	self.selectedFile = filename
	self.selectedData = self:load(filename, init)
	return self.selectedData
end

function M:get(key, default)
	self.selectedData = self.selectedData or {}
	return self.selectedData[key] or default
end

function M:put(key, value)
	self.selectedData = self.selectedData or {}
	self.selectedData[key] = value
end

function M:getLevelFlag(levelName, kind, idx)
	self.selectedData.flags = self.selectedData.flags or {}
	self.selectedData.flags.levels = self.selectedData.flags.levels or {}
	return self.selectedData.flags.levels[levelName][kind][idx]
end

function M:setLevelFlag(levelName, kind, idx, number)
	local num = number or self.selectedData.flags.levels[levelName][kind][idx]
	if num > 0 and not number then num = num - 1 end
	self.selectedData.flags.levels[levelName][kind][idx] = num
end

function M:getQuestFlag(questName, idx)
	self.selectedData.flags = self.selectedData.flags or {}
	self.selectedData.flags.quests = self.selectedData.flags.quests or {}
	return self.selectedData.flags.quests[questName][idx]
end

function M:setQuestFlag(questName, idx, number)
	local num = number or self.selectedData.flags.quests[questName][idx]
	if num > 0 and not number then num = num - 1 end
	self.selectedData.flags.quests[questName][idx] = num
end

function M:store()
	if self.selectedFile then
		self:save(self.selectedFile, self.selectedData)
	end
end

--[[
	TEST CODE
]]--

function M:test_config()
	M:saveConfig({index=100, level='lv1'})
	table.print(M:loadConfig())
end

function M:test_data()
	M:save('file1.js', {hp=100, mp=33})
	M:save('file2.js', {hp=200, mp=88})
	table.print(M:load('file1.js'))
	table.print(M:load('file2.js'))
end

function M:test_file()
	local filename = 'abcd.dat'
	local filepath = self:path(filename)
	if self:exists(filepath) then
		print('exist error')
		return false
	end

	self:write(filepath, {name='alex', address='fukuoka'})
	if not self:exists(filepath) then
		print('write error')
		return false
	end

	local tbl = self:read(filepath)
	if tbl == nil then
		print('nodata error')
		return false
	else
		table.print(tbl)
	end

	if not self:remove(filepath) then
		print('remove error')
		return false
	end

	return true
end

function M:test_dir()
	local dirname = 'mySub'
	if not self:mkdir(dirname) then
		print('mkdir error')
		return
	end
	local dirpath = self:path(dirname)
	local filenames = {'ab.dat', 'cd.dat'}
	for i, filename in ipairs(filenames) do
		local filepath = dirpath .. '/' .. filename
		self:write(filepath, {filename=filepath})
	end

	-- for i, filename in ipairs(filenames) do
	-- 	local filepath = self:path(filename, dirpath)
	-- 	local dat = self.read(filepath)
	-- 	table.print(dat)
	-- end
	local files = self:files(dirpath)
	for i, file in ipairs(files) do
		print(file)
	end

	for i, filename in ipairs(filenames) do
		local filepath = dirpath .. '/' .. filename
		if not self:remove(filepath) then
			print(filename .. 'was removed')
		end
	end

	if not self:remove(dirpath) then
		print('dir remove error')
	end
end

return M