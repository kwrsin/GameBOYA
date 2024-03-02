return {
  path = "assets/images/aboya.png",
  sheetParams = {numFrames = 5, height = 64, sheetContentHeight = 64, sheetContentWidth = 5*64, width = 64},
  sequences = {
    {loopCount = 0, time = 240, frames = {1, 2}, name = "move"},
    {loopCount = 0, time = 240, frames = {3, 4}, name = "ladder"},
    {loopCount = 1, time = 240, frames = {5}, name = "jump"},
  },
  sounds = {
    aboyaWalk='assets/sounds/step01.wav',
    aboyaLadder='assets/sounds/ladder.wav',
    aboyaJump='assets/sounds/jump.wav',
  }
}