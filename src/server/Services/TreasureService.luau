local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Config")
local TreasureConfig = require(Config:WaitForChild("TreasureConfig"))
local RarityConfig = require(Config:WaitForChild("RarityConfig"))
local ZoneConfig = require(Config:WaitForChild("ZoneConfig"))

local TreasureService = {}

-- Server-only state — never exposed to clients
local activeNodes: { [string]: any } = {}
local zoneNodeCounts: { [string]: number } = {}
local debugFolder: Folder? = nil
local debugParts: { [string]: BasePart } = {}

local DEBUG_ENABLED = true
local RAYCAST_DISTANCE = 500

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

-- ─────────────────────────────────────────────
-- Utilities
-- ─────────────────────────────────────────────

local function generateId(): string
	return HttpService:GenerateGUID(false)
end

local function randomInRange(min: number, max: number): number
	return min + math.random() * (max - min)
end

local function getRandomPositionInPart(part: BasePart): Vector3
	local size = part.Size
	local halfSize = size / 2
	local localX = math.random() * size.X - halfSize.X
	local localZ = math.random() * size.Z - halfSize.Z
	return part.CFrame:PointToWorldSpace(Vector3.new(localX, halfSize.Y, localZ))
end

local function findGround(origin: Vector3, excludeList: { Instance }): Vector3?
	raycastParams.FilterDescendantsInstances = excludeList
	local result = workspace:Raycast(origin, Vector3.new(0, -RAYCAST_DISTANCE, 0), raycastParams)
	if result then
		return result.Position
	end
	return nil
end

-- ─────────────────────────────────────────────
-- Weighted random treasure selection
-- ─────────────────────────────────────────────

function TreasureService._rollTreasure(zoneName: string): (string?, string?, number)
	local zone = ZoneConfig[zoneName]
	if not zone then
		return nil, nil, 0
	end

	local entries = {}
	local totalWeight = 0

	for _, treasureId in zone.lootPool do
		local treasure = TreasureConfig.GetTreasure(treasureId)
		if treasure then
			local rarityData = RarityConfig[treasure.rarity]
			if rarityData then
				local weight = rarityData.weight * (treasure.spawnWeight or 1.0)
				totalWeight += weight
				table.insert(entries, {
					treasureId = treasureId,
					rarity = treasure.rarity,
					weight = weight,
					depthRange = treasure.depthRange,
				})
			end
		end
	end

	if totalWeight <= 0 or #entries == 0 then
		return nil, nil, 0
	end

	local roll = math.random() * totalWeight
	local cumulative = 0

	for _, entry in entries do
		cumulative += entry.weight
		if roll <= cumulative then
			local depth = math.random(entry.depthRange[1], entry.depthRange[2])
			return entry.treasureId, entry.rarity, depth
		end
	end

	local last = entries[#entries]
	return last.treasureId, last.rarity, math.random(last.depthRange[1], last.depthRange[2])
end

-- ─────────────────────────────────────────────
-- Node creation
-- ─────────────────────────────────────────────

function TreasureService._createNode(
	zoneName: string,
	position: Vector3,
	treasureId: string,
	rarity: string,
	depth: number
)
	local nodeId = generateId()

	local node = {
		nodeId = nodeId,
		position = position,
		zone = zoneName,
		depth = depth,
		treasureId = treasureId,
		rarity = rarity,
		claimed = false,
		claimedBy = nil,
		spawnedAt = tick(),
	}

	activeNodes[nodeId] = node
	zoneNodeCounts[zoneName] = (zoneNodeCounts[zoneName] or 0) + 1

	if DEBUG_ENABLED then
		TreasureService._createDebugPart(node)
	end

	return node
end

-- ─────────────────────────────────────────────
-- Spawning
-- ─────────────────────────────────────────────

function TreasureService._spawnNodeInZone(zoneName: string): boolean
	local zonesFolder = workspace:FindFirstChild("TreasureZones")
	if not zonesFolder then
		warn("[TreasureService] No TreasureZones folder in Workspace")
		return false
	end

	local zonePart = zonesFolder:FindFirstChild(zoneName)
	if not zonePart or not zonePart:IsA("BasePart") then
		warn(`[TreasureService] Zone part '{zoneName}' not found`)
		return false
	end

	local zone = ZoneConfig[zoneName]
	if not zone then
		return false
	end

	local excludeList: { Instance } = { zonesFolder }
	if debugFolder then
		table.insert(excludeList, debugFolder)
	end

	local minSpacing = zone.minSpacing or 8
	local heightOffset = zone.spawnHeightOffset or 100

	for _ = 1, 10 do
		local topPos = getRandomPositionInPart(zonePart)
		topPos = Vector3.new(topPos.X, topPos.Y + heightOffset, topPos.Z)

		local groundPos = findGround(topPos, excludeList)
		if groundPos then
			local tooClose = false
			for _, existing in activeNodes do
				if existing.zone == zoneName then
					if (existing.position - groundPos).Magnitude < minSpacing then
						tooClose = true
						break
					end
				end
			end

			if not tooClose then
				local treasureId, rarity, depth = TreasureService._rollTreasure(zoneName)
				if treasureId and rarity then
					TreasureService._createNode(zoneName, groundPos, treasureId, rarity, depth)
					return true
				end
			end
		end
	end

	return false
end

-- ─────────────────────────────────────────────
-- Claiming (called by DigService later)
-- ─────────────────────────────────────────────

function TreasureService.ClaimNode(nodeId: string, playerId: number): any?
	local node = activeNodes[nodeId]
	if not node or node.claimed then
		return nil
	end

	node.claimed = true
	node.claimedBy = playerId

	local treasure = TreasureConfig.GetTreasure(node.treasureId)
	if not treasure then
		warn(`[TreasureService] Unknown treasure '{node.treasureId}'`)
		return nil
	end

	local weight = randomInRange(treasure.weightRange[1], treasure.weightRange[2])
	weight = math.floor(weight * 100) / 100

	local treasureInstance = {
		instanceId = generateId(),
		treasureId = node.treasureId,
		displayName = treasure.displayName,
		rarity = node.rarity,
		variant = nil,
		baseValue = treasure.baseValue,
		calculatedValue = treasure.baseValue,
		passiveIncome = treasure.passiveIncomeBase,
		weight = weight,
		originalDiscoverer = playerId,
		currentOwner = playerId,
		discoveredAt = os.time(),
		discoveredZone = node.zone,
	}

	-- Clean up node
	local zoneName = node.zone
	if DEBUG_ENABLED then
		TreasureService._removeDebugPart(nodeId)
	end
	activeNodes[nodeId] = nil
	zoneNodeCounts[zoneName] = math.max(0, (zoneNodeCounts[zoneName] or 1) - 1)

	-- Schedule respawn
	local zone = ZoneConfig[zoneName]
	if zone then
		local delay = randomInRange(zone.respawnDelay[1], zone.respawnDelay[2])
		task.delay(delay, function()
			if (zoneNodeCounts[zoneName] or 0) < zone.maxNodes then
				TreasureService._spawnNodeInZone(zoneName)
			end
		end)
	end

	return treasureInstance
end

-- ─────────────────────────────────────────────
-- Queries (for detector system)
-- ─────────────────────────────────────────────

function TreasureService.GetNearbyNodes(
	position: Vector3,
	radius: number
): { { nodeId: string, distance: number, depth: number } }
	local nearby = {}
	for nodeId, node in activeNodes do
		if not node.claimed then
			local dist = (node.position - position).Magnitude
			if dist <= radius then
				table.insert(nearby, {
					nodeId = nodeId,
					distance = dist,
					depth = node.depth,
				})
			end
		end
	end
	return nearby
end

function TreasureService.GetClosestNode(
	position: Vector3,
	maxDistance: number
): (string?, number?)
	local closestId: string? = nil
	local closestDist = maxDistance + 1

	for nodeId, node in activeNodes do
		if not node.claimed then
			local dist = (node.position - position).Magnitude
			if dist < closestDist then
				closestId = nodeId
				closestDist = dist
			end
		end
	end

	if closestId and closestDist <= maxDistance then
		return closestId, closestDist
	end
	return nil, nil
end

function TreasureService.GetNodeData(nodeId: string)
	return activeNodes[nodeId]
end

-- ─────────────────────────────────────────────
-- Debug visualization
-- ─────────────────────────────────────────────

function TreasureService._createDebugPart(node: any)
	if not debugFolder then
		debugFolder = Instance.new("Folder")
		debugFolder.Name = "_DebugTreasureNodes"
		debugFolder.Parent = workspace
	end

	local treasure = TreasureConfig.GetTreasure(node.treasureId)
	local rarityData = RarityConfig[node.rarity]
	local color = if rarityData then rarityData.color else Color3.new(1, 1, 1)

	local part = Instance.new("Part")
	part.Name = `Node_{node.nodeId:sub(1, 8)}`
	part.Size = Vector3.new(1.5, 0.3, 1.5)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = 0.3
	part.Shape = Enum.PartType.Cylinder
	part.CFrame = CFrame.new(node.position + Vector3.new(0, 0.15, 0))
		* CFrame.Angles(0, 0, math.rad(90))

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 200, 0, 80)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = part

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = if treasure then treasure.displayName else node.treasureId
	nameLabel.TextColor3 = color
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = billboard

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(1, 0, 0.5, 0)
	infoLabel.Position = UDim2.new(0, 0, 0.5, 0)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = `{node.rarity} · Depth {node.depth}`
	infoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	infoLabel.TextStrokeTransparency = 0.5
	infoLabel.TextScaled = true
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.Parent = billboard

	part.Parent = debugFolder
	debugParts[node.nodeId] = part
end

function TreasureService._removeDebugPart(nodeId: string)
	local part = debugParts[nodeId]
	if part then
		part:Destroy()
		debugParts[nodeId] = nil
	end
end

function TreasureService._clearAllDebugParts()
	for _, part in debugParts do
		part:Destroy()
	end
	table.clear(debugParts)
	if debugFolder then
		debugFolder:Destroy()
		debugFolder = nil
	end
end

function TreasureService.SetDebugEnabled(enabled: boolean)
	if enabled == DEBUG_ENABLED then
		return
	end
	DEBUG_ENABLED = enabled

	if enabled then
		for _, node in activeNodes do
			TreasureService._createDebugPart(node)
		end
		print("[TreasureService] Debug visualization ON")
	else
		TreasureService._clearAllDebugParts()
		print("[TreasureService] Debug visualization OFF")
	end
end

-- ─────────────────────────────────────────────
-- Status / diagnostics
-- ─────────────────────────────────────────────

function TreasureService.GetStatus(): { [string]: any }
	local totalNodes = 0
	local byZone: { [string]: number } = {}
	local byRarity: { [string]: number } = {}

	for _, node in activeNodes do
		totalNodes += 1
		byZone[node.zone] = (byZone[node.zone] or 0) + 1
		byRarity[node.rarity] = (byRarity[node.rarity] or 0) + 1
	end

	return {
		totalNodes = totalNodes,
		nodesByZone = byZone,
		nodesByRarity = byRarity,
		debugEnabled = DEBUG_ENABLED,
	}
end

function TreasureService.RespawnAllNodes()
	for nodeId in activeNodes do
		if DEBUG_ENABLED then
			TreasureService._removeDebugPart(nodeId)
		end
	end
	table.clear(activeNodes)
	table.clear(zoneNodeCounts)

	for zoneName, zoneData in ZoneConfig do
		local zonesFolder = workspace:FindFirstChild("TreasureZones")
		if zonesFolder and zonesFolder:FindFirstChild(zoneName) then
			zoneNodeCounts[zoneName] = 0
			for i = 1, zoneData.maxNodes do
				TreasureService._spawnNodeInZone(zoneName)
				if i % 5 == 0 then
					task.wait()
				end
			end
		end
	end

	local status = TreasureService.GetStatus()
	print(`[TreasureService] Respawned all — {status.totalNodes} nodes active`)
end

-- ─────────────────────────────────────────────
-- Initialization
-- ─────────────────────────────────────────────

function TreasureService.Init()
	print("[TreasureService] Initializing...")

	local zonesFolder = workspace:FindFirstChild("TreasureZones")
	if not zonesFolder then
		zonesFolder = Instance.new("Folder")
		zonesFolder.Name = "TreasureZones"
		zonesFolder.Parent = workspace
		warn("[TreasureService] Created TreasureZones folder — add zone parts to it")
	end

	local anyZoneFound = false
	for zoneName, zoneData in ZoneConfig do
		local zonePart = zonesFolder:FindFirstChild(zoneName)
		if zonePart and zonePart:IsA("BasePart") then
			anyZoneFound = true
			zoneNodeCounts[zoneName] = 0
			print(`[TreasureService] Spawning {zoneData.maxNodes} nodes in {zoneData.displayName}...`)

			local spawned = 0
			for i = 1, zoneData.maxNodes do
				if TreasureService._spawnNodeInZone(zoneName) then
					spawned += 1
				end
				if i % 5 == 0 then
					task.wait()
				end
			end
			print(`[TreasureService]   → {spawned}/{zoneData.maxNodes} spawned`)
		else
			warn(`[TreasureService] Zone part '{zoneName}' missing from TreasureZones`)
		end
	end

	if not anyZoneFound then
		warn("[TreasureService] No zone parts found! Add a Part named 'StarterShores' to Workspace > TreasureZones")
	end

	local status = TreasureService.GetStatus()
	print(`[TreasureService] Ready — {status.totalNodes} nodes active`)
	for rarity, count in status.nodesByRarity do
		print(`  {rarity}: {count}`)
	end
end

return TreasureService
