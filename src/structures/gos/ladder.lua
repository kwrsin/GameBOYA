-- ladder.lua
local relations = require 'src.structures.relations'

return {
  path = "assets/images/ladder.png",
  sheetParams = {numFrames = 1, height = 30, sheetContentHeight = 30, sheetContentWidth = 34, width = 34},
  relation=relations.wallBits,
  class='ladder',
}