export type Sol = {
	[string]: Module,
	init: (self: Sol) -> any,
}

export type Module = { [string]: ((any) -> any) | any } | any

return nil
