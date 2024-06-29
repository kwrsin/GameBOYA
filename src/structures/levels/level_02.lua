local M = {}

M.edition=1

M.structures={
  names={
    'cylinder01',
    'cube01',
    'bnk01',
    'cirkit_sky',
    'cirkit_fence',
    'cirkit_ground',
    'cirkit_tracks',
    'cirkit_adboard',
    'cirkit_audience',
    'cirkit_goal',
    'cirkit_starter',
    'cirkit_shadow',
    'cirkit_racer_red',
    'cirkit_bankA',
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
				class='src.gos.walls.wall_cirkit_ground_custom',
				params={
					x=CX,
					y=CY,
					props={
						rotation=0.000000,
					},
				},
			},			
			{
				class='src.gos.walls.wall_sky_custom',
				params={
					x=CX,
					y=CY,
					props={
						rotation=0.000000,
					},
				},
			},			
			{
				class='src.gos.walls.static_audience_objects_custom',
				params={
					x=CX,
					y=CY-200,
					props={
						rotation=0.000000,
					},
				},
			},			
			{
				class='src.gos.walls.wall_adboard_custom',
				params={
					x=60,
					y=CY - 100,
					props={
						rotation=0.000000,
					},
				},
			},			
			{
				class='src.gos.walls.wall_tracks_custom',
				params={
					x=CX,
					y=CY,
					props={
						rotation=0.000000,
					},
				},
			},			
			{
				class='src.gos.walls.wall_bankA_custom',
				params={
					x=CX,
					y=CY+30,
					props={
						rotation=0.000000,
					},
				},
			},			
			{
				class='src.gos.walls.wall_bankA_custom',
				params={
					x=CX+180,
					y=CY+30,
					props={
						rotation=0.000000,
					},
				},
			},			
			{
				class='src.gos.walls.wall_bankA_custom',
				params={
					x=CX+380,
					y=CY+30,
					props={
						rotation=0.000000,
					},
				},
			},			
			{
				class='src.gos.walls.wall_adboard_custom',
				params={
					x=60,
					y=CY + 180,
					props={
						rotation=0.000000,
					},
				},
			},			
			{
				class='src.gos.actors.actor_starter_custom',
				params={
					x=240,
					y=CY + 46,
					props={
						rotation=0.000000,
					},
				},
			},			
			{
				class='src.gos.walls.wall_fence_custom',
				params={
					x=126,
					y=CY-160,
					props={
						rotation=0.000000,
					},
				},
			},			
			{
				class='src.gos.walls.wall_cirkit_goal_custom',
				params={
					x=4800.000000,
					y=CY+48,
					props={
						rotation=0.000000,
					},
				},
			},
			{
				class='src.gos.actors.actor_shadow_custom',
				params={
					x=128,
					y=CY,
					props={
						rotation=0.000000,
					},
					isPlayer=true,
				},
			},
			-- {
			-- 	class='src.gos.actors.actCylinder_custom',
			-- 	params={
			-- 		x=329.000000,
			-- 		y=100.000000,
			-- 		props={
			-- 			rotation=0.000000,
			-- 		},
			-- 		isPlayer=true,
			-- 	},
			-- },
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
