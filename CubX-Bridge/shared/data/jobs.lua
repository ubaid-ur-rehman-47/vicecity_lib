--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

CBUX.DefaultJobs = {
    unemployed = {
        label = "Unemployed",
        defaultDuty = true,
        grades = {
            [0] = { name = "Unemployed", payment = 0 }
        }
    },
    police = {
        label = "Law Enforcement",
        defaultDuty = false,
        grades = {
            [0] = { name = "Cadet", payment = 50 },
            [1] = { name = "Officer", payment = 75 },
            [2] = { name = "Sergeant", payment = 100 },
            [3] = { name = "Lieutenant", payment = 125 },
            [4] = { name = "Chief", payment = 150 }
        }
    },
    ambulance = {
        label = "Emergency Medical Services",
        defaultDuty = false,
        grades = {
            [0] = { name = "Trainee", payment = 50 },
            [1] = { name = "EMT", payment = 75 },
            [2] = { name = "Paramedic", payment = 100 },
            [3] = { name = "Doctor", payment = 125 },
            [4] = { name = "Chief", payment = 150 }
        }
    },
    mechanic = {
        label = "Mechanic",
        defaultDuty = false,
        grades = {
            [0] = { name = "Trainee", payment = 40 },
            [1] = { name = "Mechanic", payment = 60 },
            [2] = { name = "Senior Mechanic", payment = 80 },
            [3] = { name = "Manager", payment = 100 }
        }
    },
    taxi = {
        label = "Taxi",
        defaultDuty = false,
        grades = {
            [0] = { name = "Driver", payment = 30 },
            [1] = { name = "Senior Driver", payment = 50 },
            [2] = { name = "Manager", payment = 70 }
        }
    },
    realestate = {
        label = "Real Estate",
        defaultDuty = false,
        grades = {
            [0] = { name = "Agent", payment = 50 },
            [1] = { name = "Senior Agent", payment = 75 },
            [2] = { name = "Broker", payment = 100 }
        }
    }
}

return CBUX.DefaultJobs