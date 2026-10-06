local TreasureConfig = {}

TreasureConfig.Treasures = {
	-- ══════════════════════════════════════
	-- COMMON
	-- ══════════════════════════════════════
	rusty_coin = {
		displayName = "Rusty Coin",
		rarity = "Common",
		baseValue = 15,
		passiveIncomeBase = 1,
		weightRange = { 0.1, 0.3 },
		depthRange = { 1, 2 },
		description = "A weathered old coin, barely recognizable.",
		spawnWeight = 1.0,
	},
	old_bottle = {
		displayName = "Old Bottle",
		rarity = "Common",
		baseValue = 20,
		passiveIncomeBase = 1,
		weightRange = { 0.5, 1.0 },
		depthRange = { 1, 2 },
		description = "A glass bottle from a bygone era.",
		spawnWeight = 1.0,
	},
	bent_spoon = {
		displayName = "Bent Spoon",
		rarity = "Common",
		baseValue = 25,
		passiveIncomeBase = 2,
		weightRange = { 0.1, 0.2 },
		depthRange = { 1, 2 },
		description = "A tarnished silver spoon, bent out of shape.",
		spawnWeight = 1.0,
	},
	broken_watch = {
		displayName = "Broken Watch",
		rarity = "Common",
		baseValue = 35,
		passiveIncomeBase = 2,
		weightRange = { 0.2, 0.4 },
		depthRange = { 1, 3 },
		description = "A pocket watch frozen in time.",
		spawnWeight = 0.9,
	},

	-- ══════════════════════════════════════
	-- UNCOMMON
	-- ══════════════════════════════════════
	old_key = {
		displayName = "Old Key",
		rarity = "Uncommon",
		baseValue = 60,
		passiveIncomeBase = 4,
		weightRange = { 0.1, 0.2 },
		depthRange = { 2, 3 },
		description = "A mysterious key. What does it open?",
		spawnWeight = 1.0,
	},
	silver_coin = {
		displayName = "Silver Coin",
		rarity = "Uncommon",
		baseValue = 90,
		passiveIncomeBase = 5,
		weightRange = { 0.1, 0.3 },
		depthRange = { 2, 4 },
		description = "A gleaming silver coin in surprisingly good condition.",
		spawnWeight = 1.0,
	},
	silver_ring = {
		displayName = "Silver Ring",
		rarity = "Uncommon",
		baseValue = 125,
		passiveIncomeBase = 7,
		weightRange = { 0.05, 0.1 },
		depthRange = { 2, 4 },
		description = "An elegant silver ring with a faded inscription.",
		spawnWeight = 0.9,
	},

	-- ══════════════════════════════════════
	-- RARE
	-- ══════════════════════════════════════
	old_compass = {
		displayName = "Old Compass",
		rarity = "Rare",
		baseValue = 250,
		passiveIncomeBase = 12,
		weightRange = { 0.3, 0.5 },
		depthRange = { 3, 5 },
		description = "An antique compass that still points north.",
		spawnWeight = 1.0,
	},
	pearl_necklace = {
		displayName = "Pearl Necklace",
		rarity = "Rare",
		baseValue = 400,
		passiveIncomeBase = 18,
		weightRange = { 0.2, 0.4 },
		depthRange = { 3, 6 },
		description = "A string of luminous pearls from the deep sea.",
		spawnWeight = 0.8,
	},
	pirate_medal = {
		displayName = "Pirate Medal",
		rarity = "Rare",
		baseValue = 600,
		passiveIncomeBase = 25,
		weightRange = { 0.3, 0.6 },
		depthRange = { 4, 6 },
		description = "A medal awarded to a fearsome pirate captain.",
		spawnWeight = 0.7,
	},

	-- ══════════════════════════════════════
	-- EPIC
	-- ══════════════════════════════════════
	jeweled_dagger = {
		displayName = "Jeweled Dagger",
		rarity = "Epic",
		baseValue = 1500,
		passiveIncomeBase = 50,
		weightRange = { 0.8, 1.5 },
		depthRange = { 5, 7 },
		description = "A dagger encrusted with precious gems.",
		spawnWeight = 1.0,
	},
	ancient_idol = {
		displayName = "Ancient Idol",
		rarity = "Epic",
		baseValue = 2500,
		passiveIncomeBase = 80,
		weightRange = { 2.0, 4.0 },
		depthRange = { 5, 8 },
		description = "A mysterious idol radiating ancient power.",
		spawnWeight = 0.7,
	},

	-- ══════════════════════════════════════
	-- LEGENDARY
	-- ══════════════════════════════════════
	pirate_crown = {
		displayName = "Pirate Crown",
		rarity = "Legendary",
		baseValue = 8000,
		passiveIncomeBase = 200,
		weightRange = { 1.5, 3.0 },
		depthRange = { 7, 10 },
		description = "The legendary crown of the Pirate King.",
		spawnWeight = 1.0,
	},
}

function TreasureConfig.GetTreasure(treasureId: string)
	return TreasureConfig.Treasures[treasureId]
end

function TreasureConfig.GetTreasureIds(): { string }
	local ids = {}
	for id in TreasureConfig.Treasures do
		table.insert(ids, id)
	end
	return ids
end

return TreasureConfig
