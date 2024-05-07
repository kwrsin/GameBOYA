-- global.lua

require 'src.systems.debug'
logger = require 'src.systems.logger'
utils = require 'src.libs.utils' 
require 'REPL.systems.system'

--[[ SCRATCHPAD]]--
local sgGen = require 'dev.tools.scenes.parts.scalableGraph'
local sg = sgGen()
Runtime:addEventListener( 'mouse', sg )
Runtime:addEventListener( 'key', sg )

--[[ TASKS

- MUTTILINE
	x- BACKGROUND
	x- SELECTION
	x- CURSOR
	x- CTRL-A/V/C/X
	x- insert
	x- delete
	x- print
- INVENTORYBOX
	- BTNMAKER
- SCALABLE GRAPH
- 9SLICE MAKER

]]--
