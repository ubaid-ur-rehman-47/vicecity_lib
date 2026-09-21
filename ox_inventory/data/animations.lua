--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

return {
	anim = {
		['eating'] = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger_fp' },
		['smoking'] = { dict = 'mp_player_int_uppersmoke', clip = 'mp_player_int_smoke' },
		['sniffing'] = { dict = 'anim@mp_player_intcelebrationmale@face_palm', clip = 'face_palm' },
		['pills'] = { dict = 'mp_suicide', clip = 'pill' },
	},
	prop = {
		['burger'] = { model = `prop_cs_burger_01`, pos = vec3(0.02, 0.02, -0.02), rot = vec3(0.0, 0.0, 0.0) },
		['cigarette'] = { model = `prop_cs_ciggy_01`, pos = vec3(0.01, 0.0, 0.0), rot = vec3(50.0, 0.0, -80.0) },
	}
}