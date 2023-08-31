local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Astro = require(ReplicatedStorage.Astro)
local Probe = require(ReplicatedStorage.Probe)

Probe:BindTo("Hello", function(message)
	print(message .. " says hi")
end)

local numberState = Astro(1)
local disconnect = numberState:tie(function(value)
	print(value)
end)

task.wait(5)
numberState:set(110)
disconnect()
task.wait(5)
numberState:set(10)

warn(numberState:toString())
