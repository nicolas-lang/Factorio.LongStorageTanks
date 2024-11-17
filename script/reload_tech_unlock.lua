﻿-------------------------------------------------------------------------------------
--Enable Recipes if tech researched ( usefull if an update added new WH types)
-------------------------------------------------------------------------------------
local function reload_tech_unlock(technology_name)
	log("reload_tech_unlock")
	for _, force in pairs(game.forces) do
		if force.technologies[technology_name].researched then
			for _, effect in pairs(force.technologies[technology_name].prototype.effects) do
				if effect.type == "unlock-recipe" then
					force.recipes[effect.recipe].enabled = true
					log(effect.recipe .. " enabled")
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------
local function script_on_configuration_changed()
	reload_tech_unlock("nco-LongStorageTanks")
end
-------------------------------------------------------------------------------------
script.on_configuration_changed(script_on_configuration_changed)
