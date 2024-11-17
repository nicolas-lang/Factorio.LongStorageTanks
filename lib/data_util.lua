﻿local data_util = {}
-------------------------------------------------------------------------------------
function data_util.round(f)
	return tonumber(math.floor(f + 0.5))
end

-------------------------------------------------------------------------------------
function data_util.trim(s)
	return s:match '^%s*(.*%S)' or ''
end

-------------------------------------------------------------------------------------
function data_util.csv_split(str, separator)
	local pattern = '([^' .. separator .. ']+)'
	local result = {}
	if str then
		for word in string.gmatch(str, pattern) do
			table.insert(result, word)
		end
	end
	return result
end

-------------------------------------------------------------------------------------
function data_util.has_value(tab, val)
	if val == nil then
		return false
	end
	if not tab then
		return false
	end
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

-------------------------------------------------------------------------------------
function data_util.getResearchUnitIngredients(technology_name)
	local technology = data_util.getTechnologyFromName(technology_name)
	if technology and next(technology) ~= nil then
		if technology.unit then
			if technology.unit.ingredients then
				return technology.unit.ingredients
			end
		end
	end
	return {}
end

-------------------------------------------------------------------------------------
function data_util.getTechnologyFromName(technology_name)
	for name, technology in pairs(data.raw.technology) do
		if name == technology_name then
			return technology
		end
	end
	return nil
end

-------------------------------------------------------------------------------------

function data_util.getResearchUnitCount(technology_name)
	local technology = data_util.getTechnologyFromName(technology_name)
	if technology and next(technology) ~= nil then
		if technology.unit then
			if technology.unit.count then
				return technology.unit.count
			end
		end
	end
	return 1
end

-------------------------------------------------------------------------------------
return data_util
