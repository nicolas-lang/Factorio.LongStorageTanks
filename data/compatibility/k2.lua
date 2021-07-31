local data_util = require("__nco-LongStorageTanks__/lib/data_util")

if mods["Krastorio2"] then
	local whTech = data.raw["technology"]["nco-LongStorageTanks"]
	if settings.startup["kr-containers"].value then
		table.insert(whTechFluid.prerequisites, "kr-containers")
	end
	table.insert(whTechFluid.prerequisites, "kr-steel-fluid-handling")
	whTechFluid.unit.ingredients = myGlobal.getResearchUnitIngredients("kr-steel-fluid-handling")
	whTechFluid.unit.count = myGlobal.getResearchUnitCount("kr-steel-fluid-handling")*2
end