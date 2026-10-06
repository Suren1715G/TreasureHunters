local ReplicatedStorage = game:GetService("ReplicatedStorage")

ReplicatedStorage:WaitForChild("Config", 10)

local TreasureService = require(script.Parent.Services.TreasureService)

TreasureService.Init()

print("[ServerMain] Treasure Hunters initialized")
