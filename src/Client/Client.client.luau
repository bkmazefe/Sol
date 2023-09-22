local Sol = require(game:GetService("ReplicatedStorage").Sol)

Sol:init():await()

Sol.Probe:BindTo("Hello", function(message)
	print(message .. " says hi")
end)
