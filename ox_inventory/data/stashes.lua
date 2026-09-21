--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

return {
	{
		coords = vec3(-1051.6958007812, -817.77142333984, 10.951585769653),
		name = 'policelocker',
		label = 'Casier personnel',
		owner = true,
		slots = 70,
		weight = 70000,
		groups = shared.police,
		interact = {
			dist = 2.5,
			icon = 'fa-box-archive',
			message = 'CASIER PERSONNEL',
		},
	},

	{
		coords = vec3(362.72348022461, -1422.4041748047, 32.511646270752),
		name = 'emslocker',
		label = 'Casier personnel',
		owner = true,
		slots = 70,
		weight = 70000,
		groups = {['ambulance'] = 0},
		interact = {
			dist = 2.5,
			icon = 'fa-box-archive',
			message = 'CASIER PERSONNEL',
		},
	},
}