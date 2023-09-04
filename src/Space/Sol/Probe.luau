local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Promise = require(ReplicatedStorage.Packages.Promise)

type Probe = {
	Bindings: { [string]: { (...any) -> any } },
	Probes: { event: RemoteEvent, func: RemoteFunction },
	_setup: (self: Probe) -> (),
	_server: (self: Probe) -> (),
	_client: (self: Probe) -> (),
	new: () -> Probe,
	BindTo: (self: Probe, event_name: string, callback: (...any) -> ()) -> (),
	AssignTo: (self: Probe, event_name: string, callback: (...any) -> any) -> (),
	Fire: (self: Probe, event_name: string, player_or_arg1: Player | any, ...any) -> (),
	FireAll: (self: Probe, event_name: string, ...any) -> (),
	Invoke: (self: Probe, event_name: string, player_or_arg1: Player | any, ...any) -> any,
}

local SETTINGS = {
	DoUntilOutOfScope = 50,
}

local Probe = {}
Probe.__index = Probe

local function pack(v1: any, v2: any, v3: any, v4: any, v5: any, v6: any, v7: any, v8: any, v9: any)
	return {
		[1] = v1,
		[2] = v2,
		[3] = v3,
		[4] = v4,
		[5] = v5,
		[6] = v6,
		[7] = v7,
		[8] = v8,
		[9] = v9,
	}
end
local function unpack(t: { any }): ...any
	return t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9]
end

-- connect to remotes
function Probe._client(self: Probe)
	-- remoteevent
	self.Probes.event.OnClientEvent:Connect(function(event_name: string, ...: any)
		local compressedVararg = pack(...)
		for i = 1, 50 do
			if self.Bindings[event_name] ~= nil then
				for _, callback in self.Bindings[event_name] do
					Promise.new(function(resolve, reject)
						callback(unpack(compressedVararg))
						resolve()
					end):catch(function(err)
						warn(err)
					end)
				end

				break
			end

			task.wait()
		end
	end)
	self.Probes.func.OnClientInvoke = function(event_name: string, ...: any)
		for i = 1, 50 do
			local callback = self.Bindings["_" .. event_name][1]
			if callback ~= nil then
				return callback(...)
			end

			task.wait()
		end
		error("No listeners has been found for [" .. event_name .. "]")
	end
end

-- connect to remotes
function Probe._server(self: Probe)
	self.Probes.event.OnServerEvent:Connect(function(player: Player, event_name: string, ...: any)
		local compressedVararg = pack(...)
		if self.Bindings[event_name] ~= nil then
			for _, callback in self.Bindings[event_name] do
				Promise.new(function(resolve, reject)
					callback(unpack(compressedVararg))
					resolve()
				end):catch(function(err)
					warn(err)
				end)
			end
		end
	end)
	self.Probes.func.OnServerInvoke = function(player: Player, event_name: string, ...: any)
		local callback = self.Bindings["_" .. event_name][1]
		if callback ~= nil then
			return callback(...)
		else
			error("No listeners has been found for [" .. event_name .. "]")
		end
	end
end

function Probe._setup(self: Probe)
	return Promise.new(function(resolve, reject)
		if RunService:IsServer() == true then
			self.Probes.event = Instance.new("RemoteEvent")
			self.Probes.event.Parent = script
			self.Probes.func = Instance.new("RemoteFunction")
			self.Probes.func.Parent = script
			self:_server()
			resolve()
		else
			for i = 1, SETTINGS.DoUntilOutOfScope do
				self.Probes.event = script:FindFirstChild("RemoteEvent")
				self.Probes.func = script:FindFirstChild("RemoteFunction")

				if self.Probes.event and self.Probes.func then
					self:_client()
					resolve()
					break
				end
				task.wait()
			end

			reject("Promise has fallen out of scope")
		end
	end)
end

function Probe.new(): Probe
	local self = setmetatable({}, Probe)
	self.Bindings = {}
	self.Probes = {}

	self:_setup():await()

	return self
end

function Probe.BindTo(self: Probe, event_name: string, callback: (...any) -> ())
	if self.Bindings[event_name] == nil then
		self.Bindings[event_name] = {}
	end
	table.insert(self.Bindings[event_name], callback)
end

function Probe.AssignTo(self: Probe, event_name: string, callback: (...any) -> any)
	if self.Bindings[event_name] == nil then
		self.Bindings["_" .. event_name][1] = callback
	end
end

function Probe.Fire(self: Probe, event_name: string, player_or_arg1: Player | any, ...: any)
	local compressedVararg = pack(...)
	if RunService:IsServer() == true then
		Promise.new(function(resolve, reject)
			self.Probes.event:FireClient(player_or_arg1, event_name, unpack(compressedVararg))
		end):catch(function(err)
			warn(err)
		end)
	else
		self.Probes.event:FireServer(event_name, player_or_arg1, ...)
	end
end

function Probe.FireAll(self: Probe, event_name: string, ...: any)
	if RunService:IsServer() == true then
		self.Probes.event:FireAllClients(event_name, ...)
	else
		warn("Can't run :FireAll on Client")
	end
end

function Probe.Invoke(self: Probe, event_name: string, player_or_arg1: Player | any, ...: any): any
	if RunService:IsServer() == true then
		return self.Probes.func:InvokeClient(player_or_arg1, event_name, ...)
	else
		return self.Probes.func:InvokeServer(event_name, player_or_arg1, ...)
	end
end

return Probe.new()
