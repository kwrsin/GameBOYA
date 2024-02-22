local M = require(utils.dotPath('tiles.level01', dot_structures))

M.structures={
  names={
    'redhead',
    'platform2_walls',
  },
  structPath=utils.dotPath('gos.', dot_structures)
}
M.gos={
  {class=utils.dotPath('grounds.walls01', dot_go), gid=1},
  {class=utils.dotPath('grounds.walls01', dot_go), gid=2},
  {class=utils.dotPath('grounds.walls01', dot_go), gid=3},
  {class=utils.dotPath('grounds.walls01', dot_go), gid=4},
  {class=utils.dotPath('grounds.walls01', dot_go), gid=5},
  {class=utils.dotPath('grounds.walls01', dot_go), gid=6},
  {class=utils.dotPath('grounds.walls01', dot_go), gid=7},
  {class=utils.dotPath('grounds.walls01', dot_go), gid=8},
  {class=utils.dotPath('grounds.walls01', dot_go), gid=9},
  {class=utils.dotPath('actors.redhead', dot_go), gid=10, x=cx, y=cy, isPlayer=true}
}

return M