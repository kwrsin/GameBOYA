local M = require(utils.dotPath('tiles.level01', dot_structures))

M.structures={
  names={
    'aboya',
    'ladder'
  },
  structPath=utils.dotPath('data.', dot_structures)
}
M.musics={
  bgm='assets/sounds/oldRRR_battle.wav',
}
M.gos={
  {class=utils.dotPath('actors.player', dot_go), gid=1, x=cx, y=cy, isPlayer=true},
  {class=utils.dotPath('actors.ladder', dot_go), gid=2, iterations=4},
}

return M