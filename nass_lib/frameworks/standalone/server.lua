if GetResourceState('qb-core') == 'started' then return end
if GetResourceState('es_extended') == 'started' then return end
nass.framework = "standalone"

function nass.getPlayerIdentifier(source)
    for k, v in ipairs(GetPlayerIdentifiers(source)) do
		if string.match(v, "license:") then
			local identifier = string.gsub(v, "license:", "")
			return identifier;
		end
	end
end

function nass.getPlayerName(source, full)
    return GetPlayerName(source)
end