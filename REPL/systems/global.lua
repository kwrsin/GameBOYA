-- global.lua

require 'src.systems.debug'
logger = require 'src.systems.logger'
utils = require 'src.libs.utils' 

language = require(string.format( '%s%s', 'src.structures.localizations.', utils.lang())) 

-- GLOBAL
function L(key)
	return language[key] or key
end
