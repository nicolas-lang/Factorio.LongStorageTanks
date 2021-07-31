log("storagetanks-tech")
local myGlobal = require("__nco-LongStorageTanks__/lib/nco_data")
local data_util = require("__nco-LongStorageTanks__/lib/data_util")
--===================================================================================
--Register Tech
--===================================================================================
local techIcon = "__nco-LongStorageTanks__/graphics/icons/tech-long-storage-tanks.png"
local whTech = {
		type = "technology",
		name = "nco-LongStorageTanks",
		localised_name = {"technology-name.nco-LongStorageTanks"},
		localised_description = {"technology-description.nco-LongStorageTanks"},
		icon = techIcon,
		icon_size = myGlobal.imageInfo[techIcon].width,
		prerequisites = {
			"fluid-wagon"
		},
		effects = {},
		unit = {
			count = 0,
			ingredients = {},
			time = 30
		},
		order = "c-a"
	}
-------------------------------------------------------------------------------------
whTech.unit.ingredients = data_util.getResearchUnitIngredients("fluid-wagon")
whTech.unit.count = data_util.getResearchUnitCount("fluid-wagon")*4
-------------------------------------------------------------------------------------
for k,v in pairs(myGlobal.RegisteredStorageTanks) do
	table.insert(whTech.effects,{type = "unlock-recipe",recipe = v.name})
end
data:extend({whTech})
