-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================


Resmon = {}
Resmon.Lib = {}

-- ============================================================
--  UTILITIES
-- ============================================================

local lib = Resmon.Lib

local function _deepCopy(value)
    if type(value) == "table" then
        local copy = {}
        for k, v in next, value, nil do
            copy[Resmon.Lib._deepCopy(k)] = Resmon.Lib._deepCopy(v)
        end
        setmetatable(copy, Resmon.Lib._deepCopy(getmetatable(value)))
        return copy
    else
        return value
    end
end
Resmon.Lib._deepCopy = _deepCopy

local function contains(tbl, target)
    if not tbl then
        return true
    end
    for _, v in pairs(tbl) do
        if v == target then
            return true
        end
    end
    return false
end
Resmon.Lib.Contains = contains


-- ============================================================
--  EXPORTS
-- ============================================================

local function Get0Resmon()
    return Resmon
end
Get0Resmon = Get0Resmon

exports("GetCoreObject", Get0Resmon)

exports("Framework", function()
    return Config.Framework
end)