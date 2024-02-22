-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
require 'src.definitions.const'
utils = require 'src.libs.utils'
storage = require 'src.libs.storage'

require 'src.systems.system'
require 'src.systems.debug'


utils.gotoScene(loader_scene)
