export type Sol = {
	[string]: Module,
	init: (self: Sol) -> any,
	Probe: Probe,
	Comet: Comet<any>,
}

export type Probe = {
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

export type Comet<T> = {
	new: (T) -> Comet<T>,
	set: (self: Comet<T>, new_value: T, force_update: boolean) -> (),
	get: (self: Comet<T>) -> T,
	tie: (self: Comet<T>, callback: (value: T) -> any, on_disconnect: (() -> ())?) -> () -> (),
	_updateAll: (self: Comet<T>) -> (),
	toString: (self: Comet<T>) -> (),

	stored_value: T,
	_connections: { [(value: T) -> any]: (value: T) -> any },
}

export type Module = { [string]: ((any) -> any) | any } | any

return nil
