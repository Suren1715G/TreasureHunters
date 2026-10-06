local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteService = {}

local remotesFolder: Folder

function RemoteService.Init()
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
	print("[RemoteService] Remotes folder created")
end

function RemoteService.CreateFunction(name: string): RemoteFunction
	local rf = Instance.new("RemoteFunction")
	rf.Name = name
	rf.Parent = remotesFolder
	return rf
end

function RemoteService.CreateEvent(name: string): RemoteEvent
	local re = Instance.new("RemoteEvent")
	re.Name = name
	re.Parent = remotesFolder
	return re
end

return RemoteService
