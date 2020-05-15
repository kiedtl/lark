-- a thin wrapper around the builtin
-- functions provided by lark:
--     * _builtin_connect
--     * _builtin_send

local api = {}

function api.connect(host, port)
	_builtin_connect(host, port)
end

function api.send(data)
	_builtin_send(data)
end

function api.sendf(fmt, ...)
	_builtin_send(string.format(fmt, ...))
end

return api
