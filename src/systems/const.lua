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

INITIAL_LEVEL = 'levels.level01'
DEFAULT_CONTENT_MANAGER = 'src.scenes.contents.contentManager'
GAME_LEVELS = {
	level01=DEFAULT_CONTENT_MANAGER,
}

GAME_SCENE = 'game'
TITLE_SCENE = 'title'
LOADER_SCENE = 'loader'
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

VC_POS = {x=-CX+120, y=CY - 120}
VBA_POS = {x=CX-120, y=CY - 120}

