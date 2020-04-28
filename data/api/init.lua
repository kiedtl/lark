local api = {}

function api.send(data)
	_builtin_send(data)
end

function api.sendf(data)
	_builtin_send(string.format(data))
end

return api
