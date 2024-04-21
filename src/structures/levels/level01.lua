local M = require(utils.dotPath('tiles.level01', DOT_STRUCTURES))

M.structures={
  names={
    'aboya',
    'ladder',
    'gorilla',
  },
  structPath=utils.dotPath('gos.', DOT_STRUCTURES)
}
M.musics={
  bgm='assets/sounds/oldRRR_battle.wav',
}
M.sounds={
  lblclear='assets/sounds/lblclear.wav',
}
M.gos={
  {class=utils.dotPath('actors.player', DOT_GO), gid=1, x=CX, y=CY, isPlayer=true},
  {class=utils.dotPath('actors.ladder', DOT_GO), gid=2, iterations=4},
  {class=utils.dotPath('actors.goal', DOT_GO), gid=3},
  {class=utils.dotPath('actors.gorilla', DOT_GO), gid=4},
}

return M