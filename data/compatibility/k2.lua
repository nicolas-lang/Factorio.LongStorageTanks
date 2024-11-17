local data_util = require("__nco-LongStorageTanks__/lib/data_util")

if mods["Krastorio2"] then
	local whTechFluid = data.raw["technology"]["nco-LongStorageTanks"]
	if settings.startup["kr-containers"] and settings.startup["kr-containers"].value then
		table.insert(whTechFluid.prerequisites, "kr-containers")
	end
	table.insert(whTechFluid.prerequisites, "kr-steel-fluid-handling")
	whTechFluid.unit.ingredients = data_util.getResearchUnitIngredients("kr-steel-fluid-handling")
	whTechFluid.unit.count = data_util.getResearchUnitCount("kr-steel-fluid-handling") * 2
end
