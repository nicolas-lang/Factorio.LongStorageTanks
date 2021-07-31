local data_util = require("__nco-LongStorageTanks__/lib/data_util")
if mods["aai-containers"] then
	--
	local whTech = data.raw["technology"]["nco-LongStorageTanks"]
	table.insert(whTech.prerequisites,"aai-storehouse-base")
	whTech.unit.ingredients = data_util.getResearchUnitIngredients("aai-storehouse-base")
	whTech.unit.count = data_util.getResearchUnitCount("aai-storehouse-base")*2
end