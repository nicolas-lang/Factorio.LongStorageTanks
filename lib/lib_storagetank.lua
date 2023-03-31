local util = require("util")
local lib_storagetank = {}
local myGlobal = require("__nco-LongStorageTanks__/lib/nco_data")
--=================================================================================--
function lib_storagetank.getStorageTankData(unitSize,sizeScaling)
	sizeScaling = sizeScaling or 0
	local gridSize = unitSize*6 + math.max(0,unitSize-1)
	local storageTankNameBase = "cust-storage-tank"
	local storageTankSizeName = string.format("%03d" , gridSize)
	local storageTankSizeNameAdvanced = string.format("%d-%d" ,unitSize,gridSize)
	local storageTankName = string.format("%s-%s", storageTankNameBase, storageTankSizeName)
	local sortOrder = string.format("a[%d-%s]", 0, storageTankSizeName)

	local storageTankCapacity = math.max(unitSize * sizeScaling, 1)
	if settings.startup["st-limit-chest-size"].value then
		storageTankCapacity = math.min(storageTankCapacity, 1500000)
	end

	local storageTankHealth = 500 + unitSize * 250
	return {
			storageTankNameBase = storageTankNameBase,
			storageTankSizeName = storageTankSizeName,
			storageTankSizeNameAdvanced = storageTankSizeNameAdvanced,
			storageTankName = storageTankName,
			gridSize = gridSize,
			storageTankCapacity = storageTankCapacity,
			storageTankHealth = storageTankHealth,
			sortOrder = sortOrder
		}
end
-------------------------------------------------------------------------------------
function lib_storagetank.getStorageTankIcon(unitSize)
	local storageTankIconImage = "__nco-LongStorageTanks__/graphics/icons/long-storage-tank.png"
	local storageTankIconImageSize = "__nco-LongStorageTanks__/graphics/icons/Numbers/icon_" .. tostring(unitSize) .. ".png"
	local Icons = {
		{
			icon = storageTankIconImage,
			icon_size = myGlobal.imageInfo[storageTankIconImage].width,
		},
		{
			icon = storageTankIconImageSize,
			icon_size = myGlobal.imageInfo[storageTankIconImageSize].width,
		}
	}
	return Icons
end
-------------------------------------------------------------------------------------
function lib_storagetank.getParentSize(unitSize)
	local parentSize = -1
	local sizeList = myGlobal.StorageTankSizes
	for k,v in pairs(sizeList) do
		if v < unitSize then
			parentSize = v
		else
			return parentSize
		end
	end
	return -1
end
-------------------------------------------------------------------------------------
function lib_storagetank.getTankparent(unitSize)
	local parentSize = lib_storagetank.getParentSize(unitSize)
	if parentSize>0 then
		return lib_storagetank.getStorageTankData(parentSize,0,"proxy")
	end
end
-------------------------------------------------------------------------------------
function lib_storagetank.getStorageTankIngredients(unitSize)
	local initialScore = math.pow(2,unitSize)*55
	local resourceScore = initialScore
	local ingredients ={}
	local storageTankParent = lib_storagetank.getTankparent(unitSize)
	if storageTankParent then
		table.insert(ingredients, {storageTankParent.storageTankName,1})
		resourceScore = resourceScore / 2
	end
	local resourceCount = math.min(5,unitSize)
	local data
	data = lib_storagetank.getStorageTankIngredientsByScore(resourceScore,myGlobal.baseIngredients,resourceCount)

	local additionalIngredients = data.ingredients
	for k,v in pairs(additionalIngredients) do
		table.insert(ingredients, v)
	end
	return ingredients
end
-------------------------------------------------------------------------------------
function lib_storagetank.getStorageTankIngredientsByScore(resourceScore,resourceTable,maxcount)
	--Tank Wert unitSize^2*skalar
	--Immer ein storageTank der nächst kleineren Größe
	--Schleife (max 6 resourcen)
	--	50% restwert berechnen - Teuerste Resource für den Preis verwenden ( gerundet auf pseudo-stack )
	local ingredients = {}
	local i=0
	for k,res in pairs(resourceTable) do
		--log("checking resource: "..serpent.block( res, {comment = false, numformat = '%1.8g' } ))
		if resourceScore>res.val then
			local cnt  = resourceScore/res.val
			cnt = math.floor(cnt/res.count)*res.count
			cnt = math.min(cnt,res.limit)
			if cnt>0 and i < maxcount then
				i = i + 1
				resourceScore = resourceScore - res.val*cnt
				table.insert(ingredients, {res.name,cnt})
			end
		end
	end
	return {ingredients=ingredients,resourceScore=resourceScore}
end
--=================================================================================--
function lib_storagetank.buildSpriteLayer(unitSize,direction)
	local imageFile, imageFileHr, shft
	local entityData = lib_storagetank.getStorageTankData(unitSize,0,direction)
	local layers = {}
	local bgTint = {r = 0.1, g = 0.1, b = 0.1, a = 0.8}

	-------------------------------------------------------------------------------------
	--left background
	-------------------------------------------------------------------------------------
	imageFile = "__nco-LongStorageTanks__/graphics/entity/storage-tank-" .. direction .. "-bg-left.png"
	shft = {
		-(32*entityData.gridSize/2) + (32*3/2),
		5
	}
	if direction == "v" then
		shft = {0,shft[1]+2}
	end
	table.insert(layers,{
			filename = imageFile,
			width = myGlobal.imageInfo[imageFile].width,
			height = myGlobal.imageInfo[imageFile].height,
			shift = util.by_pixel(shft[1],shft[2]),
			scale = 0.25,
			tint = util.table.deepcopy(bgTint)
		})
	-------------------------------------------------------------------------------------
	--middle background
	-------------------------------------------------------------------------------------
	imageFile = "__nco-LongStorageTanks__/graphics/entity/storage-tank-" .. direction .. "-bg-mid.png"
	if unitSize > 1 then
		for i=1,math.max(0,unitSize-1) do
			shft = {
				-(32*entityData.gridSize/2) + (32*6.5) + ((i-1)*32*7),
				5
			}
			if direction == "v" then
				shft = {0,shft[1]+2}
			end
			table.insert(layers,{
				filename = imageFile,
				width = myGlobal.imageInfo[imageFile].width,
				height = myGlobal.imageInfo[imageFile].height,
				shift = util.by_pixel(shft[1],shft[2]),
				scale = 0.25,
				tint = util.table.deepcopy(bgTint)
			})
		end
	end
	-------------------------------------------------------------------------------------
	--right background
	-------------------------------------------------------------------------------------
	imageFile = "__nco-LongStorageTanks__/graphics/entity/storage-tank-" .. direction .. "-bg-right.png"
	shft = {
		(32*entityData.gridSize/2) - (32*3/2),
		5
	}
	if direction == "v" then
		shft = {0,shft[1]+2}
	end
	table.insert(layers,{
		filename = imageFile,
		width = myGlobal.imageInfo[imageFile].width,
		height = myGlobal.imageInfo[imageFile].height,
		shift = util.by_pixel(shft[1],shft[2]),
		scale = 0.25,
		tint = util.table.deepcopy(bgTint)
	})
	-------------------------------------------------------------------------------------
	--pipes
	-------------------------------------------------------------------------------------
	imageFile = "__nco-LongStorageTanks__/graphics/entity/storage-tank-" .. direction .. "-building.png"
	imageFileHr = "__nco-LongStorageTanks__/graphics/entity/hr/storage-tank-" .. direction .. "-building.png"
	for i=1,unitSize do
		shft = {
			-(32*entityData.gridSize/2) + (32*6/2 + 5) + ((i-1)*32*7)-5,
			0
		}
		if direction == "v" then
			shft = {0,shft[1]}
		end
		table.insert(layers,{
			filename = imageFile,
			width = myGlobal.imageInfo[imageFile].width,
			height = myGlobal.imageInfo[imageFile].height,
			shift = util.by_pixel(shft[1],shft[2]),
			scale = 1,
			hr_version = {
				filename = imageFileHr,
				width = myGlobal.imageInfo[imageFileHr].width,
				height = myGlobal.imageInfo[imageFileHr].height,
				shift = util.by_pixel(shft[1],shft[2]),
				scale = 0.25,
			}
		})
	end
	-------------------------------------------------------------------------------------
	--sidepipes
	-------------------------------------------------------------------------------------
	local pipe_directions = {"left","right"}
	if direction == "v" then
		pipe_directions = {"up","down"}
	end
	for i, pd in pairs(pipe_directions) do
		shft = {
			-(32*entityData.gridSize/2) + 16,
			-(32*0.5)
		}
		if i>1 then
			shft = {-shft[1],-shft[2]}
		end
		if direction == "v" then
			shft = {-shft[2],shft[1]}
		end
		imageFile = "__nco-LongStorageTanks__/graphics/entity/pipe-to-ground/pipe-to-ground-" .. pd .. ".png"
		imageFileHr = "__nco-LongStorageTanks__/graphics/entity/hr/pipe-to-ground/hr-pipe-to-ground-" .. pd .. ".png"
		table.insert(layers,{
			filename = imageFile,
			width = myGlobal.imageInfo[imageFile].width,
			height = myGlobal.imageInfo[imageFile].height,
			shift = util.by_pixel(shft[1],shft[2]),
			scale = 1,
			hr_version = {
				filename = imageFileHr,
				width = myGlobal.imageInfo[imageFileHr].width,
				height = myGlobal.imageInfo[imageFileHr].height,
				shift = util.by_pixel(shft[1],shft[2]),
				scale = 0.5
			}
		})
	end
	--log(serpent.block( layers, {comment = false, numformat = '%1.8g', compact = true } ))
	return util.table.deepcopy(layers)
end

return lib_storagetank
