function nass.loadModel(model)
	if type(model) ~= "number" then
		model = joaat(model)
	end
	while not HasModelLoaded(model) do Wait(0); RequestModel(model); end
	return model
end

function nass.requestAnimDict(dict)
    if not DoesAnimDictExist(dict) then return end
    if HasAnimDictLoaded(dict) then return dict end
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end