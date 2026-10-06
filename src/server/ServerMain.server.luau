local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage:WaitForChild("Config", 10)

local RemoteService = require(script.Parent.Services.RemoteService)
local TreasureService = require(script.Parent.Services.TreasureService)

-- Initialize services (remotes first so clients can find them)
RemoteService.Init()
TreasureService.Init()

-- ─────────────────────────────────────────────
-- Detector ping handler
-- ─────────────────────────────────────────────

local DETECTOR_RANGE = 50
local PING_COOLDOWN = 0.3
local lastPingTime: { [number]: number } = {}

local detectorPing = RemoteService.CreateFunction("DetectorPing")

detectorPing.OnServerInvoke = function(player: Player)
	local now = tick()
	local userId = player.UserId

	-- Rate limit
	if lastPingTime[userId] and (now - lastPingTime[userId]) < PING_COOLDOWN then
		return nil
	end
	lastPingTime[userId] = now

	local character = player.Character
	if not character then
		return nil
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return nil
	end

	local nodeId, distance = TreasureService.GetClosestNode(rootPart.Position, DETECTOR_RANGE)
	if not nodeId or not distance then
		return nil
	end

	local signal = math.clamp(1 - (distance / DETECTOR_RANGE), 0, 1)
	return { signal = signal }
end

-- Clean up on player leave
Players.PlayerRemoving:Connect(function(player)
	lastPingTime[player.UserId] = nil
end)

print("[ServerMain] Treasure Hunters initialized")
