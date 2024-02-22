-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
require 'src.libs.debug'
require 'src.definitions.const'
utils = require 'src.libs.utils'
storage = require 'src.libs.storage'

physics.start()
system.activate( "multitouch" )


utils.gotoScene(loader_scene)
