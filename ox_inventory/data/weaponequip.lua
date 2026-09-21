--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

return {
    {
        label = "Par defaut",
        animation = {
            equip = { dict = "reaction@intimidation@1h", name = "intro", duration = 800 },
            unequip = { dict = "reaction@intimidation@1h", name = "outro", duration = 900 }
        }
    },
    {
        label = "Melee",
        animation = {
            equip = { dict = "melee@holster", name = "holster", duration = 500 },
            unequip = { dict = "melee@holster", name = "unholster", duration = 750 }
        }
    },
    {
        label = "Gangster",
        animation = {
            equip = { dict = "combat@combat_reactions@pistol_1h_gang", name = "0", duration = 750 },
            unequip = { dict = "combat@combat_reactions@pistol_1h_gang", name = "0", duration = 700 }
        }
    },
    {
        label = "Holster",
        animation = {
            equip = { dict = "rcmjosh4", name = "josh_leadout_cop2", duration = 700 },
            unequip = { dict = "reaction@intimidation@cop@unarmed", name = "intro", duration = 500 },
        }
    },
    {
        label = "Fermier",
        animation = {
            equip = { dict = "combat@combat_reactions@pistol_1h_hillbilly", name = "0", duration = 750 },
            unequip = { dict = "combat@combat_reactions@pistol_1h_gang", name = "0", duration = 700 },
        }
    },
    {
        label = "Holster jambe",
        animation = {
            equip = { dict = "reaction@male_stand@big_variations@d", name = "react_big_variations_m", duration = 600 },
            unequip = { dict = "reaction@male_stand@big_variations@d", name = "react_big_variations_m", duration = 600 },
        }
    },
}