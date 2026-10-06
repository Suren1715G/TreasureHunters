local RarityConfig = {
	Common = {
		order = 1,
		color = Color3.fromRGB(180, 180, 180),
		displayColor = Color3.fromRGB(200, 200, 200),
		weight = 45,
		valueMultiplier = 1.0,
		announcement = false,
	},
	Uncommon = {
		order = 2,
		color = Color3.fromRGB(30, 200, 30),
		displayColor = Color3.fromRGB(50, 220, 50),
		weight = 30,
		valueMultiplier = 1.0,
		announcement = false,
	},
	Rare = {
		order = 3,
		color = Color3.fromRGB(30, 100, 255),
		displayColor = Color3.fromRGB(60, 130, 255),
		weight = 15,
		valueMultiplier = 1.0,
		announcement = false,
	},
	Epic = {
		order = 4,
		color = Color3.fromRGB(160, 30, 255),
		displayColor = Color3.fromRGB(180, 60, 255),
		weight = 7,
		valueMultiplier = 1.0,
		announcement = true,
	},
	Legendary = {
		order = 5,
		color = Color3.fromRGB(255, 170, 0),
		displayColor = Color3.fromRGB(255, 200, 50),
		weight = 3,
		valueMultiplier = 1.0,
		announcement = true,
	},
	-- Future rarities — add here when ready:
	-- Mythic   = { order = 6, color = Color3.fromRGB(255, 50, 100),  weight = 1,   ... },
	-- Exotic   = { order = 7, color = Color3.fromRGB(0, 255, 200),   weight = 0.5, ... },
	-- Secret   = { order = 8, color = Color3.fromRGB(20, 20, 20),    weight = 0.1, ... },
}

local sorted = {}
for name, data in RarityConfig do
	if typeof(data) == "table" and data.order then
		table.insert(sorted, name)
	end
end
table.sort(sorted, function(a, b)
	return RarityConfig[a].order < RarityConfig[b].order
end)

RarityConfig._sorted = sorted

return RarityConfig
