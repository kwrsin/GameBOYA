local M = {}

M.edition=1

M.structures={
  names={
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
				class='src.gos.UIs.ui_menu_background',
				params={
					x=0,
					y=0,
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
	{
		gos={
			{
				class='src.gos.UIs.ui_menu',
				params={
					x=320.000000,
					y=64.133331,
					props={
						rotation=0.000000,
					},
				},
			},
		},
		props={
			name='Foreground',
			visible=true,
		},
	},
}

return M
