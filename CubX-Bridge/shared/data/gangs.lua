--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

CBUX.DefaultGangs = {
    none = {
        label = "No Gang",
        grades = {
            [0] = { name = "None", isboss = false }
        }
    },
    ballas = {
        label = "Ballas",
        grades = {
            [0] = { name = "Recruit", isboss = false },
            [1] = { name = "Member", isboss = false },
            [2] = { name = "Enforcer", isboss = false },
            [3] = { name = "Shot Caller", isboss = false },
            [4] = { name = "OG", isboss = true }
        }
    },
    vagos = {
        label = "Vagos",
        grades = {
            [0] = { name = "Recruit", isboss = false },
            [1] = { name = "Member", isboss = false },
            [2] = { name = "Enforcer", isboss = false },
            [3] = { name = "Shot Caller", isboss = false },
            [4] = { name = "OG", isboss = true }
        }
    },
    families = {
        label = "Families",
        grades = {
            [0] = { name = "Recruit", isboss = false },
            [1] = { name = "Member", isboss = false },
            [2] = { name = "Enforcer", isboss = false },
            [3] = { name = "Shot Caller", isboss = false },
            [4] = { name = "OG", isboss = true }
        }
    },
    lostmc = {
        label = "The Lost MC",
        grades = {
            [0] = { name = "Hangaround", isboss = false },
            [1] = { name = "Prospect", isboss = false },
            [2] = { name = "Member", isboss = false },
            [3] = { name = "Road Captain", isboss = false },
            [4] = { name = "President", isboss = true }
        }
    },
    triads = {
        label = "Triads",
        grades = {
            [0] = { name = "Recruit", isboss = false },
            [1] = { name = "Member", isboss = false },
            [2] = { name = "Red Pole", isboss = false },
            [3] = { name = "White Paper Fan", isboss = false },
            [4] = { name = "Dragon Head", isboss = true }
        }
    }
}

return CBUX.DefaultGangs