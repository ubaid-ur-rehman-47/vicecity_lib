--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

CBUX.VehicleCategories = {
    compacts = "Compacts",
    sedans = "Sedans",
    suvs = "SUVs",
    coupes = "Coupes",
    muscle = "Muscle",
    sports = "Sports",
    sportsclassics = "Sports Classics",
    super = "Super",
    motorcycles = "Motorcycles",
    offroad = "Off-Road",
    industrial = "Industrial",
    utility = "Utility",
    vans = "Vans",
    cycles = "Cycles",
    boats = "Boats",
    helicopters = "Helicopters",
    planes = "Planes",
    service = "Service",
    emergency = "Emergency",
    military = "Military",
    commercial = "Commercial",
    trains = "Trains",
    openwheel = "Open Wheel"
}

function CBUX.GetVehicleCategory(vehicle)
    local class = GetVehicleClass(vehicle)
    local categories = {
        [0] = "compacts",
        [1] = "sedans",
        [2] = "suvs",
        [3] = "coupes",
        [4] = "muscle",
        [5] = "sportsclassics",
        [6] = "sports",
        [7] = "super",
        [8] = "motorcycles",
        [9] = "offroad",
        [10] = "industrial",
        [11] = "utility",
        [12] = "vans",
        [13] = "cycles",
        [14] = "boats",
        [15] = "helicopters",
        [16] = "planes",
        [17] = "service",
        [18] = "emergency",
        [19] = "military",
        [20] = "commercial",
        [21] = "trains",
        [22] = "openwheel"
    }
    
    return categories[class] or "unknown"
end

return CBUX.VehicleCategories