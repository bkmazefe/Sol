local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()

local Promise = require(ReplicatedStorage.Packages.Promise)
local SolTypes = require(script.SolTypes)

local Sol = {} :: SolTypes.Sol

function Sol.init(self: SolTypes.Sol)
	return Promise.new(function(resolve)
		if IsServer then
			require(script.SolServer)(self)
		else
			script.SolServer:Destroy()
			require(script.SolClient)(self)
		end
		self.Probe = require(script.Probe)
		self.Comet = require(script.Comet)

		resolve("Sol initialized")
	end)
end

function Sol.import(self: SolTypes.Sol, moduleName: string): SolTypes.Module
	return self[moduleName]
end

return Sol :: SolTypes.Sol
