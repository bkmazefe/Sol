local Sol = require(game:GetService("ReplicatedStorage").Sol)

Sol:init():await()

game.Players.PlayerAdded:Connect(function(player: Player)
	--player.CharacterAdded:Wait()
	Sol.Probe:Fire("Hello", player, "bkmazefe")
end)
