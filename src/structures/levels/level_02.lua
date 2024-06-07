local M = {}

M.edition=1

M.structures={
  names={
    'cylinder01',
    'cube01',
    'bnk01',
  },
  structPath='src.structures.gos.'
}

M.musics={
}

M.sounds={
}

M.layers={
	{
		width=4096,
		height=4096,
		gos={
			{
				class='src.gos.actors.actCylinder_custom',
				params={
					x=329.000000,
					y=100.000000,
					props={
						rotation=0.000000,
					},
					isPlayer=true,
				},
			},
			{
				class='src.gos.actors.circle_custom',
				params={
					x=60.000000,
					y=100.000000,
					props={
						rotation=0.000000,
					},
				},
			},
			{
				class='src.gos.walls.wallCube_custom',
				params={
					x=480.000000,
					y=568.000000,
					props={
						rotation=0.000000,
					},
				},
			},
			{
				class='src.gos.walls.bnk01_custom',
				params={
					x=224.000000,
					y=280.000000,
					props={
						rotation=0.000000,
					},
				},
			},
			{
				class='src.gos.walls.bnk01_custom',
				params={
					x=329.600006,
					y=385.600006,
					props={
						rotation=0.000000,
					},
				},
			},
		},
		props={
			name='Background',
			visible=true,
		},
	},
}

return M
