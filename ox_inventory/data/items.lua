return {
	['testburger'] = {
		label = 'Test Burger',
		weight = 220,
		degrade = 60,
		client = {
			image = 'burger_chicken.png',
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			export = 'ox_inventory_examples.testburger'
		},
		server = {
			export = 'ox_inventory_examples.testburger',
			test = 'what an amazingly delicious burger, amirite?'
		},
		buttons = {
			{
				label = 'Lick it',
				action = function(slot)
					print('You licked the burger')
				end
			},
			{
				label = 'Squeeze it',
				action = function(slot)
					print('You squeezed the burger :(')
				end
			},
			{
				label = 'What do you call a vegan burger?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('A misteak.')
				end
			},
			{
				label = 'What do frogs like to eat with their hamburgers?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('French flies.')
				end
			},
			{
				label = 'Why were the burger and fries running?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('Because they\'re fast food.')
				end
			}
		},
		consume = 0.3
	},

	['bandage'] = {
		label = 'Bandage',
		weight = 115,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500,
		}
	},

	['black_money'] = {
		label = 'Dirty Money',
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 400000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'You ate a delicious burger'
		},
	},
    	['tosti'] = {
		label = 'tosti',
		weight = 220,
		client = {
			status = { hunger = 800000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'You ate a delicious tosti'
		},
	},

	['sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'You quenched your thirst with a sprunk'
		}
	},

	['parachute'] = {
		label = 'Parachute',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},

	['garbage'] = {
		label = 'Garbage',
	},

	['paperbag'] = {
		label = 'Paper Bag',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},

	['identification'] = {
		label = 'Identification',
		client = {
			image = 'card_id.png'
		}
	},

	['panties'] = {
		label = 'Knickers',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},

	['lockpick'] = {
		label = 'Lockpick',
		weight = 160,
	},

	['phone'] = {
		label = 'Phone',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
	},

	['money'] = {
		label = 'Money',
	},

	['mustard'] = {
		label = 'Mustard',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = 'You.. drank mustard'
		}
	},

	['water'] = {
		label = 'Water',
		weight = 500,
		client = {
			status = { thirst = 500000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank some refreshing water'
		}
	},

	['radio'] = {
		label = 'Radio',
		weight = 1000,
		stack = false,
		allowArmed = true
	},

	['armour'] = {
		label = 'Bulletproof Vest',
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500
		}
	},

	['clothing'] = {
		label = 'Clothing',
		consume = 0,
	},

	['mastercard'] = {
		label = 'Fleeca Card',
		stack = false,
		weight = 10,
		client = {
			image = 'card_bank.png'
		}
	},

	['scrapmetal'] = {
		label = 'Scrap Metal',
		weight = 80,
	},

	['blank_plate'] = {
		label = 'Blank Plate',
		description = 'Unpressed blank vehicle license plate',
		weight = 500,
		stack = true,
		close = true,
		consume = 0,
	},

	['plate_ink'] = {
		label = 'Plate Ink',
		description = 'Special ink for license plate printing',
		weight = 200,
		stack = true,
		close = true,
		consume = 0,
	},

	-- FAKE PLATE REMOVER MATERIALS

	['screwdriver'] = {
		label = 'Screwdriver',
		description = 'Multi-purpose screwdriver',
		weight = 150,
		stack = true,
		close = true,
		consume = 0,
	},

	['solvent'] = {
		label = 'Solvent',
		description = 'Chemical solvent - dissolves adhesives and paints',
		weight = 300,
		stack = true,
		close = true,
		consume = 0,
	},

	-- NITRO MATERIALS

	['nitrous_fuel'] = {
		label = 'Nitrous Fuel',
		description = 'High-performance fuel canister for nitrous systems',
		weight = 2000,
		stack = true,
		close = true,
		consume = 0,
	},
    ['towing_rope'] = {
		label = 'Towing Rope',
		description = 'Used For Car towing',
		weight = 2000,
		stack = true,
		close = true,
		consume = 0,
	},

	['nitro_kit'] = {
		label = 'Nitro Installation Kit',
		description = 'Nitro system installation materials',
		weight = 1500,
		stack = true,
		close = true,
		consume = 0,
	},

	-- OUTPUT ITEMS - FAKE PLATE

	['fake_plate'] = {
		label = 'Fake License Plate',
		description = 'Vehicle license plate copy - can be detected by police. Use near a vehicle to install.',
		weight = 500,
		stack = false,
		close = true,
		consume = 0,
		-- Metadata: craftedBy, craftedAt
		client = {
			image = 'fake_plate.png',
		},
	},

	['fake_plate_remover'] = {
		label = 'Plate Remover',
		description = 'Used to remove fake plates from vehicles',
		weight = 300,
		stack = false,
		close = true,
		consume = 0,
		-- Metadata: craftedBy, craftedAt
		client = {
			image = 'fake_plate_remover.png',
		},
	},

	-- OUTPUT ITEMS - NITRO SYSTEM

	['nitro_filled'] = {
		label = 'Nitro System (Filled)',
		description = 'Vehicle-installable filled nitro system - 100 uses',
		weight = 4000,
		stack = false,
		close = true,
		consume = 0,
		-- Metadata: uses, maxUses, heatPerUse, craftedBy, craftedAt
		client = {
			image = 'nitro_filled.png',
		},
	},

	['nitro_empty'] = {
		label = 'Nitro System (Empty)',
		description = 'Empty nitro system - can be refilled by illegal mechanic',
		weight = 2000,
		stack = false,
		close = true,
		consume = 0,
		-- Metadata: maxUses, craftedBy, craftedAt
		client = {
			image = 'nitro_empty.png',
		},
	},

	-- SYSTEM ITEMS

	['mechanic_tablet'] = {
		label = 'Mechanic Tablet',
		description = 'A portable tablet for managing mechanic shop operations.',
		weight = 500,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'tablet.png',
			export = 'dusa_mechanic.openMiniTablet',
		},
	},

	['mechanic_invoice'] = {
		label = 'Mechanic Invoice',
		description = 'A detailed service invoice from the mechanic shop.',
		weight = 100,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'mechanic_invoice.png',
		},
	},

	['mechanic_bill'] = {
		label = 'Mechanic Bill',
		description = 'An unpaid bill from the mechanic shop. Use it to pay.',
		weight = 100,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'mechanic_bill.png',
		},
	},

	-- REMOTE CONTROLLERS

	['stance_remote'] = {
		label = 'Stance Remote',
		description = 'Controls vehicle camber and suspension height',
		weight = 200,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'stance_remote.png',
		},
	},

	['light_remote'] = {
		label = 'Light Remote',
		description = 'Controls vehicle neon and xenon lights',
		weight = 200,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'light_remote.png',
		},
	},

	-- SERVICING ITEMS

	-- ICE (Internal Combustion) fluids & standard parts
	['oil_filter'] = {
		label = 'Engine Oil',
		description = 'Engine oil change kit. Used by mechanics during servicing.',
		weight = 1000,
		stack = true,
		close = true,
		consume = 0,
	},

	['spark_plug'] = {
		label = 'Spark Plug',
		description = 'Replacement spark plug set. Used by mechanics during servicing.',
		weight = 200,
		stack = true,
		close = true,
		consume = 0,
	},

	['brake_fluid'] = {
		label = 'Brake Fluid',
		description = 'Hydraulic brake fluid. Used by mechanics during servicing.',
		weight = 500,
		stack = true,
		close = true,
		consume = 0,
	},

	['coolant_fluid'] = {
		label = 'Coolant',
		description = 'Engine coolant / antifreeze. Used by mechanics during servicing.',
		weight = 800,
		stack = true,
		close = true,
		consume = 0,
	},

	['power_steering_fluid'] = {
		label = 'Power Steering Fluid',
		description = 'Hydraulic power steering fluid. Used by mechanics during servicing.',
		weight = 500,
		stack = true,
		close = true,
		consume = 0,
	},

	['fuel_injector'] = {
		label = 'Fuel Injector',
		description = 'Fuel injector replacement. Used by mechanics during servicing.',
		weight = 400,
		stack = true,
		close = true,
		consume = 0,
	},

	-- ICE two-handed install parts
	['brake_pad'] = {
		label = 'Brake Pads',
		description = 'Replacement brake pad set. Used by mechanics during servicing.',
		weight = 1500,
		stack = true,
		close = true,
		consume = 0,
	},

	['drive_belt'] = {
		label = 'Drive Belt',
		description = 'Engine drive belt. Used by mechanics during servicing.',
		weight = 600,
		stack = true,
		close = true,
		consume = 0,
	},

	['tire_kit'] = {
		label = 'Tire Kit',
		description = 'Set of replacement tires. Used by mechanics during servicing.',
		weight = 4000,
		stack = true,
		close = true,
		consume = 0,
	},

	['suspension_kit'] = {
		label = 'Suspension Kit',
		description = 'Replacement shocks, struts, and mounting hardware. Used by mechanics during servicing.',
		weight = 4500,
		stack = true,
		close = true,
		consume = 0,
	},

	['radiator_cap'] = {
		label = 'Radiator',
		description = 'Radiator assembly. Used by mechanics during servicing.',
		weight = 2500,
		stack = true,
		close = true,
		consume = 0,
	},

	['alternator_part'] = {
		label = 'Alternator',
		description = 'Replacement alternator. Used by mechanics during servicing.',
		weight = 3000,
		stack = true,
		close = true,
		consume = 0,
	},

	['transmission_fluid'] = {
		label = 'Transmission Fluid',
		description = 'Automatic transmission fluid. Used by mechanics during servicing.',
		weight = 900,
		stack = true,
		close = true,
		consume = 0,
	},

	-- EV (Electric Vehicle) specific parts
	['battery_coolant'] = {
		label = 'Battery Coolant',
		description = 'High-voltage battery coolant. Used by mechanics during servicing.',
		weight = 800,
		stack = true,
		close = true,
		consume = 0,
	},

	['hv_wiring_kit'] = {
		label = 'HV Wiring Kit',
		description = 'High-voltage wiring harness kit. Used by mechanics during servicing.',
		weight = 1200,
		stack = true,
		close = true,
		consume = 0,
	},

	['ev_battery_cell'] = {
		label = 'EV Battery Cell',
		description = 'Replacement EV battery cell module. Used by mechanics during servicing.',
		weight = 5000,
		stack = true,
		close = true,
		consume = 0,
	},

	['motor_brush'] = {
		label = 'Electric Motor Brush',
		description = 'Electric motor brush set. Used by mechanics during servicing.',
		weight = 700,
		stack = true,
		close = true,
		consume = 0,
	},

	-- ENGINE SWAPS

	['engine_i4_turbo'] = {
		label = 'I4 Turbo Engine',
		description = 'Turbocharged inline-4 engine swap kit',
		weight = 15000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'engine_i4_turbo.png',
		},
	},

	['engine_v6_33l'] = {
		label = 'V6 3.3L Engine',
		description = 'V6 3.3 liter engine swap kit',
		weight = 18000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'engine_v6_33l.png',
		},
	},

	['engine_v8_65l'] = {
		label = 'V8 6.5L Engine',
		description = 'High-performance V8 6.5 liter engine swap kit',
		weight = 22000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'engine_v8_65l.png',
		},
	},

	['engine_v12_60l'] = {
		label = 'V12 6.0L Engine',
		description = 'Premium V12 6.0 liter engine swap kit',
		weight = 25000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'engine_v12_60l.png',
		},
	},

	-- BRAKES

	['ceramic_brake_kit'] = {
		label = 'Ceramic Brake Kit',
		description = 'High-performance ceramic brake system',
		weight = 3000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'ceramic_brake_kit.png',
		},
	},

	-- HANDLING

	['drift_tuning_kit'] = {
		label = 'Drift Tuning Kit',
		description = 'Complete drift setup package for handling modifications',
		weight = 5000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'drift_tuning_kit.png',
		},
	},

	-- DRIVETRAIN

	['drivetrain_awd'] = {
		label = 'AWD Drivetrain',
		description = 'All-wheel drive conversion kit',
		weight = 8000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'drivetrain_awd.png',
		},
	},

	['drivetrain_rwd'] = {
		label = 'RWD Drivetrain',
		description = 'Rear-wheel drive conversion kit',
		weight = 7000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'drivetrain_rwd.png',
		},
	},

	['drivetrain_fwd'] = {
		label = 'FWD Drivetrain',
		description = 'Front-wheel drive conversion kit',
		weight = 7000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'drivetrain_fwd.png',
		},
	},

	-- TURBO

	['turbo_kit'] = {
		label = 'Turbo Kit',
		description = 'High-performance turbocharger system',
		weight = 5000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'turbo_kit.png',
		},
	},

	-- TYRES

	['tyres_slick'] = {
		label = 'Slick Tyres',
		description = 'Racing slick tyres for maximum grip on dry surfaces',
		weight = 4000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'tyres_slick.png',
		},
	},

	['tyres_semi_slick'] = {
		label = 'Semi-Slick Tyres',
		description = 'Semi-slick performance tyres for street and track',
		weight = 4000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'tyres_semi_slick.png',
		},
	},

	['tyres_offroad'] = {
		label = 'Off-Road Tyres',
		description = 'Heavy-duty off-road tyres for rough terrain',
		weight = 5000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'tyres_offroad.png',
		},
	},

	-- DRIVER AIDS

	['tcs_ecs_pack'] = {
		label = 'TCS & ECS Pack',
		weight = 500,
		stack = false,
		close = true,
		description =
		'Traction Control + Electronic Stability Control install kit. Mechanic-installed on customer vehicles.',
		client = {
			image = 'tcs_ecs_pack.png',
		},
		server = {
			export = 'dusa_mechanic.installTcsEcsPack',
		},
	},

	['manual_transmission_swap'] = {
		label = 'Manual Transmission Swap',
		weight = 800,
		stack = false,
		close = true,
		description =
		'Replace the automatic transmission with a manual gearbox. Mechanic-installed on customer vehicles. Driver shifts with LSHIFT (up) / LCTRL (down) + LALT (clutch), N (neutral).',
		client = {
			image = 'manual_transmission_swap.png',
		},
		server = {
			export = 'dusa_mechanic.installManualTransmissionPack',
		},
	},

	['anti_lag_kit'] = {
		label = 'Anti-Lag Kit',
		weight = 600,
		stack = false,
		close = true,
		description =
		'Anti-lag system install kit. Keeps turbo spooled on throttle release; fires exhaust backfire at high RPM. Mechanic-installed on customer vehicles. Wears engine and turbo.',
		client = {
			image = 'anti_lag_kit.png',
		},
		server = {
			export = 'dusa_mechanic.installAntiLagKit',
		},
	},

	-- ECU TUNING

	['ds_ecu_chiptuner'] = {
		label = 'ECU Chip Tuner',
		description =
		'Diagnostic OBD interface for ECU map flashing and limp-mode bypass. Required to open the ECU app on the tablet.',
		weight = 800,
		stack = false,
		close = true,
		consume = 0,
		client = {
			image = 'ds_ecu_chiptuner.png',
		},
	},

	-- TOW KIT

	['ds_roadside_repair_kit'] = {
		label = 'Roadside Repair Kit',
		weight = 2000,
		stack = true,
		close = true,
		description = 'Roadside Repair Kit',
		client = {
			status = { stress = -0.05 },
			anim   = { dict = 'mini@repair', clip = 'fixing_a_player' },
			prop   = { model = 'prop_tool_box_04' },
		},
	},

	-- CAR JACK

	['car_jack'] = {
		label = 'Car Jack',
		weight = 1000,
		stack = false,
		close = true,
		description = 'Hydraulic car jack for lifting vehicles.',
		client = {
			image = 'car_jack.png',
		},
	},

	-- REPAIR KIT

	['repairkit'] = {
		label = 'Repair Kit',
		weight = 500,
		stack = false,
		close = true,
		description = 'Repair kit for vehicle maintenance.',
		client = {
			image = 'repairkit.png',
		},
	},

    	['repairitem'] = {
		label = 'Repair Item',
		weight = 500,
		stack = false,
		close = true,
		description = 'Repair kit for vehicle maintenance.',
		client = {
			image = 'repairkit.png',
		},
	},

	-- CLEANING KIT repairitem

	['cleaningkit'] = {
		label = 'Cleaning Kit',
		weight = 500,
		stack = false,
		close = true,
		consume = 0,
		description = 'Cleaning kit for vehicle cleaning.',
		client = {
			image = 'cleaningkit.png',
			export = 'dusa_mechanic.useCleaningKit',
		},
	},
	['tablet'] = {
		label = 'Tablet',
		weight = 500,
		stack = false,
		close = true,
	},
    ['drill'] = {
		label = 'Drill',
		weight = 1000,
		stack = false,
		close = true,
	},
    ['trojan_usb'] = {
		label = 'Trojan Usb',
		weight = 1000,
		stack = false,
		close = true,
	},
    ['cryptostick'] = {
		label = 'Cryptostick',
		weight = 1000,
		stack = false,
		close = true,
	},
    ['electronickit'] = {
		label = 'Electronickit',
		weight = 1000,
		stack = false,
		close = true,
	},
	['vehicle_manual'] = {
		label = 'Vehicle manual',
		weight = 50,
		close = true,
		consume = 0,
		client = {},
		server = {
			export = 'rcore_fuel.vehicle_manual',
		},
	},

	['window_cleaner'] = {
		label = 'windows cleaner',
		weight = 50,
		close = true,
		consume = 0,
		client = {
			export = 'rcore_fuel.window_cleaner',
		},
	},

	['fuel_pump'] = {
		label = 'Fuel pumper',
		weight = 10000,
		close = true,
		consume = 0,
		client = {},
		server = {
			export = 'rcore_fuel.fuel_pump',
		},
	},
	['phone'] = {
		label = 'Phone',
		weight = 190,
		stack = false,
		consume = 0
	},

	['wireless_earbuds'] = {
		label = 'Wireless Earbuds',
		weight = 120,
		stack = true,
		close = true,
		server = {
			export = 'qs-smartphone.useWirelessEarbuds'
		}
	},

	['powerbank'] = {
		label = 'Powerbank',
		weight = 300,
		stack = true,
		close = true,
		server = {
			export = 'qs-smartphone.usePowerbank'
		}
	},

	['phone_sim'] = {
		label = 'SIM Card',
		weight = 45,
		stack = false,
		consume = 0,
		close = true,
		server = {
			export = 'qs-smartphone.useSimCard'
		}
	},
	["coffee"] = {
		label = "Coffee",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 700000 },
			anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
			prop = {
				model = 'v_res_mcofcup',
				bone = 18905,
				pos = vec3(0.14, 0.0, 0.07),
				rot = vec3(-119.7, -54.56, 7.22)
			},
			usetime = 6500,
		}
	},
	["chips_cheese"] = {
		label = "Chips Big Cheese",
		weight = 1,
		stack = true,
		client = {
			status = { hunger = 200000 },
			anim = { dict = "amb@world_human_drinking@coffee@male@idle_a", clip = "idle_a" },
			prop = {
				model = 'mxc_vend_prop_item_chips1',
				bone = 57005,
				pos = vec3(0.16, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 6500,
		}
	},
	["chips_paprika"] = {
		label = "Chips Paprika",
		weight = 1,
		stack = true,
		client = {
			status = { hunger = 200000 },
			anim = { dict = "amb@world_human_drinking@coffee@male@idle_a", clip = "idle_a" },
			prop = {
				model = 'mxc_vend_prop_item_chips2',
				bone = 57005,
				pos = vec3(0.16, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 6500,
		}
	},
	["chips_ribs"] = {
		label = "Chips Sticky Ribs",
		weight = 1,
		stack = true,
		client = {
			status = { hunger = 200000 },
			anim = { dict = "amb@world_human_drinking@coffee@male@idle_a", clip = "idle_a" },
			prop = {
				model = 'mxc_vend_prop_item_chips3',
				bone = 57005,
				pos = vec3(0.16, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 6500,
		}
	},
	["chips_salt"] = {
		label = "Chips: Salt & Sauce",
		weight = 1,
		stack = true,
		client = {
			status = { hunger = 200000 },
			anim = { dict = "amb@world_human_drinking@coffee@male@idle_a", clip = "idle_a" },
			prop = {
				model = 'mxc_vend_prop_item_chips4',
				bone = 57005,
				pos = vec3(0.16, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 6500,
		}
	},
	["chips_supersalt"] = {
		label = "Chips: Super Salt",
		weight = 1,
		stack = true,
		client = {
			status = { hunger = 200000 },
			anim = { dict = "amb@world_human_drinking@coffee@male@idle_a", clip = "idle_a" },
			prop = {
				model = 'mxc_vend_prop_item_chips5',
				bone = 57005,
				pos = vec3(0.16, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 6500,
		}
	},
	["chips_habanero"] = {
		label = "Chips: Habanero",
		weight = 1,
		stack = true,
		client = {
			status = { hunger = 200000 },
			anim = { dict = "amb@world_human_drinking@coffee@male@idle_a", clip = "idle_a" },
			prop = {
				model = 'mxc_vend_prop_item_chips6',
				bone = 57005,
				pos = vec3(0.16, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 6500,
		}
	},
	["chocolate_meteorite"] = {
		label = "Chocolate: Meteorite",
		weight = 1,
		stack = true,
		client = {
			status = { hunger = 200000 },
			anim = { dict = "mp_player_inteat@burger", clip = "mp_player_int_eat_burger_fp" },
			prop = {
				model = `mxc_vend_prop_item_chocolate1`,
				bone = 18905,
				pos = vec3(0.12, 0.04, 0.01),
				rot = vec3(51.55, -47.5, -4.65)
			},
			usetime = 2500,
		}
	},
	["chocolate_captain"] = {
		label = "Chocolate: Captain's Log",
		weight = 1,
		stack = true,
		client = {
			status = { hunger = 200000 },
			anim = { dict = "mp_player_inteat@burger", clip = "mp_player_int_eat_burger_fp" },
			prop = {
				model = `mxc_vend_prop_item_chocolate2`,
				bone = 18905,
				pos = vec3(0.12, 0.04, 0.01),
				rot = vec3(51.55, -47.5, -4.65)
			},
			usetime = 2500,
		}
	},
	["condom"] = {
		label = "Condom: Soth Lags",
		weight = 1,
		stack = true,
	},
	["candy_zebra"] = {
		label = "Candy: Zebrabar",
		weight = 1,
		stack = true,
		client = {
			status = { hunger = 200000 },
			anim = { dict = "mp_player_inteat@burger", clip = "mp_player_int_eat_burger_fp" },
			prop = {
				model = `mxc_vend_prop_item_candybar1`,
				bone = 18905,
				pos = vec3(0.12, 0.04, 0.01),
				rot = vec3(51.55, -47.5, -4.65)
			},
			usetime = 2500,
		}
	},
	["candy_psqs"] = {
		label = "Candy: P's & Q's",
		weight = 1,
		stack = true,
		client = {
			status = { hunger = 200000 },
			anim = { dict = "mp_player_inteat@pnq", clip = "loop" },
			prop = {
				model = `mxc_vend_prop_item_candybar2`,
				bone = 18905,
				pos = vec3(0.14, -0.02, 0.06),
				rot = vec3(65.76, -57.6, 2.8)
			},
			usetime = 2500,
		}
	},
	["medicine_laxmax"] = {
		label = "Medicine: Lax to the Max",
		weight = 1,
		stack = true,
		client = {
			anim = { dict = "amb@world_human_drinking@coffee@male@idle_a", clip = "idle_a" },
			prop = {
				model = 'mxc_vend_prop_item_medical1',
				bone = 57005,
				pos = vec3(0.16, 0.01, -0.07),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 1500,
		}
	},
	["medicine_alcopatch"] = {
		label = "Medicine: AlcoPatch",
		weight = 1,
		stack = true,
		client = {
			anim = { dict = "amb@world_human_drinking@coffee@male@idle_a", clip = "idle_a" },
			prop = {
				model = 'mxc_vend_prop_item_medical2',
				bone = 57005,
				pos = vec3(0.16, 0.01, -0.07),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 1500,
		}
	},
	["medicine_mollis"] = {
		label = "Medicine: Mollis",
		weight = 1,
		stack = true,
		client = {
			anim = { dict = "amb@world_human_drinking@coffee@male@idle_a", clip = "idle_a" },
			prop = {
				model = 'mxc_vend_prop_item_medical3',
				bone = 57005,
				pos = vec3(0.16, 0.01, -0.07),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 1500,
		}
	},
	["medicine_betta"] = {
		label = "Medicine: Betta",
		weight = 1,
		stack = true,
		client = {
			anim = { dict = "amb@world_human_drinking@coffee@male@idle_a", clip = "idle_a" },
			prop = {
				model = 'mxc_vend_prop_item_medical4',
				bone = 57005,
				pos = vec3(0.16, 0.01, -0.07),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 1500,
		}
	},
	["gum_peppermint"] = {
		label = "Gum: Peppermint",
		weight = 1,
		stack = true,
		client = {
			anim = { dict = "mp_player_inteat@pnq", clip = "loop" },
			prop = {
				model = `mxc_vend_prop_item_gum1`,
				bone = 18905,
				pos = vec3(0.14, -0.02, 0.06),
				rot = vec3(65.76, -57.6, 2.8)
			},
			usetime = 2500,
		}
	},
	["gum_cinnamon"] = {
		label = "Gum: Cinnamon",
		weight = 1,
		stack = true,
		client = {
			anim = { dict = "mp_player_inteat@pnq", clip = "loop" },
			prop = {
				model = `mxc_vend_prop_item_gum2`,
				bone = 18905,
				pos = vec3(0.14, -0.02, 0.06),
				rot = vec3(65.76, -57.6, 2.8)
			},
			usetime = 2500,
		}
	},
	["gum_spearmint"] = {
		label = "Gum: Spearmint",
		weight = 1,
		stack = true,
		client = {
			anim = { dict = "mp_player_inteat@pnq", clip = "loop" },
			prop = {
				model = `mxc_vend_prop_item_gum3`,
				bone = 18905,
				pos = vec3(0.14, -0.02, 0.06),
				rot = vec3(65.76, -57.6, 2.8)
			},
			usetime = 2500,
		}
	},
	["bottle_cola"] = {
		label = "Cola",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
			prop = {
				model = `mxc_vend_prop_item_bottle1`,
				bone = 18905,
				pos = vec3(0.12, -0.03, 0.03),
				rot = vec3(-98.4, 0.0, -15.0),
				bone = 18905
			},
			usetime = 2500,
		}
	},
	["bottle_junk"] = {
		label = "Junk",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
			prop = {
				model = `mxc_vend_prop_item_bottle2`,
				bone = 18905,
				pos = vec3(0.12, -0.03, 0.03),
				rot = vec3(-98.4, 0.0, -15.0)
			},
			usetime = 2500,
		}
	},
	["bottle_orang"] = {
		label = "Orang Tang",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
			prop = {
				model = `mxc_vend_prop_item_bottle3`,
				bone = 18905,
				pos = vec3(0.12, -0.03, 0.03),
				rot = vec3(-98.4, 0.0, -15.0)
			},
			usetime = 2500,
		}
	},
	["bottle_tonic"] = {
		label = "Tonic",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
			prop = {
				model = `mxc_vend_prop_item_bottle4`,
				bone = 18905,
				pos = vec3(0.12, -0.03, 0.03),
				rot = vec3(-98.4, 0.0, -15.0)
			},
			usetime = 2500,
		}
	},
	["bottle_water"] = {
		label = "Water",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
			prop = {
				model = `mxc_vend_prop_item_bottle5`,
				bone = 18905,
				pos = vec3(0.12, -0.03, 0.03),
				rot = vec3(-98.4, 0.0, -15.0)
			},
			usetime = 2500,
		}
	},
	["bottle_sprunk"] = {
		label = "Sprunk",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
			prop = {
				model = `mxc_vend_prop_item_bottle6`,
				bone = 18905,
				pos = vec3(0.12, -0.03, 0.03),
				rot = vec3(-98.4, 0.0, -15.0)
			},
			usetime = 2500,
		}
	},
	["can_cola"] = {
		label = "Cola Can",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_a' },
			prop = {
				model = `mxc_vend_prop_item_cansoda1`,
				bone = 57005,
				pos = vec3(0.14, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 2500,
		}
	},
	["can_orang"] = {
		label = "Orang Tang Can",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_a' },
			prop = {
				model = `mxc_vend_prop_item_cansoda2`,
				bone = 57005,
				pos = vec3(0.14, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 2500,
		}
	},
	["can_junk"] = {
		label = "Junk Can",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_a' },
			prop = {
				model = `mxc_vend_prop_item_cansoda3`,
				bone = 57005,
				pos = vec3(0.14, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 2500,
		}
	},
	["can_sprunk"] = {
		label = "Sprunk Can",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_a' },
			prop = {
				model = `mxc_vend_prop_item_cansoda4`,
				bone = 57005,
				pos = vec3(0.14, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 2500,
		}
	},
	["can_logger"] = {
		label = "Logger Can",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_a' },
			prop = {
				model = `mxc_vend_prop_item_canbeer1`,
				bone = 57005,
				pos = vec3(0.14, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 2500,
		}
	},
	["can_blarneys"] = {
		label = "Blarneys Can",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_a' },
			prop = {
				model = `mxc_vend_prop_item_canbeer2`,
				bone = 57005,
				pos = vec3(0.14, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 2500,
		}
	},
	["can_hoplivion"] = {
		label = "Hoplivion Can",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_a' },
			prop = {
				model = `mxc_vend_prop_item_canbeer3`,
				bone = 57005,
				pos = vec3(0.14, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 2500,
		}
	},
	["can_cerbeza"] = {
		label = "Cerbeza Can",
		weight = 1,
		stack = true,
		client = {
			status = { thirst = 300000 },
			anim = { dict = 'amb@world_human_drinking@coffee@male@idle_a', clip = 'idle_a' },
			prop = {
				model = `mxc_vend_prop_item_canbeer4`,
				bone = 57005,
				pos = vec3(0.14, 0.01, -0.04),
				rot = vec3(-64.96, 36.0, -3.0)
			},
			usetime = 2500,
		}
	},
	["svapo_vaporglow1a"] = {
		label = "Vaporglow 2",
		weight = 1,
		stack = true
	},
	["svapo_vaporglow1b"] = {
		label = "Vaporglow 1",
		weight = 1,
		stack = true
	},
	["svapo_vaporglow1c"] = {
		label = "Vaporglow 1",
		weight = 1,
		stack = true
	},
	["svapo_vaporglow1d"] = {
		label = "Vaporglow 1",
		weight = 1,
		stack = true
	},
	["svapo_vaporglow1e"] = {
		label = "Vaporglow 1",
		weight = 1,
		stack = true
	},
	["svapo_vaporglow1f"] = {
		label = "Vaporglow 1",
		weight = 1,
		stack = true
	},
	["svapo_evape1a"] = {
		label = "E-Vape 1",
		weight = 1,
		stack = true
	},
	["svapo_evape1b"] = {
		label = "E-Vape 1",
		weight = 1,
		stack = true
	},
	["svapo_evape1c"] = {
		label = "E-Vape 1",
		weight = 1,
		stack = true
	},
	["svapo_evape1d"] = {
		label = "E-Vape 1",
		weight = 1,
		stack = true
	},
	["svapo_evape1e"] = {
		label = "E-Vape 1",
		weight = 1,
		stack = true
	},
	["svapo_evape1f"] = {
		label = "E-Vape 1",
		weight = 1,
		stack = true
	},
	["svapo_evape2a"] = {
		label = "E-Vape 2",
		weight = 1,
		stack = true
	},
	["svapo_evape2b"] = {
		label = "E-Vape 2",
		weight = 1,
		stack = true
	},
	["svapo_evape2c"] = {
		label = "E-Vape 2",
		weight = 1,
		stack = true
	},
	["svapo_evape2d"] = {
		label = "E-Vape 2",
		weight = 1,
		stack = true
	},
	["svapo_evape2e"] = {
		label = "E-Vape 2",
		weight = 1,
		stack = true
	},
	["svapo_evape2f"] = {
		label = "E-Vape 2",
		weight = 1,
		stack = true
	},
	["svapo_smoke1a"] = {
		label = "Smoke 1",
		weight = 1,
		stack = true
	},
	["svapo_smoke1b"] = {
		label = "Smoke 1",
		weight = 1,
		stack = true
	},
	["svapo_smoke1c"] = {
		label = "Smoke 1",
		weight = 1,
		stack = true
	},
	["svapo_smoke1d"] = {
		label = "Smoke 1",
		weight = 1,
		stack = true
	},
	["svapo_smoke1e"] = {
		label = "Smoke 1",
		weight = 1,
		stack = true
	},
	["svapo_smoke1f"] = {
		label = "Smoke 1",
		weight = 1,
		stack = true
	},
	["svapo_evape_box"] = {
		label = "E-Vape Box",
		weight = 1,
		stack = true
	},
	["svapo_evape2_box"] = {
		label = "E-Vape 2 Box",
		weight = 1,
		stack = true
	},
	["svapo_smoke_box"] = {
		label = "Smoke Box",
		weight = 1,
		stack = true
	},
	["svapo_sumo_box"] = {
		label = "Sumo Box",
		weight = 1,
		stack = true
	},
	["svapo_vaporglow_box"] = {
		label = "Vaporglow Box",
		weight = 1,
		stack = true
	},
	["cigs_redwood"] = {
		label = "Cigarettes: Redwood",
		weight = 1,
		stack = true,
		client = {
			--status = {},
			anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c' },
			prop = {
				model = 'prop_cs_ciggy_01b',
				bone = 57005,
				pos = vec3(0.18, 0.02, 0.02),
				rot = vec3(0, 103.42, 0)
			},
			usetime = 10000,
		}
	},
	["cigs_redwood2"] = {
		label = "Cigarettes: Redwood2",
		weight = 1,
		stack = true,
		client = {
			--status = {},
			anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c' },
			prop = {
				model = 'prop_cs_ciggy_01b',
				bone = 57005,
				pos = vec3(0.18, 0.02, 0.02),
				rot = vec3(0, 103.42, 0)
			},
			usetime = 10000,
		}
	},
	["cigs_debonaireb"] = {
		label = "Cigarettes: Debonaire Blue",
		weight = 1,
		stack = true,
		client = {
			--status = {},
			anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c' },
			prop = {
				model = 'prop_cs_ciggy_01b',
				bone = 57005,
				pos = vec3(0.18, 0.02, 0.02),
				rot = vec3(0, 103.42, 0)
			},
			usetime = 10000,
		}
	},
	["cigs_debonaireg"] = {
		label = "Cigarettes: Debonaire Green",
		weight = 1,
		stack = true,
		client = {
			--status = {},
			anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c' },
			prop = {
				model = 'prop_cs_ciggy_01b',
				bone = 57005,
				pos = vec3(0.18, 0.02, 0.02),
				rot = vec3(0, 103.42, 0)
			},
			usetime = 10000,
		}
	},
	["cigs_cardiaque"] = {
		label = "Cigarettes: Cardiaque",
		weight = 1,
		stack = true,
		client = {
			--status = {},
			anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c' },
			prop = {
				model = 'prop_cs_ciggy_01b',
				bone = 57005,
				pos = vec3(0.18, 0.02, 0.02),
				rot = vec3(0, 103.42, 0)
			},
			usetime = 10000,
		}
	},
	["cigs_69brand"] = {
		label = "Cigarettes: 69Brand",
		weight = 1,
		stack = true,
		client = {
			--status = {},
			anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c' },
			prop = {
				model = 'prop_cs_ciggy_01b',
				bone = 57005,
				pos = vec3(0.18, 0.02, 0.02),
				rot = vec3(0, 103.42, 0)
			},
			usetime = 10000,
		}
	},
	["cigs_cok"] = {
		label = "Cigarettes: CoK",
		weight = 1,
		stack = true,
		client = {
			--status = {},
			anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c' },
			prop = {
				model = 'prop_cs_ciggy_01b',
				bone = 57005,
				pos = vec3(0.18, 0.02, 0.02),
				rot = vec3(0, 103.42, 0)
			},
			usetime = 10000,
		}
	},
	["cigs_estancia"] = {
		label = "Cigars: Estancia",
		weight = 1,
		stack = true,
		client = {
			--status = {},
			anim = { dict = 'amb@world_human_aa_smoke@male@idle_a', clip = 'idle_c' },
			prop = {
				model = 'prop_cs_ciggy_01b',
				bone = 57005,
				pos = vec3(0.18, 0.02, 0.02),
				rot = vec3(0, 103.42, 0)
			},
			usetime = 10000,
		}
	},
	-- Vapes
	["evape1"] = {
		label       = "E-Vape + Atomizer",
		weight      = 1,
		stack       = false,
		metadata    = true,
		description = "A crafted E-Vape with atomizer.",
		useable     = true,
	},
	["evape2"] = {
		label       = "Smoke + Atomizer",
		weight      = 1,
		stack       = false,
		metadata    = true,
		description = "A crafted Smoke vape with atomizer.",
		useable     = true,
	},
	["vapesuitcase"] = {
		label   = "Vape Suitcase",
		weight  = 100,
		stack   = false,
		useable = true,
	},

	-- Stick Vape
	["blue_stickevape"] = {
		label   = "Blue Stick E-Vape",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["red_stickevape"] = {
		label   = "Red Stick E-Vape",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["green_stickevape"] = {
		label   = "Green Stick E-Vape",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["pink_stickevape"] = {
		label   = "Pink Stick E-Vape",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["lightgrey_stickevape"] = {
		label   = "Light Grey Stick E-Vape",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["black_stickevape"] = {
		label   = "Black Stick E-Vape",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["orange_stickevape"] = {
		label   = "Orange Stick E-Vape",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["yellow_stickevape"] = {
		label   = "Yellow Stick E-Vape",
		weight  = 1,
		stack   = false,
		useable = true,
	},

	-- Sumo Vape
	["blue_sumovape"] = {
		label   = "Blue Sumo",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["red_sumovape"] = {
		label   = "Red Sumo",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["green_sumovape"] = {
		label   = "Green Sumo",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["pink_sumovape"] = {
		label   = "Pink Sumo",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["lightgrey_sumovape"] = {
		label   = "Light Grey Sumo",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["black_sumovape"] = {
		label   = "Black Sumo",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["orange_sumovape"] = {
		label   = "Orange Sumo",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["yellow_sumovape"] = {
		label   = "Yellow Sumo",
		weight  = 1,
		stack   = false,
		useable = true,
	},

	-- Vapor Vape
	["blue_vaporglowvape"] = {
		label   = "Blue VaporGlow",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["red_vaporglowvape"] = {
		label   = "Red VaporGlow",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["green_vaporglowvape"] = {
		label   = "Green VaporGlow",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["pink_vaporglowvape"] = {
		label   = "Pink VaporGlow",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["lightgrey_vaporglowvape"] = {
		label   = "Light Grey VaporGlow",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["black_vaporglowvape"] = {
		label   = "Black VaporGlow",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["orange_vaporglowvape"] = {
		label   = "Orange VaporGlow",
		weight  = 1,
		stack   = false,
		useable = true,
	},
	["yellow_vaporglowvape"] = {
		label   = "Yellow VaporGlow",
		weight  = 1,
		stack   = false,
		useable = true,
	},

	-- Boxes
	-- E-Vape
	["sand_evapebox"] = {
		label = "Sand E-Vape Box",
		weight = 1,
		stack = false,
	},
	["black_evapebox"] = {
		label = "Black E-Vape Box",
		weight = 1,
		stack = false,
	},
	["redblack_evapebox"] = {
		label = "Red & Black E-Vape Box",
		weight = 1,
		stack = false,
	},
	["cyan_evapebox"] = {
		label = "Cyan E-Vape Box",
		weight = 1,
		stack = false,
	},
	["redwhite_evapebox"] = {
		label = "Red & White E-Vape Box",
		weight = 1,
		stack = false,
	},
	["grey_evapebox"] = {
		label = "Grey E-Vape Box",
		weight = 1,
		stack = false,
	},

	-- Smokebox
	["blue_smokebox"] = {
		label = "Blue Smoke Box",
		weight = 1,
		stack = false,
	},
	["red_smokebox"] = {
		label = "Red Smoke Box",
		weight = 1,
		stack = false,
	},
	["green_smokebox"] = {
		label = "Green Smoke Box",
		weight = 1,
		stack = false,
	},
	["pink_smokebox"] = {
		label = "Pink Smoke Box",
		weight = 1,
		stack = false,
	},
	["lightblue_smokebox"] = {
		label = "L. Blue Smoke Box",
		weight = 1,
		stack = false,
	},
	["black_smokebox"] = {
		label = "Black Smoke Box",
		weight = 1,
		stack = false,
	},
	["orange_smokebox"] = {
		label = "Orange Smoke Box",
		weight = 1,
		stack = false,
	},
	["yellow_smokebox"] = {
		label = "Yellow Smoke Box",
		weight = 1,
		stack = false,
	},

	-- Atomizers
	["silver_longatomizer"] = {
		label = "Long Silver Atomizer",
		weight = 1,
		stack = true,
	},
	["red_longatomizer"] = {
		label = "Long Red Atomizer",
		weight = 1,
		stack = true,
	},
	["blue_longatomizer"] = {
		label = "Long Blue Atomizer",
		weight = 1,
		stack = true,
	},
	["green_longatomizer"] = {
		label = "Long Green Atomizer",
		weight = 1,
		stack = true,
	},
	["pink_longatomizer"] = {
		label = "Long Pink Atomizer",
		weight = 1,
		stack = true,
	},
	["grey_longatomizer"] = {
		label = "Long Grey Atomizer",
		weight = 1,
		stack = true,
	},
	["black_longatomizer"] = {
		label = "Long Black Atomizer",
		weight = 1,
		stack = true,
	},
	["orange_longatomizer"] = {
		label = "Long Orange Atomizer",
		weight = 1,
		stack = true,
	},
	["yellow_longatomizer"] = {
		label = "Long Yellow Atomizer",
		weight = 1,
		stack = true,
	},

	-- 2
	["silver_shortatomizer"] = {
		label = "Short Silver Atomizer",
		weight = 1,
		stack = true,
	},
	["red_shortatomizer"] = {
		label = "Short Red Atomizer",
		weight = 1,
		stack = true,
	},
	["blue_shortatomizer"] = {
		label = "Short Blue Atomizer",
		weight = 1,
		stack = true,
	},
	["green_shortatomizer"] = {
		label = "Short Green Atomizer",
		weight = 1,
		stack = true,
	},
	["pink_shortatomizer"] = {
		label = "Short Pink Atomizer",
		weight = 1,
		stack = true,
	},
	["grey_shortatomizer"] = {
		label = "Short Grey Atomizer",
		weight = 1,
		stack = true,
	},
	["black_shortatomizer"] = {
		label = "Short Black Atomizer",
		weight = 1,
		stack = true,
	},
	["orange_shortatomizer"] = {
		label = "Short Orange Atomizer",
		weight = 1,
		stack = true,
	},
	["yellow_shortatomizer"] = {
		label = "Short Yellow Atomizer",
		weight = 1,
		stack = true,
	},

	-- 3
	["silver_notankatomizer"] = {
		label = "Silver NO-Tank Atomizer",
		weight = 1,
		stack = true,
	},
	["gold_notankatomizer"] = {
		label = "Gold NO-Tank Atomizer",
		weight = 1,
		stack = true,
	},
	["black_notankatomizer"] = {
		label = "Black NO-Tank Atomizer",
		weight = 1,
		stack = true,
	},
	["red_notankatomizer"] = {
		label = "Red NO-Tank Atomizer",
		weight = 1,
		stack = true,
	},

	-- Liquids
	["liquid_sweettemptation"] = {
		label   = "Liquid: Sweet Temptation",
		weight  = 1,
		stack   = true,
		useable = true,
	},
	["liquid_iceberg"] = {
		label   = "Liquid: Iceberg",
		weight  = 1,
		stack   = true,
		useable = true,
	},
	["liquid_snoopify"] = {
		label   = "Liquid: Snoopify",
		weight  = 1,
		stack   = true,
		useable = true,
	},
	["liquid_goldtobacco"] = {
		label   = "Liquid: Goldtobacco",
		weight  = 1,
		stack   = true,
		useable = true,
	},
	["liquid_fruitytrip"] = {
		label   = "Liquid: FruityTrip",
		weight  = 1,
		stack   = true,
		useable = true,
	},
	["liquid_candybomb"] = {
		label   = "Liquid: CandyBomb",
		weight  = 1,
		stack   = true,
		useable = true,
	},
	["liquid_sensei"] = {
		label   = "Liquid: Sensei",
		weight  = 1,
		stack   = true,
		useable = true,
	},
	["liquid_blueberry"] = {
		label   = "Liquid: Blue Berry",
		weight  = 1,
		stack   = true,
		useable = true,
	},

	-- Cardboard Vapes
	["smokebox_cardboard"] = {
		label   = "Smoke Box Cardboard",
		weight  = 1,
		stack   = true,
		useable = true,
	},
	["evape1_cardboard"] = {
		label   = "E-Vape Stick Cardboard",
		weight  = 1,
		stack   = true,
		useable = true,
	},
	["evape2_cardboard"] = {
		label   = "E-Vape Box Cardboard",
		weight  = 1,
		stack   = true,
		useable = true,
	},
	["sumo_cardboard"] = {
		label   = "Sumo Vape Cardboard",
		weight  = 1,
		stack   = true,
		useable = true,
	},
	["vaporglow_cardboard"] = {
		label   = "VaporGlow Cardboard",
		weight  = 1,
		stack   = true,
		useable = true,
	},
	['instant_camera'] = {
		label = 'Instant Camera',
		weight = 0,
		consume = 0,
		description = 'A simple camera designed to take photos at a crime scene',
		server = { export = "origen_police.instant_camera" },
		client = { image = 'polaroid.png' }
	},

	['photo'] = {
		label = 'Photo',
		weight = 0,
		consume = 0,
		description = 'An image',
		server = { export = "origen_police.photo" },
		client = { image = 'photos.png' }
	},

	['evidence_a'] = {
		label = 'Evidence of Bullet',
		weight = 0,
		consume = 0,
		description = 'Evidence obtained from a crime scene',
		client = { image = 'evidence_a.png' }
	},

	['evidence_az'] = {
		label = 'Evidence',
		weight = 0,
		consume = 0,
		description = 'Evidence obtained from a crime scene',
		client = { image = 'evidence_az.png' }
	},

	['evidence_b'] = {
		label = 'Vehicle Evidence',
		weight = 0,
		consume = 0,
		description = 'Evidence obtained from a crime scene',
		client = { image = 'evidence_b.png' }
	},

	['evidence_n'] = {
		label = 'Impact Evidence',
		weight = 0,
		consume = 0,
		description = 'Evidence obtained from a crime scene',
		client = { image = 'evidence_n.png' }
	},

	['evidence_ne'] = {
		label = 'Footprint Evidence',
		weight = 0,
		consume = 0,
		description = 'Evidence obtained from a crime scene',
		client = { image = 'evidence_ne.png' }
	},

	['evidence_r'] = {
		label = 'Blood Evidence',
		weight = 0,
		consume = 0,
		description = 'Evidence obtained from a crime scene',
		client = { image = 'evidence_r.png' }
	},

	['evidence_ro'] = {
		label = 'Evidence',
		weight = 0,
		consume = 0,
		description = 'Evidence obtained from a crime scene',
		client = { image = 'evidence_ro.png' }
	},

	['evidence_v'] = {
		label = 'Drug Evidence',
		weight = 0,
		consume = 0,
		description = 'Evidence obtained from a crime scene',
		client = { image = 'evidence_v.png' }
	},

	['report_evidence'] = {
		label = 'Evidence Report',
		weight = 0,
		consume = 0,
		description = 'Here there can be collected up to 4 pieces of evidence',
		server = { export = 'origen_police.report_evidence' },
		client = { image = 'report_evidence.png' }
	},

	['k9'] = {
		label = 'K9 Whistle',
		weight = 0,
		consume = 0,
		description = 'Use the whistle to call the K9 unit',
		server = { export = "origen_police.k9" },
		client = { image = 'whistle.png' }
	},

	['lspd_badge'] = {
		label = 'Police Badge',
		weight = 0,
		consume = 0,
		description = 'Your identification as a police officer, includes your rank and badge number',
		server = { export = "origen_police.lspd_badge" },
		client = { image = 'lspd_badge.png' }
	},

	['bcsd_badge'] = {
		label = 'Sheriff Badge',
		weight = 0,
		consume = 0,
		description = "Your identification as a sheriff's agent, including your rank and badge number",
		server = { export = "origen_police.bcsd_badge" },
		client = { image = 'bcsd_badge.png' }
	},

	['fib_badge'] = {
		label = "FIB Badge",
		weight = 200,
		server = { export = "origen_police.fib_badge" },
		consume = 0
	},

	['police_cad'] = {
		label = 'Police Tablet',
		weight = 0,
		consume = 0,
		description = 'Your personal tablet with all the information of the San Andreas police',
		server = { export = "origen_police.police_cad" },
		client = { image = 'police_cad.png' }
	},

	['advanced_pickaxe'] = {
		label = 'Advanced Pickaxe',
		weight = 100,
		stack = true,
		close = true,
		description = 'Advanced Pickaxe',
		client = {
			image = 'advanced_pickaxe.png'
		}
	},

	['blackpowder'] = {
		label = 'Black Powder',
		weight = 100,
		stack = true,
		close = true,
		description = 'Black Powder',
		client = {
			image = 'blackpowder.png'
		}
	},

	['coal'] = {
		label = 'Coal',
		weight = 100,
		stack = true,
		close = true,
		description = 'Coal',
		client = {
			image = 'coal.png'
		}
	},

	['concrete'] = {
		label = 'Concrete',
		weight = 100,
		stack = true,
		close = true,
		description = 'Concrete',
		client = {
			image = 'concrete.png'
		}
	},

	['copper_ingot'] = {
		label = 'Copper Ingot',
		weight = 100,
		stack = true,
		close = true,
		description = 'Copper Ingot',
		client = {
			image = 'copper_ingot.png'
		}
	},

	['copper_ore'] = {
		label = 'Copper Ore',
		weight = 100,
		stack = true,
		close = true,
		description = 'Copper Ore',
		client = {
			image = 'copper_ore.png'
		}
	},

	['diamond_ingot'] = {
		label = 'Diamond Ingot',
		weight = 100,
		stack = true,
		close = true,
		description = 'Diamond Ingot',
		client = {
			image = 'diamond_ingot.png'
		}
	},

	['diamond_ore'] = {
		label = 'Diamond Ore',
		weight = 100,
		stack = true,
		close = true,
		description = 'Diamond Ore',
		client = {
			image = 'diamond_ore.png'
		}
	},

	['glass'] = {
		label = 'Glass',
		weight = 100,
		stack = true,
		close = true,
		description = 'Glass',
		client = {
			image = 'glass.png'
		}
	},

	['glass_mold'] = {
		label = 'Glass Mold',
		weight = 100,
		stack = true,
		close = true,
		description = 'Glass Mold',
		client = {
			image = 'glass_mold.png'
		}
	},

	['goldingot'] = {
		label = 'Gold Ingot',
		weight = 100,
		stack = true,
		close = true,
		description = 'Gold Ingot',
		client = {
			image = 'wool.png'
		}
	},

	['gold_ore'] = {
		label = 'Gold Ore',
		weight = 100,
		stack = true,
		close = true,
		description = 'Gold Ore',
		client = {
			image = 'goldingot.png'
		}
	},

	['ingot_mold'] = {
		label = 'Ingot Mold',
		weight = 100,
		stack = true,
		close = true,
		description = 'Ingot Mold',
		client = {
			image = 'ingot_mold.png'
		}
	},

	['iron_ingot'] = {
		label = 'Iron Ingot',
		weight = 100,
		stack = true,
		close = true,
		description = 'Iron Ingot',
		client = {
			image = 'iron_ingot.png'
		}
	},

	['iron_ore'] = {
		label = 'Iron Ore',
		weight = 100,
		stack = true,
		close = true,
		description = 'Iron Ore',
		client = {
			image = 'iron_ore.png'
		}
	},

	['limestone'] = {
		label = 'Limestone',
		weight = 100,
		stack = true,
		close = true,
		description = 'Limestone',
		client = {
			image = 'limestone.png'
		}
	},

	['normal_pickaxe'] = {
		label = 'Normal Pickaxe',
		weight = 100,
		stack = true,
		close = true,
		description = 'Normal Pickaxe',
		client = {
			image = 'normal_pickaxe.png'
		}
	},

	['professional_pickaxe'] = {
		label = 'Professional Pickaxe',
		weight = 100,
		stack = true,
		close = true,
		description = 'Professional Pickaxe',
		client = {
			image = 'professional_pickaxe.png'
		}
	},

	['rock'] = {
		label = 'Rock',
		weight = 100,
		stack = true,
		close = true,
		description = 'Rock',
		client = {
			image = 'rock.png'
		}
	},

	['sandstone'] = {
		label = 'Sandstone',
		weight = 100,
		stack = true,
		close = true,
		description = 'Sandstone',
		client = {
			image = 'sandstone.png'
		}
	},

	['special_water'] = {
		label = 'Special Water',
		weight = 100,
		stack = true,
		close = true,
		description = 'Special Water',
		client = {
			image = 'special_water.png'
		}
	},

	['sticky_gel'] = {
		label = 'Sticky Gel',
		weight = 100,
		stack = true,
		close = true,
		description = 'Sticky Gel',
		client = {
			image = 'sticky_gel.png'
		}
	},

	['sulfur'] = {
		label = 'Sulfur',
		weight = 100,
		stack = true,
		close = true,
		description = 'Sulfur',
		client = {
			image = 'sulfur.png'
		}
	},
    ["pigeonmeat"] = {
        label = "Pigeon Meat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Delicious pigeon meat for your culinary adventures.",
    },
    ["pigeonfeather"] = {
        label = "Pigeon Feather",
        weight = 1000,
        stack = true,
        close = true,
        description = "A soft and lightweight feather from a pigeon.",
    },
    ["crowmeat"] = {
        label = "Crow Meat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Tasty crow meat, perfect for daring gourmets.",
    },
    ["crowfeather"] = {
        label = "Crow Feather",
        weight = 1000,
        stack = true,
        close = true,
        description = "A sleek and dark feather from a crow.",
    },
    ["seagullmeat"] = {
        label = "Seagull Meat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Savory seagull meat, a delicacy among fishermen.",
    },
    ["seagullfeather"] = {
        label = "Seagull Feather",
        weight = 1000,
        stack = true,
        close = true,
        description = "A graceful and light feather from a seagull.",
    },
    ["cormorantmeat"] = {
        label = "Cormorant Meat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Meaty cormorant meat, a rare find for adventurous eaters.",
    },
    ["cormorantbeak"] = {
        label = "Cormorant Beak",
        weight = 1000,
        stack = true,
        close = true,
        description = "A sturdy and pointed beak from a cormorant.",
    },
    ["deermeat"] = {
        label = "Deer Meat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Succulent deer meat, a favorite among hunters.",
    },
    ["deerhorn"] = {
        label = "Deer Horn",
        weight = 1000,
        stack = true,
        close = true,
        description = "A majestic horn from a deer, prized for its beauty.",
    },
    ["rabbitmeat"] = {
        label = "Rabbit Meat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Tender rabbit meat, perfect for stews and roasts.",
    },
    ["rabbitskin"] = {
        label = "Rabbit Skin",
        weight = 1000,
        stack = true,
        close = true,
        description = "A soft and supple skin from a rabbit, ideal for crafting.",
    },
    ["ratmeat"] = {
        label = "Rat Meat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Edible rat meat, a survivalist's choice in desperate times.",
    },
    ["pigmeat"] = {
        label = "Pig Meat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Juicy pig meat, a staple in many hearty meals.",
    },
    ["pigskin"] = {
        label = "Pig Skin",
        weight = 1000,
        stack = true,
        close = true,
        description = "Thick and durable pig skin, useful for crafting leather goods.",
    },
    ["coyotemeat"] = {
        label = "Coyote Meat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Lean and gamey coyote meat, favored by wilderness enthusiasts.",
    },
    ["coyoteskin"] = {
        label = "Coyote Skin",
        weight = 1000,
        stack = true,
        close = true,
        description = "Tough and weather-resistant coyote skin, perfect for outdoor gear.",
    },
    ["coguarmeat"] = {
        label = "Cougarmeat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Exotic cougarmeat, a delicacy for adventurous palates.",
    },
    ["coguarskin"] = {
        label = "Cougar Skin",
        weight = 1000,
        stack = true,
        close = true,
        description = "Supple cougar skin, highly valued in the fashion industry.",
    },
    ["boarmeat"] = {
        label = "Boar Meat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Hearty boar meat, a popular choice among hunters and chefs.",
    },
    ["boarskin"] = {
        label = "Boar Skin",
        weight = 1000,
        stack = true,
        close = true,
        description = "Tough boar skin, excellent for crafting rugged goods.",
    },
    ["snakemeat"] = {
        label = "Snake Meat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Savory snake meat, a delicacy in some cultures.",
    },
    ["boarhorn"] = {
        label = "Boar Horn",
        weight = 1000,
        stack = true,
        close = true,
        description = "A large and impressive horn from a boar.",
    },
    ["snakeskin"] = {
        label = "Snake Skin",
        weight = 1000,
        stack = true,
        close = true,
        description = "Smooth and patterned snake skin, used for various crafts.",
    },
    ["hawkmeat"] = {
        label = "Hawk Meat",
        weight = 1000,
        stack = true,
        close = true,
        description = "Lean and gamey hawk meat, a rare delicacy among hunters.",
    },
    ["hawkskin"] = {
        label = "Hawk Skin",
        weight = 1000,
        stack = true,
        close = true,
        description = "Beautiful hawk skin, prized for its unique markings.",
    },
    ["hawkpeak"] = {
        label = "Hawk Peak",
        weight = 1000,
        stack = true,
        close = true,
        description = "A majestic feather from a hawk's peak, a symbol of freedom.",
    },
}
