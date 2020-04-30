local api    = require('api')
local config = require('config')

local core = {}

function core.init()
	local server = config.server or "irc.freenode.net"
	local port   = config.port or 6667

	-- TODO: handle disconnects, errors
	-- connect to server
	api.connect(server, port)

	-- set username, realname, etc
	api.sendf(
		"USER %s 0 * :%s",
		config.username,
		config.realname
	)

	-- set nickname
	api.sendf("NICK %s", config.nickname)

	-- send password
	api.sendf("PASS %s", config.password or "")
end

function core.on_receive(usr, cmd, pars, txt)
	local handlers = require('core.handlers')
	local handler = handlers[cmd]

	if handler then
		handler(usr, pars, txt)
	else
		core.printf("%12s %s: %s", "-?-", cmd, txt)
	end
end

function core.on_error(err)
	print(debug.traceback(err, 2))
	os.exit(2)
end

function core.printf(fmt, ...)
	-- TODO: move to core.common
	print(string.format(fmt, ...))
end

return core
