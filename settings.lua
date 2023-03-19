data:extend({
	{
		type = "string-setting",
		name = "storage-tank-sizes",
		setting_type = "startup",
		order = "A",
		default_value = "2;4;6",
	},
	{
		type = "int-setting",
		name = "st-wagon-size",
		order = "B",
		setting_type = "startup",
		default_value = 25000,
	},
	{
		type = "int-setting",
		name = "st-storage-multiplier",
		order = "C",
		setting_type = "startup",
		default_value = 2,
	},
	{
		type = "bool-setting",
		name = "st-limit-chest-size",
		order = "G",
		setting_type = "startup",
		default_value = true,
	},
})
