local EquipmentConfig = {}

EquipmentConfig.Detectors = {
	starter_detector = {
		displayName = "Starter Detector",
		rarity = "Common",
		range = 50,
		pingInterval = 0.5,
		revealDepth = false,
		revealRarity = false,
		beepSoundId = "",
	},
	-- Future detectors:
	-- bronze_detector = { range = 70, revealDepth = true, ... },
	-- silver_detector = { range = 90, revealDepth = true, revealRarity = true, ... },
}

EquipmentConfig.Shovels = {
	starter_shovel = {
		displayName = "Starter Shovel",
		rarity = "Common",
		digPower = 1,
		digSpeed = 1.0,
		maxDepth = 3,
	},
	-- Future shovels:
	-- iron_shovel = { digPower = 2, digSpeed = 1.2, maxDepth = 5, ... },
}

return EquipmentConfig
