local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)

local Astro = {}
Astro.__index = Astro

export type Astro<T> = {
	new: (T) -> Astro<T>,
	set: (self: Astro<T>, new_value: T, force_update: boolean) -> (),
	get: (self: Astro<T>) -> T,
	tie: (self: Astro<T>, callback: (value: T) -> any, on_disconnect: (() -> ())?) -> () -> (),
	_updateAll: (self: Astro<T>) -> (),
	toString: (self: Astro<T>) -> (),

	stored_value: T,
	_connections: { [(value: T) -> any]: (value: T) -> any },
}

local WEAK_KEYS_METATABLE = { __mode = "k" }

function Astro.new<T>(value: T): Astro<T>
	local self = setmetatable({
		stored_value = value,
		_connections = setmetatable({}, WEAK_KEYS_METATABLE),
	}, Astro)

	return self
end

function Astro.set<T>(self: Astro<T>, new_value: T, force_update: boolean?)
	if self.stored_value ~= new_value or force_update then
		self.stored_value = new_value
		self:_updateAll()
	end
end

function Astro.get<T>(self: Astro<T>): T
	return self.stored_value
end

function Astro._updateAll<T>(self: Astro<T>)
	for _, callback in self._connections do
		Promise.new(function()
			callback(self:get())
		end):catch(warn)
	end
end

function Astro.tie<T>(self: Astro<T>, callback: (value: T) -> any, on_disconnect: (() -> ())?): () -> ()
	self._connections[callback] = callback

	return function()
		self._connections[callback] = nil
		if on_disconnect ~= nil then
			on_disconnect()
		end
	end
end

function Astro.toString<T>(self: Astro<T>)
	return tostring(self:get())
end

return Astro.new
