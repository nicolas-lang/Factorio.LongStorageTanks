if not data.raw["item-subgroup"]["cust-storage-tank"] then
	data:extend({
		{
			type = "item-subgroup",
			name = "cust-storage-tank",
			group = "logistics",
			order = "ze",
		},
	})
end