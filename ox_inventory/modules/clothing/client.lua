-- Clothing slot visibility toggle: click a clothing icon in the inventory UI
-- to hide/show that piece of the player's currently worn appearance.
-- No inventory items are involved; clothing is never consumed or given here.
if not lib then return end

local hiddenSlots = {}
local originalAppearance

local function captureOriginalAppearance()
	if originalAppearance then return end

	local ok, appearance = ViceCity.Appearance.Get(cache.ped)
	if ok then
		originalAppearance = appearance
	end
end

local function restoreComponent(slotKey, componentId)
	local drawable, texture

	if originalAppearance and originalAppearance.components and originalAppearance.components[componentId] then
		local comp = originalAppearance.components[componentId]
		drawable, texture = comp.drawable, comp.texture
	else
		local ok, comp = ViceCity.Appearance.GetComponent(cache.ped, componentId)
		if not ok then return end
		drawable, texture = comp.drawable, comp.texture
	end

	ViceCity.Appearance.SetComponent(cache.ped, componentId, drawable, texture)
end

local function restoreProp(slotKey, propId)
	local drawable, texture

	if originalAppearance and originalAppearance.props and originalAppearance.props[propId] then
		local prop = originalAppearance.props[propId]
		drawable, texture = prop.drawable, prop.texture
	else
		local ok, prop = ViceCity.Appearance.GetProp(cache.ped, propId)
		if not ok then return end
		drawable, texture = prop.drawable, prop.texture
	end

	ViceCity.Appearance.SetProp(cache.ped, propId, drawable, texture)
end

local function hideComponent(componentId)
	local default = ViceCity.Appearance.GetDefaultComponent(cache.ped, componentId)
	if not default then return end

	ViceCity.Appearance.SetComponent(cache.ped, componentId, default.drawable, default.texture)
end

local function hideProp(propId)
	local default = ViceCity.Appearance.GetDefaultProp(cache.ped, propId)
	ViceCity.Appearance.SetProp(cache.ped, propId, default and default.drawable or -1, default and default.texture or 0)
end

local function toggleClothingVisibility(slotKey, hidden)
	local componentId = ViceCity.AppearanceSlotComponents[slotKey]
	local propId = ViceCity.AppearanceSlotProps[slotKey]

	if not componentId and not propId then return false end

	captureOriginalAppearance()

	if hidden then
		if componentId then hideComponent(componentId) else hideProp(propId) end
	else
		if componentId then restoreComponent(slotKey, componentId) else restoreProp(slotKey, propId) end
	end

	hiddenSlots[slotKey] = hidden or nil

	return true
end

Clothing = {
	ToggleClothingVisibility = toggleClothingVisibility,
	CaptureOriginalAppearance = captureOriginalAppearance,
	GetHiddenSlots = function() return hiddenSlots end,
}
