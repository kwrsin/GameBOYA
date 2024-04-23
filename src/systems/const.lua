-- const.lua

CX=display.contentCenterX
CY=display.contentCenterY
CW=display.contentWidth
CH=display.contentHeight

DOT_SCENES = 'src.scenes'
DOT_GO = 'src.gos'
DOT_CONTENTS = 'src.scenes.contents'
DOT_STRUCTURES = 'src.structures'
PATH_IMAGE = 'assets/images'

INITIAL_LEVEL = 'levels.opening'
MENU_LEVEL = DOT_STRUCTURES .. '.levels.menu'
DEFAULT_CONTENT_MANAGER = 'src.scenes.contents.contentManagerOpening'
GAME_LEVELS = {
	opening=DEFAULT_CONTENT_MANAGER,
	menu='src.scenes.contents.contentManagerMenu',
}

GAME_SCENE = 'game'
TITLE_SCENE = 'title'
LOADER_SCENE = 'loader'
INTERMID_SCENE= 'intermid'
SCORE_SCENE = 'SCORE_SCENE'
VIEW_WIDTH = 480
VIEW_HEIGHT = 320
CONTENT_X = 48
CONTENT_Y = CY - 256 - 24
FRAME_WIDTH = 100
FRAME_HEIGHT = 100

QUEST_FLAGS = 'flags'
SAVE_FILENAME = 'data1.js'

TAG_TIMER = 'timer'
TAG_TRANSITION = 'trans'
TAG_BLINK = 'blink'

CONTENT_DESTORY = -1
CONTENT_PAUSE = 0
CONTENT_START = 1

VC_POS = {x=-CX+120, y=CY - 120}
VBA_POS = {x=CX-120, y=CY - 120}

PUBSUB_EVENT_TOP = 'PUBSUB_EVENT_TOP'
PUBSUB_PARAMETERS = 'PUBSUB_PARAMETERS'

STORAGE_SELECTED_LEVEL = 'selectedLevel'

SCENE_OPENING = '[OPENING]'
SCENE_LOADER = '[LOADER]'
SCENE_INTERMID = '[INTERMID]'
SCENE_MENU = '[MENU]'
SCENE_GAME = '[GAME]'

LOCALIZATIONS_PATH = 'src.structures.localizations.'
