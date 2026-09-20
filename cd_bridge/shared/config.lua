Cfg = {}

---------------------------------------------------------------------
-- AUTO-DETECT
-- 'auto_detect' will scan running resources and pick the best match.
-- Only change values if you want to FORCE a specific system.
---------------------------------------------------------------------

---------------------------------------------------------------------
Cfg.Framework = 'auto_detect'
-- auto_detect | esx | qbcore | qbox | vrp | standalone | other

Cfg.Database = 'auto_detect'
-- auto_detect | ghmattimysql | oxmysql | none

Cfg.Language = 'EN'
-- EN | ES | FR | DE | IT | PT | PT-BR | NL | PL | RU | TR | ZH | JA | AR | UA | CZ | DK | SE | NO | KR | HI
---------------------------------------------------------------------

---------------------------------------------------------------------
Cfg.BridgeDebugSQL = false -- Print SQL queries
Cfg.BridgeDebug = false    -- Print debug information
Cfg.DisableDuty = false    -- Disable the built-in framework duty system. Set this to true if you want police to be on duty at all times.
---------------------------------------------------------------------

---------------------------------------------------------------------
Cfg.Banking = 'okokBanking'
-- auto_detect | none | other |>
-- esx_banking | fd_banking | ns_SolarBanking | okokBanking | omes_banking | p_banking | ps-banking | qb-banking |>
-- Renewed-Banking | RxBanking | tgg-banking | wasabi_banking |

Cfg.Billing = 'auto_detect'
-- auto_detect | none | other |>
-- codem_billing | codem-billingv2 | esx_billing | okokBilling |

Cfg.Dispatch = 'auto_detect'
-- auto_detect | none | other |>
-- cd_dispatch | cd_dispatch3d | codem-dispatch | codem-mdtv2 | core_dispatch | emergencydispatch | lb-tablet |>
-- origen_police | ps-dispatch | qs-dispatch | rcore_dispatch | tk_dispatch

Cfg.DrawTextUI = 'auto_detect'
-- auto_detect | none | other |>
-- esx_textui | cd_drawtextui | jg-textui | okokTextUI | ox_lib | ps-ui | qb-core | tgiann-core | vms_notifyv2 | ZSX_UIV2 |

Cfg.Duty = 'auto_detect'
-- auto_detect | none | other |>
-- core_multijob | jobs_creator | origen_police |

Cfg.Gang = 'auto_detect'
-- auto_detect | none | other |>
-- av_gangs | rcore_gangs |

Cfg.Hud = 'auto_detect'
-- auto_detect | none | other |>
-- Codem-BlackHUDV2 | esx_hud | izzy-hudv5 | izzy-hudv6 | izzy-hudv7 | jg-hud | lation_ui | mHud | tgiann-lumihud |>
-- vms_hud | wais-hudv6 | 0r-hud-v3 | 17mov_Hud |

Cfg.Inventory = 'auto_detect'
-- auto_detect | none | other |>
-- ak47_inventory | ak47_qb_inventory | chezza-inventory | codem-inventory | core_inventory | esx_inventory | jaksam_inventory |>
-- jpr-inventory | origen_inventory | ox_inventory | ps-inventory | qb-inventory | qs-inventory | tgiann-inventory |

Cfg.Mechanic = 'auto_detect'
-- auto_detect | none | other |>
-- cd_mechanic | jg-mechanic |

Cfg.Notification = 'auto_detect'
-- auto_detect | other | chat |>
-- cd_notifications | codem-notification | codem-supreme-notification | esx | lation_ui | mythic_notify | okokNotify | origen_notify |>
-- ox_lib | pNotify | ps-ui | qbcore | qbox | rtx_notify | tgiann-lumihud | vms_notifyv2 | ZSX_UI | ZSX_UIV2 | 17mov_Hud |

Cfg.PersistentVehicles = 'cd_garage'
-- auto_detect | none | other |>
-- cd_garage | AdvancedParking |

Cfg.Phone = 'auto_detect'
-- auto_detect | none | other |>
-- esx_phone | gcphone | gksphone | high-phone | lb-phone | npwd | ns_Phone | okokPhone | qb-phone | qbx_npwd |>
-- qs-smartphone | qs-smartphone-pro | roadphone | sd-phone | yseries | 17mov_Phone |

Cfg.Society = 'okokBanking'
-- auto_detect | none | other |>
-- esx_society | fd_banking | ns_SolarBanking | okokBanking | p_banking | qb-banking | Renewed-Banking | RxBanking |>
-- tgg-banking | tgiann-bank | wasabi_banking |

Cfg.Target = 'auto_detect'
-- auto_detect | none |>
-- ox_target | qb-target |

Cfg.TimeWeather = 'auto_detect'
-- auto_detect | none | other |>
-- cd_easytime | codem-dynamicweather | qb-weathersync | vSync |

Cfg.VehicleFuel = 'auto_detect'
-- auto_detect | none | other |>
-- BigDaddy-Fuel | cdn-fuel | esx-sna-fuel | FRFuel | lc_fuel | LegacyFuel | lj-fuel | lyre_fuel | mnr_fuel | myFuel |>
-- ND_Fuel | okokGasStation | ox_fuel | ps-fuel | qb-fuel | qb-sna-fuel | qs-fuelstations | rcore_fuel | Renewed-Fuel |>
-- ti_fuel | x-fuel |

Cfg.VehicleKeys = 'qbx_vehiclekeys'
-- auto_detect | none | other |>
-- ak47_qb_vehiclekeys | ak47_vehiclekeys | cd_garage | fast-vehiclekeys | fivecode_carkeys | F_RealCarKeysSystem | ic3d_vehiclekeys |>
-- is_vehiclekeys | jc_vehiclekeys | loaf_keysystem | mk_vehiclekeys | mm_carkeys | MrNewbVehicleKeys | mx_carkeys | qb-vehiclekeys |>
-- qbx_vehiclekeys | qs-vehiclekeys | Renewed-Vehiclekeys | stasiek_vehiclekeys | tc_keys | t1ger_keys | tgiann-hotwire |>
-- ti_vehicleKeys | vehicles_keys | wasabi_carlock | xd_locksystem |

Cfg.VehicleMileage = 'cd_garage'
-- auto_detect | none | other |>
-- cd_garage | cd_mechanic | jg-vehiclemileage |

Cfg.VehicleShop = 'auto_detect'
-- auto_detect | none | other |>
-- cd_vehicleshop | dealerships_creator | esx_vehicleshop | jg-dealerships | okokVehicleShop | qb-vehicleshop | qbx-vehicleshop |>
-- qs-vehicleshop | vms_vehicleshopv2 |
---------------------------------------------------------------------

---------------------------------------------------------------------
ESXVehiclesTables = { 'vehicles', }
-- Add additional vehicle tables here if needed (used for storing vehicle data in ESX).

CodesignDiscordWebhook = 'DISCORD_WEBHOOK_HERE'
-- Discord webhook URL for remote error and debug reporting. Set this to the Discord webhook URL provided by Codesign if requested. Leave empty to disable.

Cfg.Keys = {
    ['ESC'] = 322,
    ['F1'] = 288,
    ['F2'] = 289,
    ['F3'] = 170,
    ['F5'] = 166,
    ['F6'] = 167,
    ['F7'] = 168,
    ['F8'] = 169,
    ['F9'] = 56,
    ['F10'] = 57,
    ['~'] = 243,
    ['1'] = 157,
    ['2'] = 158,
    ['3'] = 160,
    ['4'] = 164,
    ['5'] = 165,
    ['6'] = 159,
    ['7'] = 161,
    ['8'] = 162,
    ['9'] = 163,
    ['-'] = 84,
    ['='] = 83,
    ['BACKSPACE'] = 177,
    ['TAB'] = 37,
    ['Q'] = 44,
    ['W'] = 32,
    ['E'] = 38,
    ['R'] = 45,
    ['T'] = 245,
    ['Y'] = 246,
    ['U'] = 303,
    ['P'] = 199,
    ['['] = 39,
    [']'] = 40,
    ['ENTER'] = 18,
    ['CAPS'] = 137,
    ['A'] = 34,
    ['S'] = 8,
    ['D'] = 9,
    ['F'] = 23,
    ['G'] = 47,
    ['H'] = 74,
    ['K'] = 311,
    ['L'] = 182,
    ['LEFTSHIFT'] = 21,
    ['Z'] = 20,
    ['X'] = 73,
    ['C'] = 26,
    ['V'] = 0,
    ['B'] = 29,
    ['N'] = 249,
    ['M'] = 244,
    [','] = 82,
    ['.'] = 81,
    ['LEFTCTRL'] = 36,
    ['LEFTALT'] = 19,
    ['SPACE'] = 22,
    ['RIGHTCTRL'] = 70,
    ['HOME'] = 213,
    ['PAGEUP'] = 10,
    ['PAGEDOWN'] = 11,
    ['DELETE'] = 178,
    ['LEFTARROW'] = 174,
    ['RIGHTARROW'] = 175,
    ['TOP'] = 27,
    ['DOWNARROW'] = 173,
    ['NENTER'] = 201,
    ['N4'] = 108,
    ['N5'] = 60,
    ['N6'] = 107,
    ['N+'] = 96,
    ['N-'] = 97,
    ['N7'] = 117,
    ['N8'] = 61,
    ['N9'] = 118,
    ['UPARROW'] = 172,
    ['INSERT'] = 121
}
-- Key mapping table. Used for converting key names to their corresponding key codes.
---------------------------------------------------------------------
