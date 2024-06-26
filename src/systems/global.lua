-- global.lua
require 'src.systems.debug'
require 'src.systems.const'
require 'src.systems.labels'
publisher = require 'src.libs.bindings.publisher'
logger = require 'src.systems.logger'
utils = require 'src.libs.utils'
storage = require 'src.libs.storage'
controller = require 'src.libs.controller'
virtualControlelr = require 'src.libs.virtual_controller'
sound = require 'src.libs.sound'
uiLib = require 'src.libs.uiLib'
language = require(string.format( '%s%s',LOCALIZATIONS_PATH, utils.lang())) 

publisher:observe(PUBSUB_EVENT_TOP, {})
publisher:observe(PUBSUB_EVENT_MENU, {})
publisher:observe(PUBSUB_PARAMETERS, {})

gImageSheets = nil
player = nil

contentManager = nil

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
