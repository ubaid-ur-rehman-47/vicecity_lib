nass.savedOutfits = {}
function nass.setClothing(ped, clothing, props)
    if ped == PlayerPedId() then
        nass.savedOutfits[GetInvokingResource()] = nass.getClothing(ped)
    end
    RemoveClothingProps(ped)
    if clothing then
		for _, v in pairs(clothing.clothing ~= nil and clothing.clothing or clothing) do
			SetPedComponentVariation(ped, v.component, v.drawable, v.texture, 0)
		end
	end
	if props or clothing.props then
		for _, v in pairs(clothing.props ~= nil and clothing.props or props) do
			SetPedPropIndex(ped, v.component, v.drawable, v.texture, true)
		end
	end
	if clothing.headBlend then
		SetPedHeadBlendData(ped, clothing.headBlend.shapeFirst, clothing.headBlend.shapeSecond, clothing.headBlend.shapeThird, clothing.headBlend.skinFirst, clothing.headBlend.skinSecond, clothing.headBlend.skinThird, clothing.headBlend.shapeMix, clothing.headBlend.skinMix, clothing.headBlend.thirdMix, false)
	end
	if clothing.faceFeature then
		for _, v in pairs(clothing.faceFeature) do
			SetPedFaceFeature(ped, v.component, v.feature)
		end
	end
	if clothing.overlayData then
		for _, v in pairs(clothing.overlayData) do
			SetPedHeadOverlay(ped, v.component, v.overlayValue, v.overlayOpacity)
			SetPedHeadOverlayColor(ped, v.component, 1, v.colourType, v.firstColour, v.secondColour)
		end
	end
	if clothing.hair then
		SetPedHairColor(ped, clothing.hair.color, clothing.hair.highlight)
	end
end

function nass.resetClothing(ped, resource)
    RemoveClothingProps(ped)
    local outfit = nass.savedOutfits[GetInvokingResource() ~= nil and GetInvokingResource() or resource]
    if not outfit then return end
    if outfit.clothing and next(outfit.clothing) then
        for _, clothingData in pairs(outfit.clothing) do
            SetPedComponentVariation(ped, clothingData.component, clothingData.drawable, clothingData.texture, 0)
        end
    end
    if outfit.props and next(outfit.props) then
        for _, propData in pairs(outfit.props) do
            SetPedPropIndex(ped, propData.component, propData.drawable, propData.texture, true)
        end
    end
	if outfit.hair then
		SetPedHairColor(ped, outfit.hair.color, outfit.hair.highlight)
	end
    nass.savedOutfits[GetInvokingResource() ~= nil and GetInvokingResource() or resource] = nil
end

function nass.getClothing(ped)
	local civilianOutfit = { clothing = {}, props = {}, faceFeature = {}, overlayData = {}, headBlend = {}, hair = {} }
	for i = 0, 11 do
		local drawable = GetPedDrawableVariation(ped, i)
		local texture = GetPedTextureVariation(ped, i)
		civilianOutfit.clothing[#civilianOutfit.clothing + 1] = {
			component = i,
			drawable = drawable,
			texture = texture
		}
	end
	for i = 0, 7 do
		local drawable = GetPedPropIndex(ped, i)
		local texture = GetPedPropTextureIndex(ped, i)
		civilianOutfit.props[#civilianOutfit.props + 1] = {
			component = i,
			drawable = drawable,
			texture = texture
		}
	end

	for i = 0, 19 do
		local feature = GetPedFaceFeature(ped, i)
		civilianOutfit.faceFeature[#civilianOutfit.faceFeature + 1] = {
			component = i,
			feature = feature
		}
	end

	for i = 0, 12 do
		local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, i)
		if success then
			civilianOutfit.overlayData[#civilianOutfit.overlayData + 1] = {
				component = i,
				overlayValue = overlayValue + 1,
				overlayOpacity = overlayOpacity,
				firstColour = firstColour,
				secondColour = secondColour,
				colourType = colourType,
			}
		end
	end

	local shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix = Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped, Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0))
	local data = {shapeFirst=shapeFirst, shapeSecond=shapeSecond, shapeThird=shapeThird, skinFirst=skinFirst, skinSecond=skinSecond, skinThird=skinThird, shapeMix=shapeMix, skinMix=skinMix, thirdMix=thirdMix}
	if data then
		civilianOutfit.headBlend = data
	end

	civilianOutfit.hair = {
		color = GetPedHairColor(ped),
		highlight = GetPedHairHighlightColor(ped)
	}

	return civilianOutfit
end

function nass.getGender(ped)
    return GetEntityModel(ped) ~= GetHashKey("mp_m_freemode_01") and "female" or GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") and "male" or "unknown"
end

function RemoveClothingProps(ped)
	SetPedPropIndex(ped, 0, -1, 0, true)
	for i = 0, 11 do
		ClearPedProp(ped, i)
	end
	for i = 0, 7 do
		ClearPedProp(ped, i)
	end
end

AddEventHandler('onResourceStop', function(resourceName)
    if nass.savedOutfits[resourceName] then 
		nass.resetClothing(PlayerPedId(), resourceName)
	end
end)