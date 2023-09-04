local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Promise = require(ReplicatedStorage.Packages.Promise)
local SolTypes = require(script.Parent.SolTypes)

local function _wrapThread(f, ...)
	task.spawn(f, ...)
end

local function initModules(folder: Folder, object)
	return Promise.new(function(resolve)
		for _, v in folder:GetChildren() do
			Promise.new(function(resolve)
				if not string.match(v.Name, "_ignore") then
					object[v.Name] = require(v)
				end
				resolve(v.Name .. " has succesfully loaded.")
			end)
				:andThen(function(body)
					print(body)
				end)
				:catch(function(err)
					warn(v.Name .. " has failed to load. " .. err)
				end)
				:await()
		end

		resolve("Sol has loaded.")
	end)
end

local function init(self: SolTypes.Sol)
	local services = ServerScriptService.Services
	local handlers = ServerScriptService.Handlers

	initModules(services, self):await()
	initModules(handlers, self):await()
end

return init
