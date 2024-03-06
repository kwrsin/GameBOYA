-- global.lua
utils = require 'src.libs.utils'
storage = require 'src.libs.storage'
controller = require 'src.libs.controller'
virtualControlelr = require 'src.libs.virtual_controller'
sound = require 'src.libs.sound'
content = require 'src.scenes.contents.content'

gImageSheets = nil
player = nil

mRatio = 2
tagTimer = 'timer'
tagCask = 'cask'

buttonStatus = {
	up=0,
	down=0,
	right=0,
	left=0,
	btnA=0,
}
