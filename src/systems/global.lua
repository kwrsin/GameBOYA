-- global.lua
require 'src.systems.debug'
require 'src.systems.const'
logger = require 'src.systems.logger'
utils = require 'src.libs.utils'
storage = require 'src.libs.storage'
controller = require 'src.libs.controller'
virtualControlelr = require 'src.libs.virtual_controller'
sound = require 'src.libs.sound'
contentManager = require 'src.scenes.contents.contentManager'

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

require 'src.systems.system'
utils.gotoScene(LOADER_SCENE)
