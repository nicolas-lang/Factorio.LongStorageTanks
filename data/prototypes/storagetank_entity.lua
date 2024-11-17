--log("storagetanks-entity")
local util = require("util")
local myGlobal = require("__nco-LongStorageTanks__/lib/nco_data")
local data_util = require("__nco-LongStorageTanks__/lib/data_util")
local lib_storagetank = require("__nco-LongStorageTanks__/lib/lib_storagetank")
local pipecoverspictures = _G.pipecoverspictures --just a fix for lua style check
local tankSizeScaling = settings.startup["st-wagon-size"].value * settings.startup["st-storage-multiplier"].value
-------------------------------------------------------------------------------------
local function makestoragetank(unitSize)
	-------------------------------------------------------------------------------------
	-- Configure Details
	-------------------------------------------------------------------------------------
	local storageTankData = lib_storagetank.getStorageTankData(unitSize, tankSizeScaling)
	local storageTankSizeA = storageTankData.gridSize
	local storageTankSizeB = 1.98
	local fluid_h = 1
	local fluid_base_area = storageTankData.storageTankCapacity / fluid_h / 100
	log("registering storagetank " .. storageTankData.storageTankName)
	table.insert(myGlobal["RegisteredStorageTanks"], { name = storageTankData.storageTankName })
	--===================================================================================
	--Define Recipe
	--===================================================================================
	local storageTankRec = {
		type = "recipe",
		name = storageTankData.storageTankName,
		energy_required = 20,
		enabled = "false",
		ingredients = lib_storagetank.getStorageTankIngredients(unitSize),
		result = storageTankData.storageTankName,
		icons = lib_storagetank.getStorageTankIcon(unitSize),
		subgroup = "cust-storage-tank",
		order = storageTankData.sortOrder,
		localised_name = { "recipe-name.cust-storage-tank", storageTankData.storageTankSizeNameAdvanced }
	}
	--===================================================================================
	--Define Item
	--===================================================================================
	local storageTankItm = {
		type = "item",
		name = storageTankData.storageTankName,
		icons = lib_storagetank.getStorageTankIcon(unitSize),
		subgroup = "cust-storage-tank",
		order = storageTankData.sortOrder,
		place_result = storageTankData.storageTankName,
		stack_size = 5,
		localised_name = { "item-name.cust-storage-tank", storageTankData.storageTankSizeNameAdvanced },
		localised_description = "",
	}
	--===================================================================================
	--Define Entity
	--===================================================================================
	local storageTankEnt = {
		name = storageTankData.storageTankName,
		type = "storage-tank",
		minable = { mining_time = 5, result = storageTankData.storageTankName },
		two_direction_only = true,
		corpse = "storage-tank-remnants",
		dying_explosion = "storage-tank-explosion",
		flags = {
			"placeable-player",
			"player-creation"
		},
		icons = lib_storagetank.getStorageTankIcon(unitSize),
		max_health = 500,
		fluid_box = {
			base_area = fluid_base_area,
			height = fluid_h,
			base_level = 0,
			pipe_connections = {},
			pipe_covers = pipecoverspictures(),
		},
		flow_length_in_ticks = 1,

		pictures = {
			flow_sprite = { filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png", height = 1, width = 1 },
			fluid_background = { filename = "__base__/graphics/entity/storage-tank/fluid-background.png", height = 1, width = 1 },
			gas_flow = { filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png", height = 1, width = 1 },
			window_background = { filename = "__base__/graphics/entity/storage-tank/window-background.png", height = 1, width = 1 },
			picture = { layers = {} },
		},
		collision_box = { { -(storageTankSizeA / 2 - 0.01), -(storageTankSizeB / 2 - 0.01) }, { (storageTankSizeA / 2 - 0.01), (storageTankSizeB / 2 - 0.01) } },
		selection_box = { { -(storageTankSizeA / 2), -(storageTankSizeB / 2) }, { (storageTankSizeA / 2), (storageTankSizeB / 2) } },
		window_bounding_box = { { 0, 0 }, { 0, 0 } },
		working_sound = util.table.deepcopy(data.raw["storage-tank"]["storage-tank"]["working_sound"]),
		vehicle_impact_sound = { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		circuit_wire_connection_points = circuit_connector_definitions["storage-tank"].points,
		circuit_connector_sprites = circuit_connector_definitions["storage-tank"].sprites,
		circuit_wire_max_distance = 15,
		localised_name = { "entity-name.cust-storage-tank", storageTankData.storageTankSizeNameAdvanced },
		localised_description = { "entity-description.cust-storage-tank", string.format("%dk", data_util.round(storageTankData.storageTankCapacity / 1000)) },
	}
	--===================================================================================
	-- Sprites
	--===================================================================================

	local mySpriteH = lib_storagetank.buildSpriteLayer(unitSize, "h")
	local mySpriteV = lib_storagetank.buildSpriteLayer(unitSize, "v")
	storageTankEnt.pictures.picture = { north = {}, south = {}, west = {}, east = {} }
	storageTankEnt.pictures.picture.north.layers = util.table.deepcopy(mySpriteH)
	storageTankEnt.pictures.picture.south.layers = util.table.deepcopy(mySpriteH)
	storageTankEnt.pictures.picture.west.layers = util.table.deepcopy(mySpriteV)
	storageTankEnt.pictures.picture.east.layers = util.table.deepcopy(mySpriteV)
	--===================================================================================
	-- FluidBox:Pipes
	--===================================================================================
	local pipeConnection
	for i = 0, (unitSize - 1) do
		for x = 0, 2 do
			pipeConnection = { position = { data_util.round((-storageTankSizeA / 2) + (i * 7) + (2 * x)), data_util.round(storageTankSizeB / 2) + 0.5 } }
			table.insert(storageTankEnt.fluid_box.pipe_connections, pipeConnection)
			pipeConnection = { position = { data_util.round((-storageTankSizeA / 2) + (i * 7) + (2 * x) + 1), -data_util.round(storageTankSizeB / 2) - 0.5 } }
			table.insert(storageTankEnt.fluid_box.pipe_connections, pipeConnection)
		end
	end

	--side connections
	pipeConnection = { position = { -data_util.round(storageTankSizeA) / 2 - 0.5, -data_util.round(storageTankSizeB) / 4 } }
	table.insert(storageTankEnt.fluid_box.pipe_connections, pipeConnection)
	pipeConnection = { position = { data_util.round(storageTankSizeA) / 2 + 0.5, data_util.round(storageTankSizeB) / 4 } }
	table.insert(storageTankEnt.fluid_box.pipe_connections, pipeConnection)

	--===================================================================================
	--Register storagetank
	--===================================================================================
	local storageTankLog = util.table.deepcopy(storageTankEnt)
	storageTankLog.circuit_wire_connection_points = nil
	storageTankLog.circuit_connector_sprites = nil
	storageTankLog.working_sound = nil
	storageTankLog.fluid_box.pipe_covers = nil
	--log(storageTankEnt.name..":"..serpent.block( storageTankLog, {comment = false, numformat = '%1.8g' } ))

	data:extend({ storageTankItm })
	data:extend({ storageTankEnt })
	data:extend({ storageTankRec })
	log("storageTankItm:" .. storageTankItm.name)
	log("storageTankEnt:" .. storageTankEnt.name)
	log("storageTankRec:" .. storageTankRec.name)
end -- function makestoragetank

--===================================================================================
-- call storageTank Generator based on mod settings
--===================================================================================
myGlobal["StorageTankSizes"] = {}
for _, size in pairs(data_util.csv_split(settings.startup["storage-tank-sizes"].value, ';')) do
	local sizeValue = tonumber(data_util.trim(size))
	if (
			sizeValue
			and sizeValue < 32
			and not data_util.has_value(myGlobal["StorageTankSizes"], sizeValue)
		) then
		table.insert(myGlobal["StorageTankSizes"], sizeValue)
	else
		log("invalid size: " .. sizeValue)
	end
end
-------------------------------------------------------------------------------------
for _, size in pairs(myGlobal["StorageTankSizes"]) do
	makestoragetank(size);
end
