local ZoneConfig = {
	StarterShores = {
		displayName = "Starter Shores",
		maxNodes = 25,
		respawnDelay = { 15, 30 },
		minSpacing = 8,
		spawnHeightOffset = 100,
		minPlayerLevel = 0,
		lootPool = {
			"rusty_coin",
			"old_bottle",
			"bent_spoon",
			"broken_watch",
			"old_key",
			"silver_coin",
			"silver_ring",
			"old_compass",
			"pearl_necklace",
			"pirate_medal",
			"jeweled_dagger",
			"ancient_idol",
			"pirate_crown",
		},
	},

	-- Future zones — add here when ready:
	-- PirateCove   = { displayName = "Pirate Cove",   maxNodes = 30, ... },
	-- LostDesert   = { displayName = "Lost Desert",   maxNodes = 35, ... },
	-- FrozenLands  = { displayName = "Frozen Lands",  maxNodes = 30, ... },
	-- VolcanoIsland = { displayName = "Volcano Island", maxNodes = 25, ... },
}

return ZoneConfig
