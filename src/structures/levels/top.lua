local M = {}

M.edition=1

M.structures={
  names={
    'my_examples',
    'letsgo',
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
				class='src.gos.walls.my_examples_custom',
				params={
					x=320.000000,
					y=312.000000,
					props={
						rotation=349.000000,
					},
				},
			},
			{
				class='src.gos.walls.letsgo_custom',
				params={
					x=320.000000,
					y=812.000000,
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
