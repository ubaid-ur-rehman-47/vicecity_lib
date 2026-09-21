--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

return {
	{
		label = "Atelier - Armes Légères",
		icon = "fa-wrench",
		distance = 2.0,
		AuthorisedType = "WeaponSelling",
		items = {
			{
				name = "WEAPON_HAMMER",
				ingredients = {
					farm_fer = 40,
					farm_planche = 20,
					farm_bois = 10,
				},
				duration = 300000, -- 5 minutes
				count = 1,
			},
			{
				name = "WEAPON_WRENCH",
				ingredients = {
					farm_fer = 60,
					farm_ferraille = 40,
					farm_planche = 15,
					WEAPON_HAMMER = 0.15,
				},
				duration = 360000, -- 6 minutes
				count = 1,
			},
			{
				name = "WEAPON_CROWBAR",
				ingredients = {
					farm_fer = 80,
					farm_ferraille = 60,
					farm_planche = 25,
					kevlar_fiber = 150,
					WEAPON_WRENCH = 0.20,
				},
				duration = 420000, -- 7 minutes
				count = 1,
			},
			{
				name = "kevlar_plates",
				ingredients = {
					kevlar_fiber = 40,
					farm_fer = 15,
					farm_ferraille = 10,
					WEAPON_HAMMER = 0.30,
				},
				duration = 300000, -- 5 minutes
				count = 1,
			},
			{
				name = "WEAPON_PISTOL",
				ingredients = {
					farm_fer = 80,
					farm_ferraille = 50,
					farm_planche = 30,
					farm_bois = 20,
					kevlar_fiber = 200,
					WEAPON_HAMMER = 0.20,
					WEAPON_WRENCH = 0.08,
				},
				duration = 600000, -- 10 minutes
				count = 1,
			},

			{
				name = "WEAPON_SNSPISTOL",
				ingredients = {
					farm_fer = 40,
					farm_ferraille = 30,
					farm_planche = 20,
					farm_bois = 20,
					kevlar_fiber = 100,
					WEAPON_HAMMER = 0.20,
					WEAPON_WRENCH = 0.08,
				},
				duration = 600000, -- 10 minutes
				count = 1,
			},
			{
				name = "WEAPON_MICROSMG",
				ingredients = {
					farm_fer = 100,
					farm_ferraille = 75,
					farm_planche = 70,
					farm_bois = 35,
					kevlar_fiber = 600,
					WEAPON_HAMMER = 0.15,
					WEAPON_WRENCH = 0.12,
					WEAPON_CROWBAR = 0.08,
				},
				duration = 720000, -- 12 minutes
				count = 1,
			},
			{
				name = "WEAPON_MINISMG",
				ingredients = {
					farm_fer = 110,
					farm_ferraille = 90,
					farm_planche = 75,
					farm_bois = 40,
					kevlar_fiber = 1000,
					WEAPON_HAMMER = 0.20,
					WEAPON_WRENCH = 0.15,
					WEAPON_CROWBAR = 0.12,
				},
				duration = 840000, -- 14 minutes
				count = 1,
			},
			{
				name = "WEAPON_DBSHOTGUN",
				ingredients = {
					farm_fer = 100,
					farm_ferraille = 80,
					farm_planche = 60,
					farm_bois = 40,
					kevlar_fiber = 900,
					WEAPON_HAMMER = 0.15,
					WEAPON_WRENCH = 0.12,
					WEAPON_CROWBAR = 0.08,
				},
				duration = 780000, -- 13 minutes
				count = 1,
			},
			{
				name = "WEAPON_MACHINEPISTOL",
				ingredients = {
					farm_fer = 100,
					farm_ferraille = 80,
					farm_planche = 60,
					farm_bois = 50,
					kevlar_fiber = 1400,
					WEAPON_HAMMER = 0.15,
					WEAPON_WRENCH = 0.12,
					WEAPON_CROWBAR = 0.08,
				},
				duration = 780000, -- 13 minutes
				count = 1,
			},
			{
				name = "WEAPON_SAWNOFFSHOTGUN",
				ingredients = {
					farm_fer = 150,
					farm_ferraille = 120,
					farm_planche = 100,
					farm_bois = 70,
					kevlar_fiber = 1750,
					WEAPON_HAMMER = 0.30,
					WEAPON_WRENCH = 0.25,
					WEAPON_CROWBAR = 0.20,
				},
				duration = 1000000, -- 16.67 minutes
				count = 1,
			},
		},
		points = {
			vec3(543.98, -173.07, 53.48),
		},
	},

	{
		label = "Atelier - Armes Lourdes",
		icon = "fa-wrench",
		distance = 2.0,
		AuthorisedType = "WeaponSelling",
		items = {
			{
				name = "WEAPON_HAMMER",
				ingredients = {
					farm_fer = 40,
					farm_planche = 20,
					farm_bois = 10,
				},
				duration = 300000, -- 5 minutes
				count = 1,
			},
			{
				name = "WEAPON_WRENCH",
				ingredients = {
					farm_fer = 60,
					farm_ferraille = 40,
					farm_planche = 15,
					WEAPON_HAMMER = 0.15,
				},
				duration = 360000, -- 6 minutes
				count = 1,
			},
			{
				name = "WEAPON_CROWBAR",
				ingredients = {
					farm_fer = 80,
					farm_ferraille = 60,
					farm_planche = 25,
					kevlar_fiber = 150,
					WEAPON_WRENCH = 0.20,
				},
				duration = 420000, -- 7 minutes
				count = 1,
			},
			{
				name = "WEAPON_ASSAULTRIFLE",
				ingredients = {
					farm_fer = 200,
					farm_ferraille = 120,
					farm_planche = 100,
					farm_bois = 70,
					kevlar_fiber = 2500,
					WEAPON_HAMMER = 0.30,
					WEAPON_WRENCH = 0.25,
					WEAPON_CROWBAR = 0.20,
				},
				duration = 1000000, -- 16.67 minutes
				count = 1,
			},
			{
				name = "WEAPON_BULLPUPRIFLE",
				ingredients = {
					farm_fer = 240,
					farm_ferraille = 150,
					farm_planche = 120,
					farm_bois = 80,
					kevlar_fiber = 3000,
					WEAPON_HAMMER = 0.35,
					WEAPON_WRENCH = 0.30,
					WEAPON_CROWBAR = 0.25,
				},
				duration = 1080000, -- 18 minutes
				count = 1,
			},
			{
				name = "WEAPON_COMBATSHOTGUN",
				ingredients = {
					farm_fer = 200,
					farm_ferraille = 140,
					farm_planche = 110,
					farm_bois = 75,
					kevlar_fiber = 2750,
					WEAPON_HAMMER = 0.30,
					WEAPON_WRENCH = 0.25,
					WEAPON_CROWBAR = 0.20,
				},
				duration = 1000000, -- 16.67 minutes
				count = 1,
			},
			{
				name = "WEAPON_HEAVYSHOTGUN",
				ingredients = {
					farm_fer = 240,
					farm_ferraille = 160,
					farm_planche = 120,
					farm_bois = 80,
					kevlar_fiber = 3500,
					WEAPON_HAMMER = 0.40,
					WEAPON_WRENCH = 0.35,
					WEAPON_CROWBAR = 0.30,
				},
				duration = 1140000, -- 19 minutes
				count = 1,
			},
			{
				name = "WEAPON_COMPACTRIFLE",
				ingredients = {
					farm_fer = 160,
					farm_ferraille = 120,
					farm_planche = 120,
					farm_bois = 80,
					kevlar_fiber = 1750,
					WEAPON_HAMMER = 0.40,
					WEAPON_WRENCH = 0.35,
					WEAPON_CROWBAR = 0.30,
				},
				duration = 1140000, -- 19 minutes
				count = 1,
			},
		},
		points = {
			vec3(1722.8403320312, 4772.3354492188, 37.103298187256),
		},
	},
}