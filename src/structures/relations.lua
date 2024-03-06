-- relations.lua
local M = {}

M.playerBits = { categoryBits=2, maskBits=57 }
M.wallBits = { categoryBits=1, maskBits=26 }
-- M.enemyBits = { categoryBits=8, maskBits=7 }
-- M.playerBulletBits = { categoryBits=4, maskBits=8 }
M.enemyrBulletBits = { categoryBits=16, maskBits=3 }
-- M.platformBits = { categoryBits=32, maskBits=2 }

return M
