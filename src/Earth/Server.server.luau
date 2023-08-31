local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Probe = require(ReplicatedStorage.Probe)

Players.PlayerAdded:Connect(function(player)
	Probe:Fire("Hello", player, "bkmazefe")
end)
