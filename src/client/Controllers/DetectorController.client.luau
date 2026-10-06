local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DetectorHUD = require(script.Parent.Parent.UI.DetectorHUD)

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local DetectorPing = Remotes and Remotes:WaitForChild("DetectorPing", 10)

if not DetectorPing then
	warn("[DetectorController] DetectorPing remote not found")
	return
end

-- Signal state
local targetSignal = 0
local displaySignal = 0
local lastBeepTime = 0

-- Beep sound (optional audio — set SoundId for audio beeps)
local beepSound = Instance.new("Sound")
beepSound.Name = "DetectorBeep"
beepSound.Volume = 0.5
beepSound.SoundId = ""
beepSound.Parent = player:WaitForChild("PlayerGui")

local function getBeepInterval(signal: number): number?
	if signal <= 0.01 then
		return nil
	end
	if signal < 0.15 then
		return 1.8
	elseif signal < 0.30 then
		return 1.2
	elseif signal < 0.50 then
		return 0.7
	elseif signal < 0.70 then
		return 0.4
	elseif signal < 0.85 then
		return 0.2
	elseif signal < 0.95 then
		return 0.1
	end
	return 0.06
end

-- Ping server in a separate thread (InvokeServer yields)
task.spawn(function()
	while true do
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local ok, result = pcall(function()
				return DetectorPing:InvokeServer()
			end)

			if ok and result then
				targetSignal = result.signal or 0
			else
				targetSignal = 0
			end
		else
			targetSignal = 0
		end

		task.wait(0.5)
	end
end)

-- HUD + beep update every frame
RunService.Heartbeat:Connect(function(dt: number)
	-- Smooth signal interpolation
	displaySignal += (targetSignal - displaySignal) * math.min(dt * 10, 1)
	if displaySignal < 0.005 then
		displaySignal = 0
	end

	DetectorHUD.Update(displaySignal)

	-- Beep timing uses raw target signal for crisp rhythm
	local now = tick()
	local interval = getBeepInterval(targetSignal)
	if interval and (now - lastBeepTime >= interval) then
		lastBeepTime = now
		DetectorHUD.Flash()

		if beepSound.SoundId ~= "" then
			beepSound.PlaybackSpeed = 0.8 + targetSignal * 0.7
			beepSound:Play()
		end
	end
end)
