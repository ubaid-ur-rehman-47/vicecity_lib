-- =========================================
-- Decrypted & Cleaned by AK Members
-- =========================================
Config = {}

Config.useCashAsItem = false

Config.zoneControls = {
    x = {
        fwd = {control = 32, name = "INPUT_MOVE_UP_ONLY"},
        back = {control = 33, name = "INPUT_MOVE_DOWN_ONLY"},
    },
    y = {
        left = {control = 34, name = "INPUT_MOVE_LEFT_ONLY"},
        right = {control = 35, name = "INPUT_MOVE_RIGHT_ONLY"},
    },
    z = {
        up = {control = 52, name = "INPUT_CONTEXT_SECONDARY", label = 'Up'},
        down = {control = 51, name = "INPUT_CONTEXT", label = 'Down'},
    },
    speed = {
        faster = {control = 21, name = "INPUT_SPRINT", label = 'Faster'},
        slower = {control = 19, name = "INPUT_CHARACTER_WHEEL", label = 'Slower'},
    },
    input = {
        undo = {control = 25, name = "INPUT_AIM"},
        select = {control = 24, name = "INPUT_ATTACK", label = 'Select'},
        cancel = {control = 194, name = "INPUT_FRONTEND_RRIGHT", label = 'Cancel'},
        rotUp = {control = 17, name = "INPUT_SELECT_PREV_WEAPON"},
        rotDown = {control = 16, name = "INPUT_SELECT_NEXT_WEAPON", label = 'Rotation'},
    },
}

Config.menuControls = {
    {name="nass_menu_up",     key="UP",       label="Menu - Up Key Input"},
    {name="nass_menu_down",   key="DOWN",     label="Menu - Down Key Input"},
    {name="nass_menu_left",   key="LEFT",     label="Menu - Left Key Input"},
    {name="nass_menu_right",  key="RIGHT",    label="Menu - Right Key Input"},
    {name="nass_menu_enter",  key="RETURN",   label="Menu - Enter Key Input"},
    {name="nass_menu_close",  key="BACK",     label="Menu - Cancel Key Input"},
}