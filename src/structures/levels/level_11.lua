local M = {}

M.edition=1

M.structures={
  names={
    'superGreen',
  },
  structPath='src.structures.gos.'
}

M.musics={
}

M.sounds={
}

M.layers={
	{
		gos={
			{
				class='src.gos.walls.wallspg_custom',
				params={
					x=320.000000,
					y=568.000000,
					props={
						rotation=0.000000,
					},
					relation={
						categoryBits=1, maskBits=26, 
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
