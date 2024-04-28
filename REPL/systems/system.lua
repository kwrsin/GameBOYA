-- system.lua

language = require(string.format( '%s%s', 'src.structures.localizations.', utils.lang())) 

-- GLOBAL
function L(key)
	return language[key] or key
end
