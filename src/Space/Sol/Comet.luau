local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SolTypes = require(script.Parent.SolTypes)
local Promise = require(ReplicatedStorage.Packages.Promise)

local Comet = {}
Comet.__index = Comet

type Comet<T> = SolTypes.Comet<T>

local WEAK_KEYS_METATABLE = { __mode = "k" }

function Comet.new<T>(value: T): Comet<T>
	local self = setmetatable({
		stored_value = value,
		_connections = setmetatable({}, WEAK_KEYS_METATABLE),
	}, Comet)

	return self
end

function Comet.set<T>(self: Comet<T>, new_value: T, force_update: boolean?)
	if self.stored_value ~= new_value or force_update then
		self.stored_value = new_value
		self:_updateAll()
	end
end

function Comet.get<T>(self: Comet<T>): T
	return self.stored_value
end

function Comet._updateAll<T>(self: Comet<T>)
	for _, callback in self._connections do
		Promise.new(function()
			callback(self:get())
		end):catch(warn)
	end
end

function Comet.tie<T>(self: Comet<T>, callback: (value: T) -> any, on_disconnect: (() -> ())?): () -> ()
	self._connections[callback] = callback

	return function()
		self._connections[callback] = nil
		if on_disconnect ~= nil then
			on_disconnect()
		end
	end
end

function Comet.toString<T>(self: Comet<T>)
	return tostring(self:get())
end

return Comet.new
