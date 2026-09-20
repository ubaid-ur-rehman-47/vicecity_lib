function SaveTargetOptions(targetType, invokingResource, identifier, options, extraData)
	if not ActiveTargets[targetType] then ActiveTargets[targetType] = {} end
	if not ActiveTargets[targetType][invokingResource] then ActiveTargets[targetType][invokingResource] = {} end
	ActiveTargets[targetType][invokingResource][#ActiveTargets[targetType][invokingResource] + 1] = {
		identifier = identifier,
		options =
			options
	}
	if targetType == 'model' and extraData and extraData.models then
		ActiveTargets[targetType][invokingResource][#ActiveTargets[targetType][invokingResource]].model = extraData
			.models
	end
end

function GenerateTargetIdentifier(targetType, invokingResource, compatibilityIdentifier)
	if not ActiveTargets[targetType] then ActiveTargets[targetType] = {} end
	if not ActiveTargets[targetType][invokingResource] then ActiveTargets[targetType][invokingResource] = {} end
	if compatibilityIdentifier then return compatibilityIdentifier end
	if not next(ActiveTargets[targetType][invokingResource]) then return 1 end
	if type(ActiveTargets[targetType][invokingResource][#ActiveTargets[targetType][invokingResource]].identifier) == 'number' then
		return ActiveTargets[targetType][invokingResource][#ActiveTargets[targetType][invokingResource]].identifier + 1
	end
	return #ActiveTargets[targetType][invokingResource] or 0 + 1
end