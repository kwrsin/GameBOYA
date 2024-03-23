publisher = require 'src.libs.bindings.publisher'
storage = require 'src.libs.storage'
uiLib = require 'src.libs.uiLib'
utils = {}
local composer = require 'composer'

-- CONSTANTS
CX = display.contentCenterX
CY = display.contentCenterY
CW = display.contentWidth
CH = display.contentHeight
SOY, SOX = display.screenOriginY, display.screenOriginY
ACW, ACH = display.actualContentWidth, display.actualContentHeight

GOS_TOP = 'dev.tools.scenes.top'
GOS_DATA_MAKER = 'dev.tools.scenes.GOSDataMaker'
SEQUENCE_MAKER = 'dev.tools.scenes.SequenceMaker'
GAMEOBJECT_MAKER = 'dev.tools.scenes.GameObjectMaker'
FILE_SELECTOR = 'dev.tools.scenes.FileSelector'
FILE_PICKER = 'dev.tools.scenes.FilePicker'
RELATIONS_MAKER = 'dev.tools.scenes.RelationsMaker'
MULTI_SELECTOR = 'dev.tools.scenes.MultiSelector'
TEST_PUBSUB = 'dev.tools.scenes.tests.TestPubSub'
ARRAY_MAKER = 'dev.tools.scenes.ArrayMaker'

IMAGES_PATH = '../../../assets/images'
IMAGES_BASE_PATH = 'assets/images/'
SOUNDS_PATH = '../../../assets/sounds'
SOUNDS_BASE_PATH = 'assets/sounds/'
GOS_DATA_PATH = '../../../src/structures/gos'
RELATIONS_PATH = '../../../src/structures/relations_.lua'

HEADER_HEIGHT = 64

BIND_SELECTEDITEM = 'selectedItem'
BIND_SELECTEDITEMS = 'selectedItems'
BIND_SEQUENCE = 'selectedSequence'

NAME_FILE_SELECTOR = 'File Selector'
NAME_SOUND_SELECTOR = 'Sound Selector'
NAME_COLLISION_NAME = 'Collision Name'
NAME_COLLISION_TYPE = 'Collision Type'


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

function utils.gotoRelationsMaker(options)
	local options  = options or {}
	options.effect = 'fromLeft' 
	options.time = 400
	utils.gotoScene(RELATIONS_MAKER, options)
end

function utils.gotoMultiSelector(options)
	local options  = options or {}
	options.effect = 'fromLeft' 
	options.time = 400
	utils.gotoScene(MULTI_SELECTOR, options)
end

function utils.gotoSequenceMaker(options)
	local options  = options or {}
	options.effect = 'fromLeft' 
	options.time = 400
	utils.gotoScene(SEQUENCE_MAKER, options)
end

function utils.gotoArrayMaker(options)
	local options  = options or {}
	options.effect = 'fromLeft' 
	options.time = 400
	utils.gotoScene(ARRAY_MAKER, options)
end

function utils.gotoFileSelector(options)
	local options  = options or {}
	-- options.effect = 'fromLeft' 
	-- options.time = 400
	-- utils.gotoScene(FILE_SELECTOR, options)
	options.isModal = true
	options.effect = "fade"
	options.time = 400

	utils.gotoScene(FILE_SELECTOR, options )
end

function utils.gotoGameObjectMaker(options)
	local options  = options or {}
	options.effect = 'fromLeft' 
	options.time = 400
	utils.gotoScene(GAMEOBJECT_MAKER, options)
end

function utils.gotoFilePicker(options)
	local options  = options or {}
	options.effect = 'fromLeft' 
	options.time = 400
	utils.gotoScene(FILE_PICKER, options)
end

function utils.gotoTestPubSub(options)
	utils.gotoScene(TEST_PUBSUB, options)
end

function utils.hideFileSelector(options)
	-- composer.hideOverlay( "fade", 400 )
	utils.previous(options)
end

function utils.previous(options)
	local options  = options or {}
	options.effect = 'fromRight' 
	options.time = 400
	utils.gotoScene(
	composer.getSceneName( 'previous' ), options)
end

function utils.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[utils.deepcopy(orig_key)] = utils.deepcopy(orig_value)
        end
        setmetatable(copy, utils.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


function utils.merge(params, options)
	if params == nil then
		return options
	end
	for k, v in pairs(params) do
		options[k] = params[k]		
	end
	return options
end

system.setTapDelay( 0.2 )

-- utils.gotoTop()
-- utils.gotoGameObjectMaker()
utils.gotoFilePicker()
-- utils.gotoRelationsMaker()
-- utils.gotoDataMaker()
-- utils.gotoTestPubSub()



-- require 'dev.tools.scenes.tests.TestAPI'

