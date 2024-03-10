uiLib = require 'src.libs.uiLib'
utils = {}
local composer = require 'composer'

-- CONSTANTS
CX = display.contentCenterX
CY = display.contentCenterY
GOS_TOP = 'dev.tools.scenes.top'
GOS_DATA_MAKER = 'dev.tools.scenes.GOSDataMaker'
SEQUENCE_MAKER = 'dev.tools.scenes.SequenceMaker'
FILE_SELECTOR = 'dev.tools.scenes.FileSelector'

HEADER_HEIGHT = 64



-- GLOBAL VALUES


-- GLOBAL FUNCTIONS
function utils.gotoScene(name, options)
	composer.gotoScene(name, options)
end

function utils.gotoTop(options)
	local options  = options or {}
	options.effect = 'fromRight' 
	options.time = 400
	utils.gotoScene(GOS_TOP, options)
end

function utils.gotoDataMaker(options)
	local options  = options or {}
	options.effect = 'fromLeft' 
	options.time = 400
	utils.gotoScene(GOS_DATA_MAKER, options)
end

function utils.gotoSequenceMaker(options)
	local options  = options or {}
	options.effect = 'fromLeft' 
	options.time = 400
	utils.gotoScene(SEQUENCE_MAKER, options)
end

function utils.gotoFileSelector(options)
	local options  = options or {}
	-- options.effect = 'fromLeft' 
	-- options.time = 400
	-- utils.gotoScene(FILE_SELECTOR, options)
	options.isModal = true
  options.effect = "fade"
  options.time = 400

	composer.showOverlay( FILE_SELECTOR, options )
end

function utils.hideFileSelector()
	composer.hideOverlay( "fade", 400 )
end

function utils.previous(options)
	local options  = options or {}
	options.effect = 'fromRight' 
	options.time = 400
	utils.gotoScene(
	composer.getSceneName( 'previous' ), options)
end