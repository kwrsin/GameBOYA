-- global.lua
require 'src.systems.debug'
require 'src.systems.const'
logger = require 'src.systems.logger'
utils = require 'src.libs.utils'
storage = require 'src.libs.storage'
controller = require 'src.libs.controller'
virtualControlelr = require 'src.libs.virtual_controller'
sound = require 'src.libs.sound'

gImageSheets = nil
player = nil

mRatio = 2

buttonStatus = {
	up=0,
	down=0,
	right=0,
	left=0,
	btnA=0,
}

function getContentManager()
	local key = 
		utils.lastWord(storage:get('selectedLevel'))
	local dotPath = GAME_LEVELS[key] or DEFAULT_CONTENT_MANAGER
	return require(dotPath)
end

require 'src.systems.system'
utils.gotoScene(LOADER_SCENE)
