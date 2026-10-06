local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DetectorHUD = {}

local screenGui: ScreenGui
local signalLabel: TextLabel
local signalBar: Frame
local beepLabel: TextLabel

local function getSignalColor(signal: number): Color3
	if signal < 0.01 then
		return Color3.fromRGB(80, 80, 90)
	elseif signal < 0.30 then
		return Color3.fromRGB(80, 200, 80)
	elseif signal < 0.60 then
		return Color3.fromRGB(230, 210, 40)
	elseif signal < 0.85 then
		return Color3.fromRGB(245, 140, 30)
	end
	return Color3.fromRGB(245, 50, 50)
end

local function create()
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DetectorHUD"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local frame = Instance.new("Frame")
	frame.Name = "Container"
	frame.Size = UDim2.new(0, 240, 0, 72)
	frame.Position = UDim2.new(0.5, -120, 0, 16)
	frame.AnchorPoint = Vector2.new(0, 0)
	frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 80)
	stroke.Thickness = 1.5
	stroke.Parent = frame

	signalLabel = Instance.new("TextLabel")
	signalLabel.Size = UDim2.new(0.6, 0, 0, 24)
	signalLabel.Position = UDim2.new(0, 14, 0, 8)
	signalLabel.BackgroundTransparency = 1
	signalLabel.Text = "SIGNAL: --"
	signalLabel.TextColor3 = Color3.fromRGB(80, 80, 90)
	signalLabel.TextXAlignment = Enum.TextXAlignment.Left
	signalLabel.Font = Enum.Font.GothamBold
	signalLabel.TextSize = 15
	signalLabel.Parent = frame

	beepLabel = Instance.new("TextLabel")
	beepLabel.Size = UDim2.new(0.4, -14, 0, 24)
	beepLabel.Position = UDim2.new(0.6, 0, 0, 8)
	beepLabel.BackgroundTransparency = 1
	beepLabel.Text = ""
	beepLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	beepLabel.TextXAlignment = Enum.TextXAlignment.Right
	beepLabel.Font = Enum.Font.GothamBold
	beepLabel.TextSize = 14
	beepLabel.TextTransparency = 1
	beepLabel.Parent = frame

	local barBg = Instance.new("Frame")
	barBg.Name = "BarBackground"
	barBg.Size = UDim2.new(1, -28, 0, 14)
	barBg.Position = UDim2.new(0, 14, 0, 40)
	barBg.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	barBg.BorderSizePixel = 0
	barBg.Parent = frame

	local barBgCorner = Instance.new("UICorner")
	barBgCorner.CornerRadius = UDim.new(0, 4)
	barBgCorner.Parent = barBg

	signalBar = Instance.new("Frame")
	signalBar.Name = "Fill"
	signalBar.Size = UDim2.new(0, 0, 1, 0)
	signalBar.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	signalBar.BorderSizePixel = 0
	signalBar.Parent = barBg

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 4)
	fillCorner.Parent = signalBar

	screenGui.Parent = playerGui
end

function DetectorHUD.Update(signal: number)
	if not signalLabel then
		return
	end

	local pct = math.floor(signal * 100)
	local color = getSignalColor(signal)

	signalLabel.Text = if pct > 0 then `SIGNAL: {pct}%` else "SIGNAL: --"
	signalLabel.TextColor3 = color
	signalBar.BackgroundColor3 = color

	TweenService:Create(signalBar, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(math.clamp(signal, 0, 1), 0, 1, 0),
	}):Play()
end

function DetectorHUD.Flash()
	if not beepLabel then
		return
	end

	beepLabel.Text = "BEEP"
	beepLabel.TextTransparency = 0

	TweenService:Create(beepLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 1,
	}):Play()
end

function DetectorHUD.Destroy()
	if screenGui then
		screenGui:Destroy()
		screenGui = nil
	end
end

create()

return DetectorHUD
