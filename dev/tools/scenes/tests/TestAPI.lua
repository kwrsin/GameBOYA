local storage = require 'src.libs.storage'


local function testReadPaths()
	local home = './'
	local paths = storage:files(home)
	print('CURRENT DIR')
	for i, path in ipairs(paths) do
		print(string.format('--> %s, is %s' , path, storage:isDir(home .. path) == true and 'dir' or 'file'))
	end
	
	local parent = '../'
	paths = storage:files(parent)
	print('\nPARENT DIR')
	for i, path in ipairs(paths) do
		print(string.format('--> %s, is %s' , path, storage:isDir(parent .. path) == true and 'dir' or 'file'))
	end

end

local function testParentDir()
	local pp = 'src/dev/tools/'
	local pppp, _ = pp:gsub('/$', ""):gsub('/([^/]+)$', "")
	print(pppp)
end



-- testReadPaths()
testParentDir()