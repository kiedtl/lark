local api = {}

function api.send(data)
	_builtin_send(data)
end

function api.sendf(fmt, ...)
	_builtin_send(string.format(fmt, ...))
end

return api
